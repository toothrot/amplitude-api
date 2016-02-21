require 'spec_helper'

describe AmplitudeAPI::Event do
  user = Struct.new(:id)

  context 'with a user object' do
    describe '#body' do
      it "populates with the user's id" do
        event = described_class.new(
          user_id: user.new(123),
          event_type: 'clicked on home'
        )
        expect(event.to_hash[:user_id]).to eq(123)
      end
    end
  end

  context 'with a user id' do
    describe '#body' do
      it "populates with the user's id" do
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home'
        )
        expect(event.to_hash[:user_id]).to eq(123)
      end
    end
  end

  context 'without a user' do
    describe '#body' do
      it 'populates with the unknown user' do
        event = described_class.new(
          user_id: nil,
          event_type: 'clicked on home'
        )
        expect(event.to_hash[:user_id]).to eq(AmplitudeAPI::USER_WITH_NO_ACCOUNT)
      end
    end
  end

  describe '#body' do
    it 'includes the event type' do
      event = described_class.new(
        user_id: 123,
        event_type: 'clicked on home'
      )
      expect(event.to_hash[:event_type]).to eq('clicked on home')
    end

    it 'includes arbitrary properties' do
      event = described_class.new(
        user_id: 123,
        event_type: 'clicked on home',
        event_properties: { abc: :def }
      )
      expect(event.to_hash[:event_properties]).to eq(abc: :def)
    end

    it 'includes a time for the event' do
      time = Time.parse('2016-01-01 00:00:00 -0000')
      event = described_class.new(
        user_id: 123,
        event_type: 'clicked on home',
        time: time
      )
      expect(event.to_hash[:time]).to eq(1_451_606_400_000)
    end

    it 'does not include time if it is not set' do
      event = described_class.new(
        user_id: 123,
        event_type: 'clicked on home'
      )
      expect(event.to_hash).not_to have_key(:time)
    end
  end
end
