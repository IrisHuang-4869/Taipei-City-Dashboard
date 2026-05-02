export const localGarbageMapLayers = [
  {
    "id": 990001,
    "index": "garbage_map_taipei_local",
    "query_type": "map_legend",
    "history_data": false,
    "chart_config": {
      "types": [
        "MapLegend"
      ],
      "color": [
        "#E6DF44",
        "#31b36b"
      ],
      "unit": "站",
      "categories": []
    },
    "chart_data": [
      {
        "name": "垃圾車收運點位",
        "type": "circle",
        "value": 4012
      },
      {
        "name": "限時收受點",
        "type": "circle",
        "value": 30
      }
    ],
    "map_config": [
      {
        "index": "garbage_taipei_truck_local",
        "source": "geojson",
        "city": "taipei",
        "title": "垃圾車收運點位",
        "type": "circle",
        "size": "big",
        "icon": null,
        "paint": {
          "circle-color": [
            "case",
            [
              "<",
              [
                "to-number",
                [
                  "get",
                  "arrive_time"
                ]
              ],
              1700
            ],
            "#E6DF44",
            [
              "<",
              [
                "to-number",
                [
                  "get",
                  "arrive_time"
                ]
              ],
              1900
            ],
            "#F4633C",
            [
              "<",
              [
                "to-number",
                [
                  "get",
                  "arrive_time"
                ]
              ],
              2100
            ],
            "#D63940",
            "#9C2A4B"
          ],
          "circle-opacity": 0.85,
          "circle-stroke-color": "#ffffff",
          "circle-stroke-width": 0.6
        },
        "property": [
          {
            "key": "dist",
            "name": "行政區"
          },
          {
            "key": "vil",
            "name": "里別"
          },
          {
            "key": "brigade",
            "name": "分隊"
          },
          {
            "key": "license_plate",
            "name": "車號"
          },
          {
            "key": "route",
            "name": "路線"
          },
          {
            "key": "route_shift",
            "name": "車次"
          },
          {
            "key": "arrive_time",
            "name": "抵達時間"
          },
          {
            "key": "leave_time",
            "name": "離開時間"
          },
          {
            "key": "address",
            "name": "地點"
          }
        ]
      },
      {
        "index": "garbage_taipei_dropoff_local",
        "source": "geojson",
        "city": "taipei",
        "title": "限時收受點",
        "type": "circle",
        "size": "big",
        "icon": null,
        "paint": {
          "circle-color": "#31b36b",
          "circle-opacity": 0.85,
          "circle-stroke-color": "#d7f5e3",
          "circle-stroke-width": 0.8
        },
        "property": [
          {
            "key": "dist",
            "name": "行政區"
          },
          {
            "key": "brigade",
            "name": "分隊"
          },
          {
            "key": "phone",
            "name": "電話"
          },
          {
            "key": "address",
            "name": "地址"
          },
          {
            "key": "note",
            "name": "備註"
          }
        ]
      }
    ],
    "map_filter": {
      "mode": "byLayer"
    },
    "name": "垃圾地圖總覽",
    "source": "臺北市環保局",
    "time_from": "static",
    "time_to": null,
    "update_freq": null,
    "update_freq_unit": null,
    "short_desc": "整合台北市垃圾車收運點位與垃圾資源回收、廚餘回收限時收受點。",
    "long_desc": "整合台北市垃圾車收運點位與垃圾資源回收、廚餘回收限時收受點，並提供圖層分類切換。",
    "use_case": "用於查找台北市垃圾相關收運與定點回收資訊。",
    "links": [
      "https://data.taipei/dataset/detail?id=6bb3304b-4f46-4bb0-8cd1-60c66dcd1cae",
      "https://data.taipei/dataset/detail?id=1acf38f3-1509-4cb1-898a-9b1d4f31a3af"
    ],
    "tags": [
      "garbage",
      "recycle"
    ],
    "contributors": [
      "local"
    ],
    "city": "taipei"
  },
  {
    "id": 990002,
    "index": "garbage_map_ntpc_local",
    "query_type": "map_legend",
    "history_data": false,
    "chart_config": {
      "types": [
        "MapLegend"
      ],
      "color": [
        "#4e79a7",
        "#f28e2b",
        "#e15759",
        "#76b7b2"
      ],
      "unit": "站",
      "categories": []
    },
    "chart_data": [
      {
        "name": "循線清運點",
        "type": "circle",
        "value": 11129
      },
      {
        "name": "機動定點清運點",
        "type": "circle",
        "value": 328
      },
      {
        "name": "限時定點清運點",
        "type": "circle",
        "value": 61
      },
      {
        "name": "臨停清運點",
        "type": "circle",
        "value": 308
      }
    ],
    "map_config": [
      {
        "index": "garbage_ntpc_route_local",
        "source": "geojson",
        "city": "metrotaipei",
        "title": "循線清運點",
        "type": "circle",
        "size": "big",
        "icon": null,
        "paint": {
          "circle-color": "#4e79a7",
          "circle-opacity": 0.82,
          "circle-stroke-color": "#f4f4f4",
          "circle-stroke-width": 0.8
        },
        "property": [
          {
            "key": "dist",
            "name": "行政區"
          },
          {
            "key": "vil",
            "name": "里別"
          },
          {
            "key": "point_name",
            "name": "清運點名稱"
          },
          {
            "key": "point_type_summary",
            "name": "站點型態"
          },
          {
            "key": "schedule_summary",
            "name": "表定時間"
          }
        ]
      },
      {
        "index": "garbage_ntpc_mobile_local",
        "source": "geojson",
        "city": "metrotaipei",
        "title": "機動定點清運點",
        "type": "circle",
        "size": "big",
        "icon": null,
        "paint": {
          "circle-color": "#f28e2b",
          "circle-opacity": 0.82,
          "circle-stroke-color": "#f4f4f4",
          "circle-stroke-width": 0.8
        },
        "property": [
          {
            "key": "dist",
            "name": "行政區"
          },
          {
            "key": "vil",
            "name": "里別"
          },
          {
            "key": "point_name",
            "name": "清運點名稱"
          },
          {
            "key": "point_type_summary",
            "name": "站點型態"
          },
          {
            "key": "schedule_summary",
            "name": "表定時間"
          }
        ]
      },
      {
        "index": "garbage_ntpc_timed_local",
        "source": "geojson",
        "city": "metrotaipei",
        "title": "限時定點清運點",
        "type": "circle",
        "size": "big",
        "icon": null,
        "paint": {
          "circle-color": "#e15759",
          "circle-opacity": 0.82,
          "circle-stroke-color": "#f4f4f4",
          "circle-stroke-width": 0.8
        },
        "property": [
          {
            "key": "dist",
            "name": "行政區"
          },
          {
            "key": "vil",
            "name": "里別"
          },
          {
            "key": "point_name",
            "name": "清運點名稱"
          },
          {
            "key": "point_type_summary",
            "name": "站點型態"
          },
          {
            "key": "schedule_summary",
            "name": "表定時間"
          }
        ]
      },
      {
        "index": "garbage_ntpc_temp_local",
        "source": "geojson",
        "city": "metrotaipei",
        "title": "臨停清運點",
        "type": "circle",
        "size": "big",
        "icon": null,
        "paint": {
          "circle-color": "#76b7b2",
          "circle-opacity": 0.82,
          "circle-stroke-color": "#f4f4f4",
          "circle-stroke-width": 0.8
        },
        "property": [
          {
            "key": "dist",
            "name": "行政區"
          },
          {
            "key": "vil",
            "name": "里別"
          },
          {
            "key": "point_name",
            "name": "清運點名稱"
          },
          {
            "key": "point_type_summary",
            "name": "站點型態"
          },
          {
            "key": "schedule_summary",
            "name": "表定時間"
          }
        ]
      }
    ],
    "map_filter": {
      "mode": "byLayer"
    },
    "name": "新北垃圾清運分類",
    "source": "新北市環保局",
    "time_from": "static",
    "time_to": null,
    "update_freq": null,
    "update_freq_unit": null,
    "short_desc": "整合新北市垃圾清運資訊查詢網的站點型態分類。",
    "long_desc": "整合新北市垃圾清運資訊查詢網中的循線、機動、限時與臨停清運點，並提供分類切換。",
    "use_case": "用於查找新北市不同站點型態的垃圾清運點位。",
    "links": [
      "https://crd-rubbish.epd.ntpc.gov.tw/dispPageBox/Ntpcepd/NtpCp.aspx?ddsPageID=SEARCHC"
    ],
    "tags": [
      "garbage",
      "ntpc"
    ],
    "contributors": [
      "local"
    ],
    "city": "metrotaipei"
  },
  {
    "id": 990003,
    "index": "garbage_ntpc_gold_local",
    "query_type": "map_legend",
    "history_data": false,
    "chart_config": {
      "types": [
        "MapLegend"
      ],
      "color": [
        "#c9a227"
      ],
      "unit": "站",
      "categories": []
    },
    "chart_data": [
      {
        "name": "黃金資收站",
        "type": "circle",
        "value": 195
      }
    ],
    "map_config": [
      {
        "index": "garbage_ntpc_gold_local",
        "source": "geojson",
        "city": "metrotaipei",
        "title": "黃金資收站",
        "type": "circle",
        "size": "big",
        "icon": null,
        "paint": {
          "circle-color": "#c9a227",
          "circle-opacity": 0.88,
          "circle-stroke-color": "#fff0b3",
          "circle-stroke-width": 0.9
        },
        "property": [
          {
            "key": "dist",
            "name": "行政區"
          },
          {
            "key": "vil",
            "name": "里別"
          },
          {
            "key": "leader",
            "name": "里長"
          },
          {
            "key": "siteaddress",
            "name": "資收地點"
          },
          {
            "key": "worktime",
            "name": "資收時間"
          },
          {
            "key": "phone",
            "name": "電話"
          }
        ]
      }
    ],
    "map_filter": null,
    "name": "新北黃金資收站",
    "source": "新北市環保局",
    "time_from": "static",
    "time_to": null,
    "update_freq": null,
    "update_freq_unit": null,
    "short_desc": "整合新北市黃金資收站的站點、時間與聯絡資訊。",
    "long_desc": "整合新北市黃金資收站查詢頁與公告 PDF 的站點、里長、時間與聯絡資訊。",
    "use_case": "用於查找新北市黃金資收站地點與開放時段。",
    "links": [
      "https://recyclebank.epd.ntpc.gov.tw/Upload/Map/%E6%96%B0%E5%8C%97%E5%B8%82%E9%BB%83%E9%87%91%E8%B3%87%E6%94%B6%E7%AB%99%E5%90%84%E7%AB%99%E8%B3%87%E8%A8%8A1150324.pdf",
      "https://recyclebank.epd.ntpc.gov.tw/Map/Index"
    ],
    "tags": [
      "recyclebank"
    ],
    "contributors": [
      "local"
    ],
    "city": "metrotaipei"
  }
];
