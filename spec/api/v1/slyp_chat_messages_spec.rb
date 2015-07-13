require 'spec_helper'

RSpec.describe API::V1::SlypChatMessages do
  include Rack::Test::Methods

  def app
    API::V1::Base
  end

  describe "POST /v1/slyp_chat_messages" do
    let(:user){ FactoryGirl.create(:user, :with_slyps) }
    context "when cookie credentials are valid" do
      before do
        set_cookie "user_id=#{user.id}"
        set_cookie "api_token=#{user.api_token}"
      end

      it "creates the slyp chat message" do
        slyp_chat = user.slyp_chats.create(slyp_id: user.slyps.first.id)
        content = Faker::Lorem.sentence
        post "/v1/slyp_chat_messages", {slyp_chat_id: slyp_chat.id, content: content}
        slyp_chat.reload
        expect(slyp_chat.slyp_chat_messages.first.content).to eq content
        expect(last_response.status).to eq 201
      end

      it "cannot create a message on a conversation the user is not a part of" do
        slyp_chat = SlypChat.create(slyp_id: user.slyps.first.id)
        content = Faker::Lorem.sentence
        post "/v1/slyp_chat_messages", {slyp_chat_id: slyp_chat.id, content: content}
        slyp_chat.reload
        expect(slyp_chat.slyp_chat_messages.count).to eq 0
        expect(last_response.status).to eq 400
      end

      context "when the slyp_chat id does not exist" do
        it "returns a 400" do
          content = Faker::Lorem.sentence
          post "/v1/slyp_chat_messages", {slyp_chat_id: 103840, content: content}
          expect(last_response.status).to eq 400
        end
      end
    end
    context "when cookie credentials are invalid" do
      it "returns 401" do
        post "/v1/slyp_chat_messages"
        expect(last_response.status).to eq 401
      end
    end
  end
end