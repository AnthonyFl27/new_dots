#!/bin/bash

# Función para obtener el número de actualizaciones
get_updates() {
  local pacman_updates aur_updates

  pacman_updates=$(checkupdates 2> /dev/null | wc -l)
  aur_updates=$(paru --aur -Qu 2> /dev/null | wc -l)

  if [[ -z "$pacman_updates" ]]; then
    pacman_updates=0
  fi

  if [[ -z "$aur_updates" ]]; then
    aur_updates=0
  fi

  echo "$pacman_updates $aur_updates"
}

get_wifi_info() {
    ssid=$(iwgetid -r)
    if [ $? -eq 0 ]; then
        echo "$ssid"
    else
        echo "DISCONNECTED"
    fi
}

get_brightness() {
    if command -v brightnessctl >/dev/null 2>&1; then
        brightnessctl -m | awk -F, '{print $4}' | tr -d '%'
    else
        echo "N/A"
    fi
}


while true; do
  BATTERY=$(cat /sys/class/power_supply/BAT0/capacity 2> /dev/null)
  TIME=$(date "+%I:%M %p")
  VOLUME=$(amixer get Master | grep '%' | head -n 1 | cut -d '[' -f 2 | cut -d ']' -f 1)
  wifi_info=$(get_wifi_info)
  BRIGHTNESS=$(get_brightness)


  # Obtener el número de actualizaciones
  updates=$(get_updates)
  pacman_updates=$(echo $updates | awk '{print $1}')
  aur_updates=$(echo $updates | awk '{print $2}')
  total_updates=$((pacman_updates + aur_updates))

  # Determinar el mensaje de actualización
  if [[ "$total_updates" -gt 0 ]]; then
    update_message=" "
    if [[ "$pacman_updates" -gt 0 ]]; then
      update_message+=" ${pacman_updates}(P)"
    fi
    if [[ "$aur_updates" -gt 0 ]]; then
      update_message+=" ${aur_updates}(A)"
    fi
  else
    update_message="UPDATED"
  fi

  # Mostrar el estado
  xsetroot -name "$update_message | $TIME | VOL: $VOLUME | BRI: $BRIGHTNESS% | BAT: $BATTERY% | $wifi_info"

  sleep 1
done

