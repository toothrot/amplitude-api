# Amplitude API
[![Build Status](https://travis-ci.org/toothrot/amplitude-api.svg?branch=master)](https://travis-ci.org/toothrot/amplitude-api)
[![Code Climate](https://codeclimate.com/github/toothrot/amplitude-api/badges/gpa.svg)](https://codeclimate.com/github/toothrot/amplitude-api)
[![Gem Version](https://badge.fury.io/rb/amplitude-api.svg)](http://badge.fury.io/rb/amplitude-api)

## Installation

```sh
gem install amplitude-api
```

## Basic Usage

The following code snippet will immediately track an event to the Amplitude API.

```ruby
# Configure your Amplitude API key
AmplitudeAPI.config.api_key = "abcdef123456"


event = AmplitudeAPI::Event.new({
  user_id: "12345",
  event_type: "clicked on home",
  time: Time.now,
  insert_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
  event_properties: {
    cause: "button",
    arbitrary: "properties"
  }
})
AmplitudeAPI.track(event)
```

You can track multiple events with a single call, with the only limit of the payload
size imposed by Amplitude:

```ruby
event_1 = AmplitudeAPI::Event.new(...)
event_2 = AmplitudeAPI::Event.new(...)

AmplitudeAPI.track(event_1, event_2)
```

```ruby
events = [event_1, event_2]
AmplitudeAPI.track(*events)
```

In case you use an integer as the time, it is expected to be in seconds. Values in
the time field will be converted to milliseconds using `->(time) { time ? time.to_i * 1_000 : nil }`
You can change this behaviour and use your custom formatter. For example, in case
you wanted to use milliseconds instead of seconds you could do this:
```ruby
AmplitudeAPI.config.time_formatter = ->(time) { time ? time.to_i : nil },
```

You can speficy track options in the config. The options will be applied to all subsequent requests:

```ruby
AmplitudeAPI.config.options = { min_id_length: 10 }
AmplitudeAPI.track(event)
```


## User Privacy APIs

The following code snippet will delete a user from amplitude

```ruby
# Configure your Amplitude API key
AmplitudeAPI.config.api_key = "abcdef123456"

# Configure your Amplitude Secret Key
AmplitudeAPI.config.secret_key = "secretMcSecret"

AmplitudeAPI.delete(user_ids: ["12345"],
  requester: "privacy@example.com"
)
```

Currently, we are using this in Rails and using ActiveJob to dispatch events asynchronously. I plan on moving
background/asynchronous support into this gem.

## What's Next

* Thread support for background dispatching in bulk
* Configurable default account to use when no `user_id` present

## Other useful resources
* [Amplitude HTTP API V2 Api Documentation](https://developers.amplitude.com/docs/http-api-v2)
* [Segment.io Amplitude integration](https://segment.com/docs/integrations/amplitude/)

## Contributing

I'd love to hear how you're using this. Please check out the [issues](https://github.com/toothrot/amplitude-api/issues).
