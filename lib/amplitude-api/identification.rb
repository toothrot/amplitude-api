class AmplitudeAPI
  class Identification
    def initialize(user_id: "", user_properties: {})
      self.user_id = user_id
      self.user_properties = user_properties
    end

    def to_hash
      {
        user_id: self.user_id,
        user_properties: self.user_properties
      }
    end
  end
end
