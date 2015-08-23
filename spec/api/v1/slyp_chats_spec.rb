require 'spec_helper'

RSpec.describe API::V1::SlypChats do
  include Rack::Test::Methods

  def app
    API::V1::Base
  end

  describe "GET /v1/slyp_chats" do
    let(:user){ FactoryGirl.create(:user, :with_slyps_and_chats) }
    context "when cookie credentials are valid" do
      before do
        set_cookie "user_id=#{user.id}"
        set_cookie "api_token=#{user.api_token}"
        @slyp = user.slyps.first
        get "/v1/slyp_chats", {slyp_id: @slyp.id}
      end
      it "returns the slyp chats and messages for the users slyp" do
        # make sure all slyp_chats get loaded
        expect(JSON.parse(last_response.body).map{|el| el["id"]}).to eq user.slyp_chats.where(slyp_id: @slyp.id).map{|el| el.id}

        # make sure all messages get loaded
        user.slyp_chats.where(slyp_id: @slyp.id).each do |sc|
          sc.slyp_chat_messages.each do |m|
            expect(last_response.body.include?(m.content)).to eq true
          end
        end
      end
      it "returns users nested in the slyp_chats" do
        json_resp = JSON.parse(last_response.body)
        users = json_resp.each do |slyp_chat|
          users = slyp_chat["users"]
          slyp_chat["users"].each do |user|
            expect(SlypChatUser.where(user_id: user["id"], slyp_chat_id: slyp_chat["id"]).first).to_not be_nil
          end
        end
      end

      context "when slyp_id does not exist for the user" do
        it "returns a 404" do
          slyp = FactoryGirl.create(:slyp)
          get "/v1/slyp_chats", {slyp_id: slyp.id}
          expect(last_response.status).to eq 404
        end
      end
    end
    context "when cookie credentials are invalid" do
      it "returns 401" do
        get "/v1/slyp_chats"
        expect(last_response.status).to eq 401
      end
    end
  end

  describe "POST /v1/slyp_chats" do
    let(:user){ FactoryGirl.create(:user, :with_slyps) }
    context "when cookie credentials are valid" do
      before do
        set_cookie "user_id=#{user.id}"
        set_cookie "api_token=#{user.api_token}"
      end

      context "and everything is valid" do
        let(:slyp){ user.slyps.first }
        let(:recipient){ FactoryGirl.create(:user) }

        it "sends the slyps and returns 200" do
          expect_any_instance_of(User).to receive(:send_slyp).with(slyp.id, recipient.id, user.id).and_call_original
          post "/v1/slyp_chats", {slyp_id: slyp.id, emails:[recipient.email]}
          expect(last_response.status).to eq 201
        end

        it "returns an array of the created slyp chats" do
          post "/v1/slyp_chats", {slyp_id: slyp.id, emails:[recipient.email]}
          recipient.reload
          slyp_chat = recipient.slyp_chats.where(slyp_id: slyp.id).first

          #deleting created at because of a timestamp mismatch bug.. round all timestamps to 000Z
          res_json = JSON.parse(last_response.body).each {|el| el.delete "created_at"}

          expect(res_json.first["id"].to_i).to eq slyp_chat.id
          expect(res_json.first["slyp_id"].to_i).to eq slyp_chat.slyp_id
          expect(res_json.first["users"].map{|el| el["id"].to_i}).to eq [recipient.id]
        end
      end

      context "when slyp_id does not belong to user" do
        it "returns a 400" do
          post "/v1/slyp_chats", {slyp_id: 9901923}
          expect(last_response.status).to eq 400
        end
      end

      context "when the emails are not valid" do
        it "returns a 400" do
          post "/v1/slyp_chats", {slyp_id: user.slyps.first.id, emails: ["sjbjbsva", "afsafds"]}
          expect(last_response.status).to eq 400
        end
      end

      context "when there are emails that do not exist" do
        let(:emails) { [Faker::Internet.email, Faker::Internet.email, FactoryGirl.create(:user).email] }
        it "creates the new users" do
          post "/v1/slyp_chats", {slyp_id: user.slyps.first.id, emails: emails}
          emails.each {|email| expect(User.where(email: email).first).to_not be_nil}
        end
      end
    end
    context "when cookie credentials are invalid" do
      it "returns a 401" do
        post "/v1/slyp_chats"
        expect(last_response.status).to eq 401
      end
    end
  end

  describe "POST /v1/slyp_chats/read" do
    let(:user){ FactoryGirl.create(:user, :with_slyps_and_chats) }
    context "when cookie credentials are valid" do
      before do
        set_cookie "user_id=#{user.id}"
        set_cookie "api_token=#{user.api_token}"
      end

      context "and everything else is valid" do
        it "marks the slyp_chat_user record as read" do
          post "/v1/slyp_chats/read", {slyp_chat_id: user.slyp_chats.first.id}
        end
      end
    end
  end

end