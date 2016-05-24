module Humidifier

  # The payload sent to the shim methods, representing the stack and the options
  class SdkPayload

    # The maximum amount of time that Humidifier should wait for a stack to complete a CRUD operation
    MAX_WAIT = 180

    attr_accessor :stack, :options, :max_wait

    extend Forwardable
    def_delegators :stack, :id=, :identifier, :name, :to_cf

    # Store the given options
    def initialize(stack, options)
      self.stack    = stack
      self.options  = options
      self.max_wait = options.delete(:max_wait) || MAX_WAIT
    end

    # True if the stack and options are the same as the other (used for testing)
    def ==(other)
      stack == other.stack && options == other.options
    end
  end
end
