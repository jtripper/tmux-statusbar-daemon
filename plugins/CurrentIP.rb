require 'net/http'
require_relative '../lib/statusbar.rb'

# get current ip
class CurrentIP < StatusBarPlugin
  def initialize
    @output   = ""
    @interval = 3600
  end

  def run
    getter = Net::HTTP.new('check.torproject.org', 443)
    getter.use_ssl = true
    tor_check = getter.get('/', nil).body

    ip = tor_check.scan(/Your IP address appears to be:\s+<[^>]+>([^<]+)/)[0][0]

    # turn IP red if we're not using Tor
    @output = tor_check.include?('Congratulations') ? ip : "#{red}#{ip}"
  end
end
