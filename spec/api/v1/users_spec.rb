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
        expect(last_response.status).to eq 201
      end
    end
  end

  describe "GET /v1/users" do
    let(:user){ FactoryGirl.create(:user)}
    context "when cookie credentials are valid" do
      it "returns current user" do
        set_cookie "user_id=#{user.id}"
        set_cookie "api_token=#{user.api_token}"
        get "/v1/users"
        # binding.pry
        js_resp = JSON.parse(last_response.body)
        expect(js_resp["id"]).to eq user.id
        expect(js_resp["email"]).to eq user.email
        expect(js_resp["icon_url"]).to eq user.icon_url
      end
    end
  end

  describe "GET /v1/users/friends" do
    let(:user){ FactoryGirl.create(:user, :with_slyps_and_chats)}
    context "when cookie credentials are valid" do
      it "returns all of the user's friends" do
        set_cookie "user_id=#{user.id}"
        set_cookie "api_token=#{user.api_token}"
        get "/v1/users/friends"

        sql = "select distinct u.id, u.email "\
              "from slyp_chat_users u1 "\
              "join slyp_chat_users u2 "\
              "on (u1.slyp_chat_id = u2.slyp_chat_id) "\
              "join users u "\
              "on (u2.user_id = u.id) "\
              "where u1.user_id = " + user.id.to_s + " and u2.user_id <> " + user.id.to_s + ";"
        friends = ActiveRecord::Base.connection.select_all(sql).as_json
        friends_resp = JSON.parse(last_response.body)
        expect(friends == friends_resp).to eq true
      end
    end
  end

  describe "GET /v1/users/auth" do
    let(:user){ FactoryGirl.create(:user) }
    context "when a valid email and access token are sent" do
      it "set cookies" do
        get "/v1/users/auth", {email: user.email, access_token: user.access_token}
        expect(last_response.headers["Set-Cookie"].match("user_id=#{user.id}").nil?).to eq false
        expect(last_response.headers["Set-Cookie"].match("api_token=#{user.api_token}").nil?).to eq false
        expect(last_response.status).to eq 302
      end
      it "redirects to home" do
        get "/v1/users/auth", {email: user.email, access_token: user.access_token}
        expect(last_response.status).to eq 302
      end
    end

    context "when invalid token is used" do
      it "does not set cookies" do
        get "/v1/users/auth", {email: user.email, access_token: "123"}
        expect(last_response.headers["Set-Cookie"]).to be_nil
        expect(last_response.status).to eq 302
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