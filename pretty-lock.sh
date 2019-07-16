(xscreensaver -nosplash 2>/dev/null &
xscreensaver-command -activate 2>&1 >/dev/null
sleep 5
APPLE_SCREENSAVER_PID="$(pgrep atv4)"
if ! kill -0 "$APPLE_SCREENSAVER_PID" 2>/dev/null; then
    printf '\n[ Error ] Unable to activate xscreensaver\n' > /dev/stderr
    exit 1
fi
while true; do
    if ! kill -0 "$APPLE_SCREENSAVER_PID" 2>/dev/null; then
        xscreensaver-command -exit 2>&1 >/dev/null
        dbus-send --type=method_call --dest=org.gnome.ScreenSaver \
            /org/gnome/ScreenSaver org.gnome.ScreenSaver.Lock
        exit 0
    fi
done) &
sleep 5
exit 0
