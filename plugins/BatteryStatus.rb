require_relative '../lib/statusbar.rb'

class GetBatteryStatus
  def time_as_str(hours)
    seconds = hours.to_f * 60 * 60
    hours   = hours.to_i
    minutes = (seconds / 60  % 60).to_i
    seconds = (seconds % 60).to_i
    "%02d:%02d:%02d" % [ hours, minutes, seconds ]
  end

  def read_file(fname, strip: false)
    begin
      data = File.open(fname)
    rescue Errno::ENOENT
      return ""
    end

    while line = data.gets
      line.rstrip if strip
      yield line
    end
  end

  # enumerate battery
  def find_battery(dirs)
    dirs.each do |dir|
      read_file("#{dir}/type") do |line|
        return dir if line.include?("Battery")
      end
    end
  end

  # import battery stats into a hash
  def uevent(dir)
    results = {}

    read_file("%s/uevent" % dir) do |line|
      line = line.split("=")
      next if line.length < 2
      results[line[0]] = line[1..-1].join("=").rstrip
    end

    results
  end

  # get battery stats
  def stats
    statuses = {
      "Charging" => "Plugged in:",
      "Unknown"  => "Plugged in:",
      "Full"     => "Plugged in:"
    }

    orig_dir = Dir.pwd
    Dir.chdir "/sys/class/power_supply"

    begin
      # enumerate battery
      battery = find_battery(Dir.glob "*/")

      # get the batteries stats
      battery_stats = uevent(battery)

      # determine whether on battery or plugged in
      if statuses.include?(battery_stats["POWER_SUPPLY_STATUS"])
        battery_plugged_in = statuses[battery_stats["POWER_SUPPLY_STATUS"]]
      else
        battery_plugged_in = "On battery:"
      end

      # get charge levels
      energy_now     = battery_stats["POWER_SUPPLY_ENERGY_NOW"].to_f
      energy_full    = battery_stats["POWER_SUPPLY_ENERGY_FULL"].to_f
      battery_charge = ((energy_now / energy_full) * 100).round(2)

      power_now      = battery_stats["POWER_SUPPLY_POWER_NOW"].to_f

      # calculate charge time
      if power_now == 0
        time_until_charged = "charged"
      elsif battery_plugged_in == "On battery:"
        time_until_charged = energy_now / power_now
      else
        time_until_charged = (energy_full - energy_now ) / power_now
      end

      if time_until_charged.class != String
        time_until_charged = time_as_str(time_until_charged)
      end
    ensure
      Dir.chdir orig_dir
    end

    return battery_plugged_in, battery_charge, time_until_charged
  end
end

# Plugin class
# updates every 15 seconds
class BatteryStatus < StatusBarPlugin
  def run
    bat_stats = GetBatteryStatus.new
    plugged_in, charge, time_needed = bat_stats.stats

    if charge < 15
      color = red
    elsif charge < 30
      color = yellow
    else
      color = blue
    end

    @output = "#{plugged_in} #{color}#{charge}%#{green} (#{time_needed})"
  end
end
