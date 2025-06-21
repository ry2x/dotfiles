WALLPAPER=$(grep "wallpaper =" ~/.config/waypaper/config.ini | cut -d '=' -f2- | xargs)
# チルダ展開
WALLPAPER="${WALLPAPER/#\~/$HOME}"

if [[ -f "$WALLPAPER" ]]; then
  wal -i "$WALLPAPER"
else
  notify-send "waypaper" "[!] Invalid wallpaper path: $WALLPAPER"
fi
