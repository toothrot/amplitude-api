class AmplitudeAPI
  # AmplitudeAPI::Event
  class Event
    # @!attribute [ rw ] user_id
    #   @return [ String ] the user_id to be sent to Amplitude
    attr_accessor :user_id
    # @!attribute [ rw ] event_type
    #   @return [ String ] the event_type to be sent to Amplitude
    attr_accessor :event_type
    # @!attribute [ rw ] event_properties
    #   @return [ String ] the event_properties to be attached to the Amplitude Event
    attr_accessor :event_properties
    # @!attribute [ rw ] user_properties
    #   @return [ String ] the user_properties to be passed for the user
    attr_accessor :user_properties
    # @!attribute [ rw ] time
    #   @return [ Time ] Time that the event occurred (defaults to now)
    attr_accessor :time
    # @!attribute [ rw ] ip
    #   @return [ String ] IP address of the user
    attr_accessor :ip


    # @!attribute [ rw ] price
    #   @return [ String ] (required for revenue data) price of the item purchased
    attr_accessor :price

    # @!attribute [ rw ] quantity
    #   @return [ String ] (required for revenue data, defaults to 1 if not specified) quantity of the item purchased
    attr_accessor :quantity

    # @!attribute [ rw ] product_id
    #   @return [ String ] an identifier for the product. (Note: you must send a price and quantity with this field)
    attr_accessor :product_id

    # @!attribute [ rw ] revenue_type
    #   @return [ String ] type of revenue. (Note: you must send a price and quantity with this field)
    attr_accessor :revenue_type

    # Create a new Event
    #
    # @param [ String ] user_id a user_id to associate with the event
    # @param [ String ] event_type a name for the event
    # @param [ Hash ] event_properties various properties to attach to the event
    # @param [ Time ] Time that the event occurred (defaults to now)
    # @param [ Double ] price (optional, but required for revenue data) price of the item purchased
    # @param [ Integer ] quantity (optional, but required for revenue data) quantity of the item purchased
    # @param [ String ] product_id (optional) an identifier for the product.
    # @param [ String ] revenue_type (optional) type of revenue

    def initialize(options = {})
      self.user_id = options.fetch(:user_id, '')
      self.event_type = options.fetch(:event_type, '')
      self.event_properties = options.fetch(:event_properties, {})
      self.user_properties = options.fetch(:user_properties, {})
      self.time = options[:time]
      self.ip = options.fetch(:ip, '')

      self.price = options[:price]
      self.quantity = options[:quantity] || 1 if self.price
      self.product_id = options[:product_id]
      self.revenue_type = options[:revenue_type]
      validate_revenue_arguments
    end

    def user_id=(value)
      @user_id =
      if value.respond_to?(:id)
        value.id
      else
        value || AmplitudeAPI::USER_WITH_NO_ACCOUNT
      end
    end

    # @return [ Hash ] A serialized Event
    #
    # Used for serialization and comparison
    def to_hash
      serialized_event = {}
      serialized_event[:event_type] = event_type
      serialized_event[:user_id] = user_id
      serialized_event[:event_properties] = event_properties
      serialized_event[:user_properties] = user_properties
      serialized_event[:time] = formatted_time if time
      serialized_event[:ip] = ip if ip
      serialized_event[:productId] = product_id if product_id
      serialized_event[:revenueType] = revenue_type if revenue_type
      serialized_event[:quantity] = quantity if quantity
      serialized_event[:price] = price if price
      serialized_event
    end

    # @return [ true, false ]
    #
    # Compares +to_hash+ for equality
    def ==(other)
      if other.respond_to?(:to_hash)
        to_hash == other.to_hash
      else
        false
      end
    end

    private

    def formatted_time
      time.to_i * 1_000
    end

    def validate_revenue_arguments
      return if self.price
      raise ArgumentError.new("You must provide a price in order to use the product_id") if self.product_id
      raise ArgumentError.new("You must provide a price in order to use the revenue_type") if self.revenue_type
    end

  end

end
