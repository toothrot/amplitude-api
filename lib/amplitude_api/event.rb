# frozen_string_literal: true

class AmplitudeAPI
  # AmplitudeAPI::Event
  class Event
    AmplitudeAPI::Config.instance.whitelist.each do |attribute|
      instance_eval("attr_accessor :#{attribute}", __FILE__, __LINE__)
    end

    # Create a new Event
    #
    # See (Amplitude HTTP API Documentation)[https://developers.amplitude.com/docs/http-api-v2]
    # for a list of valid parameters and their types.
    def initialize(attributes = {})
      attributes.each do |k, v|
        send("#{k}=", v) if respond_to?("#{k}=")
      end
      validate_arguments
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
      event = {
        event_type: event_type,
        event_properties: formatted_event_properties,
        user_properties: formatted_user_properties
      }
      event[:user_id] = user_id if user_id
      event[:device_id] = device_id if device_id
      event.merge(optional_properties).merge(revenue_hash)
    end
    alias to_h to_hash

    # @return [ Hash ] Optional properties
    def optional_properties
      %i[device_id time ip platform country insert_id].map do |prop|
        val = prop == :time ? formatted_time : send(prop)
        val ? [prop, val] : nil
      end.compact.to_h
    end

    # @return [ true, false ]
    #
    # Returns true if the event type matches one reserved by Amplitude API.
    def reserved_event?(type)
      ["[Amplitude] Start Session",
       "[Amplitude] End Session",
       "[Amplitude] Revenue",
       "[Amplitude] Revenue (Verified)",
       "[Amplitude] Revenue (Unverified)",
       "[Amplitude] Merged User"].include?(type)
    end

    # @return [ true, false ]
    #
    # Compares +to_hash+ for equality
    def ==(other)
      return false unless other.respond_to?(:to_h)

      to_h == other.to_h
    end

    private

    def formatted_time
      Config.instance.time_formatter.call(time)
    end

    def formatted_event_properties
      Config.instance.event_properties_formatter.call(event_properties)
    end

    def formatted_user_properties
      Config.instance.user_properties_formatter.call(user_properties)
    end

    def validate_arguments
      validate_required_arguments
      validate_revenue_arguments
    end

    def validate_required_arguments
      raise ArgumentError, "You must provide user_id or device_id (or both)" unless user_id || device_id
      raise ArgumentError, "You must provide event_type" unless event_type
      raise ArgumentError, "Invalid event_type - cannot match a reserved event name" if reserved_event?(event_type)
    end

    def validate_revenue_arguments
      return self.quantity ||= 1 if price
      raise ArgumentError, "You must provide a price in order to use the product_id" if product_id
      raise ArgumentError, "You must provide a price in order to use the revenue_type" if revenue_type
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
