require 'spec_helper'

describe AmplitudeAPI do
  User = Struct.new(:id)

  before do
    @user = User.new(id: 123)
  end

  describe ".send_event" do
    it "sends an event to AmplitudeAPI" do
      body = AmplitudeAPI.body("test_event", @user.id, test_property: 1)
      expect(Typhoeus).to receive(:post).with(AmplitudeAPI::URI_STRING, body: body)

      AmplitudeAPI.send_event("test_event", @user, test_property: 1)
    end

    context "the user is nil" do
      it "sends an event with the no account user" do
        body = AmplitudeAPI.body("test_event", AmplitudeAPI::USER_WITH_NO_ACCOUNT, test_property: 1)
        expect(Typhoeus).to receive(:post).with(AmplitudeAPI::URI_STRING, body: body)

        AmplitudeAPI.send_event("test_event", nil, test_property: 1)
      end
    end

    context "the user is a user_id" do
      it "sends an event to AmplitudeAPI" do
        body = AmplitudeAPI.body("test_event", @user.id, test_property: 1)
        expect(Typhoeus).to receive(:post).with(AmplitudeAPI::URI_STRING, body: body)

        AmplitudeAPI.send_event("test_event", @user.id, test_property: 1)
      end
    end
  end

  describe "#body" do
    it "should add an api key" do
      body = AmplitudeAPI.body("test_event", "user_id", {foo: "bar"})
      expect(body[:api_key]).to eq('stub api key')
    end

    it "should create an event" do
      body = AmplitudeAPI.body("test_event", 23, {foo: "bar"})
      expected = JSON.generate({event_type: "test_event", user_id: 23, event_properties: {foo: "bar"}})
      expect(body[:event]).to eq(expected)
    end
  end
end
