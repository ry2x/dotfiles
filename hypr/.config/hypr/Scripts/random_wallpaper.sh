#!/bin/bash

# ディレクトリのパス
WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# swww-daemon が起動していなければ起動
pgrep -x swww-daemon > /dev/null || swww-daemon &

# 壁紙をランダムに選択
WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

# 壁紙を適用（アニメーション付き）
swww img "$WALLPAPER" --transition-type grow --transition-duration 1.0

# 色スキームを再生成
wal -i "$WALLPAPER"
