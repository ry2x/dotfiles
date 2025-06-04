#!/bin/bash

# 壁紙ディレクトリ
WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# 画像ファイルの一覧を取得し、wofiで選択
SELECTED=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) \
    | sort \
    | wofi --dmenu --cache-file /dev/null --prompt "Select Wallpaper")

# ユーザーが選択した場合だけ実行
if [[ -n "$SELECTED" ]]; then
    swww img "$SELECTED" --transition-type any --transition-fps 60 --transition-duration 1
fi
