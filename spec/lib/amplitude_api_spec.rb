require 'spec_helper'

describe AmplitudeAPI do
  let(:user) { Struct.new(:id).new(123) }

  describe '.track' do
    context 'with a single event' do
      it 'sends the event to Amplitude' do
        event = AmplitudeAPI::Event.new(
          user_id: 123,
          event_type: 'clicked on sign up'
        )
        body = {
          api_key: described_class.api_key,
          event: JSON.generate([event.to_hash])
        }

        expect(Typhoeus).to receive(:post).with(AmplitudeAPI::TRACK_URI_STRING, body: body)

        described_class.track(event)
      end
    end

    context 'with multiple events' do
      it 'sends all events in a single request' do
        event = AmplitudeAPI::Event.new(
          user_id: 123,
          event_type: 'clicked on sign up'
        )
        event2 = AmplitudeAPI::Event.new(
          user_id: 456,
          event_type: 'liked a widget'
        )
        body = {
          api_key: described_class.api_key,
          event: JSON.generate([event.to_hash, event2.to_hash])
        }

        expect(Typhoeus).to receive(:post).with(AmplitudeAPI::TRACK_URI_STRING, body: body)

        described_class.track([event, event2])
      end
    end
  end

  describe '.identify' do
    context 'with a single identification' do
      it 'sends the identification to Amplitude' do
        identification = AmplitudeAPI::Identification.new(
          user_id: 123,
          user_properties: {
            first_name: 'John',
            last_name: 'Doe'
          }
        )
        body = {
          api_key: described_class.api_key,
          identification: JSON.generate([identification.to_hash])
        }

        expect(Typhoeus).to receive(:post).with(AmplitudeAPI::IDENTIFY_URI_STRING, body: body)

        described_class.identify(identification)
      end
    end

    context 'with multiple identifications' do
      it 'sends all identifications in a single request' do
        identification = AmplitudeAPI::Identification.new(
          user_id: 123,
          user_properties: {
            first_name: 'Julian',
            last_name: 'Ponce'
          }
        )
        identification2 = AmplitudeAPI::Identification.new(
          user_id: 456,
          user_properties: {
            first_name: 'John',
            last_name: 'Doe'
          }
        )
        body = {
          api_key: described_class.api_key,
          identification: JSON.generate([identification.to_hash, identification2.to_hash])
        }

        expect(Typhoeus).to receive(:post).with(AmplitudeAPI::IDENTIFY_URI_STRING, body: body)

        described_class.identify([identification, identification2])
      end
    end
  end

  describe '.initializer ' do
    it 'initializes event without parameter' do
      event = AmplitudeAPI::Event.new
      expect(event.to_hash).to eq(
        event_type: '',
        user_id: '',
        event_properties: {},
        user_properties: {},
        ip: ''
      )
    end

    it 'initializes event with parameter' do
      event = AmplitudeAPI::Event.new(
        user_id: 123,
        event_type: 'test_event',
        event_properties: {
          test_property: 1
        },
        ip: '8.8.8.8'
      )
      expect(event.to_hash).to eq(
        event_type: 'test_event',
        user_id: 123,
        event_properties: { test_property: 1 },
        user_properties: {},
        ip: '8.8.8.8'
      )
    end
  end

  describe '.send_event' do
    it 'sends an event to AmplitudeAPI' do
      event = AmplitudeAPI::Event.new(
        user_id: user,
        event_type: 'test_event',
        event_properties: { test_property: 1 }
      )
      expect(described_class).to receive(:track).with(event)

      described_class.send_event('test_event', user, event_properties: { test_property: 1 })
    end

    context 'the user is nil' do
      it 'sends an event with the no account user' do
        event = AmplitudeAPI::Event.new(
          user_id: nil,
          event_type: 'test_event',
          event_properties: { test_property: 1 }
        )
        expect(described_class).to receive(:track).with(event)

        described_class.send_event('test_event', nil, event_properties: { test_property: 1 })
      end
    end

    context 'the user is a user_id' do
      it 'sends an event to AmplitudeAPI' do
        event = AmplitudeAPI::Event.new(
          user_id: 123,
          event_type: 'test_event',
          event_properties: { test_property: 1 }
        )
        expect(described_class).to receive(:track).with(event)

        described_class.send_event('test_event', user.id, event_properties: { test_property: 1 })
      end

      it 'sends arbitrary user_properties to AmplitudeAPI' do
        event = AmplitudeAPI::Event.new(
          user_id: 123,
          event_type: 'test_event',
          event_properties: { test_property: 1 },
          user_properties: { test_user_property: 'abc' }
        )
        expect(described_class).to receive(:track).with(event)

        described_class.send_event(
          'test_event',
          user.id,
          event_properties: { test_property: 1 },
          user_properties: { test_user_property: 'abc' }
        )
      end
    end
  end

  describe '.send_identify' do
    it 'sends an identify to AmplitudeAPI' do
      identification = AmplitudeAPI::Identification.new(
        user_id: user,
        user_properties: {
          first_name: 'John',
          last_name: 'Doe'
        }
      )
      expect(described_class).to receive(:identify).with(identification)

      described_class.send_identify(user, first_name: 'John', last_name: 'Doe')
    end

    context 'the user is nil' do
      it 'sends an identify with the no account user' do
        identification = AmplitudeAPI::Identification.new(
          user_id: nil,
          user_properties: {
            first_name: 'John',
            last_name: 'Doe'
          }
        )
        expect(described_class).to receive(:identify).with(identification)

        described_class.send_identify(nil, first_name: 'John', last_name: 'Doe')
      end
    end

    context 'the user is a user_id' do
      it 'sends an identify to AmplitudeAPI' do
        identification = AmplitudeAPI::Identification.new(
          user_id: 123,
          user_properties: {
            first_name: 'John',
            last_name: 'Doe'
          }
        )
        expect(described_class).to receive(:identify).with(identification)

        described_class.send_identify(user.id, first_name: 'John', last_name: 'Doe')
      end
    end
  end

  describe '#body' do
    it 'adds an api key' do
      event = AmplitudeAPI::Event.new(
        user_id: user,
        event_type: 'test_event',
        event_properties: {
          test_property: 1
        }
      )
      body = described_class.track_body(event)
      expect(body[:api_key]).to eq('stub api key')
    end

    it 'creates an event' do
      event = AmplitudeAPI::Event.new(
        user_id: 23,
        event_type: 'test_event',
        event_properties: {
          foo: 'bar'
        },
        user_properties: {
          abc: '123'
        },
        ip: '8.8.8.8'
      )
      body = described_class.track_body(event)

      expected = JSON.generate(
        [
          {
            event_type: 'test_event',
            user_id: 23,
            event_properties: {
              foo: 'bar'
            },
            user_properties: {
              abc: '123'
            },
            ip: '8.8.8.8'
          }
        ]
      )
      expect(body[:event]).to eq(expected)
    end
  end
end
