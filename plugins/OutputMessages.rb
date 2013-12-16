require_relative '../lib/statusbar.rb'

# PM notifications
class OutputMessages < StatusBarPlugin
  def run
    begin
      msg = File.open("#{ENV["HOME"]}/.messages").gets.rstrip
    rescue
    end

    if msg and  msg != ""
      @output = "#{green}PM from: #{yellow}#{msg}#{blue}"
      File.open("#{ENV["HOME"]}/.messages", "w").close
    else
      @output = "#{green}No new messages#{blue}"
    end
  end
end
