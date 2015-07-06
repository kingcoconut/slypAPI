require 'spec_helper'
require_relative '../factories/user.rb'

describe User do
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
end