require 'spec_helper'

RSpec.describe API::V1::Users do
  include Rack::Test::Methods

  def app
    API::V1::Base
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
          expect_any_instance_of(User).to receive(:send_slyp).with(slyp.id, recipient.id)
          post "/v1/slyp_chats", {slyp_id: slyp.id, emails:[recipient.email]}
          expect(last_response.status).to eq 201
        end
      end

      context "when slyp_id does not belong to user" do
        it "returns a 400" do
          post "/v1/slyp_chats", {slyp_id: 9901923}
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
end