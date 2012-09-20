provides 'resolv'

resolv_config_file = '/etc/resolv.conf'
ip = %r{((?:[01]?\d\d?|2[0-4]\d|25[0-5])\.(?:[01]?\d\d?|2[0-4]\d|25[0-5])\.(?:[01]?\d\d?|2[0-4]\d|25[0-5])\.(?:[01]?\d\d?|2[0-4]\d|25[0-5]))}

resolv_config = Mash.new

if File.exist?(resolv_config_file)
  lines = File.readlines(resolv_config_file)
  resolv_config[:name_servers] = lines.grep(/^nameserver #{ip}$/).map {|l| l[ip, 1] }
end

resolv resolv_config
