#/bin/sh

# Conky monitors
conky -p 3 -c $HOME/.config/conky/conky_meter.conf > /dev/null 2>&1 &
conky -p 3 -c $HOME/.config/conky/conky_clock.conf > /dev/null 2>&1 &
