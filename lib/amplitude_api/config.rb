# frozen_string_literal: true

require "singleton"

class AmplitudeAPI
  # AmplitudeAPI::Config
  class Config
    include Singleton

    attr_accessor :api_key, :secret_key, :whitelist, :time_formatter,
                  :event_properties_formatter, :user_properties_formatter,
                  :options

    def initialize
      self.class.defaults.each { |k, v| send("#{k}=", v) }
    end

    class << self
      def base_properties
        %i[event_type event_properties user_properties user_id device_id]
      end

      def revenue_properties
        %i[revenue_type product_id revenue price quantity]
      end

      def optional_properties
        %i[
          time
          ip platform country insert_id
          groups app_version os_name os_version
          device_brand device_manufacturer device_model
          carrier region city dma language
          location_lat location_lng
          idfa idfv adid android_id
          event_id session_id
        ]
      end

      def defaults
        {
          api_key: nil,
          secret_key: nil,
          whitelist: base_properties + revenue_properties + optional_properties,
          time_formatter: ->(time) { time ? time.to_i * 1_000 : nil },
          event_properties_formatter: ->(props) { props || {} },
          user_properties_formatter: ->(props) { props || {} }
        }
      end
    end
  end
end
