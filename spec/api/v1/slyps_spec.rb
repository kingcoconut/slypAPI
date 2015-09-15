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
        date_attrs = [:created_at, :date]
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
        derived_attrs = [:engaged, :archived, :starred, :users, :unread_messages, :sender, :topic]

        all_attrs = date_attrs + native_attrs + derived_attrs
        fSlyp = json_res.first
        expect(fSlyp.keys).to match_array all_attrs.map &:to_s

        json_res.each do |rSlyp|
          # :engaged
          expect(rSlyp["engaged"]).to eq UserSlyp.where(slyp_id: rSlyp["id"], user_id: user.id).first.engaged

          # :archived
          expect(rSlyp["archived"]).to eq UserSlyp.where(slyp_id: rSlyp["id"], user_id: user.id).first.archived

          # :starred
          expect(rSlyp["starred"]).to eq UserSlyp.where(slyp_id: rSlyp["id"], user_id: user.id).first.starred

          # :users
          rUsers = rSlyp["users"]
          slyp_id = rSlyp["id"].to_s
          user_id = user.id.to_s
          sql = "select u.id, u.email, scu.slyp_chat_id, count(distinct scm.id) as unread_messages "\
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

          # :topic
          # TODO: how do you test this -- expose :topic, using: Topic::Entity

          expect(last_response.status).to eq 200
        end
      end
      it "adds messages to slyp_chat, engages it, then adds more" do
        slyp_chat_id = user.slyp_chats.first.id
        slyp_id = user.slyp_chats.first.slyp_id
        # TODO: we have to add messages to this slyp_chat from a different 
        # user. We want to be able to detect unread messages,
        # engage those messages and for those states to be reflected on
        # the get "slyps/:id" endpoint.
      end
      it "gets a particular slyp that this user owns" do
        slyp_id = user.slyps.last.id
        get "/v1/slyps/"+slyp_id.to_s
        expect(JSON.parse(last_response.body)["id"]).to eq user.slyps.find_by(id: slyp_id).id
        expect(last_response.status).to eq 200        
      end
      it "gets a particular slyp that this user does not own, and responds with a 400" do
        slyp_id = 0
        get "/v1/slyps/"+slyp_id.to_s
        expect(last_response.status).to eq 400
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

  describe "PUT /v1/slyps/starred/:id" do
    let(:user){ FactoryGirl.create(:user, :with_slyps) }
    context "when cookie credentials are valid" do
      before do
        set_cookie "user_id=#{user.id}"
        set_cookie "api_token=#{user.api_token}"
      end
      it "updates the user_slyp model with starred" do
        slyp = user.slyps.first
        put "/v1/slyps/starred/#{slyp.id}"
        expect(user.user_slyps.where(slyp_id: slyp.id).first.starred).to eq true
      end
      it "sends 400 bad request because slyp_id is invalid" do
        delete "/v1/slyps/-1"
        expect(last_response.status).to eq 400
      end
    end
  end

  describe "PUT /v1/slyps/unstarred/:id" do
    let(:user){ FactoryGirl.create(:user, :with_slyps) }
    context "when cookie credentials are valid" do
      before do
        set_cookie "user_id=#{user.id}"
        set_cookie "api_token=#{user.api_token}"
      end
      it "updates the user_slyp model with starred" do
        slyp = user.slyps.first
        put "/v1/slyps/unstarred/#{slyp.id}"
        expect(user.user_slyps.where(slyp_id: slyp.id).first.starred).to eq false
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
