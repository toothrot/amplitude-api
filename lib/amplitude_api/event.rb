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

    # @!attribute [ rw ] insert_id
    #   @return [ String ] the unique identifier to be sent to Amplitude
    attr_accessor :insert_id

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
    # @param [ String ] IP address of the user
    # @param [ String ] insert_id a unique identifier for the event
    def initialize(attributes = {})
      self.user_id = getopt(attributes, :user_id, '')
      self.event_type = getopt(attributes, :event_type, '')
      self.event_properties = getopt(attributes, :event_properties, {})
      self.user_properties = getopt(attributes, :user_properties, {})
      self.time = getopt(attributes, :time)
      self.ip = getopt(attributes, :ip, '')
      self.insert_id = getopt(attributes, :insert_id)
      validate_revenue_arguments(attributes)
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
      serialized_event[:insert_id] = insert_id if insert_id

      serialized_event.merge(revenue_hash)
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

    def validate_revenue_arguments(options)
      self.price = getopt(options, :price)
      self.quantity = getopt(options, :quantity, 1) if price
      self.product_id = getopt(options, :product_id)
      self.revenue_type = getopt(options, :revenue_type)
      return if price
      raise ArgumentError, 'You must provide a price in order to use the product_id' if product_id
      raise ArgumentError, 'You must provide a price in order to use the revenue_type' if revenue_type
    end

    def revenue_hash
      revenue_hash = {}
      revenue_hash[:productId] = product_id if product_id
      revenue_hash[:revenueType] = revenue_type if revenue_type
      revenue_hash[:quantity] = quantity if quantity
      revenue_hash[:price] = price if price
      revenue_hash
    end

    def getopt(options, key, default = nil)
      options.fetch(key.to_sym, options.fetch(key.to_s, default))
    end
  end
end
