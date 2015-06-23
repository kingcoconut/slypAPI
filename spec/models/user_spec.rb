require 'spec_helper'
require_relative '../factories/user.rb'

describe User do
  describe "validations" do
    it { should validate_presence_of :email }
    it { should validate_uniqueness_of :email }
  end
  describe "#setup_password" do
    context "existing user" do
      let(:current_password){ "password" }
      let(:user){ FactoryGirl.create(:user, password: current_password)}

      it "doesn't change the password" do
        user.password = "123foobar"
        user.save
        expect(user.valid_password?(current_password)).to be true
      end
    end
    context "new user" do
      it "setups up the new password" do
        user = FactoryGirl.create(:user, password: "password123")
        expect(user.valid_password?("password123")).to be true
      end
    end
  end

  describe "#valid_password?" do
    context "there is no password set" do
      let(:user){ FactoryGirl.create(:user) }

      it "returns false" do
        expect(user.valid_password?("asfasfas")).to be false
      end
    end

    context "there is a password set" do
      let(:password){ "password0000" }
      let(:user){ FactoryGirl.create(:user, password: password) }

      it "returns true when password is valid" do
        expect(user.valid_password? password).to be true
      end

      it "returns false when password is invalid" do
        expect(user.valid_password? "1234").to be false
      end
    end
  end

  describe "#generate_api_token" do
    it "generates an api key when a user is created" do
      user = FactoryGirl.create(:user)
      expect(user.api_token).to_not be_nil
    end
  end
end