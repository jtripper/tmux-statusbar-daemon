#!/usr/bin/env ruby
require 'socket'
require_relative '../lib/statusbar.rb'

# mpd client
class MPC
  def initialize(ip: "127.0.0.1", port: 6600)
    @sock = TCPSocket.new ip, port
  end

  # sends command to mpd and returns hash of response
  def cmd(command)
    @sock.puts(command + "\n")

    data = ""
    while not data.end_with?("\nOK\n") and rcvd = @sock.gets do
      data += rcvd
    end

    results = Hash.new
    data.split("\n").each do |line|
      next if line.start_with? "OK"

      line = line.split ":"
      next if line.length < 2

      results[line[0]] = line[1..-1].join(":").lstrip
    end

    results
  end

  # get the currently playing song and stats
  def now_playing
    status          = cmd("status")

    if not status["songid"]
      f = File.open("status", "a+")
      f << status
      f.close
      return nil
    end

    song            = cmd("playlistid #{status["songid"]}")
    song["Elapsed"] = seconds(status["elapsed"].to_f)
    song["Time"]    = seconds(song["Time"].to_f)
    song
  end

  def seconds(seconds)
    "%02d:%02d" % [ seconds / 60, seconds % 60 ]
  end

  def close
    @sock.close
  end
end

# plugin to get currently playing song
class NowPlaying < StatusBarPlugin
  def initialize
    @output     = ""
    @interval   = 1
    @mpd_client = nil
  end

  def run
    song_format = "#{red}%s #{blue}(#{yellow}%s/%s#{blue}) #{red}%s#{blue}"

    begin
      @mpd_client = MPC.new if not @mpd_client
      song = @mpd_client.now_playing
    rescue Exception => ex
      @output = "Error: #{ex.message}"
      @mpd_client = nil
      return
    end

    if not song
      @output = "Nothing playing"
      return
    end

    elapsed     = song["Elapsed"]
    total       = song["Time"]
    artist      = song["Artist"]
    title       = song["Title"]

    @output = song_format % [ artist, elapsed, total, title ]
  end
end
