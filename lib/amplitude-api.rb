require 'json'
require 'bundler/setup'
Bundler.require(:default)
require 'amplitude-api/event'

class AmplitudeAPI
  URI_STRING = "https://api.amplitude.com/httpapi"

  USER_WITH_NO_ACCOUNT = "user who doesn't have an account"

  class << self
    attr_accessor :api_key

    def send_event(event_name, user, properties = {})
      user_id = 
        if user.respond_to?(:id) 
          user.id
        else
           user || USER_WITH_NO_ACCOUNT
        end

      body = body(event_name, user_id, properties)
      Typhoeus.post(URI_STRING, body: body)
    end

    def body(event_type, user_id, event_properties)
      {
        api_key: self.api_key,
        event: JSON.generate({
          event_type: event_type,
          user_id: user_id,
          event_properties: event_properties
        })
      }
    end

    def track(*events)
      event_body = events.flatten.map do |event|
        event.to_hash
      end
      post_body = {
        api_key: self.api_key,
        event: JSON.generate(event_body)
      }

      Typhoeus.post(URI_STRING, body: post_body)
    end
  end
end
