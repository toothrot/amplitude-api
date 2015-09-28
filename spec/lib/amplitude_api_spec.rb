require 'spec_helper'

describe AmplitudeAPI do
  before do
    @user = Struct.new(:id).new(123)
  end

  describe ".track" do
    context "with a single event" do
      it "sends the event to Amplitude" do
        event = AmplitudeAPI::Event.new(user_id: 123, event_type: 'clicked on sign up')
        body = {api_key: AmplitudeAPI.api_key, event: JSON.generate([event.to_hash])}

        expect(Typhoeus).to receive(:post).with(AmplitudeAPI::URI_STRING, body: body)

        AmplitudeAPI.track(event)
      end
    end

    context "with multiple events" do
      it "sends all events in a single request" do
        event = AmplitudeAPI::Event.new(user_id: 123, event_type: 'clicked on sign up')
        event2 = AmplitudeAPI::Event.new(user_id: 456, event_type: 'liked a widget')
        body = {api_key: AmplitudeAPI.api_key, event: JSON.generate([event.to_hash, event2.to_hash])}

        expect(Typhoeus).to receive(:post).with(AmplitudeAPI::URI_STRING, body: body)

        AmplitudeAPI.track([event, event2])
      end
    end
  end

  describe ".initializer " do
    it "initializes event without parameter" do
      event = AmplitudeAPI::Event.new()
      expect(event.to_hash).to eq({
        event_type: "",
        user_id: "",
        event_properties: {}
      })
    end

    it "initializes event with parameter" do
      event = AmplitudeAPI::Event.new(user_id: 123, event_type: "test_event", event_properties: {test_property: 1})
      expect(event.to_hash).to eq({
        event_type: "test_event",
        user_id: 123,
        event_properties: {test_property: 1}
      })
    end
  end

  describe ".send_event" do
    it "sends an event to AmplitudeAPI" do
      event = AmplitudeAPI::Event.new(user_id: @user, event_type: "test_event", event_properties: {test_property: 1})
      expect(AmplitudeAPI).to receive(:track).with(event)

      AmplitudeAPI.send_event("test_event", @user, test_property: 1)
    end

    context "the user is nil" do
      it "sends an event with the no account user" do
        event = AmplitudeAPI::Event.new(user_id: nil, event_type: "test_event", event_properties: {test_property: 1})
        expect(AmplitudeAPI).to receive(:track).with(event)

        AmplitudeAPI.send_event("test_event", nil, test_property: 1)
      end
    end

    context "the user is a user_id" do
      it "sends an event to AmplitudeAPI" do
        event = AmplitudeAPI::Event.new(user_id: 123, event_type: "test_event", event_properties: {test_property: 1})
        expect(AmplitudeAPI).to receive(:track).with(event)

        AmplitudeAPI.send_event("test_event", @user.id, test_property: 1)
      end
    end
  end

  describe "#body" do
    it "should add an api key" do
      event = AmplitudeAPI::Event.new(user_id: @user, event_type: "test_event", event_properties: {test_property: 1})
      body = AmplitudeAPI.body(event)
      expect(body[:api_key]).to eq('stub api key')
    end

    it "should create an event" do
      event = AmplitudeAPI::Event.new(user_id: 23, event_type: "test_event", event_properties: {foo: "bar"})
      body = AmplitudeAPI.body(event)

      expected = JSON.generate([{event_type: "test_event", user_id: 23, event_properties: {foo: "bar"}}])
      expect(body[:event]).to eq(expected)
    end
  end
end
