##----------------------------------------------------------------------------
## file:          ~/.osx
## author:        fielding johnston - http://www.justfielding.com
## credit:        inspired by Mathias Bynens and his .osx file
##----------------------------------------------------------------------------

# Remove all of whatever that is in the dock
# Consider that this might only want to be ran after fresh install
# defaults write com.apple.dock persistent-apps -array && killall Dock

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

# Experimental: Overly sluggish performance after heavy useage on my macbook
# air has resulted in exploring/tracking down the culprit.
#
# Spindump appears to be a major resource hog and working over time on my
# system. I have read about issues with crash reports being generated almost
# non stop and in turn causing more crashes and a viscious cycle.
#
# I need to verify, but the problem is reported to be more of an issue for
# systems that meet one or more of the following:
#
# 1. running a developer beta.
# 2. /AppleInternal folder
# 3. an older computer.
#
# Currently I meet two of three of those conditions, so here goes some
# experimenting.
#
# The following line turns off spindump.
defaults write com.apple.crashreporter LogSpins -bool NO

