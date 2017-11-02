# dotfiles

## Table of Contents
- [Overview](#overview)
- [Installation](#installation)
- [Extended information](#extended-information)
- [TODO](#todo)
- [Inspiration / Special Thanks](#inspiration-/-special-thanks-to...)

---

## Overview

```
babel       >
bash        > bash settings, aliases, functions
bin         > scripts
dircolors   > color settings for ls output
eslint      >
fonts       >
git         > global git configuration and templates
grc         > colorized command output configuration
iterm2      > iterm2 color presets
karabiner   > karabiner config files
mpv         >
neovim      > config and colors for the successor to vim
readline    > vi editing mode and iterm2 unicode usage via .inputrc
ruby        >
shell       >
terminfo    > iterm and tmux-256color with italics support terminfo files
tmux        > .tmux.conf and tmux plugins
vim         >
vint        >
.osx        > sensible os x defaults
```

---

## Installation

```sh
brew install stow

stow babel bash bin dircolors eslint fonts git grc iterm2 mpv neovim readline ruby shell terminfo tmux vim vint

git submodule update --init --recursive

tic ~/.termino/69/iterm.terminfo
tic ~/.terminfo/74/tmux.terminfo
tic ~/.terminfo/74/tmux-256color.terminfo

vim +BundleInstall +BundleClean +q

~/.tmux/plugins/tpm/bin/install_plugins
```

---

## Extended Information

### Bash

### VIM

![VIM Screenshot](previews/vim.png)

#### VIM Plugins

##### Feature Plugins
[bronson/vim-trailing-whitespace](https://github.com/bronson/vim-trailing-whitespace)  
[nathanaelkane/vim-indent-guides](https://github.com/nathanaelkane/vim-indent-guides)  
[tpope/vim-afterimage](https://github.com/tpope/vim-afterimage)  
[scrooloose/syntastic](https://github.com/scrooloose/syntastic)  
[scrooloose/nerdtree](https://github.com/scrooloose/nerdtree)  
[terryma/vim-multiple-cursors](https://github.com/terryma/vim-multiple-cursors)  
[kien/ctrlp.vim](https://github.com/kien/ctrlp.vim)  
[ryanss/vim-hackernews](https://github.com/ryanss/vim-hackernews)  
[fs111/pydoc.vim](https://github.com/fs111/pydoc.vim)  
[christoomey/vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)  
[sjl/vitality.vim](https://github.com/sjl/vitality.vim)  
[shime/vim-livedown](https://github.com/shime/vim-livedown)  
[mrtazz/simplenote.vim](https://github.com/mrtazz/simplenote.vim)  
[junegunn/goyo.vim](https://github.com/junegunn/goyo.vim)  
[moll/vim-bbye](https://github.com/moll/vim-bbye)  
[tomtom/tcomment_vim](https://github.com/tomtom/tcomment_vim)  
[mhinz/vim-startify](https://github.com/mhinz/vim-startify)  
[airblade/vim-gitgutter](https://github.com/airblade/vim-gitgutter)  
[godlygeek/csapprox](https://github.com/godlygeek/csapprox)  
[godlygeek/tabular](https://github.com/godlygeek/tabular)  

##### Specific language support/features

[plasticboy/vim-markdown](https://github.com/plasticboy/vim-markdown)  
[leshill/vim-json](https://github.com/leshill/vim-json)  


##### Current Color Scheme

[w0ng/vim-hybrid](https://github.com/w0ng/vim-hybrid)  

### Tmux

#### Tmux Plugins
[tmux-plugins/tmux-sensible](https://github.com/tmux-plugins/tmux-sensible)  
[tmux-plugins/tmux-pain-control](https://github.com/tmux-plugins/tmux-pain-control)  
[tmux-plugins/tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect)  
[tmux-plugins/tmux-continuum](https://github.com/tmux-plugins/tmux-continuum)  

---
## README Maintenance

vim search and replace to convert bundles.vim to markdown hyperlinks for plugin section.

```
  %s/[\(.*\)](https://github.com/\(.*\))  /[\1](https:\/\/github.com\/\1)  /
```

---
## TODO

- [x] binds/tune up text/code folding within vim (temp marking as done, I think I am content with za, zo, zc, and their bigcase counterparts)
- [x] Rework implementation/installation at new workstation; current .gitignore with the git repo existing in ~ is pretty bogus
- [x] check in to submodules for tmux/vim/whatev plugins
- [x] Tmux configuration (basically a default config currently)
- [ ] write up on using GNU Stow and what each stow package is for, etc
  - [ ] update "overview" section to include a brief overview of what my settings/additions include
- [ ] where the hell should I put .colors/fielding? XResources?
- [ ] find a suitable vim binding for Goyo and Goyo!
- [ ] check in to vim-hackernews and adding additional color highlighting to
 comments pages. A small dab of color could go a long way
- [ ] can I get Github Flavored Markdown for livedown/vim-livedown?
- [ ] Revise Vim plugins; Try and incorporate desired, but currently unsed
plugins, in to my workflow, and then remove any "unfitting" or not needed.
- [ ] Tmux scrolling with less
- [ ] Reevaluate clipboard "functionality" and sanity with vim/tmux and os x
- [ ] AN OPTIMISTIC ADVENTURE DOWN POSTAL LANE: MUTT the ultimate setup.
  - [ ] MUTT
  - [ ] notmuch
  - [ ] msmtp
  - [ ] POSSIBLY offlineimap
  - [ ] contacts (brew install contacts)
- [ ] License/consider if needed
- [ ] Colors between powerline/tmux/vim seem to be off a tad bit
- [ ] .vimrc restructuring using folding and better sections
- [ ] add my weechat configuration
- [ ] submodule upkeep? (git submodule foreach git pull or git submodule foreach git pull origin master)
- [ ] actually configure and include custom powerline configuration for latest version
- [ ] include and test pip-upgrade-all with update alias
- [ ] seinfeild/git commit daily indicator on tmux status line
- [ ] reevaluate tmux status line and add/remove accordingly
- [ ] vim PluginUpdate fails on gmarik/vundle, just need to make sure this is correct behavior
- [ ] revisit grc
- [ ] utilize grc.bashrc (as an include in the bash_profile.d include directory)

### Someday/Maybe
- [ ] Hotline Miami Color Scheme

---
## Inspiration / Special Thanks to...

* [Jeffrey Carpenter](https://github.com/i8degrees), his [dotfiles repository](https://github.com/i8degrees/dotfiles), and for having somebody to "talk nerdy" to!
* [Mathias Bynens](https://mathiasbynens.be/) and his [dotfile repository](https://github.com/mathiasbynens/dotfiles)
* [Xero Harrison](http://xero.nu) and his [dotfile repository](https://github.com/xero/dotfiles)

