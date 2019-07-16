$HOME/configs/touchpad.sh
xmodmap $HOME/.Xmodmap
source $HOME/.profile
xbindkeys -f $HOME/.xbindkeysrc

exec gnome-session
