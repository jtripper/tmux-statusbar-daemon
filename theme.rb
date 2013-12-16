require_relative 'lib/statusbar.rb'

# default theme file
class Theme
  attr_reader :plugins
  attr_reader :format_left
  attr_reader :format_right

  # import colors
  include Colors

  def initialize
    # list of plugins to load
    @plugins =
      [ :NowPlaying, :CurrentIP, :BatteryStatus, :CurrentTime, :OutputMessages ]

    # {{plugin name}} will substitute the output of the plugins
    # the left side of the status bar
    @format_left = 
      " #{blue}[ #{white}{{CurrentIP}}#{blue} ] [ {{OutputMessages}} ] [ {{NowPlaying}} ]"

    # right side of the status bar
    @format_right = 
      " #{blue}[ #{green}{{BatteryStatus}}#{blue} ] [ #{white}{{CurrentTime}}#{blue} ] "
  end
end

