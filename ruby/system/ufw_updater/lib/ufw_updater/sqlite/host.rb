require 'sequel'
require 'socket'
require File.join(File.dirname(File.absolute_path(__FILE__)), "..", "log.rb")

module UfwUpdater
  module Sqlite
    class Host
      include Log

      @@db = Sequel.connect(File.join("sqlite://", File.dirname(File.absolute_path(__FILE__)), "..", "..", "..", "db", "ufw_domain_update.db"))

      unless @@db.table_exists?(:hosts)
        logger.info "Created table hosts"
        @@db.create_table :hosts do
          primary_key :id
          String :name
          String :domain
          String :ip
          Integer :port
        end
      end

      attr_accessor :id, :name, :domain, :port, :ip

      def initialize *args
      end

      # Save host
      def insert
        logger.info "Insert host '#{self.domain}'"
        raise "Domain attribute is mandatory" unless self.domain

        cmd = "sudo ufw allow from #{self.ip} to any port #{self.port}"
        logger.info "Running command '#{cmd}'"

        out = IO.popen(cmd)
        if out.readlines.first.downcase.start_with? "rule added"
          self.id = @@db.from(:hosts).insert(name: self.name, domain: self.domain, ip: self.ip, port: self.port)
          logger.info "Host saved with attributes #{self.attributes}"
        else
          return if out.readlines.empty?

          logger.info out.readlines
          raise "ufw allow command failed"
        end
      end

      # Update host
      def update
        logger.info "Update host '#{self.domain}' to #{self.attributes}"
        @@db.from(:hosts).where('id = ?', self.id).update(name: self.name, domain: self.domain, ip: self.ip, port: self.port)
      end

      # Remove host
      def remove
        logger.info "Remove host '#{self.domain}'"

        out = IO.popen("sudo ufw delete allow from #{self.ip} to any port #{self.port}")
        if out.readlines.first.downcase.start_with? "rule deleted"
          @@db.from(:hosts).where('id = ?', self.id).delete
        else
          return if out.readlines.empty?

          logger.info out.readlines
          raise "ufw delete command failed"
        end
      end

      # Resolve host ip
      def resolve_ip
        begin
          IPSocket::getaddress(self.domain)
        rescue
          nil
        end
      end

      # Get host attributes
      def attributes
        "id: #{self.id}, name: #{self.name}, domain: #{self.domain}, ip: #{self.ip}, port: #{self.port}"
      end

      # Find host by domain
      def self.find_by_domain domain
        hosts = []
        db_hosts = @@db.from(:hosts).where(domain: domain)

        for db_host in db_hosts
          hosts << Sqlite::Host.new_from_db(db_host)
        end

        return hosts
      end

      # Find all hosts
      def self.all
        hosts = []
        db_hosts = @@db.from(:hosts).all

        for db_host in db_hosts
          hosts << Sqlite::Host.new_from_db(db_host)
        end

        return hosts
      end

      # Create host from db
      def self.new_from_db db_host
        host = self.new
        host.id = db_host[:id]
        host.name = db_host[:name]
        host.domain = db_host[:domain]
        host.ip = db_host[:ip]
        host.port = db_host[:port]

        return host
      end
    end
  end
end
