# colors module, provides color functions for plugins
module Colors
  def color(fg: "blue")
  #  if tmux
    "#[fg=#{fg}]"
  #  else
  #    "\005{#{screen_colors[fg]}}"
  #  end
  end

  def red
    color(fg: "red")
  end

  def yellow
    color(fg: "yellow")
  end

  def blue
    color(fg: "blue")
  end

  def green
    color(fg: "green")
  end

  def white
    color(fg: "white")
  end
end

# Status Bar Plugin base class
class StatusBarPlugin
  attr_accessor :interval
  attr_accessor :output

  include Colors

  def initialize
    @output   = ""
    @interval = 15
  end
end
