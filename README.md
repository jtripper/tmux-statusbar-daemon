Tmux Statusbar Daemon
=========

Tmux Statusbar Daemon is a daemon for creating dynamic status bars for tmux. The daemon is based on plugins and allows a user to customize their tmux statusbar in Ruby.

## Installation

The daemon can be installed by cloning the git repository and then adding the following lines to the tmux configuration (~/.tmux.conf):

```
# optional
set-option -g status-position top
set-option -g status-bg black

set-option -g status on
set-option -g status-interval 1
set-option -g status-justify centre

set-option -g status-right-length 60
set-option -g status-left-length 90

set-option -g status-left "#(/path/to/tmuxd/run.rb left)"
set-option -g status-right "#(/path/to/tmuxd/run.rb right)"
```

Also, install the Ruby EventMachine gem.

```
gem install eventmachine
```

## Running

To run, simply execute:

```
/path/to/tmuxd/run.rb
```

This will start the daemon and tmux will automatically connect when started.

The daemon can be restarted with:

```
/path/to/tmuxd/run.rb reload
```

And stopped with:

```
/path/to/tmuxd/run.rb stop
```

## Theming

To theme the statusbar daemon, edit the theme.rb file. New plugins can be added in the plugins directory, use the code of existing plugins as an example of usage (CurrentIP.rb is the simplest).
