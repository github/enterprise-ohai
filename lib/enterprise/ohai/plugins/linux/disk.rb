provides 'disk'

require_plugin 'linux::block_device'
require_plugin 'linux::filesystem'
require_plugin 'linux::swap'

def disk_path(link)
  dir   = File.dirname(link)
  path  = File.readlink(link)

  File.expand_path(File.join(dir, path))
end

def disk_size(path)
  %x{fdisk -lu #{path} 2>&1}[%r{^Disk #{path}: (.*),}, 1]
end

disks = Mash.new

by_path_root  = '/dev/disk/by-path'
by_label_root = '/dev/disk/by-label'
by_uuid_root  = '/dev/disk/by-uuid'

%x{parted --list --script}.split("\n\n\n").each do |section|
  path, headers, partitions, info = nil, nil, [], Mash.new

  section.split("\n").each do |line|
    case line
    when %r{^Error: (.*): } then disks[$1] ||= Mash.new
    when %r{^Model: (.*)$} then info[:model] = $1
    when %r{^Disk (.*): (.*)$} then path, info[:size] = $1, $2
    when %r{^Number\s+} then headers = line.split(/\s{2,}/).map {|h| h.downcase.gsub(/\W/, '_') }
    when %r{^ \d+} then
      next if headers.nil?
      keys    = headers.map {|h| h.downcase.gsub(/\W/, '_') }
      values  = line.split

      partition_info = keys.zip(values).inject(Mash.new) do |m, (k,v)|
        m.update(k => v)
      end

      partitions << partition_info
    end
  end

  info[:partitions] = partitions

  (disks[path] ||= Mash.new).merge!(info)
end

Dir.glob(File.join(by_path_root, '*')).each do |disk_name_link|
  disk_name = File.basename(disk_name_link)
  path      = disk_path(disk_name_link)

  next unless disks[path]

  disks[path][:name] = disk_name
end

Dir.glob(File.join(by_label_root, '*')).each do |disk_label_link|
  disk_label = File.basename(disk_label_link)
  path       = disk_path(File.join(by_label_root, disk_label))

  next unless disks[path]

  disks[path][:label] = disk_label
end

Dir.glob(File.join(by_uuid_root, '*')).each do |disk_uuid_link|
  disk_uuid = File.basename(disk_uuid_link)
  path      = disk_path(File.join(by_uuid_root, disk_uuid))

  next unless disks[path]

  disks[path][:uuid] = disk_uuid
end

disks.keys.each do |device|
  disks[device].update(filesystem[device]) if filesystem[device]
  disks[device].update(:swap => true)      if swap[device]
end

disk disks
