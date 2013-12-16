#!/usr/bin/ruby
require 'eventmachine'
require 'timeout'
require_relative 'lib/statusbar.rb'
require_relative 'theme.rb'

# tmux statusbar daemon class
class TmuxD
  def initialize
    # initialize theme
    @theme   = Theme.new

    # import all plugins
    @plugins = []
    @theme.plugins.each do |plugin|
      @plugins << load_plugin(plugin)
    end
  end

  # starts the tmux statusbar daemon
  def run
    # run each plugin first
    @plugins.each do |plugin|
      run_plugin plugin
    end

    # start the event machine
    EventMachine.run do

      # create events for each plugin
      @plugins.each do |plugin|
        EventMachine.add_periodic_timer(plugin.interval) do
          run_plugin plugin
        end
      end

    end
  end

  # run a plugin, times out after 5 seconds
  def run_plugin plugin
    begin
      Timeout::timeout(5) do
        plugin.run
      end
      update_bar
    rescue
    end
  end

  # update each side
  def update_bar
    write_bar "right"
    write_bar "left"
  end

  # write out status bar side to files
  def write_bar side
    output = @theme.send "format_#{side}".to_sym

    @plugins.each do |plugin|
      output = output.sub("{{#{plugin.class}}}", plugin.output)
    end

    f = File.open("#{ENV['HOME']}/.tmuxd/#{side}", "w")
    f << output
    f.close
  end

  # import plugin from plugins directory
  # returns an instance of the class
  def load_plugin(plugin)
    require_relative "plugins/#{plugin}.rb"
    Kernel.const_get(plugin).new
  end
end
