#!/usr/bin/env bash

set -e  # Exit on error

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to list upgradable official packages
list_pacman_updates() {
    pacman -Qu | cut -d' ' -f1 || echo "  なし！"
}

# Function to list upgradable AUR packages (exclude official packages)
list_paru_updates() {
    if ! command -v paru &> /dev/null; then
        echo "[ERROR] paru is not installed. Please install paru first." >&2
        exit 1
    fi
    
    # paru -Qua shows only AUR packages
    paru -Qua | cut -d' ' -f1 || echo "  なし！"
}

# Function to select and update system packages with pacman
update_pacman() {
    local packages=$(pacman -Qu | cut -d' ' -f1)
    
    # No packages to update
    if [ -z "$packages" ]; then
        echo -e "${GREEN}[INFO]${NC} Official リポジトリはすべて最新だよ！"
        return
    fi
    
    local selected_mode=$(echo -e "すべてアップデート\n個別に選択" | fzf --prompt="アップデート方法を選択してね > ")
    
    if [ "$selected_mode" = "すべてアップデート" ]; then
        # Show all upgradable packages
        local all_packages=$(pacman -Qu)
        local package_count=$(echo "$all_packages" | wc -l)
        
        echo -e "\n${YELLOW}[確認]${NC} 全部で ${GREEN}${package_count}個${NC} のパッケージをアップデートするよ："
        
        # Show all packages
        echo -e "${GREEN}----------------------------------------${NC}"
        echo "$all_packages" | while read -r line; do
            pkg_name=$(echo "$line" | cut -d' ' -f1)
            old_ver=$(echo "$line" | cut -d' ' -f2)
            new_ver=$(echo "$line" | cut -d'>' -f2 | sed 's/^[[:space:]]*//')
            echo -e " ${BLUE}$pkg_name${NC}: $old_ver -> ${GREEN}$new_ver${NC}"
        done
        echo -e "${GREEN}----------------------------------------${NC}"

        # Confirmation prompt
        read -p "全パッケージをアップデートする？ (y/n): " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}[INFO]${NC} すべてのsystem packagesをアップデートするね!"
            sudo pacman -Syu --noconfirm
        else
            echo -e "${YELLOW}[INFO]${NC} アップデートがキャンセルされたよ"
            return
        fi
    elif [ "$selected_mode" = "個別に選択" ]; then
        local selected_packages_full=$(pacman -Qu | fzf --prompt="アップデートするパッケージを選んでね (TABでトグル、複数選択可) > " --multi --header="TAB: 選択・解除、Enter: 決定")
        local selected_packages=$(echo "$selected_packages_full" | cut -d' ' -f1)
        
        if [ -n "$selected_packages" ]; then
            # Show selected packages
            echo -e "\n${YELLOW}[確認]${NC} 以下のパッケージをアップデートするよ："
            echo -e "${GREEN}----------------------------------------${NC}"
            
            # Format and display version information
            echo "$selected_packages_full" | while read -r line; do
                pkg_name=$(echo "$line" | cut -d' ' -f1)
                old_ver=$(echo "$line" | cut -d' ' -f2)
                new_ver=$(echo "$line" | cut -d'>' -f2 | sed 's/^[[:space:]]*//')
                echo -e " ${BLUE}$pkg_name${NC}: $old_ver -> ${GREEN}$new_ver${NC}"
            done
            echo -e "${GREEN}----------------------------------------${NC}"
            
            # Confirmation prompt
            read -p "アップデートを実行する？ (y/n): " confirm
            if [[ $confirm =~ ^[Yy]$ ]]; then
                echo -e "${BLUE}[INFO]${NC} 選択したパッケージをアップデートするね!"
                echo "$selected_packages" | sudo xargs pacman -S --noconfirm
            else
                echo -e "${YELLOW}[INFO]${NC} アップデートがキャンセルされたよ"
                return
            fi
        else
            echo -e "${YELLOW}[INFO]${NC} パッケージが選択されなかったよ"
            return
        fi
    else
        echo -e "${YELLOW}[INFO]${NC} キャンセルされたよ！"
        return
    fi
}

# Function to update AUR packages with paru
update_paru() {
    local packages=$(paru -Qua | cut -d' ' -f1)

    # No packages to update
    if [ -z "$packages" ]; then
        echo -e "${GREEN}[INFO]${NC} AURパッケージはすべて最新だよ！"
        return
    fi
    
    local selected_mode=$(echo -e "すべてアップデート\n個別に選択" | fzf --prompt="AURパッケージのアップデート方法を選択してね > ")
    
    if [ "$selected_mode" = "すべてアップデート" ]; then
        # Show all upgradable packages
        local all_packages=$(paru -Qua)
        local package_count=$(echo "$all_packages" | wc -l)
        
        echo -e "\n${YELLOW}[確認]${NC} 全部で ${GREEN}${package_count}個${NC} のAURパッケージをアップデートするよ："

        # Show all packages
        echo -e "${GREEN}----------------------------------------${NC}"
        echo "$all_packages" | while read -r line; do
            pkg_name=$(echo "$line" | cut -d' ' -f1)
            old_ver=$(echo "$line" | cut -d' ' -f2)
            new_ver=$(echo "$line" | cut -d'>' -f2 | sed 's/^[[:space:]]*//')
            echo -e " ${BLUE}$pkg_name${NC}: $old_ver -> ${GREEN}$new_ver${NC}"
        done
        echo -e "${GREEN}----------------------------------------${NC}"

        # Confirmation prompt
        read -p "全AURパッケージをアップデートする？ (y/n): " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}[INFO]${NC} すべてのAURパッケージをアップデートするね..."
            paru -Syu --noconfirm
        else
            echo -e "${YELLOW}[INFO]${NC} アップデートがキャンセルされたよ"
            return
        fi
    elif [ "$selected_mode" = "個別に選択" ]; then
        # Get AUR package update information
        local selected_packages_full=$(paru -Qua | fzf --prompt="アップデートするAURパッケージを選んでね (TABでトグル、複数選択可) > " --multi --header="TAB: 選択・解除、Enter: 決定")
        local selected_packages=$(echo "$selected_packages_full" | cut -d' ' -f1)
        
        if [ -n "$selected_packages" ]; then
            # Show selected packages
            echo -e "\n${YELLOW}[確認]${NC} 以下のAURパッケージをアップデートするよ："
            echo -e "${GREEN}----------------------------------------${NC}"

            # Format and display version information
            echo "$selected_packages_full" | while read -r line; do
                pkg_name=$(echo "$line" | cut -d' ' -f1)
                old_ver=$(echo "$line" | cut -d' ' -f2)
                new_ver=$(echo "$line" | cut -d'>' -f2 | sed 's/^[[:space:]]*//')
                echo -e " ${BLUE}$pkg_name${NC}: $old_ver -> ${GREEN}$new_ver${NC}"
            done
            echo -e "${GREEN}----------------------------------------${NC}"

            # Confirmation prompt
            read -p "アップデートを実行する？ (y/n): " confirm
            if [[ $confirm =~ ^[Yy]$ ]]; then
                echo -e "${BLUE}[INFO]${NC} 選択したAURパッケージをアップデートするね..."
                echo "$selected_packages" | xargs paru -S --noconfirm
            else
                echo -e "${YELLOW}[INFO]${NC} アップデートがキャンセルされたよ"
                return
            fi
        else
            echo -e "${YELLOW}[INFO]${NC} パッケージが選択されなかったよ"
            return
        fi
    else
        echo -e "${YELLOW}[INFO]${NC} キャンセルされたよ！"
        return
    fi
}

# Get terminal width for formatting
TERM_WIDTH=$(tput cols)
HALF_WIDTH=$(( TERM_WIDTH / 2 - 5 ))

# Collect upgradable packages
pacman_updates=$(list_pacman_updates)
paru_updates=$(list_paru_updates)

# Count number of upgradable packages
pacman_count=$(echo "$pacman_updates" | grep -v "なし！" | wc -l || echo 0)
paru_count=$(echo "$paru_updates" | grep -v "なし！" | wc -l || echo 0)

# Create header with side-by-side view
header=$(
    echo -e "${GREEN}======== アップデート可能なパッケージ ========${NC}"
    echo -e "${YELLOW}Official (pacman)${NC} [${pacman_count}]    |    ${YELLOW}AUR (paru)${NC} [${paru_count}]"
    echo -e "----------------------------------|----------------------------------"

    # Show only package names (up to 15 on each side)
    paste <(echo "$pacman_updates" | head -15) <(echo "$paru_updates" | head -15) -d "|" | column -t -s "|"

    # Count any remaining packages that are not displayed
    total_hidden=$(( (pacman_count > 15 ? pacman_count - 15 : 0) + (paru_count > 15 ? paru_count - 15 : 0) ))
    if [ $total_hidden -gt 0 ]; then
        echo -e "\n${YELLOW}... その他 ${total_hidden} パッケージ (表示されていない) ...${NC}"
    fi
)

# Show menu with fzf
selected=$(echo -e "Official (pacman)\nAUR (paru)\n両方" | fzf --prompt="どちらをアップデートする？ > " --header="$header")

case "$selected" in
    "Official (pacman)")
        update_pacman
        ;;
    "AUR (paru)")
        update_paru
        ;;
    "両方")
        echo -e "${BLUE}[INFO]${NC} Officialパッケージのアップデート："
        update_pacman
        echo ""
        echo -e "${BLUE}[INFO]${NC} AURパッケージのアップデート："
        update_paru
        ;;
    "")
        echo -e "${YELLOW}[INFO]${NC} キャンセルされたよ！"
        exit 0
        ;;
    *)
        echo -e "${RED}[ERROR]${NC} 無効な選択肢だよ！"
        exit 1
        ;;
esac

echo -e "\n${GREEN}[INFO]${NC} アップデートが完了したよ！"
echo -e "${BLUE}何かキーを押すと終了するよ...${NC}"
read -n 1 -s -r
