# frozen_string_literal: true

# This class is 115 lines long. It's on the limit, it should be refactored before
# including more code.
#
# rubocop:disable Metrics/ClassLength
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
      @extra_properties = []
      attributes.each do |k, v|
        send("#{k}=", v)
      end
      validate_arguments
    end

    def method_missing(method_name, *args)
      super if block_given?
      super unless method_name.to_s.end_with? "="

      property_name = method_name.to_s.delete_suffix("=")

      @extra_properties << property_name

      create_setter property_name
      create_getter property_name

      send("#{property_name}=".to_sym, *args)
    end

    def create_setter(attribute_name)
      self.class.send(:define_method, "#{attribute_name}=".to_sym) do |value|
        instance_variable_set("@" + attribute_name.to_s, value)
      end
    end

    def create_getter(attribute_name)
      self.class.send(:define_method, attribute_name.to_sym) do
        instance_variable_get("@" + attribute_name.to_s)
      end
    end

    def respond_to_missing?(method_name, *args)
      @extra_properties.include?(method_name) || @extra_properties.include?("#{method_name}=") || super
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
      event.merge(optional_properties).merge(revenue_hash).merge(extra_properties)
    end
    alias to_h to_hash

    # @return [ Hash ] Optional properties
    #
    # Returns optional properties (belong to the API but are optional)
    def optional_properties
      AmplitudeAPI::Config.optional_properties.map do |prop|
        val = prop == :time ? formatted_time : send(prop)
        val ? [prop, val] : nil
      end.compact.to_h
    end

    # @return [ Hash ] Extra properties
    #
    # Returns optional properties (not belong to the API, are assigned by the user)
    # This way, if the API is updated with new properties, the gem will be able
    # to work with the new specification until the code is modified
    def extra_properties
      @extra_properties.map do |prop|
        val = send(prop)
        val ? [prop.to_sym, val] : nil
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
      return true if !revenue_type && !product_id
      return true if revenue || price

      raise ArgumentError, revenue_error_message
    end

    def revenue_error_message
      error_field = "product_id" if product_id
      error_field = "revenue_type" if revenue_type

      "You must provide a price or a revenue in order to use the field #{error_field}"
    end

    def revenue_hash
      revenue_hash = {}
      revenue_hash[:productId] = product_id if product_id
      revenue_hash[:revenueType] = revenue_type if revenue_type
      revenue_hash[:quantity] = quantity if quantity
      revenue_hash[:price] = price if price
      revenue_hash[:revenue] = revenue if revenue
      revenue_hash
    end

    def getopt(options, key, default = nil)
      options.fetch(key.to_sym, options.fetch(key.to_s, default))
    end
  end
end
# rubocop:enable Metrics/ClassLength
