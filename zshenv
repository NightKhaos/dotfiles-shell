pupdate() { case ":${PATH:=$1}:" in *:"$1":*) ;; *) export PATH="$1:$PATH" ;; esac; }

# Load ZSH other files
for file in $(find $HOME/.zsh -name "*.env"); do
  source "$file"
done

# Add additional user scripts
pupdate $HOME/bin
pupdate $HOME/.local/bin

# Add history
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=$HOME/.zsh_history
setopt appendhistory
setopt HIST_IGNORE_SPACE      # Commands starting with space not saved
setopt HIST_IGNORE_DUPS       # Don't save duplicate commands
setopt HIST_IGNORE_ALL_DUPS   # Remove older duplicates from history

# Add Editor
export EDITOR=vim

# Sheldon config directory (plugins.toml lives in version-controlled .shellconfig)
export SHELDON_CONFIG_DIR=~/.shellconfig/sheldon
