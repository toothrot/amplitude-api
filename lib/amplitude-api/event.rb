class AmplitudeAPI
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

    # Create a new Event
    #
    # @param [ String ] user_id
    # @param [ String ] event_type
    # @param [ Hash ] event_properties
    def initialize(user_id: , event_type: , event_properties: {})
      self.user_id = user_id
      self.event_type = event_type
      self.event_properties = event_properties
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
      {
        event_type: self.event_type,
        user_id: self.user_id,
        event_properties: self.event_properties
      }
    end

    # @return [ true, false ]
    #
    # Compares +to_hash+ for equality
    def ==(other)
      if other.respond_to?(:to_hash)
        self.to_hash == other.to_hash
      else
        false
      end
    end
  end
end
