#!/usr/bin/env ruby

require "byebug"

Dir.glob(File.join(File.dirname(File.absolute_path(__FILE__)), "lib", "**", "*.rb")) { |file| require file }

@@logging = Logging.logger(STDOUT)
UfwUpdater::Synchronize.synchronize_hosts File.join(File.dirname(__FILE__), "ufw_clients.yml")
