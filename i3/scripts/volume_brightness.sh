#!/bin/bash
# original source: https://gitlab.com/Nmoleo/i3-volume-brightness-indicator

bar_color="#7f7fff"
volume_step=5
brightness_step=10
max_volume=150
max_brightness=100  # Set maximum brightness to 100

# Uses regex to get volume from pactl
function get_volume {
    pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]{1,3}(?=%)' | head -1
}

# Uses regex to get mute status from pactl
function get_mute {
    pactl get-sink-mute @DEFAULT_SINK@ | grep -Po '(?<=Mute: )(yes|no)'
}

function get_brightness {
    # Get the current brightness value
    current_brightness=$(brightnessctl get)
    
    # Calculate the brightness percentage
    brightness_percentage=$(( (current_brightness * 100) / max_brightness ))
    
    echo "$brightness_percentage"
}

function get_volume_icon {
    volume=$(get_volume)
    mute=$(get_mute)
    
    if [ "$volume" = 0 ]; then
        volume_icon="🔇"
    elif [ "$volume" -le 30 ]; then
        volume_icon="🔈"
    elif [ "$volume" -le 70 ]; then
        volume_icon="🔉"
    else
        volume_icon="🔊"
    fi
}

function get_brightness_icon {
    # Placeholder function for getting brightness icon
    brightness_icon="🔆"
}

# Displays a volume notification using dunstify
function show_volume_notif {
    volume=$(get_volume)
    get_volume_icon
    dunstify -i audio-volume-muted-blocking -t 1000 -r 2593 -u normal "$volume_icon $volume%" -h int:value:$volume -h string:hlcolor:$bar_color
}

function show_brightness_notif {
    brightness=$(get_brightness)
    echo "Brightness value: $brightness"  # Debugging line
    get_brightness_icon
    dunstify -t 1000 -r 2593 -u normal "$brightness_icon ${brightness}%" -h int:value:$brightness -h string:hlcolor:$bar_color &
}

# Main function - Takes user input, "volume_up", "volume_down", "brightness_up", or "brightness_down"
case $1 in
    volume_up)
    # Unmutes and increases volume, then displays the notification
    pactl set-sink-mute @DEFAULT_SINK@ 0
    volume=$(get_volume)
    if [ $(( "$volume" + "$volume_step" )) -gt $max_volume ]; then
        pactl set-sink-volume @DEFAULT_SINK@ $max_volume%
    else
        pactl set-sink-volume @DEFAULT_SINK@ +$volume_step%
    fi
    show_volume_notif
    ;;

    volume_down)
    # Raises volume and displays the notification
    pactl set-sink-volume @DEFAULT_SINK@ -$volume_step%
    show_volume_notif
    ;;

    volume_mute)
    # Toggles mute and displays the notification
    pactl set-sink-mute @DEFAULT_SINK@ toggle
    show_volume_notif
    ;;

    brightness_up)
    # Increases brightness by percentage and displays the notification
    current_brightness=$(brightnessctl get)
    step=$(($max_brightness * $brightness_step / 100))

    new_brightness=$(($current_brightness + $step))
    if [ "$new_brightness" -gt "$max_brightness" ]; then
        new_brightness=$max_brightness
    fi
    brightnessctl set "$new_brightness"
    show_brightness_notif
    ;;

    brightness_down)
    # Decreases brightness by percentage and displays the notification
    current_brightness=$(brightnessctl get)
    step=$(($max_brightness * $brightness_step / 100))

    new_brightness=$(($current_brightness - $step))
    if [ "$new_brightness" -lt 0 ]; then
        new_brightness=0
    fi
    brightnessctl set "$new_brightness"
    show_brightness_notif
    ;;
esac

