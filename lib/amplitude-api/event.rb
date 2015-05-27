class AmplitudeAPI
  class Event
    attr_accessor :user_id, :event_type, :event_properties

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

    def to_hash
      {
        event_type: self.event_type,
        user_id: self.user_id,
        event_properties: self.event_properties
      }
    end

    def ==(other)
      if other.respond_to?(:to_hash)
        self.to_hash == other.to_hash
      else
        false
      end
    end
  end
end
