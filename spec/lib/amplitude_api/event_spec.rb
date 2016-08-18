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
    context 'the user does not send in a price' do
      it 'raises an error if the user sends in a product_id' do
        expect do
          described_class.new(
            user_id: 123,
            event_type: 'bad event',
            product_id: 'hopscotch.4lyfe'
          )
        end.to raise_error(ArgumentError)
      end

      it 'raises an error if the user sends in a revenue_type' do
        expect do
          described_class.new(
            user_id: 123,
            event_type: 'bad event',
            revenue_type: 'tax return'
          )
        end.to raise_error(ArgumentError)
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

    describe 'time' do
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

      it 'sets the quantity to 1 if the price is set and the quantity is not' do
        price = 100_000.99
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home',
          price: price
        )
        expect(event.to_hash[:quantity]).to eq(1)
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
end
