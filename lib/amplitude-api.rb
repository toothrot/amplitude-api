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
      event = AmplitudeAPI::Event.new(user_id: user, event_type: event_name, event_properties: properties)
      track(event)
    end

    def body(*events)
      event_body = events.flatten.map do |event|
        event.to_hash
      end
      post_body = {
        api_key: self.api_key,
        event: JSON.generate(event_body)
      }
    end

    def track(*events)
      Typhoeus.post(URI_STRING, body: body(events))
    end
  end
end
