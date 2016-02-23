#!/usr/bin/env ruby

require "yaml"
require "pp"
require "byebug"
require "sequel"
require "logging"

Dir.glob(File.join(File.dirname(File.absolute_path(__FILE__)), "lib", "**", "*.rb")) { |file| require file }
@logger = Logging.logger(STDOUT)

# Parse ufw status
def parse_ufw_status
  items = []

  out = IO.popen("sudo ufw status numbered")
  regexp = /^\[(.*?)\]\s+(.*?)\s{2,}(.*?)\s{2,}(.*?)$/
  for line in out.readlines
    attributes = line.scan(regexp).flatten
    if attributes.any?
        items << Ufw::Item.new(attributes)
    end
  end

  return items
end

# Synchronize hosts between yml and sqlite db
def synchronize_hosts
  @logger.info "Synchronizing hosts"
  @logger.info "Parsing ufw_clients.yml"
  ufw_clients = YAML.load_file(File.join(File.dirname(__FILE__), "ufw_clients.yml"))

  if ufw_clients.any?
    for ufw_client in ufw_clients
      client_domain = ufw_client["domain"]
      @logger.info "Searching for '#{client_domain}'"
      saved_hosts = Sqlite::Host.find_by_domain client_domain

      unless saved_hosts.any?
        @logger.info "Saving host '#{client_domain}'"
        host = Sqlite::Host.new
        host.domain = ufw_client["domain"] if ufw_client["domain"]
        host.name = ufw_client["name"] if ufw_client["name"]
        host.resolve_ip

        host.save
      else
        @logger.info "Host '#{client_domain}' found"
      end
    end
  end

  for host in Sqlite::Host.all
    has_host = false

    for ufw_client in ufw_clients
      if host.domain.eql?(ufw_client["domain"])
        has_host = true
        break
      end
    end

    unless has_host
      @logger.info "Host '#{host.domain}' removed" if host.remove
    end
  end
end

synchronize_hosts
