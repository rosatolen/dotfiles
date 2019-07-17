VIM_PLUGIN_DIR=~/.vim/pack
[ -d $VIM_PLUGIN_DIR ] || mkdir -p $VIM_PLUGIN_DIR

for plugin in $(cat < vim-plugins); do
    author=$(echo $plugin | cut -d '/' -f1)
    start_dir=$VIM_PLUGIN_DIR/$author/start
    repo=$(echo $plugin | cut -d '/' -f2)

    if [ ! -d $start_dir ]; then
        mkdir -p $start_dir
        git clone https://github.com/$author/$repo $start_dir/$repo
        printf '\n[ Success ] Plugin %s/%s was installed\n\n' $author $repo
    fi
done
