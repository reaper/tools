require "sequel"
require 'socket'

module Sqlite
  class Host
    @@db = Sequel.connect(File.join("sqlite://", File.dirname(File.absolute_path(__FILE__)), "..", "..", "db", "ufw_domain_update.db"))

    unless @@db.table_exists?(:hosts)
      @@db.create_table :hosts do
        primary_key :id
        String :name
        String :domain
        String :ip
      end
    end

    attr_accessor :id, :name, :domain, :ip

    def initialize *args
    end

    # Save host
    def save
      raise "Domain attribute is mandatory" unless self.domain
      self.id = @@db.from(:hosts).insert(name: self.name, domain: self.domain, ip: self.ip)
    end

    # Remove host
    def remove
      @@db.from(:hosts).where('id = ?', self.id).delete
    end

    # Resolve host ip
    def resolve_ip
      self.ip = IPSocket::getaddress(self.domain)
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

      return host
    end
  end
end
