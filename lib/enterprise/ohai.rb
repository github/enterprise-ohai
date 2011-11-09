require 'ohai'
require 'json'

Ohai::Config[:plugin_path] << File.dirname(__FILE__) + '/ohai/plugins'

module Enterprise
  module Ohai

    def self.run
      puts JSON.pretty_generate(system_data)
    end

    def self.system_data
      system = ::Ohai::System.new

      system.all_plugins

      system.data
    end
  end
end
