require 'spec_helper'

describe AmplitudeAPI::Event do
  User = Struct.new(:id)

  context "with a user object" do
    describe "#body" do
      it "populates with the user's id" do
        event = AmplitudeAPI::Event.new(user_id: User.new(123), event_type: 'clicked on home')
        expect(event.to_hash[:user_id]).to eq(123)
      end
    end
  end

  context "with a user id" do
    describe "#body" do
      it "populates with the user's id" do
        event = AmplitudeAPI::Event.new(user_id: 123, event_type: 'clicked on home')
        expect(event.to_hash[:user_id]).to eq(123)
      end
    end
  end

  context "without a user" do
    describe "#body" do
      it "populates with the unknown user" do
        event = AmplitudeAPI::Event.new(user_id: nil, event_type: 'clicked on home')
        expect(event.to_hash[:user_id]).to eq(AmplitudeAPI::USER_WITH_NO_ACCOUNT)
      end
    end
  end

  describe '#body' do
    it "includes the event type" do
      event = AmplitudeAPI::Event.new(user_id: 123, event_type: 'clicked on home')
      expect(event.to_hash[:event_type]).to eq('clicked on home')
    end

    it "includes arbitrary properties" do
      event = AmplitudeAPI::Event.new(user_id: 123, event_type: 'clicked on home', event_properties: {abc: :def})
      expect(event.to_hash[:event_properties]).to eq(abc: :def)
    end
  end
end
