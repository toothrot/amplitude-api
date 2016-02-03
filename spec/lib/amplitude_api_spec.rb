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

        expect(Typhoeus).to receive(:post).with(AmplitudeAPI::TRACK_URI_STRING, body: body)

        AmplitudeAPI.track(event)
      end
    end

    context "with multiple events" do
      it "sends all events in a single request" do
        event = AmplitudeAPI::Event.new(user_id: 123, event_type: 'clicked on sign up')
        event2 = AmplitudeAPI::Event.new(user_id: 456, event_type: 'liked a widget')
        body = {api_key: AmplitudeAPI.api_key, event: JSON.generate([event.to_hash, event2.to_hash])}

        expect(Typhoeus).to receive(:post).with(AmplitudeAPI::TRACK_URI_STRING, body: body)

        AmplitudeAPI.track([event, event2])
      end
    end
  end

  describe ".identify" do
    context "with a single identification" do
      it "sends the identification to Amplitude" do
        identification = AmplitudeAPI::Identification.new(user_id: 123, user_properties: {first_name: 'John', last_name: 'Doe'})
        body = {api_key: AmplitudeAPI.api_key, identification: JSON.generate([identification.to_hash])}

        expect(Typhoeus).to receive(:post).with(AmplitudeAPI::IDENTIFY_URI_STRING, body: body)

        AmplitudeAPI.identify(identification)
      end
    end

    context "with multiple identifications" do
      it "sends all identifications in a single request" do
        identification = AmplitudeAPI::Identification.new(user_id: 123, user_properties: {first_name: 'Julian', last_name: 'Ponce'})
        identification2 = AmplitudeAPI::Identification.new(user_id: 456, user_properties: {first_name: 'John', last_name: 'Doe'})
        body = {api_key: AmplitudeAPI.api_key, identification: JSON.generate([identification.to_hash, identification2.to_hash])}

        expect(Typhoeus).to receive(:post).with(AmplitudeAPI::IDENTIFY_URI_STRING, body: body)

        AmplitudeAPI.identify([identification, identification2])
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

  describe ".send_identify" do
    it "sends an identify to AmplitudeAPI" do
      identification = AmplitudeAPI::Identification.new(user_id: @user, user_properties: {first_name: 'John', last_name: 'Doe'})
      expect(AmplitudeAPI).to receive(:identify).with(identification)

      AmplitudeAPI.send_identify(@user, {first_name: 'John', last_name: 'Doe'})
    end

    context "the user is nil" do
      it "sends an identify with the no account user" do
        identification = AmplitudeAPI::Identification.new(user_id: nil, user_properties: {first_name: 'John', last_name: 'Doe'})
        expect(AmplitudeAPI).to receive(:identify).with(identification)

        AmplitudeAPI.send_identify(nil, {first_name: 'John', last_name: 'Doe'})
      end
    end

    context "the user is a user_id" do
      it "sends an identify to AmplitudeAPI" do
        identification = AmplitudeAPI::Identification.new(user_id: 123, user_properties: {first_name: 'John', last_name: 'Doe'})
        expect(AmplitudeAPI).to receive(:identify).with(identification)

        AmplitudeAPI.send_identify(@user.id, {first_name: 'John', last_name: 'Doe'})
      end
    end
  end

  describe "#body" do
    it "should add an api key" do
      event = AmplitudeAPI::Event.new(user_id: @user, event_type: "test_event", event_properties: {test_property: 1})
      body = AmplitudeAPI.track_body(event)
      expect(body[:api_key]).to eq('stub api key')
    end

    it "should create an event" do
      event = AmplitudeAPI::Event.new(user_id: 23, event_type: "test_event", event_properties: {foo: "bar"})
      body = AmplitudeAPI.track_body(event)

      expected = JSON.generate([{event_type: "test_event", user_id: 23, event_properties: {foo: "bar"}}])
      expect(body[:event]).to eq(expected)
    end
  end
end
