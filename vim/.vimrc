""" SET IN sensible.vim
"filetype plugin indent on
"syntax on
" I had to set leader key in sensible.vim??
"let mapleader=","

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

""" Undo & Swap
set undofile
set undodir=$HOME/.vim/vimundo
set directory^=$HOME/.vim/vimswap

""" Tabs
set expandtab " use spaces to insert tab. to override, use CTRL-V-<Tab>
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent

""" Leader Keys
" Saving
nmap <leader>w :wa<CR>
" Quitting
nmap <leader>q :wqa<CR>
" Split All Buffers
nmap <leader>sp :sba<CR>
nmap <leader>v:vert sba<CR>
" Remove Highlighting
" replaced by <C-L> in tpope/sensible.vim
"nmap <leader>j :noh<CR>
" Toggle AutoPairs
let g:"AutoPairsShortcutToggle="<leader>p"
" Toggle auto-format
"set formatoptions+=a
nmap <leader>fy :set formatoptions+=a<CR>
nmap <leader>fn :set formatoptions-=a<CR>
"
""" Search
set incsearch
set hlsearch
set ignorecase smartcase " make searches case-sensitive only if they contain upper-case characters

if filereadable("cscope.out")
    cs add cscope.out
    " else add database pointed to by environment
 elseif $CSCOPE_DB != ""
     cs add $CSCOPE_DB
endif

" Ack.vim
let g:ackprg = 'rg --hidden --vimgrep --no-heading'
nmap <leader>s :Ack!<cr>

" CtrlP
let g:ctrlp_show_hidden = 1

" Use ripgrep
if executable('rg')
  set grepprg=rg\ --color=never
  let g:ctrlp_user_command = 'rg %s --hidden --files --color=never --glob ""'
  let g:ctrlp_use_caching = 0
else
  let g:ctrlp_clear_cache_on_exit = 0
endif

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

""" Colorscheme
colorscheme zenburn

""" Plugins
set loadplugins
packloadall
silent! helptags ALL

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
autocmd BufWritePre .envrc :call KeepCursorLine(function('AggressiveShellLint'))
autocmd BufRead,BufNewFile .envrc set filetype=sh
autocmd BufWritePre .envrc set filetype=sh
autocmd BufWritePre .direnvrc :call KeepCursorLine(function('AggressiveShellLint'))
autocmd BufRead,BufNewFile .direnvrc set filetype=sh
autocmd BufWritePre .direnvrc set filetype=sh

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
"function AggressiveRustFormat()
"  silent! %!rustfmt --emit stdout
"endfunction
"autocmd BufWritePre *.rs :call KeepCursorLine(function('AggressiveRustFormat'))
" Using rust-lang/rust.vim and racer with vim-racer
let g:rustfmt_autosave = 1
autocmd FileType rust nmap gd <Plug>(rust-def)
autocmd FileType rust nmap gds <Plug>(rust-def-split)
autocmd FileType rust nmap gdv <Plug>(rust-def-vertical)
autocmd FileType rust nmap <S-k> <Plug>(rust-doc)
let g:racer_experimental_completer = 1

""" Ruby

set tag+=/Users/rosatolen/.rbenv/versions/2.6.5/lib/ruby/gems/2.6.0/gems/tags
set tag+=/Users/rosatolen/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/tags

""" Javascript

autocmd FileType javascript setlocal shiftwidth=2 tabstop=2
autocmd FileType javascriptreact setlocal shiftwidth=2 tabstop=2

""" Linting

"""" CoC
" Recommended
set nobackup
set nowritebackup
" Not needed
" set cmdheight=2
set updatetime=300
set signcolumn=number
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
inoremap <silent><expr> <c-@> coc#refresh()
" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

"""" Ale
"let g:ale_sign_error = '❌'
"let g:ale_sign_warning = '⚠️ '
"let g:ale_fix_on_save = 1
"let g:ale_linters = {
"\   'ruby': ['rubocop'],
"\}
"let g:ale_fixers = {
"\   '*': ['remove_trailing_lines', 'trim_whitespace'],
"\   'ruby': ['standardrb', 'remove_trailing_lines', 'trim_whitespace'],
"\   'javascript': ['eslint', 'prettier'],
"\   'typescript': ['eslint'],
"\   'css': ['prettier']
"\}

""" Testing
nmap <silent> t<C-n> :TestNearest<CR>
nmap <silent> t<C-s> :TestSuite<CR>
nmap <silent> t<C-f> :TestFile<CR>
nmap <silent> t<C-l> :TestLast<CR>

let test#strategy = 'basic'
"let test#strategy = 'dispatch'
let g:dispatch_quickfix_height=15

""" Git

let g:fugitive_gitlab_domains = ['https://gitlab.checkrhq.net']
let g:gitlab_api_keys = {'gitlab.checkrhq.net': 'sYzEfSUt188PvRvRoXxD'}

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
