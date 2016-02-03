class AmplitudeAPI
  class Identification
    # @!attribute [ rw ] user_id
    #   @return [ String ] the user_id to be sent to Amplitude
    attr_accessor :user_id
    # @!attribute [ rw ] user_properties
    #   @return [ String ] the user_properties to be attached to the Amplitude Identify
    attr_accessor :user_properties

    # Create a new Identification
    #
    # @param [ String ] user_id a user_id to associate with the identification
    # @param [ Hash ] user_properties various properties to attach to the user identification
    def initialize(user_id: "", user_properties: {})
      self.user_id = user_id
      self.user_properties = user_properties
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
        user_id: self.user_id,
        user_properties: self.user_properties
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
