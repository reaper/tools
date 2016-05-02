#!/usr/bin/env ruby

require "yaml"
require "logging"
require "pp"

logger = Logging.logger(STDOUT)
logger.info "Parsing config file"

config = YAML.load_file(File.join(File.dirname(__FILE__), "config.yml"))
pp config
