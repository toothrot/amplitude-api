# Amplitude API
[![Build Status](https://travis-ci.org/toothrot/amplitude-api.svg?branch=master)](https://travis-ci.org/toothrot/amplitude-api)
[![Gem Version](https://badge.fury.io/rb/amplitude-api.svg)](http://badge.fury.io/rb/amplitude-api)

## Installation

```sh
gem install amplitude-api
```

## Basic Usage

```ruby
# Configure your Amplitude API key
AmplitudeAPI.api_key = "abcdef123456"

event = AmplitudeAPI::Event.new({
  user_id: "123",
  event_type: "clicked on Home",
  event_properties: {
    cause: "button",
    arbitrary: "properties"
  }
})
AmplitudeAPI.track(event)
```
