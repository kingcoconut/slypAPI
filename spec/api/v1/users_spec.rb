require 'spec_helper'
require_relative '../../factories/user.rb'

describe API::V1::Users do
  include Rack::Test::Methods

  def app
    API::V1::Base
  end

  describe "POST /v1/users" do
    let(:email){ Faker::Internet.email }
    let(:password){ "password" }
    it "sets cookies with users id and api_token" do
      post "/v1/users", {email: email, password: password}
      user = User.where(email: email).first
      last_response.status.should == 201
      expect(last_response.headers["Set-Cookie"].match("user_id=#{user.id}").nil?).to eq false
      expect(last_response.headers["Set-Cookie"].match("api_token=#{user.api_token}").nil?).to eq false
    end
    it "sets the password" do
      post "/v1/users", {email: email, password: password}
      user = User.where(email: email).first
      expect(user.email).to eq email
      expect(user.valid_password?(password)).to eq true
    end
  end

  describe "POST /v1/users/facebook" do
    let(:facebook_id){ "3q23rq" }
    let(:email){ Faker::Internet.email }
    it "sets the facebook_id" do
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

  describe "POST /v1/users/auth" do
    context "when email and password are valid" do
      it "sets cookies with user id and api_token" do
        user = FactoryGirl.create(:user, password: "password1212")
        post "/v1/users/auth", {email: user.email, password: "password1212"}
        expect(last_response.status).to eq 201
        expect(last_response.headers["Set-Cookie"].match("user_id=#{user.id}").nil?).to eq false
        expect(last_response.headers["Set-Cookie"].match("api_token=#{user.api_token}").nil?).to eq false
      end
    end
    context "when email and password are invalid" do
      it "sets cookies with user id and api_token" do
        user = FactoryGirl.create(:user, password: "password1212")
        post "/v1/users/auth", {email: "foo@exmm.co", password: "password1212"}
        expect(last_response.status).to eq 400
      end
    end
  end
end