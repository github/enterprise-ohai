require 'ohai'
require 'json'

Ohai::Config[:plugin_path] << File.dirname(__FILE__) + '/enterprise/ohai/plugins'

module Enterprise
  module Ohai

    def self.run
      puts JSON.pretty_generate(system_data)
    end

    def self.system_data
      system = ::Ohai::System.new

      system.require_plugin('linux/block_device')
      system.require_plugin('linux/filesystem')
      system.require_plugin('linux/memory')
      system.require_plugin('network')

      system.require_plugin('swap')

      system.data
    end
  end
end
