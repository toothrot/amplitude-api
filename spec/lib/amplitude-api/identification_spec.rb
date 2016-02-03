require 'spec_helper'

describe AmplitudeAPI::Identification do
  User = Struct.new(:id)

  context "with a user object" do
    describe "#body" do
      it "populates with the user's id" do
        identification = AmplitudeAPI::Identification.new(user_id: User.new(123))
        expect(identification.to_hash[:user_id]).to eq(123)
      end
    end
  end

  context "with a user id" do
    describe "#body" do
      it "populates with the user's id" do
        identification = AmplitudeAPI::Identification.new(user_id: 123)
        expect(identification.to_hash[:user_id]).to eq(123)
      end
    end
  end

  context "without a user" do
    describe "#body" do
      it "populates with the unknown user" do
        identification = AmplitudeAPI::Identification.new(user_id: nil)
        expect(identification.to_hash[:user_id]).to eq(AmplitudeAPI::USER_WITH_NO_ACCOUNT)
      end
    end
  end

  describe '#body' do
    it "includes the user id" do
      identification = AmplitudeAPI::Identification.new(user_id: 123)
      expect(identification.to_hash[:user_id]).to eq(123)
    end

    it "includes arbitrary user properties" do
      identification = AmplitudeAPI::Identification.new(user_id: 123, user_properties: {first_name: 'John', last_name: 'Doe'})
      expect(identification.to_hash[:user_properties]).to eq(first_name: 'John', last_name: 'Doe')
    end
  end
end
