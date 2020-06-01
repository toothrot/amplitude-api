# frozen_string_literal: true

require 'json'
require 'typhoeus'

# AmplitudeAPI
class AmplitudeAPI
  require_relative 'amplitude_api/config'
  require_relative 'amplitude_api/event'
  require_relative 'amplitude_api/identification'

  TRACK_URI_STRING        = 'https://api2.amplitude.com/2/httpapi'
  IDENTIFY_URI_STRING     = 'https://api.amplitude.com/identify'
  SEGMENTATION_URI_STRING = 'https://amplitude.com/api/2/events/segmentation'
  DELETION_URI_STRING     = 'https://amplitude.com/api/2/deletions/users'

  USER_WITH_NO_ACCOUNT = "user who doesn't have an account"

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
    # @option options [ Hash ] event_properties a hash that is serialized to JSON,
    # and can contain any other property to be stored on the Event
    # @option options [ Hash ] user_properties a hash that is serialized to JSON,
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

      JSON.generate(
        api_key: api_key,
        events: event_body,
        options: { min_id_length: 1 }
      )
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
      Typhoeus.post(TRACK_URI_STRING, headers: { 'Content-Type' => 'application/json' }, body: track_body(events))
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
    # @param [ Hash ] event a hash that defines event.
    # @param [ Time ] start_time a start time.
    # @param [ Time ] end_time a end time.
    # @option options [ String ] m a string that defines aggregate function.
    # For non-property metrics: "uniques", "totals", "pct_dau", or "average" (default: "uniques").
    # For property metrics: "histogram", "sums", or "value_avg"
    # (note: a valid "group_by" value is required in parameter e).
    # @option options [ Integer ] i an integer that defines segmentation interval.
    # Set to -300000, -3600000, 1, 7, or 30 for realtime, hourly, daily, weekly,
    # and monthly counts, respectively (default: 1). Realtime segmentation is capped at 2 days,
    # hourly segmentation is capped at 7 days, and daily at 365 days.
    # @option options [ Array ] s an array that defines segment definitions.
    # @option options [ String ] g a string that defines property to group by.
    # @option options [ Integer ] limit an integer that defines number of Group By values
    # returned (default: 100). The maximum limit is 1000.
    #
    # @return [ Typhoeus::Response ]
    def segmentation(event, start_time, end_time, **options)
      Typhoeus.get SEGMENTATION_URI_STRING, userpwd: "#{api_key}:#{secret_key}", params: {
        e: event.to_json,
        m: options[:m],
        start: start_time.strftime('%Y%m%d'),
        end: end_time.strftime('%Y%m%d'),
        i: options[:i],
        s: (options[:s] || []).map(&:to_json),
        g: options[:g],
        limit: options[:limit]
      }.delete_if { |_, value| value.nil? }
    end

    # Delete a user from amplitude
    #
    # You must pass in either an array of user_ids or an array of amplitude_ids
    #
    # @param [ Array<String> ] (optional) the user_ids to delete
    # based on your database
    # @param [ Array<Integer> ] (optional) the amplitude_ids to delete
    # based on the amplitude database
    # @param [ String ] requester the email address of the person who
    # is requesting the deletion, optional but useful for reporting
    #
    # @return [ Typhoeus::Response ]
    def delete(user_ids: nil, amplitude_ids: nil, requester: nil)
      user_ids = Array(user_ids)
      amplitude_ids = Array(amplitude_ids)
      Typhoeus.post(
        DELETION_URI_STRING,
        userpwd: "#{api_key}:#{config.secret_key}",
        body: delete_body(user_ids, amplitude_ids, requester),
        headers: { 'Content-Type' => 'application/json' }
      )
    end

    private

    def delete_body(user_ids, amplitude_ids, requester)
      JSON.generate(
        {
          amplitude_ids: amplitude_ids,
          user_ids: user_ids,
          requester: requester
        }.delete_if { |_, value| value.nil? || value.empty? }
      )
    end
  end
end
