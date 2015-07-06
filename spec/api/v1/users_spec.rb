require 'spec_helper'
require_relative '../../factories/user.rb'

describe API::V1::Users do
  include Rack::Test::Methods

  def app
    API::V1::Base
  end

  describe "POST /v1/users" do
    let(:email){ Faker::Internet.email }
    it "sets cookies with users id and api_token" do
      post "/v1/users", {email: email}
      user = User.where(email: email).first
      last_response.status.should == 201
      expect(last_response.headers["Set-Cookie"].match("user_id=#{user.id}").nil?).to eq false
      expect(last_response.headers["Set-Cookie"].match("api_token=#{user.api_token}").nil?).to eq false
    end
  end

  describe "POST /v1/users/facebook" do
    let(:facebook_id){ "3q23rq" }
    let(:email){ Faker::Internet.email }
    it "creates a user with the provided facebook_id" do
      post "/v1/users/facebook", {email: email, facebook_id: facebook_id}
      user = User.where(email: email).first
      expect(user.email).to eq email
      expect(user.facebook_id).to eq facebook_id
    end
    it "sets cookies with users id and api_token" do
      post "/v1/users/facebook", {email: email, facebook_id: facebook_id}
      user = User.where(email: email).first
      expect(last_response.status).to eq 201
      expect(last_response.headers["Set-Cookie"].match("user_id=#{user.id}").nil?).to eq false
      expect(last_response.headers["Set-Cookie"].match("api_token=#{user.api_token}").nil?).to eq false
    end
  end
end