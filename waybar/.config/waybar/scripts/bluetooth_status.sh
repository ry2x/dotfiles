#!/bin/bash

# 接続済みデバイス一覧を取得
connected_devices=$(bluetoothctl info | grep "Device" | cut -d ' ' -f 2)

# 出力用メッセージ初期化
tooltip="No connected devices"

# 接続中のデバイスがある場合
if [[ -n "$connected_devices" ]]; then
  tooltip=""
  for mac in $connected_devices; do
    device_info=$(bluetoothctl info "$mac")
    name=$(echo "$device_info" | grep "Name" | cut -d ' ' -f2-)
    connected=$(echo "$device_info" | grep "Connected" | awk '{print $2}')
    battery=$(echo "$device_info" | grep "Battery Percentage" | sed -n 's/.*(\([0-9]\+\)).*/\1/p')

    # 接続状態アイコン
    if [[ "$connected" == "yes" ]]; then
      status_icon=""
    else
      status_icon=""
    fi

    # バッテリーアイコン
    battery_icon=""
    if [[ -n "$battery" ]]; then
      if (( battery < 20 )); then
        battery_icon=""
      elif (( battery < 40 )); then
        battery_icon=""
      elif (( battery < 60 )); then
        battery_icon=""
      elif (( battery < 80 )); then
        battery_icon=""
      else
        battery_icon=""
      fi
      tooltip+="$status_icon $name: $battery% $battery_icon\n"
    else
      tooltip+="$status_icon $name:\n"
    fi
  done
fi

# 改行コードを Waybar 用にエスケープ
echo -e "${tooltip}"
