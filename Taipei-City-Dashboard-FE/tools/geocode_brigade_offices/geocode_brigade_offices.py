#!/usr/bin/env python3
"""
臺北清潔隊分隊地址 → 經緯度，寫回 garbage_taipei_brigade_offices.json。

預設 Google Geocoding；可改 --provider tgos（內政部 TGOS QueryAddr v4.0）。

金鑰請放在本目錄 .env（勿提交）：
  cp .env.template .env

環境變數（.env 或 export）：
  GOOGLE_MAPS_API_KEY — Google（預設）
  TGOS_O_APP_ID / TGOS_O_API_KEY — TGOS（或 TGOS_APP_ID / TGOS_API_KEY）
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path
from typing import Any

from env_util import load_scripts_env

DEFAULT_TGOS_URL = "https://addr.tgos.tw/addrws/v40/QueryAddr.asmx/QueryAddr"
HERE = Path(__file__).resolve().parent
DEFAULT_CACHE_GOOGLE = HERE / "data" / "google_geocode_cache.json"
DEFAULT_CACHE_TGOS = HERE / "data" / "tgos_cache.json"
DEFAULT_INPUT = (
	HERE.parent.parent
	/ "public"
	/ "mapData"
	/ "garbage_taipei_brigade_offices.json"
)
GOOGLE_GEOCODE_URL = "https://maps.googleapis.com/maps/api/geocode/json"


def _tgos_credentials() -> tuple[str, str]:
	app_id = os.environ.get("TGOS_O_APP_ID") or os.environ.get("TGOS_APP_ID", "")
	api_key = os.environ.get("TGOS_O_API_KEY") or os.environ.get("TGOS_API_KEY", "")
	return app_id.strip(), api_key.strip()


def _google_api_key() -> str:
	return (os.environ.get("GOOGLE_MAPS_API_KEY") or "").strip()


def google_query_lonlat(
	address: str,
	*,
	api_key: str,
	timeout: float,
) -> tuple[tuple[float, float] | None, str | None]:
	params = urllib.parse.urlencode(
		{
			"address": address,
			"key": api_key,
			"language": "zh-TW",
			"region": "tw",
		}
	)
	url = f"{GOOGLE_GEOCODE_URL}?{params}"
	req = urllib.request.Request(
		url,
		headers={"User-Agent": "Taipei-City-Dashboard/geocode_brigade_offices (Google)"},
	)
	try:
		with urllib.request.urlopen(req, timeout=timeout) as resp:
			text = resp.read().decode("utf-8", errors="replace")
	except urllib.error.HTTPError as e:
		return None, f"HTTP {e.code}"
	except urllib.error.URLError as e:
		return None, f"連線錯誤: {e.reason!s}"
	try:
		data = json.loads(text)
	except json.JSONDecodeError:
		return None, "回傳非 JSON"

	status = str(data.get("status") or "")
	if status == "OK" and data.get("results"):
		try:
			loc = data["results"][0]["geometry"]["location"]
			lon = float(loc["lng"])
			lat = float(loc["lat"])
		except (KeyError, TypeError, ValueError):
			return None, "結果缺少座標"
		return (lon, lat), None

	err = data.get("error_message")
	if status == "ZERO_RESULTS":
		return None, "ZERO_RESULTS（找不到地址）"
	detail = status
	if err:
		detail = f"{status}: {err}"
	return None, detail


def _find_first_key(obj: Any, key: str) -> Any:
	if isinstance(obj, dict):
		if key in obj:
			return obj[key]
		for v in obj.values():
			r = _find_first_key(v, key)
			if r is not None:
				return r
	elif isinstance(obj, list):
		for item in obj:
			r = _find_first_key(item, key)
			if r is not None:
				return r
	return None


def _tgos_extract_information(payload: Any) -> str | None:
	raw = _find_first_key(payload, "Information")
	if raw is None:
		return None
	s = str(raw).strip()
	return s if s else None


def _tgos_extract_address_list(payload: Any) -> list[Any] | None:
	lst = _find_first_key(payload, "AddressList")
	if lst is None:
		return None
	if isinstance(lst, list):
		return lst
	return None


def tgos_query_lonlat(
	address: str,
	*,
	app_id: str,
	api_key: str,
	endpoint: str,
	timeout: float,
) -> tuple[tuple[float, float] | None, str | None]:
	form: dict[str, str] = {
		"oAPPId": app_id,
		"oAPIKey": api_key,
		"oAddress": address,
		"oSRS": "EPSG:4326",
		"oFuzzyType": "True",
		"oResultDataType": "JSON",
		"oNumber": "1",
		"oReturnMaxCount": "1",
		"oIsOnlyFullMatch": "false",
	}
	body = urllib.parse.urlencode(form).encode("utf-8")
	req = urllib.request.Request(
		endpoint,
		data=body,
		method="POST",
		headers={
			"Content-Type": "application/x-www-form-urlencoded; charset=utf-8",
			"User-Agent": "Taipei-City-Dashboard/geocode_brigade_offices (TGOS)",
		},
	)
	try:
		with urllib.request.urlopen(req, timeout=timeout) as resp:
			text = resp.read().decode("utf-8", errors="replace")
	except urllib.error.HTTPError as e:
		return None, f"HTTP {e.code}"
	except urllib.error.URLError as e:
		return None, f"連線錯誤: {e.reason!s}"
	try:
		payload = json.loads(text)
	except json.JSONDecodeError:
		return None, "回傳非 JSON"

	info = _tgos_extract_information(payload)
	if info and "找不到門牌資料" in info:
		return None, info

	addr_list = _tgos_extract_address_list(payload)
	if not addr_list:
		return None, info or "無 AddressList"

	first = addr_list[0]
	if not isinstance(first, dict):
		return None, info or "AddressList[0] 格式異常"

	try:
		lon = float(first.get("X", first.get("x")))
		lat = float(first.get("Y", first.get("y")))
	except (TypeError, ValueError):
		return None, info or "缺少 X/Y 座標"

	return (lon, lat), info


def load_cache(path: Path) -> dict[str, list[float]]:
	if not path.is_file():
		return {}
	try:
		raw = json.loads(path.read_text(encoding="utf-8"))
		return {k: v for k, v in raw.items() if isinstance(v, list) and len(v) == 2}
	except (json.JSONDecodeError, OSError):
		return {}


def save_cache(path: Path, cache: dict[str, list[float]]) -> None:
	path.parent.mkdir(parents=True, exist_ok=True)
	path.write_text(json.dumps(cache, ensure_ascii=False, indent=2), encoding="utf-8")


def build_query(name: str, address: str, *, prefix: str) -> str | None:
	addr = (address or "").strip()
	if not addr or "未詳列" in addr or addr == "（地址未詳列）":
		q = f"{prefix}{name}"
		return q if name.strip() else None
	return f"{prefix}{addr}"


def geocode_one(
	query: str,
	*,
	provider: str,
	timeout: float,
	cache: dict[str, list[float]],
	cache_path: Path,
	google_key: str,
	tgos_app_id: str,
	tgos_api_key: str,
	tgos_endpoint: str,
) -> tuple[float, float] | None:
	key = query.strip()
	if key in cache:
		lon, lat = cache[key]
		return lon, lat

	if provider == "google":
		if not google_key:
			raise RuntimeError("缺少 GOOGLE_MAPS_API_KEY")
		ll, err = google_query_lonlat(query, api_key=google_key, timeout=timeout)
	elif provider == "tgos":
		if not tgos_app_id or not tgos_api_key:
			raise RuntimeError("缺少 TGOS_O_APP_ID / TGOS_O_API_KEY")
		ll, err = tgos_query_lonlat(
			query,
			app_id=tgos_app_id,
			api_key=tgos_api_key,
			endpoint=tgos_endpoint,
			timeout=timeout,
		)
	else:
		raise RuntimeError(f"未知 provider: {provider}")

	if ll is None:
		raise RuntimeError(err or "地理編碼失敗")

	lon, lat = ll
	cache[key] = [lon, lat]
	save_cache(cache_path, cache)
	return lon, lat


def main() -> int:
	load_scripts_env()
	parser = argparse.ArgumentParser(description="分隊地址地理編碼 → 寫回 JSON")
	parser.add_argument(
		"--input",
		type=Path,
		default=DEFAULT_INPUT,
		help="garbage_taipei_brigade_offices.json 路徑",
	)
	parser.add_argument(
		"--output",
		type=Path,
		default=None,
		help="輸出路徑（預設與 --input 相同，即原地更新）",
	)
	parser.add_argument(
		"--provider",
		choices=("google", "tgos"),
		default="google",
	)
	parser.add_argument(
		"--address-prefix",
		default="臺北市",
		help="查詢字串前綴（提高命中率）",
	)
	parser.add_argument("--timeout", type=float, default=20.0)
	parser.add_argument("--sleep", type=float, default=0.2, help="每次 API 呼叫間隔（秒）")
	parser.add_argument(
		"--force",
		action="store_true",
		help="已存在 latitude/longitude 仍重新查詢",
	)
	parser.add_argument(
		"--dry-run",
		action="store_true",
		help="只列印將查詢的地址，不呼叫 API、不寫檔",
	)
	args = parser.parse_args()

	in_path: Path = args.input
	out_path: Path = args.output or in_path
	if not in_path.is_file():
		print(f"找不到輸入檔: {in_path}", file=sys.stderr)
		return 1

	doc = json.loads(in_path.read_text(encoding="utf-8"))
	offices = doc.get("offices")
	if not isinstance(offices, list):
		print("JSON 缺少 offices 陣列", file=sys.stderr)
		return 1

	cache_path = (
		DEFAULT_CACHE_GOOGLE if args.provider == "google" else DEFAULT_CACHE_TGOS
	)
	cache = load_cache(cache_path)
	google_key = _google_api_key()
	tgos_app_id, tgos_api_key = _tgos_credentials()
	tgos_endpoint = os.environ.get("TGOS_QUERY_ADDR_URL", DEFAULT_TGOS_URL).strip()

	for row in offices:
		if not isinstance(row, dict):
			continue
		name = str(row.get("name") or "").strip()
		address = str(row.get("address") or "").strip()
		query = build_query(name, address, prefix=args.address_prefix)
		if not query:
			continue
		lat_o = row.get("latitude")
		lon_o = row.get("longitude")
		if (
			not args.force
			and lat_o is not None
			and lon_o is not None
			and str(lat_o).lower() != "null"
			and str(lon_o).lower() != "null"
		):
			try:
				float(lat_o)
				float(lon_o)
			except (TypeError, ValueError):
				pass
			else:
				continue

		if args.dry_run:
			print(f"[dry-run] {name}\t{query}")
			continue

		try:
			lon, lat = geocode_one(
				query,
				provider=args.provider,
				timeout=args.timeout,
				cache=cache,
				cache_path=cache_path,
				google_key=google_key,
				tgos_app_id=tgos_app_id,
				tgos_api_key=tgos_api_key,
				tgos_endpoint=tgos_endpoint,
			)
		except RuntimeError as e:
			print(f"[skip] {name}\t{query}\t{e}", file=sys.stderr)
			row["geocode_error"] = str(e)
			row["geocode_query"] = query
			time.sleep(args.sleep)
			continue

		row["longitude"] = round(lon, 7)
		row["latitude"] = round(lat, 7)
		row.pop("geocode_error", None)
		row["geocode_query"] = query
		row["geocode_provider"] = args.provider
		print(f"[ok] {name}\t{lon:.6f},{lat:.6f}")
		time.sleep(args.sleep)

	if args.dry_run:
		return 0

	if isinstance(doc.get("meta"), dict):
		doc["meta"]["geocode_last_run_provider"] = args.provider

	out_path.parent.mkdir(parents=True, exist_ok=True)
	out_path.write_text(json.dumps(doc, ensure_ascii=False, indent=2), encoding="utf-8")
	print(f"已寫入: {out_path}")
	return 0


if __name__ == "__main__":
	raise SystemExit(main())
