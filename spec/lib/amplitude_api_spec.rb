# frozen_string_literal: true

require 'spec_helper'

describe AmplitudeAPI do
  let(:user) { Struct.new(:id).new(123) }
  let(:device_id) { 'abcdef' }
  let(:headers) { { 'Content-Type' => 'application/json' } }

  describe '.track' do
    context 'with a single event' do
      context 'with only user_id' do
        it 'sends the event to Amplitude' do
          event = AmplitudeAPI::Event.new(
            user_id: 123,
            event_type: 'clicked on sign up'
          )
          body = JSON.generate(
            api_key: described_class.api_key,
            events: [event.to_hash]
          )

          expect(Typhoeus).to receive(:post).with(AmplitudeAPI::TRACK_URI_STRING, headers: headers, body: body)

          described_class.track(event)
        end
      end

      context 'with only device_id' do
        it 'sends the event to Amplitude' do
          event = AmplitudeAPI::Event.new(
            device_id: device_id,
            event_type: 'clicked on sign up'
          )
          body = JSON.generate(
            api_key: described_class.api_key,
            events: [event.to_hash]
          )

          expect(Typhoeus).to receive(:post).with(AmplitudeAPI::TRACK_URI_STRING, headers: headers, body: body)

          described_class.track(event)
        end
      end

      context 'with both user_id and device_id' do
        it 'sends the event to Amplitude' do
          event = AmplitudeAPI::Event.new(
            user_id: 123,
            device_id: device_id,
            event_type: 'clicked on sign up'
          )
          body = JSON.generate(
            api_key: described_class.api_key,
            events: [event.to_hash]
          )

          expect(Typhoeus).to receive(:post).with(AmplitudeAPI::TRACK_URI_STRING, headers: headers, body: body)

          described_class.track(event)
        end
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
        body = JSON.generate(
          api_key: described_class.api_key,
          events: [event.to_hash, event2.to_hash]
        )

        expect(Typhoeus).to receive(:post).with(AmplitudeAPI::TRACK_URI_STRING, headers: headers, body: body)

        described_class.track([event, event2])
      end
    end
  end

  describe '.identify' do
    context 'with a single identification' do
      context 'with only user_id' do
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

      context 'with only device_id' do
        it 'sends the identification to Amplitude' do
          identification = AmplitudeAPI::Identification.new(
            device_id: device_id,
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

      context 'with both user_id and device_id' do
        it 'sends the identification to Amplitude' do
          identification = AmplitudeAPI::Identification.new(
            user_id: 123,
            device_id: device_id,
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
          device_id: 456,
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

  describe '.initializer' do
    let(:attributes) do
      {
        user_id: 123,
        event_type: 'test_event',
        event_properties: {
          test_property: 1
        },
        user_properties: {},
        ip: '8.8.8.8'
      }
    end

    it 'requires event type' do
      attributes.delete(:event_type)
      expect { AmplitudeAPI::Event.new(attributes) }.to raise_error(ArgumentError)
    end

    it 'requires user id or device id' do
      expect(AmplitudeAPI::Event.new(attributes).to_h).to eq(attributes)
      attributes.merge!(device_id: 'abc').delete(:user_id)
      expect(AmplitudeAPI::Event.new(attributes).to_h).to eq(attributes)
      attributes.delete(:device_id)
      expect { AmplitudeAPI::Event.new(attributes) }.to raise_error(ArgumentError)
    end

    it 'initializes event with parameter' do
      expect(AmplitudeAPI::Event.new(attributes)).to eq(attributes)
    end
  end

  describe '.send_event' do
    context 'with only user_id' do
      it 'sends an event to AmplitudeAPI' do
        event = AmplitudeAPI::Event.new(
          user_id: user,
          event_type: 'test_event',
          event_properties: { test_property: 1 }
        )
        expect(described_class).to receive(:track).with(event)

        described_class.send_event('test_event', user, nil, event_properties: { test_property: 1 })
      end

      context 'the user is nil' do
        it 'sends an event with the no account user' do
          event = AmplitudeAPI::Event.new(
            user_id: nil,
            event_type: 'test_event',
            event_properties: { test_property: 1 }
          )
          expect(described_class).to receive(:track).with(event)

          described_class.send_event('test_event', nil, nil, event_properties: { test_property: 1 })
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

          described_class.send_event('test_event', user.id, nil, event_properties: { test_property: 1 })
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
            nil,
            event_properties: { test_property: 1 },
            user_properties: { test_user_property: 'abc' }
          )
        end
      end
    end

    context 'with device_id' do
      context 'the user is not nil' do
        it 'sends an event to AmplitudeAPI' do
          event = AmplitudeAPI::Event.new(
            user_id: user,
            device_id: device_id,
            event_type: 'test_event',
            event_properties: { test_property: 1 }
          )
          expect(described_class).to receive(:track).with(event)

          described_class.send_event('test_event', user, device_id, event_properties: { test_property: 1 })
        end
      end

      context 'the user is nil' do
        it 'sends an event with the no account user' do
          event = AmplitudeAPI::Event.new(
            user_id: nil,
            device_id: device_id,
            event_type: 'test_event',
            event_properties: { test_property: 1 }
          )
          expect(described_class).to receive(:track).with(event)

          described_class.send_event('test_event', nil, device_id, event_properties: { test_property: 1 })
        end
      end
    end
  end

  describe '.send_identify' do
    context 'with no device_id' do
      it 'sends an identify to AmplitudeAPI' do
        identification = AmplitudeAPI::Identification.new(
          user_id: user,
          user_properties: {
            first_name: 'John',
            last_name: 'Doe'
          }
        )
        expect(described_class).to receive(:identify).with(identification)

        described_class.send_identify(user, nil, first_name: 'John', last_name: 'Doe')
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

          described_class.send_identify(nil, nil, first_name: 'John', last_name: 'Doe')
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

          described_class.send_identify(user.id, nil, first_name: 'John', last_name: 'Doe')
        end
      end
    end

    context 'with a device_id' do
      it 'sends an identify to AmplitudeAPI' do
        identification = AmplitudeAPI::Identification.new(
          user_id: user,
          device_id: 'abc',
          user_properties: {
            first_name: 'John',
            last_name: 'Doe'
          }
        )
        expect(described_class).to receive(:identify).with(identification)

        described_class.send_identify(user, 'abc', first_name: 'John', last_name: 'Doe')
      end
    end
  end

  describe '.segmentation' do
    let(:end_time)   { Time.now }
    let(:start_time) { end_time - 60 * 60 * 24 } # -1 day

    it 'sends request to Amplitude' do
      expect(Typhoeus).to receive(:get).with(AmplitudeAPI::SEGMENTATION_URI_STRING,
                                             userpwd: "#{described_class.api_key}:#{described_class.secret_key}",
                                             params: {
                                               e: { event_type: 'my event' }.to_json,
                                               start: start_time.strftime('%Y%m%d'),
                                               end: end_time.strftime('%Y%m%d'),
                                               s: [{ prop: 'foo', op: 'is', values: %w[bar] }.to_json]
                                             })

      described_class.segmentation({ event_type: 'my event' }, start_time, end_time,
                                   s: [{ prop: 'foo', op: 'is', values: %w[bar] }])
    end
  end

  describe '.delete' do
    context 'a single user_id' do
      it 'correctly formats the response' do
        body = {
          user_ids: ['123']
        }

        expect(Typhoeus).to receive(:post).with(
          AmplitudeAPI::DELETION_URI_STRING,
          userpwd: "#{described_class.api_key}:#{described_class.config.secret_key}",
          body: JSON.generate(body),
          headers: { 'Content-Type' => 'application/json' }
        )
        described_class.delete(user_ids: '123')
      end
    end

    context 'with user_ids' do
      it 'sends the deletion to Amplitude' do
        user_ids =  [123, 456, 555]
        body = {
          user_ids: user_ids
        }

        expect(Typhoeus).to receive(:post).with(
          AmplitudeAPI::DELETION_URI_STRING,
          userpwd: "#{described_class.api_key}:#{described_class.config.secret_key}",
          body: JSON.generate(body),
          headers: { 'Content-Type' => 'application/json' }
        )
        described_class.delete(user_ids: user_ids)
      end

      context 'with amplitude_ids' do
        it 'sends the deletion to Amplitude' do
          user_ids =  [123, 456, 555]
          amplitude_ids = [122, 456]
          body = {
            amplitude_ids: amplitude_ids,
            user_ids: user_ids
          }

          expect(Typhoeus).to receive(:post).with(
            AmplitudeAPI::DELETION_URI_STRING,
            userpwd: "#{described_class.api_key}:#{described_class.config.secret_key}",
            body: JSON.generate(body),
            headers: { 'Content-Type' => 'application/json' }
          )
          described_class.delete(
            amplitude_ids: amplitude_ids,
            user_ids: user_ids
          )
        end
      end
    end

    context 'with amplitude_ids' do
      it 'sends the deletion to Amplitude' do
        amplitude_ids = [122, 456]
        body = {
          amplitude_ids: amplitude_ids
        }

        expect(Typhoeus).to receive(:post).with(
          AmplitudeAPI::DELETION_URI_STRING,
          userpwd: "#{described_class.api_key}:#{described_class.config.secret_key}",
          body: JSON.generate(body),
          headers: { 'Content-Type' => 'application/json' }
        )
        described_class.delete(amplitude_ids: amplitude_ids)
      end
    end

    context 'a single amplitude_id' do
      it 'correctly formats the response' do
        body = {
          amplitude_ids: [122]
        }

        expect(Typhoeus).to receive(:post).with(
          AmplitudeAPI::DELETION_URI_STRING,
          userpwd: "#{described_class.api_key}:#{described_class.config.secret_key}",
          body: JSON.generate(body),
          headers: { 'Content-Type' => 'application/json' }
        )
        described_class.delete(amplitude_ids: 122)
      end
    end

    context 'with requester' do
      it 'sends the deletion to Amplitude' do
        amplitude_ids = [122, 456]

        body = {
          amplitude_ids: amplitude_ids,
          requester: 'privacy@gethopscotch.com'
        }
        userpwd = "#{described_class.api_key}:#{described_class.config.secret_key}"

        expect(Typhoeus).to receive(:post).with(
          AmplitudeAPI::DELETION_URI_STRING,
          userpwd: userpwd,
          body: JSON.generate(body),
          headers: { 'Content-Type' => 'application/json' }
        )
        described_class.delete(
          amplitude_ids: amplitude_ids,
          requester: 'privacy@gethopscotch.com'
        )
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
      body = JSON.parse(described_class.track_body(event), symbolize_names: true)
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

      expected = [
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
      expect(JSON.parse(body, symbolize_names: true)[:events]).to eq(expected)
    end
  end
end
