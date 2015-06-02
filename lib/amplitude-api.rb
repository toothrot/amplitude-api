require 'json'
require 'bundler/setup'
Bundler.require(:default)
require 'amplitude-api/event'

class AmplitudeAPI
  URI_STRING = "https://api.amplitude.com/httpapi"

  USER_WITH_NO_ACCOUNT = "user who doesn't have an account"

  class << self
    # @!attribute [ rw ] api_key
    #   @return [ String ] an Amplitude API Key
    attr_accessor :api_key

    # Send a single event immediately to the AmplitudeAPI
    #
    # @param [ String ] event_name a string that describes the event, e.g. "clicked on Home"
    # @param [ String ] user a string or integer that uniquely identifies a user.
    # @param [ Hash ] properties a hash that is serialized to JSON, and can contain any other property to be stored on the Event
    #
    # @return [ Typhoeus::Response ]
    def send_event(event_name, user, properties = {})
      event = AmplitudeAPI::Event.new(user_id: user, event_type: event_name, event_properties: properties)
      track(event)
    end

    # @overload body(event)
    #   @param [ AmplitudeAPI::Event ]
    #
    # @overload body([events])
    #   @param [ Array<AmplitudeAPI::Event> ]
    #
    # @return [ Hash ]
    #
    # Converts a series of AmplitudeAPI::Event objects into a body
    # suitable for the Amplitude API
    def body(*events)
      event_body = events.flatten.map do |event|
        event.to_hash
      end
      post_body = {
        api_key: self.api_key,
        event: JSON.generate(event_body)
      }
    end

    # @overload body(event)
    #   @param [ AmplitudeAPI::Event ] Send a single event to the Amplitude API
    #
    # @overload body([events])
    #   @param [ Array<AmplitudeAPI::Event> ] Send an array of events in a single request to Amplitude
    #
    # @return [ Typhoeus::Response ] 
    #
    # Send one or more Events to the Amplitude API
    def track(*events)
      Typhoeus.post(URI_STRING, body: body(events))
    end
  end
end
