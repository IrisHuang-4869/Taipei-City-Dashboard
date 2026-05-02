"""載入 tools/geocode_brigade_offices/.env（不覆蓋已存在之環境變數）。"""

from __future__ import annotations

import os
from pathlib import Path


def load_scripts_env() -> None:
	root = Path(__file__).resolve().parent
	env_path = root / ".env"
	if not env_path.is_file():
		return
	for raw in env_path.read_text(encoding="utf-8").splitlines():
		line = raw.strip()
		if not line or line.startswith("#"):
			continue
		if "=" not in line:
			continue
		key, _, val = line.partition("=")
		key = key.strip()
		val = val.strip().strip("'").strip('"')
		if key and key not in os.environ:
			os.environ[key] = val
