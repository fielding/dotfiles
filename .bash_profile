for file in ~/.{bashrc,extra}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

### Additional sources

# Iterm2 shell integration
if [ -f /Users/fielding/.iterm2_shell_integration.bash ]; then
	source /Users/fielding/.iterm2_shell_integration.bash
fi

### Completions

if [ -f $(brew --prefix)/share/bash-completion/bash_completion ]; then
  . $(brew --prefix)/share/bash-completion/bash_completion
fi

### Paths

# Add additional default paths
export PATH="$HOME/bin:/usr/local/opt/coreutils/libexec/gnubin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/X11/bin:/usr/local/git/bin:/opt/bin:$HOME/.cabal/bin:$HOME/.rbenv/bin"
# export PYTHONPATH="$(brew --prefix)/lib/python2.7/site-packages"