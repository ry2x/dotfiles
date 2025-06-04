#!/bin/bash

# 現在の入力メソッドを取得（例：mozc, anthy, etc）
current_im=$(fcitx5-remote -n)

# シンプルに表示したい名前に変換（必要に応じて）
case "$current_im" in
  "mozc")
    mode="  あ"
    ;;
  "keyboard-us")
    mode="  Ａ"
    ;;
  *)
    first_char="${current_im:0:1}"
    first_char_upper=$(echo "$first_char" | tr '[:lower:]' '[:upper:]')
    ord=$(printf "%d" "'$first_char_upper")
    fullwidth_code=$((0xFF00 + ord - 0x20))
    fullwidth_char=$(printf "\\U%08x" "$fullwidth_code")
    mode="  $fullwidth_char"
    ;;
esac

echo "{\"text\": \"$mode\", \"tooltip\": \"Mode: $current_im\"}"
