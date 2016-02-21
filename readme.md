# Amplitude API
[![Build Status](https://travis-ci.org/toothrot/amplitude-api.svg?branch=master)](https://travis-ci.org/toothrot/amplitude-api)
[![Code Climate](https://codeclimate.com/github/toothrot/amplitude-api/badges/gpa.svg)](https://codeclimate.com/github/toothrot/amplitude-api)
[![Gem Version](https://badge.fury.io/rb/amplitude-api.svg)](http://badge.fury.io/rb/amplitude-api)

## Installation

```sh
gem install amplitude-api
```

## Basic Usage

The following code snippet will immediately track an event to the Amplitude API. The time on the event will automatically be the time of the request.

```ruby
# Configure your Amplitude API key
AmplitudeAPI.api_key = "abcdef123456"

event = AmplitudeAPI::Event.new({
  user_id: "123",
  event_type: "clicked on home",
  event_properties: {
    cause: "button",
    arbitrary: "properties"
  }
})
AmplitudeAPI.track(event)
```

Currently, we are using this in Rails and using ActiveJob to dispatch events asynchronously. I plan on moving background/asynchronous support into this gem.

## What's Next

* Thread support for background dispatching in bulk
* `device_id` support as an alternative to `user_id`
* Configurable default account to use when no `user_id` present

## Other useful resources
* [Amplitude HTTP Api Documentation](https://amplitude.zendesk.com/hc/en-us/articles/204771828)
* [Segment.io Amplitude integration](https://segment.com/docs/integrations/amplitude/)
 
## Contributing

I'd love to hear how you're using this. Please check out the [issues](https://github.com/toothrot/amplitude-api/issues).
