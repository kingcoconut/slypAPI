require 'spec_helper'

RSpec.describe API::V1::Slyps do
  include Rack::Test::Methods

  def app
    API::V1::Base
  end

  describe "GET /v1/slyps" do
    let(:user){ FactoryGirl.create(:user, :with_slyps_and_chats) }
    context "when cookie credentials are valid" do
      before do
        set_cookie "user_id=#{user.id}"
        set_cookie "api_token=#{user.api_token}"
      end

      it "returns all of the users slyps" do
        get "/v1/slyps"

        json_res = JSON.parse(last_response.body)

        # check slyp model's date values
        date_attrs = [:created_at]
        before_time = Time.now.utc.change(:usec => 0)
        new_slyp = FactoryGirl.create(:slyp)
        # TODO: check created_at for slyp

        # check slyp model's native values
        native_attrs = [:id, :title, :url, :raw_url, :author, :text, :summary, :description, :top_image, :site_name, :video_url] # haven't included datetime stamps, messy comparisons
        json_res.each do |rSlyp|
          uSlyp = user.slyps.find_by(id: rSlyp["id"])
          native_attrs.each do |attr|
            expect(rSlyp[attr.to_s]).to eq uSlyp[attr]
          end
        end

        # check slyp model's derived values
        derived_attrs = [:topic, :engaged, :users, :unread_messgages, :sender]

        json_res.each do |rSlyp|
          # :engaged
          expect(rSlyp["engaged"]).to eq UserSlyp.where(slyp_id: rSlyp["id"], user_id: user.id).first.engaged

          # :users
          rUsers = rSlyp["users"]
          slyp_id = rSlyp["id"].to_s
          user_id = user.id.to_s
          sql = "select u.id, u.email, count(distinct scm.id) as unread_messages "\
          +"from ( "\
          +  "select scu.slyp_chat_id, scu.last_read_at "\
          +    "from slyp_chats sc "\
          +  "join slyp_chat_users scu "\
          +  "on (sc.id = scu.slyp_chat_id) "\
          +  "where scu.user_id = "+user_id+" and sc.slyp_id="+slyp_id+" "\
          +") x "\
          +"join slyp_chat_users scu "\
          +"on (scu.slyp_chat_id = x.slyp_chat_id and scu.user_id <> "+user_id+") "\
          +"join users u "\
          +"on (scu.user_id = u.id) "\
          +"left join slyp_chat_messages scm "\
          +"on (scm.user_id = u.id and scm.slyp_chat_id = x.slyp_chat_id) "\
          +"group by u.id, u.email; "
          dbUsers = ActiveRecord::Base.connection.select_all(sql).to_hash
          expect(rUsers).to eq dbUsers

          # :unread_messages
          rUnread = rSlyp["unread_messages"]
          sql = "select count(scm.id) unread_messages "\
                +"from slyp_chats sc "\
                +"join slyp_chat_users scu "\
                +"on (sc.id = scu.slyp_chat_id) "\
                +"join slyp_chat_messages scm "\
                +"on (scm.slyp_chat_id = sc.id) "\
                +"where scu.user_id = "+user_id+" and sc.slyp_id = "\
                +slyp_id+" and scm.user_id <> "\
                +user_id+" and scm.created_at > scu.last_read_at; "
          dbUnread = ActiveRecord::Base.connection.select_all(sql).first()["unread_messages"]
          expect(rUnread).to eq dbUnread

          # :sender
          rSender = rSlyp["sender"]
          sender_id = UserSlyp.find_by(slyp_id: rSlyp["id"], user_id: user.id).sender_id
          dbSender = User.find_by(id: sender_id)
          expect(rSender["id"]).to eq dbSender.id
          expect(rSender["email"]).to eq dbSender.email

          expect(last_response.status).to eq 200
        end
      end
    end
  end

  describe "DELETE /v1/slyps/:id" do
    let(:user){ FactoryGirl.create(:user, :with_slyps) }
    context "when cookie credentials are valid" do
      before do
        set_cookie "user_id=#{user.id}"
        set_cookie "api_token=#{user.api_token}"
      end
      it "deletes the user_slyp id from db" do
        slyp = user.slyps.first
        delete "/v1/slyps/#{slyp.id}"
        expect(user.slyps.first.id).to_not eq slyp.id
      end

      it "sends 400 bad request because slyp_id is invalid" do
        delete "/v1/slyps/-1"
        expect(last_response.status).to eq 400
      end
    end 
  end

  describe "PUT /v1/slyps/engaged/:id" do
    let(:user){ FactoryGirl.create(:user, :with_slyps) }
    context "when cookie credentials are valid" do
      before do
        set_cookie "user_id=#{user.id}"
        set_cookie "api_token=#{user.api_token}"
      end
      it "updates the user_slyp model with engaged=true" do
        slyp = user.slyps.first
        put "/v1/slyps/engaged/#{slyp.id}"
        expect(user.user_slyps.where(slyp_id: slyp.id).first.engaged).to eq true
      end
      it "sends 400 bad request because slyp_id is invalid" do
        delete "/v1/slyps/-1"
        expect(last_response.status).to eq 400
      end
    end
  end

  describe "PUT /v1/slyps/loved/:id" do
    let(:user){ FactoryGirl.create(:user, :with_slyps) }
    context "when cookie credentials are valid" do
      before do
        set_cookie "user_id=#{user.id}"
        set_cookie "api_token=#{user.api_token}"
      end
      it "updates the user_slyp model with loved" do
        slyp = user.slyps.first
        put "/v1/slyps/loved/#{slyp.id}"
        expect(user.user_slyps.where(slyp_id: slyp.id).first.loved).to eq true
      end
      it "sends 400 bad request because slyp_id is invalid" do
        delete "/v1/slyps/-1"
        expect(last_response.status).to eq 400
      end
    end
  end

  describe "PUT /v1/slyps/unloved/:id" do
    let(:user){ FactoryGirl.create(:user, :with_slyps) }
    context "when cookie credentials are valid" do
      before do
        set_cookie "user_id=#{user.id}"
        set_cookie "api_token=#{user.api_token}"
      end
      it "updates the user_slyp model with loved" do
        slyp = user.slyps.first
        put "/v1/slyps/unloved/#{slyp.id}"
        expect(user.user_slyps.where(slyp_id: slyp.id).first.loved).to eq false
      end
      it "sends 400 bad request because slyp_id is invalid" do
        delete "/v1/slyps/-1"
        expect(last_response.status).to eq 400
      end
    end
  end

  describe "PUT /v1/slyps/archived/:id" do
    let(:user){ FactoryGirl.create(:user, :with_slyps) }
    context "when cookie credentials are valid" do
      before do
        set_cookie "user_id=#{user.id}"
        set_cookie "api_token=#{user.api_token}"
      end
      it "updates the user_slyp model with archived=true" do
        slyp = user.slyps.first
        put "/v1/slyps/archived/#{slyp.id}"
        expect(user.user_slyps.where(slyp_id: slyp.id).first.archived).to eq true
      end
      it "sends 400 bad request because slyp_id is invalid" do
        delete "/v1/slyps/-1"
        expect(last_response.status).to eq 400
      end
    end
  end

  describe "PUT /v1/slyps/unarchived/:id" do
    let(:user){ FactoryGirl.create(:user, :with_slyps) }
    context "when cookie credentials are valid" do
      before do
        set_cookie "user_id=#{user.id}"
        set_cookie "api_token=#{user.api_token}"
      end
      it "updates the user_slyp model with engaged=true" do
        slyp = user.slyps.first
        put "/v1/slyps/unarchived/#{slyp.id}"
        expect(user.user_slyps.where(slyp_id: slyp.id).first.archived).to eq false
      end
      it "sends 400 bad request because slyp_id is invalid" do
        delete "/v1/slyps/-1"
        expect(last_response.status).to eq 400
      end
    end
  end
end
