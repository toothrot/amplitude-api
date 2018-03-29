require 'json'
require 'bundler/setup'
require 'typhoeus'

# AmplitudeAPI
class AmplitudeAPI
  require_relative 'amplitude_api/config'
  require_relative 'amplitude_api/event'
  require_relative 'amplitude_api/identification'

  TRACK_URI_STRING        = 'https://api.amplitude.com/httpapi'.freeze
  IDENTIFY_URI_STRING     = 'https://api.amplitude.com/identify'.freeze
  SEGMENTATION_URI_STRING = 'https://amplitude.com/api/2/events/segmentation'.freeze

  USER_WITH_NO_ACCOUNT = "user who doesn't have an account".freeze

  class << self
    def config
      Config.instance
    end

    def configure
      yield config
    end

    def api_key
      config.api_key
    end

    def secret_key
      config.secret_key
    end

    # ==== Event Tracking related methods

    # Send a single event immediately to the AmplitudeAPI
    #
    # @param [ String ] event_name a string that describes the event, e.g. "clicked on Home"
    # @param [ String ] user a string or integer that uniquely identifies a user.
    # @param [ String ] device a string that uniquely identifies the device.
    # @param [ Hash ] event_properties a hash that is serialized to JSON,
    # and can contain any other property to be stored on the Event
    # @param [ Hash ] user_properties a hash that is serialized to JSON,
    # and contains user properties to be associated with the user
    #
    # @return [ Typhoeus::Response ]
    def send_event(event_name, user, device, options = {})
      event = AmplitudeAPI::Event.new(
        user_id: user,
        device_id: device,
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

    def send_identify(user_id, device_id, user_properties = {})
      identification = AmplitudeAPI::Identification.new(
        user_id: user_id,
        device_id: device_id,
        user_properties: user_properties
      )
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

    # ==== Event Segmentation related methods

    # Get metrics for an event with segmentation.
    #
    # @param [ Hash ] e a hash that defines event.
    # @param [ Time ] start_time a start time.
    # @param [ Time ] end_time a end time.
    # @param [ String ] m a string that defines aggregate function.
    # For non-property metrics: "uniques", "totals", "pct_dau", or "average" (default: "uniques").
    # For property metrics: "histogram", "sums", or "value_avg"
    # (note: a valid "group_by" value is required in parameter e).
    # @param [ Integer ] i an integer that defines segmentation interval.
    # Set to -300000, -3600000, 1, 7, or 30 for realtime, hourly, daily, weekly,
    # and monthly counts, respectively (default: 1). Realtime segmentation is capped at 2 days,
    # hourly segmentation is capped at 7 days, and daily at 365 days.
    # @param [ Array ] s an array that defines segment definitions.
    # @param [ String ] g a string that defines property to group by.
    # @param [ Integer ] limit an integer that defines number of Group By values
    # returned (default: 100). The maximum limit is 1000.
    #
    # @return [ Typhoeus::Response ]
    def segmentation(e, start_time, end_time, **options)
      Typhoeus.get SEGMENTATION_URI_STRING, userpwd: "#{api_key}:#{secret_key}", params: {
        e:     e.to_json,
        m:     options[:m],
        start: start_time.strftime('%Y%m%d'),
        end:   end_time.strftime('%Y%m%d'),
        i:     options[:i],
        s:     (options[:s] || []).map(&:to_json),
        g:     options[:g],
        limit: options[:limit]
      }.delete_if { |_, value| value.nil? }
    end
  end
end
