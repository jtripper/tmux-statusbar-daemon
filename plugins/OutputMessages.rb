require_relative '../lib/statusbar.rb'

# PM notifications
class OutputMessages < StatusBarPlugin
  def run
    msg = File.open("#{ENV["HOME"]}/.messages").gets.rstrip
    if msg != ""
      @output = "#{green}PM from: #{yellow}#{msg}#{blue}"
      File.open("#{ENV["HOME"]}/.messages", "w").close
    else
      @output = "#{green}No new messages#{blue}"
    end
  end
end
