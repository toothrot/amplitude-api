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
    # @!attribute [ rw ] time
    #   @return [ Time ] Time that the event occurred (defaults to now)
    attr_accessor :time

    # Create a new Event
    #
    # @param [ String ] user_id a user_id to associate with the event
    # @param [ String ] event_type a name for the event
    # @param [ Hash ] event_properties various properties to attach to the event
    # @param [ Time ] Time that the event occurred (defaults to now)
    def initialize(user_id: '', event_type: '', event_properties: {}, time: nil)
      self.user_id = user_id
      self.event_type = event_type
      self.event_properties = event_properties
      self.time = time
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
      serialized_event[:time] = formatted_time if time
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
  end
end
