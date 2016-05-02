#!/usr/bin/env ruby

require 'socket'
require "yaml"
require "logging"
require "pp"

logger = Logging.logger(STDOUT)

begin
  raise "Invalid number of arguments: first argument should be a path to a plexWatch log file" if ARGV.size != 1
  log_file_path = ARGV[0]
  raise "File '#{log_file_path}' doesn't exist" unless File.exists?(log_file_path)

  log_file_path = File.expand_path log_file_path
  logger.info "Found plexWatch log file: #{log_file_path}"

  log_file_line_number_config_file = File.join(File.dirname(__FILE__), "db", "plex_watch_line_number.yml")
  log_file_line_number = File.exists?(log_file_line_number_config_file) ? File.read(log_file_line_number_config_file).to_i : 0
  logger.info "PlexWatch log file line number: #{log_file_line_number}"

  logger.info "Parsing config file"
  config_file = File.join(File.dirname(__FILE__), "config.yml")
  raise "Config file not found" unless File.exists?(config_file)
  config = YAML.load_file config_file

  if config
    ips = config["ips"]
    domains = config["domains"]

    ips ||= []
    domains ||= []

    logger.info "Found #{ips.size} ips"
    logger.info "Found #{domains.size} domains"

    for domain in domains
      domain_ip = IPSocket::getaddress(domain)
      if domain_ip
        logger.info "Domain '#{domain}' resolved: #{domain_ip}"
        ips << domain_ip
      end
    end

    logger.info "Ips to check #{ips.size > 1 ? 'are' : 'is'} #{ips.join(', ')}"

    plex_watch_file = File.open log_file_path

    for ip in ips
    end
  else
    raise "Something went wrong when loading config yaml file"
  end
rescue Exception => e
  logger.error e.message
end
