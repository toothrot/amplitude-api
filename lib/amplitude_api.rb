require 'json'
require 'bundler/setup'
require 'typhoeus'
require_relative 'amplitude_api/event'
require_relative 'amplitude_api/identification'

# AmplitudeAPI
class AmplitudeAPI
  TRACK_URI_STRING = 'https://api.amplitude.com/httpapi'.freeze
  IDENTIFY_URI_STRING = 'https://api.amplitude.com/identify'.freeze

  USER_WITH_NO_ACCOUNT = "user who doesn't have an account".freeze

  class << self
    # @!attribute [ rw ] api_key
    #   @return [ String ] an Amplitude API Key
    attr_accessor :api_key

    # ==== Event Tracking related methods

    # Send a single event immediately to the AmplitudeAPI
    #
    # @param [ String ] event_name a string that describes the event, e.g. "clicked on Home"
    # @param [ String ] user a string or integer that uniquely identifies a user.
    # @param [ Hash ] event_properties a hash that is serialized to JSON,
    # and can contain any other property to be stored on the Event
    # @param [ Hash ] user_properties a hash that is serialized to JSON,
    # and contains user properties to be associated with the user
    #
    # @return [ Typhoeus::Response ]
    def send_event(event_name, user, options = {})
      event = AmplitudeAPI::Event.new(
        user_id: user,
        event_type: event_name,
        event_properties: options.fetch(:event_properties, {}),
        user_properties: options.fetch(:user_properties, {})
      )
      track(event)
    end

    # @overload track_body(event)
    #   @param [ AmplitudeAPI::Event ]
    #
    # @overload track_body([events])
    #   @param [ Array<AmplitudeAPI::Event> ]
    #
    # @return [ Hash ]
    #
    # Converts a series of AmplitudeAPI::Event objects into a body
    # suitable for the Amplitude API
    def track_body(*events)
      event_body = events.flatten.map(&:to_hash)

      {
        api_key: api_key,
        event: JSON.generate(event_body)
      }
    end

    # @overload track(event)
    #   @param [ AmplitudeAPI::Event ] Send a single event to the Amplitude API
    #
    # @overload track([events])
    #   @param [ Array<AmplitudeAPI::Event> ] Send an array of events in a single request to Amplitude
    #
    # @return [ Typhoeus::Response ]
    #
    # Send one or more Events to the Amplitude API
    def track(*events)
      Typhoeus.post(TRACK_URI_STRING, body: track_body(events))
    end

    # ==== Identification related methods

    def send_identify(user_id, user_properties = {})
      identification = AmplitudeAPI::Identification.new(user_id: user_id, user_properties: user_properties)
      identify(identification)
    end

    # @overload identify_body(identification)
    #   @param [ AmplitudeAPI::Identification ]
    #
    # @overload identify_body([identifications])
    #   @param [ Array<AmplitudeAPI::Identification> ]
    #
    # @return [ Hash ]
    #
    # Converts a series of AmplitudeAPI::Identification objects into a body
    # suitable for the Amplitude Identify API
    def identify_body(*identifications)
      identification_body = identifications.flatten.map(&:to_hash)

      {
        api_key: api_key,
        identification: JSON.generate(identification_body)
      }
    end

    # @overload identify(identification)
    #   @param [ AmplitudeAPI::Identify ] Send a single identify to the Amplitude API
    #
    # @overload identify([identifications])
    #   @param [ Array<AmplitudeAPI::Identify> ] Send an array of identifications in a single request to Amplitude
    #
    # @return [ Typhoeus::Response ]
    #
    # Send one or more Identifications to the Amplitude Identify API
    def identify(*identifications)
      Typhoeus.post(IDENTIFY_URI_STRING, body: identify_body(identifications))
    end
  end
end
