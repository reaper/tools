module UfwUpdater
  module Ufw
    class Ufw
      # Parse ufw status
      def self.status
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
    end
  end
end
