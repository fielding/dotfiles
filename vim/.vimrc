" -----------------------------------------------------------------------------
" file:         ~/.vimrc
" author:       fielding johnston - http://justfielding.com
" -----------------------------------------------------------------------------

" plug {{{1
" -----------------------------------------------------------------------------
" Check and install vim-plug if it isn't installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" Plugin Host
Plug 'neovim/node-host'

" Colors
Plug 'fielding/vice'
Plug 'fielding/lightline-vice.vim'

" Features
Plug 'bronson/vim-trailing-whitespace'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'tpope/vim-afterimage'
Plug 'tpope/vim-fugitive'
Plug 'shougo/unite.vim'
Plug 'shougo/vimfiler.vim'
Plug 'terryma/vim-multiple-cursors'
Plug 'fs111/pydoc.vim'
Plug 'christoomey/vim-tmux-navigator'
" Plug 'fielding/vim-chunkwm-navigator'
" Plug '~/src/hack/vim-chunkwm-navigator'  " local path doesn't exist
Plug 'sjl/vitality.vim'
Plug 'mrtazz/simplenote.vim'
Plug 'junegunn/goyo.vim'
Plug 'moll/vim-bbye'
Plug 'tomtom/tcomment_vim'
Plug 'mhinz/vim-startify'
Plug 'airblade/vim-gitgutter'
Plug 'godlygeek/csapprox'
Plug 'godlygeek/tabular'
Plug 'itchyny/lightline.vim'
Plug 'mgee/lightline-bufferline'
Plug 'vimwiki/vimwiki', { 'branch': 'dev' }
Plug 'szw/vim-dict'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'mattn/webapi-vim'
Plug 'ap/vim-css-color'
Plug 'editorconfig/editorconfig-vim'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'ternjs/tern_for_vim', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'carlitux/deoplete-ternjs', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'othree/jspc.vim', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'ervandew/supertab'
Plug '/opt/homebrew/opt/fzf' | Plug 'junegunn/fzf.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'mattn/gist-vim'
Plug 'vimlab/mdn.vim'
Plug 'maxbrunsfeld/vim-yankstack'
Plug 'bkad/CamelCaseMotion'
Plug 'w0rp/ale'
Plug 'cocopon/pgmnt.vim'
Plug 'wakatime/vim-wakatime'
Plug 'autozimu/LanguageClient-neovim', { 'branch': 'next', 'do': 'bash install.sh'}

" Specific language support/features
Plug 'sheerun/vim-polyglot'
" Plug 'bigfish/vim-js-context-coloring', { 'branch': 'neovim' }
Plug 'alampros/vim-styled-jsx'
Plug 'davidoc/taskpaper.vim'
Plug 'jbgutierrez/vim-babel'
Plug 'jaawerth/nrun.vim'
Plug 'heavenshell/vim-jsdoc'
Plug 'chr4/nginx.vim'
Plug 'xu-cheng/brew.vim'
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }
Plug 'shime/vim-livedown', { 'for': 'markdown', 'do': ':!npm install -g livedown' }
Plug 'https://git.imbue.studio/fielding/vim-scheme.git'
Plug 'othree/yajs.vim', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'othree/jsdoc-syntax.vim', { 'for' : ['javascript', 'javascript.jsx'] }
Plug 'MaxMEllon/vim-jsx-pretty'

" Plug 'othree/es.next.syntax.vim', { 'for': ['javascript', 'javascript.jsx'] }


call plug#end()

" init {{{1
"
" ----------------------------------------------------------------------------
" Following line is taken care of by neovim and vim-plug
" Not sure if I need to keep this for vanilla vim compatability
filetype plugin indent on

let mapleader="\<Space>"

" set {{{1
" ----------------------------------------------------------------------------
" Testing to make sure that removing set nocompat doesn't cause any problems.
" Neovim straight ignores it, and I had made a comment suggesting vim was
" doing it for me, so we will see
" set nocompatible                                                              " vim sets this automatically upon findin a vimrc file, keeping because it's my homie
set fileformats=mac,unix,dos
set fileencoding=utf-8
set autoread                                                                    " Re-read file if changed outside
set autowrite                                                                   " Auto save before commands like :next
set backspace=2                                                                 " full backspacing compat
set history=50                                                                  " keep 50 lines of command line history
set ruler                                                                       " show the cursor position all the time
set showcmd                                                                     " display incomplete commands
set incsearch                                                                   " do incremental searching
set hlsearch                                                                    " highlight last used search pattern
set nowrap                                                                      " don't wrap line
set textwidth=80                                                                " stops linewrapping at invisible margins
set colorcolumn=80                                                              " column indicator
set linebreak                                                                   " wrap text
set relativenumber number                                                       " show absolute line number for current line and relative for all other lines
set pastetoggle=<f5>                                                            " toggle paste mode
set clipboard=unnamed                                                           " Use the OS clipboard by default
set wildmenu                                                                    " enhanced tab-completion
set suffixesadd=.rb                                                             " comma seperated list of file suffixes
set includeexpr+=substitute(v:fname,'s$','','g')                                " expression substitution
set showtabline=2
set modeline                                                                    " respect modeline
set modelines=4
set lazyredraw
set splitbelow
set splitright
set wildignore+=*/.git/*,*/tmp/*,*.swp

" set hidden
" working file settings and location
set directory=~/.vim/files/swap//
set updatecount=100
set undofile
set undodir=~/.vim/files/undo/
set backup
set backupdir=~/.vim/files/backup/
set backupext=-vimbackup
set backupskip=
set viminfo='100,n~/.vim/files/viminfo

                                                                                " TODO: Come up with what I want to use for listchars
set listchars=tab:▸\ ,trail:·,eol:¬,nbsp:_
set list

" disable audio/visual bells
" evaluate after flickering fix
set noerrorbells
set novisualbell
set t_vb=

" folding
" TODO: look in to foldignore
set foldignore=                                                                 " don't ignore anything when folding
set foldmethod=marker                                                           " collapse code using indent levels
set foldnestmax=20                                                              " limit max folds for indent and syntax methods
  set nofoldenable

" status bar info and appearance
" set statusline=\ \%f%m%r%h%w\ ::\ %y\ [%{&ff}]\%=\ [%p%%:\ %l/%L]\            " content for statusline
set laststatus=2                                                                " lastwindow always has status line
set cmdheight=1                                                                 " set 1 line limit for 'messages'
set noshowmode                                                                  " Hide the default mode text
set shortmess+=mwt

" indenting
set autoindent                                                                  " turns autoidenting on for new lines
set smartindent                                                                 " does the right thing (mostly)
set cindent                                                                     " stricter rules for C programs
set shiftwidth=2                                                                " 2 cols for autoindenting
set binary

" tabs
set expandtab                                                                   " use spaces instead of true tabs
set tabstop=2                                                                   " 2 column tabs

set completeopt=longest,menuone,preview


" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
  if !has('nvim')
    set ttymouse=xterm
  endif
endif

" vim 7.4+ support SGR protocol which avoids issues with mouse reporting in 'big' terminals
if has('mouse_sgr')
    set ttymouse=sgr
endif


" TODO: actually implement ident_guides worth a flip
let g:indent_guides_auto_colors = 0
let g:indent_guides_color_change_percent = 10
let g:indent_guides_guide_size = 1

" Set bash as the default shell type/syntax
let g:is_bash = 1

" Python 2 is deprecated in neovim, only set python3
let g:python3_host_prog = '/opt/homebrew/bin/python3'


au FocusLost * :silent! wall

" mapping {{{1
" -----------------------------------------------------------------------------
" I must banish these newbie poser habits
noremap <up> <nop>
noremap <down> <nop>
noremap <left> <nop>
noremap <right> <nop>

" Force writing to a file with sudo
command! Sudo :execute ':silent w !sudo tee % > /dev/null' | :edit!
command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>), 1, <bang>0)

" enables CTRL-U after inserting a line break
inoremap <C-U> <C-G>u<C-U>

" spacebar unhighlights search text
:noremap <silent> <leader>/ :silent noh<Bar>echo<CR>

:noremap <F6> :VimFilerExplorer<CR>
nnoremap <silent> <BS> :TmuxNavigateLeft<cr>

" Align blocks of text and keep them selected
vmap < <gv
vmap > >gv

" leader d to dump
nnoremap <leader>d "_d
vnoremap <leader>d "_d

" FZF
nnoremap <silent> <expr> <Leader><Leader> (expand('%') =~ 'NERD_tree' ? "\<c-w>\<c-w>" : '').":Files\<cr>"
nnoremap <silent> <Leader><Enter> :Buffers<CR>

" nmap <leader><tab> <plug>(fzf-maps-n)
" xmap <leader><tab> <plug>(fzf-maps-x)
" omap <leader><tab> <plug>(fzf-maps-o)

" Mappings for yankstack
nmap <leader>p <Plug>yankstack_substitute_older_paste
nmap <leader>P <Plug>yankstack_substitute_newer_paste

" Commands for neovim's terminal
command Term split term://$SHELL
command VTerm vsplit term://$SHELL

" Mappings for neovim's terminal
tnoremap <Esc> <C-\><C-n>
tnoremap <C-h> <C-\><C-n><C-w>h
tnoremap <C-j> <C-\><C-n><C-w>j
tnoremap <C-k> <C-\><C-n><C-w>k
tnoremap <C-l> <C-\><C-n><C-w>l

map <silent> w <Plug>CamelCaseMotion_w
map <silent> b <Plug>CamelCaseMotion_b
map <silent> e <Plug>CamelCaseMotion_e
map <silent> ge <Plug>CamelCaseMotion_ge
sunmap w
sunmap b
sunmap e
sunmap ge

nmap <Leader>1 <Plug>lightline#bufferline#go(1)
nmap <Leader>2 <Plug>lightline#bufferline#go(2)
nmap <Leader>3 <Plug>lightline#bufferline#go(3)
nmap <Leader>4 <Plug>lightline#bufferline#go(4)
nmap <Leader>5 <Plug>lightline#bufferline#go(5)
nmap <Leader>6 <Plug>lightline#bufferline#go(6)
nmap <Leader>7 <Plug>lightline#bufferline#go(7)
nmap <Leader>8 <Plug>lightline#bufferline#go(8)
nmap <Leader>9 <Plug>lightline#bufferline#go(9)
nmap <Leader>0 <Plug>lightline#bufferline#go(10)
nmap <Leader><Tab> :bn<CR>
nmap <Leader><S-Tab> :bp<CR>



" autocmd {{{1
" -----------------------------------------------------------------------------
" Only do this part when compiled with support for autocommands.
if has('autocmd')

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on
  set omnifunc=syntaxcomplete#Complete
  set path+=/path/to/your/rails-application/app/**
  set path+=/path/to/your/rails-application/lib/**
  set suffixesadd=.rb
  set includeexpr+=substitute(v:fname,'s$','','g')

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " Automatically trim trailing white space
  autocmd BufWritePre * :FixWhitespace

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

  augroup resource
    autocmd!
    " autocmd BufWritePost $MYVIMRC source $MYVIMRC
    " autocmd BufWritePost .vimrc source $MYVIMRC | echom "Reloaded " . $MYVIMRC | redraw
  augroup END

  " enter insert mode when switching to terminal buffer
  autocmd BufEnter * if &buftype == "terminal" | startinsert | endif

  autocmd StdinReadPre * let s:std_in=1

  autocmd BufRead,BufNewFile,BufFilePre *.md set filetype=markdown

  autocmd FileType c,cpp setlocal shiftwidth=4 tabstop=4 expandtab
  autocmd FileType javascript,typescript setlocal foldmethod=syntax foldlevelstart=2
  autocmd FileType markdown setlocal wrap
  autocmd FileType python setlocal shiftwidth=4 sts=4 et

  " autocmd InsertLeave,WinEnter * let &l:foldmethod=g:oldfoldmethod
  " autocmd InsertEnter,WinLeave * let g:oldfoldmethod=&l:foldmethod | setlocal foldmethod=manual



  " Functions used for .nfo, eventually could be used for others
  function! SetFileEncodings(encodings)
  let b:myfileencodingsbak=&fileencodings
  let &fileencodings=a:encodings
  endfunction

  function! RestoreFileEncodings()
  let &fileencodings=b:myfileencodingsbak
  unlet b:myfileencodingsbak
  endfunction

  " .NFO specific
  au BufReadPre *.nfo call SetFileEncodings('cp437')
  au BufReadPost *.nfo call RestoreFileEncodings()

  " Mark the current file as recently modified
  autocmd BufRead,BufEnter * call system("fdb -i /Users/fielding/.local/share/edit.z -a " . shellescape(expand("%:p")) . " &")

endif " has("autocmd")

" colors {{{1
" -----------------------------------------------------------------------------
if !exists('g:syntax_on')
  syntax enable
endif

set t_Co=256

" 24-bit true color: neovim 0.1.5+ / vim 7.4.1799+
" enable ONLY if TERM is set valid and it is NOT under mosh
function! s:is_mosh()
  let output = system("is_mosh -v")
  if v:shell_error
    return 0
  endif
  return !empty(l:output)
endfunction

function s:auto_termguicolors()
  if !(has("termguicolors"))
    return
  endif

  if (&term == 'xterm-256color' || &term == 'nvim') && !s:is_mosh()
    set termguicolors
  else
    set notermguicolors
  endif
endfunction
call s:auto_termguicolors()

" not sure why I was setting background and foreground this way
" set t_Sf=[3%dm
" set t_Sb=[4%dm


set background=dark
let g:vice_term_italic=1
colorscheme vice

" statusline {{{1
" -----------------------------------------------------------------------------

let g:lightline = {
      \ 'colorscheme': 'vice',
      \ 'tabline': {'left': [['buffers']], 'right': [[]]},
      \ 'component_expand': {'buffers': 'lightline#bufferline#buffers'},
      \ 'component_type': {'buffers': 'tabsel'}
      \ }
let g:lightline#bufferline#filename_modifier = ':t'
let g:lightline#bufferline#show_number = 2
let g:lightline#bufferline#number_map = {
\ 0: '⁰', 1: '¹', 2: '²', 3: '³', 4: '⁴',
\ 5: '⁵', 6: '⁶', 7: '⁷', 8: '⁸', 9: '⁹'}

" options {{{1
" -----------------------------------------------------------------------------
" Use vim's internal EditorConfig support (no external binary needed)
let g:EditorConfig_core_mode = 'vim_core'

let g:jsx_ext_required = 1

" ale
let g:ale_linters = {
      \  'bash': ['shellcheck'],
      \  'c': ['clangtidy'],
      \  'javascript': ['eslint'],
      \  'sh': ['shellcheck'],
      \  }

let g:ale_fixers = {
      \  'bash': ['shfmt'],
      \  'c': ['clang-format'],
      \  'css': ['prettier'],
      \  'flow': ['prettier'],
      \  'graphql': ['prettier'],
      \  'javascript': ['prettier', 'eslint'],
      \  'json': ['prettier'],
      \  'jsx': ['prettier', 'eslint'],
      \  'less': ['prettier'],
      \  'markdown': ['prettier'],
      \  'scss': ['prettier'],
      \  'sh': ['shfmt'],
      \  'typescript': ['prettier'],
      \}

let g:ale_javascript_prettier_options = '--single-quote --trailing-comma es5'
let g:ale_sh_shfmt_options = '-i 2 -ci -p'
let g:ale_bash_shfmt_options = '-i 2 -ci'

" deoplete
let g:deoplete#enable_at_startup = 1
let g:deoplete#omni#functions = {}
let g:deoplete#omni#functions.javascript = [
      \ 'tern#Complete',
      \ 'jspc#omni'
      \]

let g:deoplete#sources = {}
let g:deoplete#sources.javascript = ['file', 'ternjs', 'ultisnips']


let g:tern#command = ['tern']
let g:tern#arguments = ['--persistent']



let g:polyglot_disabled = ['markdown', 'jsx']
let g:vim_markdown_folding_style_pythonic = 1

let g:vimwiki_list = [{'path': '~/notes/', 'path_html': '~/Documents/wiki', 'syntax': 'markdown', 'ext': '.md', 'folding': 'expr'}]

let g:vimwiki_global_ext = 0

let g:dict_hosts = [['dict.org', ['gcide', 'wn', 'moby-thes', 'vera', 'jargon', 'foldoc', 'bouvier', 'dcevil']]]

let g:vimfiler_as_default_explorer = 1

let g:is_chicken = 1

" Leaving and commenting out the following line in case I want to use an
" external command to dynamically generate startify's fortunes
" let g:startify_custom_header_quotes = [ {-> systemlist('fortune')} ]

" function to center ascii/ansi art header
function! s:filter_header(lines) abort
  let longest_line   = max(map(copy(a:lines), 'strwidth(v:val)'))
  let centered_lines = map(copy(a:lines),
        \ 'repeat(" ", (&columns / 2) - (longest_line / 2)) . v:val')
  return centered_lines
endfunction

let g:sword = [
      \ '         ▟▙',
      \ ' ▟▒░░░░░░░▜▙▜████████████████████████████████▛',
      \ ' ▜▒░░░░░░░▟▛▟▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▛',
      \ '         ▜▛',
      \ ]

" let g:startify_custom_header = s:filter_header(startify#fortune#boxed()) + s:filter_header(g:sword)
let g:startify_custom_header = s:filter_header(g:sword) + s:filter_header(startify#fortune#boxed())
let g:startify_bookmarks = ["~/.vimrc"]

let g:LanguageClient_serverCommands = {
            \ 'javascript': ['tcp://127.0.0.1:2089'],
            \ 'javascript.jsx': ['tcp://127.0.0.1:2089'],
            \}

function! LanguageClientMaps()
    if has_key(g:LanguageClient_serverCommands, &filetype)
        nnoremap <buffer> <silent> K :call LanguageClient#textDocument_hover()<cr>
        nnoremap <buffer> <silent> gd :call LanguageClient#textDocument_definition()<CR>
        nnoremap <buffer> <silent> <F2> :call LanguageClient#textDocument_rename()<CR>
    endif
endfunction

autocmd FileType * call LanguageClientMaps()
