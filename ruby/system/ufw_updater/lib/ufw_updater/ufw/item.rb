module UfwUpdater
  module Ufw
    class Item
      attr_accessor :id, :to, :action, :from
      def initialize args
        raise "Unsupported ufw item: invalid number of arguments" if args.size != 4

        @id = args.at(0).strip
        @to = args.at(1).strip
        @action = args.at(2).strip
        @from = args.at(3).strip

        raise "Invalid argument: id" if !@id || @id.empty?
        raise "Invalid argument: to_port" if !@to || @to.empty?
        raise "Invalid argument: action" if !@action || @action.empty?
        raise "Invalid argument: from_port" if !@from || @from.empty?
      end
    end
  end
end
