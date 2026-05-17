brew install vim ctags ripgrep fzf bat fd
mkdir -p ~/.vim/undo
mkdir -p ~/.vim/swap

colors_dir="$HOME/.vim/colors"
mkdir -p $colors_dir
curl https://raw.githubusercontent.com/jnurmine/Zenburn/refs/heads/master/colors/zenburn.vim -o $colors_dir/zenburn.vim

base_plugins_dir="$HOME/.vim/pack/base/start"
git clone https://github.com/tpope/vim-sensible $base_plugins_dir/vim-sensible
git clone https://github.com/tpope/vim-sleuth $base_plugins_dir/vim-sleuth
git clone https://github.com/jiangmiao/auto-pairs $base_plugins_dir/auto-pairs
git clone https://github.com/tpope/vim-surround $base_plugins_dir/vim-surround
git clone https://github.com/tpope/vim-fugitive $base_plugins_dir/vim-fugitive
git clone https://github.com/jremmen/vim-ripgrep $base_plugins_dir/vim-ripgrep
git clone https://github.com/vim-test/vim-test $base_plugins_dir/vim-test
git clone https://github.com/junegunn/fzf.vim $base_plugins_dir/fzf.vim
git clone https://github.com/tpope/vim-vinegar $base_plugins_dir/vim-vinegar

cat <<EOT >> ~/.vimrc

colorscheme zenburn
let current_working_directory=getcwd()

""" Custom Commands
nmap <leader>f :F2F<cr>
nmap <leader>s :Rg<cr>
nmap <leader>w :wa<cr>
nmap <leader>b :Buffers<cr>

let g:rg_highlight = 1

set undofile
set undodir=$HOME/.vim/undo
set directory^=$HOME/.vim/swap
set cursorline
" When opening a file again, jump to the last line the cursor was on
autocmd BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$")
  \ | exe "normal! g'\"" | endif

set shell=bash\ -l

set rtp+=/opt/homebrew/bin/opt/fzf

set number
set nowrap
set hidden
set autoread
set nofixendofline
set showcmd
set hlsearch
EOT
