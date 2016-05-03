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
Bundle 'shime/vim-livedown'
Bundle 'mrtazz/simplenote.vim'
Bundle 'junegunn/goyo.vim'
Bundle 'moll/vim-bbye'
Bundle 'tomtom/tcomment_vim'
Bundle 'mhinz/vim-startify'
Bundle 'airblade/vim-gitgutter'
Bundle 'godlygeek/csapprox'
Bundle 'godlygeek/tabular'

" Specific language support/features

Bundle 'plasticboy/vim-markdown'
Bundle 'leshill/vim-json'

" Current color scheme

Bundle 'w0ng/vim-hybrid'

call vundle#end()
filetype plugin indent on