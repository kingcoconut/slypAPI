require 'spec_helper'
require_relative '../factories/user.rb'

RSpec.describe User do
  describe "associations" do
    it { should have_many(:user_slyps) }
    it { should have_many(:slyps).through(:user_slyps) }
  end

  describe "validations" do
    it { should validate_presence_of :email }
    it { should validate_uniqueness_of :email }
  end

  describe "#generate_api_token" do
    it "generates an api key when a user is created" do
      user = FactoryGirl.create(:user)
      expect(user.api_token).to_not be_nil
    end
  end

  describe "#generate_access_token" do
    it "generates a new access token" do
      user = FactoryGirl.create(:user)
      token = user.access_token
      new_token = user.generate_access_token
      expect(user.access_token).to_not eq token
      expect(user.access_token).to_not be_nil
      expect(user.access_token).to eq new_token
    end
  end
end