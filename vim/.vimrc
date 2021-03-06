filetype plugin indent on
syntax on
set number
set relativenumber
set list
set nowrap
set autoread
set hidden
set nofixeol
set showmatch
set cmdheight=1
set showtabline=1
set showcmd
set shell=bash

""" Tags
set tags=./tags,tags:$HOME

""" Undo
set undofile
set undodir=$HOME/.vimundo

""" Search
set incsearch
set hlsearch
set ignorecase smartcase " make searches case-sensitive only if they contain upper-case characters

""" Tabs
" commenting in lieu of tpope/vim-sleuth
"set expandtab " use spaces to insert tab. to override, use CTRL-V-<Tab>
"set tabstop=4
"set shiftwidth=4
"set softtabstop=4
"set autoindent

""" Leader Keys
let mapleader=","
" Saving
nmap <leader>w :wa<CR>
" Quitting
nmap <leader>q :wqa<CR>
" Split All Buffers
nmap <leader>s :sba<CR>
nmap <leader>v :vert sba<CR>
" Remove Highlighting
nmap <leader>j :noh<CR>
" Toggle AutoPairs
let g:AutoPairsShortcutToggle="<leader>p"
" Toggle auto-format
"set formatoptions+=a
nmap <leader>fy :set formatoptions+=a<CR>
nmap <leader>fn :set formatoptions-=a<CR>

""" Formatting
function NativeFormat()
  normal! ggVGgq
endfunction

""" Cursor commands
set cursorline
" When opening a file again, jump to the last line the cursor was on
autocmd BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$")
  \ | exe "normal! g'\"" | endif

function KeepCursorLine(funcToExe)
  let current_window = winsaveview()
  call a:funcToExe()
  call winrestview(current_window)
endfunction

""" CtrlP
" Use ack's defaults to list files
let g:ctrlp_user_command = 'ack -f %s'
let g:ctrlp_show_hidden = 1

""" Grep
set grepprg=ack

""" Colorscheme
colorscheme zenburn

""" Syntastic
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*
"
"let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 1
"let g:syntastic_check_on_open = 1
"let g:syntastic_check_on_wq = 0
"let g:syntastic_debug = 0

""" Tagbar
nmap <F8> :TagbarToggle<CR>

""" Plugins
set loadplugins
packloadall
silent! helptags ALL

""" Formatting
function AggressiveFormat()
  silent! gg=G
endfunction

""" Ruby
" RUBOCOP IS SUPER SLOW :/
"function AggressiveRuboCop()
"  silent! :RuboCop
"endfunction
autocmd BufWritePre *.rb :call KeepCursorLine(function('AggressiveFormat'))

""" Golang
" Using vim-go plugin until I understand how to use golang's guru tools
let g:go_fmt_command = "goimports"
let g:go_fmt_fail_silently = 1
let g:go_metalinter_autosave = 1
let g:go_metalinter_autosav_enabled = ["govet", "golint", "errcheck"]

""" Shell
function AggressiveShellLint()
  silent! %!shellharden --replace ''
endfunction
autocmd BufWritePre *.sh :call KeepCursorLine(function('AggressiveShellLint'))
autocmd BufWritePre .profile :call KeepCursorLine(function('AggressiveShellLint'))
"""" .envrc
autocmd BufWritePre .envrc :call KeepCursorLine(function('AggressiveShellLint'))
autocmd BufRead,BufNewFile .envrc set filetype=sh
autocmd BufWritePre .envrc set filetype=sh
"""" .direnvrc
autocmd BufWritePre .direnvrc :call KeepCursorLine(function('AggressiveShellLint'))
autocmd BufRead,BufNewFile .direnvrc set filetype=sh
autocmd BufWritePre .direnvrc set filetype=sh
"""" *.profile
autocmd BufWritePre *.profile :call KeepCursorLine(function('AggressiveShellLint'))
autocmd BufRead,BufNewFile *.profile set filetype=sh
autocmd BufWritePre *.profile set filetype=sh

""" Terraform
function AggressiveTFFormat()
  silent! :TerraformFmt
endfunction
autocmd BufWritePre *.tf :call KeepCursorLine(function('AggressiveTFFormat'))
autocmd BufRead,BufNewFile *.tf :call KeepCursorLine(function('AggressiveTFFormat'))

""" JSON
function AggressiveJSONFormat()
  silent! %!jq .
endfunction
autocmd BufWritePre *.json :call KeepCursorLine(function('AggressiveJSONFormat'))
autocmd BufRead,BufNewFile *.json :call KeepCursorLine(function('AggressiveJSONFormat'))

""" Markdown
autocmd BufRead,BufNewFile *.md set filetype=markdown

""" Yaml
autocmd BufRead,BufNewFile *.yml set filetype=yaml

""" XML
autocmd BufRead,BufNewFile *.xml :call KeepCursorLine(function('NativeFormat'))

""" HTML
function AggressiveHTMLFormat()
  silent! %!python -c 'import html, sys; [print(html.unescape(l), end="") for l in sys.stdin]'
endfunction
autocmd BufRead,BufNewFile *.html :call KeepCursorLine(function('AggressiveHTMLFormat'))

""" Rust
" Using rust-lang/rust.vim and racer with vim-racer
let g:rustfmt_autosave = 1
let g:racer_cmd = "/home/rosatolen/.cargo/bin/racer"
let g:racer_experimental_completer = 1
let g:racer_insert_paren = 1
autocmd FileType rust nmap gd <Plug>(rust-def)
autocmd FileType rust nmap <leader>gd <Plug>(rust-doc)
autocmd FileType rust nmap gds <Plug>(rust-def-split)
autocmd FileType rust nmap gdv <Plug>(rust-def-vertical)







""" BELOW THERE BE WIP

"function Dos2Unix()
"  silent! execute ':%s/\r\(\n\)/\1/g'
"endfunction
"
"function AutoFormatFile()
"    let curw = winsaveview()
"    :normal gg=G
"    call winrestview(curw)
"endfunction
"
"function AutoIndent(num)
"    exe "set tabstop=".a:num
"    exe "set shiftwidth=".a:num
"    call AutoFormatFile()
"endfunction

" ************************************************ "
" Shell Runner
" ************************************************ "
"command! -complete=shellcmd -nargs=+ S call s:ExecuteInShell(<q-args>)
"function s:ExecuteInShell(command)
"    let command = join(map(split(a:command), 'expand(v:val)'))
"    let winnr = bufwinnr('^' . command . '$')
"    silent! execute  winnr < 0 ? 'botright new ' . fnameescape(command) : winnr . 'wincmd w'
"    setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap number
"    echo 'Executing ' . command . '...'
"    silent! execute '"$read" !' . command
"    if line('$') < 10
"         execute 'resize ' . line('$')
"         redraw
"    endif
"    call Dos2Unix()
"endfunction

" ************************************************ "
" AutoFormatSave
" ************************************************ "
"autocmd BufWritePre *.sh :call AutoFormatFile()
"autocmd BufWritePre *.profile :call AutoFormatFile()

" The bottom line be uncommented to enable actual tab in insert mode if
" absolutely necessary. :/
" :inoremap <S-Tab> <C-V><Tab>

" ************************************************ "
" Golang
" ************************************************ "
"function s:BuildGoFiles()
"    let l:file = expand('%')
"    if l:file =~# '^\f\+_test\.go$'
"        call go#cmd#Test(0,1)
"    elseif l:file =~# '^\f\+\.go$'
"        call go#cmd#Build(0)
"    endif
"endfunction
"
"autocmd FileType go map <leader>n :cnext<CR>
"autocmd FileType go map <leader>p :cprevious<CR>
"autocmd FileType go map <leader>b :<C-u>call <SID>BuildGoFiles()<CR>
"autocmd FileType go map <leader>t :GoTest<CR>
"autocmd FileType go map <leader>r :GoRun<CR>
"autocmd FileType go map <leader>c :GoCoverageToggle<CR>
"autocmd FileType go map <leader>a :GoAlternate<CR>
"autocmd FileType go map <leader>i :GoInfo<CR>
"autocmd FileType go map <leader>dc :GoDecls<CR>
"autocmd FileType go map <leader>dc :GoFreevars<CR>


" ************************************************ "
" C
" ************************************************ "
"function GNUIndent()
"    setlocal cinoptions=>4,n-2,{2,^-2,:2,=2,g0,h2,p5,t0,+2,(0,u0,w1,m1
"    setlocal shiftwidth=2
"    setlocal tabstop=8
"    call AutoFormatFile()
"endfunction

""" Golang
" Below commands are provided by vim-go
" commands below assume goimports and gofmt exist on the path
"autocmd BufWritePre *.go silent! %!goimports
"autocmd BufWritePre *.go silent! %!gofmt
