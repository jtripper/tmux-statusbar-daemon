#!/usr/bin/env ruby
require_relative 'tmuxd.rb'

# start up tmux_statusbar_d as a daemon
def start_tmuxd tmuxd_dir
  exit if not fork

  if not pid = fork
    t = TmuxD.new
    t.run
  else
    f = File.open "#{tmuxd_dir}/tmuxd.pid", "w"
    f << pid.to_s
    f.close
  end

  exit
end

# get the PID from the pid file (or return false if it's not running)
def getpid(tmuxd_dir)
  return false if not File.exist? "#{tmuxd_dir}/tmuxd.pid"
  pid_f = File.open "#{tmuxd_dir}/tmuxd.pid"
  pid = pid_f.gets
  pid_f.close

  return false if not pid
  pid = pid.strip
  File.exist?("/proc/#{pid}") ? pid.to_i : false
end

home = ENV["HOME"]
tmuxd_dir = "#{home}/.tmuxd"

if not File.exist? tmuxd_dir
  Dir.mkdir tmuxd_dir
end

pid = getpid(tmuxd_dir)

# start tmux_startbar_d
if not ARGV[0] and not pid
  start_tmuxd tmuxd_dir
# reload tmux_statusbar_d
elsif ARGV[0] == "reload" and pid
  Process.kill(9, pid)
  File.open("#{tmuxd_dir}/left", "w").close
  File.open("#{tmuxd_dir}/right", "w").close
  start_tmuxd tmuxd_dir
# stop the daemon
elsif ARGV[0] == "stop" and pid
  Process.kill(9, pid)
  File.open("#{tmuxd_dir}/tmuxd.pid", "w").close
  File.open("#{tmuxd_dir}/left", "w").close
  File.open("#{tmuxd_dir}/right", "w").close
# get the statusbar text
elsif ARGV[0] == "left" or ARGV[0] == "right"
  f = File.open "#{tmuxd_dir}/#{ARGV[0]}"
  puts f.gets
  f.close
end
