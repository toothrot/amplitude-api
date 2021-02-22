# frozen_string_literal: true

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

  describe 'init' do
    context 'attributes' do
      it 'accepts string attributes' do
        time = Time.at(1_451_606_400_000 / 1_000)
        event = described_class.new(
          'user_id' => 123,
          'device_id' => 'abcd',
          'event_type' => 'sausage',
          'event_properties' => { 'a' => 'b' },
          'user_properties' => { 'c' => 'd' },
          'time' => time,
          'ip' => '127.0.0.1',
          'platform' => 'Web',
          'country' => 'United States',
          'insert_id' => 'bestId'
        )

        expect(event.to_hash).to eq(event_type: 'sausage',
                                    user_id: 123,
                                    device_id: 'abcd',
                                    event_properties: { 'a' => 'b' },
                                    user_properties: { 'c' => 'd' },
                                    time: 1_451_606_400_000,
                                    ip: '127.0.0.1',
                                    platform: 'Web',
                                    country: 'United States',
                                    insert_id: 'bestId')
      end

      it 'accepts symbol attributes' do
        time = Time.at(1_451_606_400_000 / 1_000)
        event = described_class.new(
          user_id: 123,
          device_id: 'abcd',
          event_type: 'sausage',
          event_properties: { 'a' => 'b' },
          user_properties: { 'c' => 'd' },
          time: time,
          ip: '127.0.0.1',
          platform: 'Web',
          country: 'United States',
          insert_id: 'bestId'
        )

        expect(event.to_hash).to eq(event_type: 'sausage',
                                    user_id: 123,
                                    device_id: 'abcd',
                                    event_properties: { 'a' => 'b' },
                                    user_properties: { 'c' => 'd' },
                                    time: 1_451_606_400_000,
                                    ip: '127.0.0.1',
                                    platform: 'Web',
                                    country: 'United States',
                                    insert_id: 'bestId')
      end
    end

    context "the user sends a revenue_type or a product_id" do

      it "raises an error if there is not a price neither a revenue" do
        expect do
          described_class.new(
            user_id: 123,
            event_type: "bad event",
            product_id: "hopscotch.4lyfe"
          )
        end.to raise_error ArgumentError, /You must provide a price or a revenue/

        expect do
          described_class.new(
            user_id: 123,
            event_type: "bad event",
            revenue_type: "whatever",
          )
        end.to raise_error ArgumentError, /You must provide a price or a revenue/
      end

      it "does not raise an error if there is a price" do
        expect do
          described_class.new(
            user_id: 123,
            event_type: "bad event",
            product_id: "hopscotch.4lyfe",
            price: 10.2
          )
        end.not_to raise_error

        expect do
          described_class.new(
            user_id: 123,
            event_type: "bad event",
            revenue_type: "whatever",
            price: 10.2
          )
        end.not_to raise_error
      end

      it "does not raise an error if there is a revenue" do
        expect do
          described_class.new(
            user_id: 123,
            event_type: "bad event",
            product_id: "hopscotch.4lyfe",
            revenue: 100.1
          )
        end.not_to raise_error

        expect do
          described_class.new(
            user_id: 123,
            event_type: "bad event",
            revenue_type: "whatever",
            revenue: 100.1
          )
        end.not_to raise_error
      end
    end
  end

  describe '#to_hash' do
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

    describe 'time' do
      it 'includes a time for the event' do
        time = Time.at(1_451_606_400_000 / 1_000)
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

    describe 'insert_id' do
      it 'includes an insert_id for the event' do
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home',
          insert_id: 'foo-bar'
        )
        expect(event.to_hash[:insert_id]).to eq('foo-bar')
      end

      it 'does not include insert_id if it is not set' do
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home'
        )
        expect(event.to_hash).not_to have_key(:insert_id)
      end
    end

    describe 'platform' do
      it 'includes the platform for the event' do
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home',
          platform: 'Web'
        )
        expect(event.to_hash[:platform]).to eq('Web')
      end

      it 'does not include the platform if it is not set' do
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home'
        )
        expect(event.to_hash).not_to have_key(:platform)
      end
    end

    describe 'country' do
      it 'includes the country for the event' do
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home',
          country: 'United States'
        )
        expect(event.to_hash[:country]).to eq('United States')
      end

      it 'does not include the country if it is not set' do
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home'
        )
        expect(event.to_hash).not_to have_key(:country)
      end
    end

    describe 'revenue params' do
      it 'includes the price if it is set' do
        price = 100_000.99
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home',
          price: price
        )
        expect(event.to_hash[:price]).to eq(price)
      end

      it 'includes the quantity if it is set' do
        quantity = 100
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home',
          quantity: quantity,
          price: 10.99
        )
        expect(event.to_hash[:quantity]).to eq(quantity)
      end

      it "includes the revenue if it is set" do
        revenue = 100
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home',
          quantity: 456,
          revenue: revenue
        )
        expect(event.to_hash[:revenue]).to eq(revenue)
      end

      it 'includes the productID if set' do
        product_id = 'hopscotch.subscriptions.rule'
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home',
          price: 199.99,
          product_id: product_id
        )
        expect(event.to_hash[:productId]).to eq(product_id)
      end

      it 'includes the revenueType if set' do
        revenue_type = 'income'
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home',
          price: 199.99,
          revenue_type: revenue_type
        )
        expect(event.to_hash[:revenueType]).to eq(revenue_type)
      end

      it 'does not include revenue params if they are not set' do
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home'
        )
        expect(event.to_hash).not_to have_key(:quantity)
        expect(event.to_hash).not_to have_key(:revenueType)
        expect(event.to_hash).not_to have_key(:productId)
        expect(event.to_hash).not_to have_key(:price)
      end
    end
  end

  describe "arbitrary properties" do
    # We need to create a class for each test because the methods we are calling
    # in this test group are modifying the class
    let(:klass) {
      Class.new described_class
    }

    let(:event) {
      klass.new(
        user_id: 123,
        event_type: "bad event"
      )
    }

    it "creates arbitrary properties when assigning values" do
      event.arbitrary_property = "arbitrary value"

      expect(event.arbitrary_property).to eq "arbitrary value"
    end

    it "responds_to? arbitrary properties" do
      event.arbitrary_property = "arbitrary value"

      expect(event.respond_to?(:arbitrary_property)).to be true
      expect(event.respond_to?(:arbitrary_property=)).to be true
    end

    it "do not accepts blocks when assigning values to create properties" do
      expect do
        event.arbitrary_property { puts "whatever" }
      end.to raise_error NoMethodError
    end

    it "includes arbitrary properties in the generated hash" do
      event.arbitrary_property = "arbitrary value"

      hash = event.to_hash

      expect(hash).to include({ arbitrary_property: "arbitrary value" })
    end
  end
end
