" -----------------------------------------------------------------------------
" file:         ~/.vimrc
" author:       fielding johnston - http://justfielding.com
" -----------------------------------------------------------------------------

" plug
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

" Current color scheme
Plug 'w0ng/vim-hybrid'

" Features
Plug 'bronson/vim-trailing-whitespace'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'tpope/vim-afterimage'
Plug 'tpope/vim-fugitive'
Plug 'scrooloose/nerdtree'
Plug 'terryma/vim-multiple-cursors'
Plug 'kien/ctrlp.vim'
Plug 'ryanss/vim-hackernews'
Plug 'fs111/pydoc.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'sjl/vitality.vim'
Plug 'shime/vim-livedown'
Plug 'mrtazz/simplenote.vim'
Plug 'junegunn/goyo.vim'
Plug 'moll/vim-bbye'
Plug 'tomtom/tcomment_vim'
Plug 'mhinz/vim-startify'
Plug 'airblade/vim-gitgutter'
Plug 'godlygeek/csapprox'
Plug 'godlygeek/tabular'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vimwiki/vimwiki'
Plug 'szw/vim-dict'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'mattn/webapi-vim'
Plug 'ap/vim-css-color'
Plug 'editorconfig/editorconfig-vim'
Plug 'neomake/neomake'
Plug 'mklabs/split-term.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'ternjs/tern_for_vim', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'carlitux/deoplete-ternjs', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'othree/jspc.vim', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'ervandew/supertab'
Plug 'ryanoasis/vim-devicons'
Plug 'mattn/gist-vim'
Plug 'sbdchd/neoformat'
Plug 'vimlab/mdn.vim'

" Specific language support/features
Plug 'sheerun/vim-polyglot'
Plug 'bigfish/vim-js-context-coloring', { 'branch': 'neovim' }
Plug 'plasticboy/vim-markdown'
Plug 'davidoc/taskpaper.vim'
Plug 'jbgutierrez/vim-babel'
Plug 'cakebaker/scss-syntax.vim'
Plug 'jaawerth/nrun.vim'
Plug 'heavenshell/vim-jsdoc'
Plug 'sheerun/vim-polyglot'
Plug 'chr4/nginx.vim'

call plug#end()

" init
" ----------------------------------------------------------------------------
filetype plugin indent on
syntax on

let mapleader=','

" set
" ----------------------------------------------------------------------------
set nocompatible                                                                " vim sets this automatically upon findin a vimrc file, keeping because it's my homie
set ffs=mac,unix,dos
set autoread                                                                    " Re-read file if changed outside
set autowrite                                                                   " Auto save before commands like :next
set backspace=2                                                                 " full backspacing compat
set history=50                                                                  " keep 50 lines of command line history
set ruler                                                                       " show the cursor position all the time
set showcmd                                                                     " display incomplete commands
set incsearch                                                                   " do incremental searching
set hlsearch                                                                    " highlight last used search pattern
set nowrap                                                                      " don't wrap line
set textwidth=0                                                                 " stops linewrapping at invisible margins
set colorcolumn=80                                                              " column indicator
set lbr                                                                         " wrap text
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
set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
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

" status bar info and appearance
" set statusline=\ \%f%m%r%h%w\ ::\ %y\ [%{&ff}]\%=\ [%p%%:\ %l/%L]\            " content for statusline
set laststatus=2                                                                " lastwindow always has status line
set cmdheight=1                                                                 " set 1 line limit for 'messages'
set noshowmode                                                                  " Hide the default mode text

" indenting
set autoindent                                                                  " turns autoidenting on for new lines
set smartindent                                                                 " does the right thing (mostly)
set cindent                                                                     " stricter rules for C programs
set shiftwidth=2                                                                " 2 cols for autoindenting

" don't add newlines at the end of files
set binary
set noeol

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

au FocusLost * :silent! wall

" mapping
" -----------------------------------------------------------------------------
" Q does formatting qith gq. Vim 5.0 style
map Q gq

" Shift or not to shift! that is the question
map ; :

" Force writing to a file with sudo
command! Sudo :execute ':silent w !sudo tee % > /dev/null' | :edit!

" enables CTRL-U after inserting a line break
inoremap <C-U> <C-G>u<C-U>

" spacebar unhighlights search text
:noremap <silent> <Space> :silent noh<Bar>echo<CR>

" Marked.app preview for markdown files
:nnoremap <leader>m :silent !open -a Marked.app '%:p'<cr>

:noremap <F6> :NERDTreeToggle<CR>
nnoremap <silent> <BS> :TmuxNavigateLeft<cr>

" Align blocks of text and keep them selected
vmap < <gv
vmap > >gv
" leader d to dump
nnoremap <leader>d "_d
vnoremap <leader>d "_d
" autocmd
" -----------------------------------------------------------------------------
" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on
  set ofu=syntaxcomplete#Complete
  set path+=/path/to/your/rails-application/app/**
  set path+=/path/to/your/rails-application/lib/**
  set suffixesadd=.rb
  set includeexpr+=substitute(v:fname,'s$','','g')

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 79 characters.:
  autocmd FileType text setlocal textwidth=79

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

  " Enabled auto sourcing when saving my vimrc
  augroup resource
    autocmd!
    autocmd BufWritePost $MYVIMRC source $MYVIMRC
  augroup END


  autocmd StdinReadPre * let s:std_in=1

  " for now not diffing NERDTree until I get it setup properly
  " autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
  " autocmd VimEnter * if !argc() | Startify | NERDTree | endif
  " autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

  autocmd FileType python setlocal sw=4 sts=4 et

  autocmd FileType javascript setlocal foldmethod=syntax foldlevelstart=1
  " Have eslint check for local npm binary before falling back to global
  autocmd BufEnter *.js let b:neomake_javascript_eslint_exe = nrun#Which('eslint')


  autocmd BufWritePost * Neomake


 " Set tmux pane title
	autocmd BufEnter * call system("settitle " . expand("%:p:t"))
  " Mark the current file as recently modified
	autocmd BufRead,BufEnter * call system("fdb -i /Users/fielding/.local/share/edit.json -a " . shellescape(expand("%:p")) . " &")
endif " has("autocmd")


" colors
" -----------------------------------------------------------------------------
set t_Co=256
set t_Sf=[3%dm
set t_Sb=[4%dm

let g:hybrid_custom_term_colors=1
set background=dark
colorscheme hybrid
highlight Normal ctermbg=NONE
highlight CursorLine ctermbg=0
highlight Comment cterm=italic
highlight ColorColumn ctermbg=234 guibg=234
highlight Conceal cterm=NONE ctermbg=NONE ctermfg=darkblue

" statusline
" -----------------------------------------------------------------------------

" options
" -----------------------------------------------------------------------------
let g:EditorConfig_exec_path = '/usr/local/bin/editorconfig'
let g:EditorConfig_core_mode = 'external_command'

let g:jsx_ext_required = 1


" let g:neomake_markdown_markdownlint_maker

let g:neomake_markdown_enabled_makers = ['markdownlint', 'proselint', 'writegood']
" let g:neomake_vimwiki_enabled_makers = ['proselint', 'writegood']
let g:neomake_javascript_enabled_makers = ['eslint']

let g:neoformat_javascript_prettier = {
            \ 'exe': 'prettier',
            \ 'args': ['--stdin', '--single-quote', '--trailing-comma es5'],
            \ 'stdin': 1,
            \ }

let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='raven'
" let g:airline_left_sep=''
" let g:airline_left_alt_sep=''
" let g:airline_right_sep=''
" let g:airline_right_alt_sep=''
let g:airline_powerline_fonts=1




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



let g:polyglot_disabled = ['markdown']
let g:vim_markdown_folding_style_pythonic = 1
let g:vimwiki_list = [{'path': '~/cloud/Dropbox/notes/', 'path_html': '~/Documents/wiki', 'syntax': 'markdown', 'ext': '.md', 'folding': 'expr'},
                    \ {'path': '~/src/hack/imbue-wiki/', 'index': 'home', 'syntax': 'markdown', 'ext': '.md', 'folding': 'expr'}]
let g:dict_hosts = [["dict.org", ["gcide", "wn", "moby-thes", "vera", "jargon", "foldoc", "bouvier", "devil"]]]

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
