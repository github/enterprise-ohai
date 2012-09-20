provides 'ntp'

ntp_config_file = '/etc/ntp.conf'

ntp_config = Mash.new

if File.exists?(ntp_config_file)
  lines = File.readlines(ntp_config_file)
  ntp_config[:servers] = lines.grep(/^server/).map {|l| l.split(" ").last }
end

ntp ntp_config
