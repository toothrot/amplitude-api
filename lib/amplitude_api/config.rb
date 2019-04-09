require 'singleton'

class AmplitudeAPI
  # AmplitudeAPI::Config
  class Config
    include Singleton

    attr_accessor :api_key, :secret_key, :whitelist, :time_formatter,
                  :event_properties_formatter, :user_properties_formatter,
                  :timeout, :connecttimeout

    def initialize
      self.class.defaults.each { |k, v| send("#{k}=", v) }
    end

    class << self
      def defaults
        {
          api_key: nil,
          secret_key: nil,
          whitelist: %i[user_id device_id event_type time
                        event_properties user_properties time ip platform country insert_id
                        revenue_type price quantity product_id],
          time_formatter: ->(time) { time ? time.to_i * 1_000 : nil },
          event_properties_formatter: ->(props) { props || {} },
          user_properties_formatter: ->(props) { props || {} },
          timeout: 0,
          connecttimeout: 0
        }
      end
    end
  end
end
