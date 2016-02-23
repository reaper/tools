module Ufw
  class Item
    attr_accessor :id, :to_port, :action, :from_port
    def initialize args
      raise "Unsupported ufw item: invalid number of arguments" if args.size != 4

      @id = args.at(0)
      @to_port = args.at(1)
      @action = args.at(2)
      @from_port = args.at(3)

      raise "Invalid argument: id" if !@id || @id.empty?
      raise "Invalid argument: to_port" if !@to_port || @to_port.empty?
      raise "Invalid argument: action" if !@action || @action.empty?
      raise "Invalid argument: from_port" if !@from_port || @from_port.empty?
    end
  end
end
