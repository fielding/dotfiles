filetype off
set rtp+=~/.vim/bundle/vundle
call vundle#begin()

" This is the Vundle package, which can be found on GitHub.
" For GitHub repos, you specify plugins using the
" 'user/repository' format
Plugin 'gmarik/vundle'


" Features

Bundle 'bronson/vim-trailing-whitespace'
Bundle 'nathanaelkane/vim-indent-guides'
Bundle 'tpope/vim-afterimage'
Bundle 'scrooloose/syntastic'
Bundle 'scrooloose/nerdtree'
Bundle 'terryma/vim-multiple-cursors'
Bundle 'kien/ctrlp.vim'
Bundle 'ryanss/vim-hackernews'
Bundle 'fs111/pydoc.vim'
Bundle 'christoomey/vim-tmux-navigator'
Bundle 'sjl/vitality.vim'
Bundle 'junegunn/goyo.vim'
Bundle 'moll/vim-bbye'
Bundle 'tomtom/tcomment_vim'

" Syntax/Indent for specific languages

Bundle 'davidhalter/jedi-vim'
Bundle 'tpope/vim-haml'
Bundle 'plasticboy/vim-markdown'
Bundle 'lambdatoast/elm.vim'
Bundle 'leshill/vim-json'
Bundle 'kchmck/vim-coffee-script'
Bundle 'ajford/vimkivy'
Bundle 'tshirtman/vim-cython'
Bundle 'airblade/vim-gitgutter.git'

" Color correction

Bundle 'godlygeek/csapprox'

" Color Schemes

Bundle 'morhetz/gruvbox'
Bundle 'tomasr/molokai'
Bundle 'adlawson/vim-sorcerer'
Bundle 'sickill/vim-monokai'
Bundle 'chriskempson/vim-tomorrow-theme'
Bundle 'w0ng/vim-hybrid'
Bundle 'Junza/Spink'

call vundle#end()
filetype plugin indent on                                               				" required!