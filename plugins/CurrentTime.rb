require_relative '../lib/statusbar.rb'

# plugin to get the time
class CurrentTime < StatusBarPlugin
  def initialize
    @output   = ""
    @interval = 1
  end

  def run
    t = Time.now
    @output = "%02d:%02d:%02d" % [ t.hour, t.min, t.sec ]
  end
end
