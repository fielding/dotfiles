#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# bootstrap.sh - f'ng <fielding@justfielding.com> https://justfielding.com
#----------------------------------------------------------------------------

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Set the timezone!
sudo systemsetup -settimezone "America/Chicago" > /dev/null

default_hostname=$(hostname)
read -p "Hostname (default: $default_hostname): " hostname
hostname=${hostname:-$default_hostname}

# Set ComputerName, HostName, and LocalHostName
sudo scutil --set ComputerName "$hostname"
sudo scutil --set HostName "$hostname"
sudo scutil --set LocalHostName "$hostname"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$hostname"

# Check for Homebrew and install it if missing
if test ! $(which brew)
then
    echo "Installing Homebrew..."
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

brew update
brew tap homebrew/bundle
brew install zsh stow mas python3 node rbenv ruby-build

tic ~/.terminfo/69/iterm.terminfo
tic ~/.terminfo/74/tmux.terminfo
tic ~/.terminfo/74/tmux-256color.terminfo

# install neovim plugins
npm install -g neovim
pip install neovim
pip3 install neovim
gem install neovim

# Remove all of whatever that is in the dock and then restart dock
defaults write com.apple.dock persistent-apps -array && killall Dock

# Enable AirDrop over Ethernet and on unsupported Macs running Lion
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Use current directory as default search scope in Finder
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Show the ~/Library folder
chflags nohidden ~/Library

# iterm2 - scroll less output
defaults write com.googlecode.iterm2 AlternateMouseScroll -bool true

# Finder Fun!
# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Finder: show full POSIX path in title bar
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Finder: show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Restart Finder
killall Finder

# set default shell to zsh
sudo dscl . -create /Users/$USER UserShell /usr/local/bin/zsh

brew bundle --file=./homebrew/.Brewfile

