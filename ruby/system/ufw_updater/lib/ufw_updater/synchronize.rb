require "yaml"

module UfwUpdater
  class Synchronize
    include Log

    # Save host from data in yaml file
    def self.insert_host ufw_client
      host = Sqlite::Host.new
      host.domain = ufw_client["domain"] if ufw_client["domain"]
      host.name = ufw_client["name"] if ufw_client["name"]
      host.port = ufw_client["port"].to_i if ufw_client["port"]
      host_ip = host.resolve_ip

      if host_ip
        host.ip = host_ip
        host.insert
      else
        logger.info "Unable to save host: cannot resolve ip"
      end
    end

    # Synchronize hosts between yml and sqlite db
    def self.synchronize_hosts yaml_file
      logger.info "Synchronizing hosts"
      logger.info "Parsing ufw_clients.yml"
      ufw_clients = YAML.load_file(yaml_file)

      if ufw_clients.any?
        for ufw_client in ufw_clients
          client_domain = ufw_client["domain"]
          logger.info "Searching for '#{client_domain}'"
          saved_hosts = Sqlite::Host.find_by_domain client_domain

          raise "too many saved hosts: should only be one" if saved_hosts.size > 1

          unless saved_hosts.any?
            logger.info "Saving host '#{client_domain}'"
            self.insert_host ufw_client
          else
            logger.info "Host '#{client_domain}' found"

            host = saved_hosts.first

            unless host.port == ufw_client["port"]
              host.remove
              self.insert_host ufw_client
            else
              should_update = false

              unless host.name.eql?(ufw_client["name"])
                host.name = ufw_client["name"]
                should_update = true
              end

              host_ip = host.resolve_ip
              unless host.ip.eql?(host_ip)
                host.ip = host_ip
                should_update = true
              end

              host.update if should_update
            end
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
          logger.info "Host '#{host.domain}' removed" if host.remove
        end
      end
    end
  end
end
