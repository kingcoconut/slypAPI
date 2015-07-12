require 'spec_helper'

RSpec.describe API::V1::Users do
  include Rack::Test::Methods

  def app
    API::V1::Base
  end

  describe "POST /v1/users" do
    let(:email){ Faker::Internet.email }
    context "when the email does not exist yet" do
      it "creates the user and sends email" do
        expect(User.where(email: email).first).to be_nil
        expect(Mail).to receive(:deliver) { nil }
        post "/v1/users", {email: email}
        expect(User.where(email: email).first).to_not be_nil
        expect(last_response.status).to eq 201
      end
    end

    context "when the email does exist" do
      let(:user){ FactoryGirl.create(:user) }
      it "sends an email to the user with signin link" do
        expect(Mail).to receive(:deliver) { nil }
        post "/v1/users", {email: email}
      end
    end
  end

  describe "GET /v1/users" do
    let(:user){ FactoryGirl.create(:user) }
    context "when a valid email and access token are sent" do
      it "set cookies" do
        user.generate_access_token
        get "/v1/users/auth", {email: user.email, access_token: user.access_token}
        expect(last_response.headers["Set-Cookie"].match("user_id=#{user.id}").nil?).to eq false
        expect(last_response.headers["Set-Cookie"].match("api_token=#{user.api_token}").nil?).to eq false
      end
      it "redirects to home" do
        user.generate_access_token
        get "/v1/users/auth", {email: user.email, access_token: user.access_token}
        expect(last_response.status).to eq 302
      end
    end

    context "when invalid token is used" do
      it "does not set cookies" do
        get "/v1/users/auth", {email: user.email, access_token: "123"}
        expect(last_response.headers["Set-Cookie"]).to be_nil
      end
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