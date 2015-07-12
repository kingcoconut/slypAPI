require 'spec_helper'

RSpec.describe User do
  describe "associations" do
    it { should have_many(:user_slyps) }
    it { should have_many(:slyps).through(:user_slyps) }
    it { should have_many(:slyp_chat_users) }
    it { should have_many(:slyp_chats).through(:slyp_chat_users) }
  end

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

  describe "#generate_access_token" do
    it "generates a new access token" do
      user = FactoryGirl.create(:user)
      token = user.access_token
      new_token = user.generate_access_token
      expect(user.access_token).to_not eq token
      expect(user.access_token).to_not be_nil
      expect(user.access_token).to eq new_token
    end
  end

  describe "#send_slyp" do
    let(:user) { FactoryGirl.create(:user, :with_slyps)}
    let(:recipient) { FactoryGirl.create(:user, :with_slyps)}

    it "creates a new slyp_chat for the two users" do
      slyp = user.slyps.first
      user.send_slyp(slyp.id, recipient.id)
      slyp_chats = user.slyp_chats.where(slyp_id: slyp.id)
      users = []
      slyp_chats.each do |sc|
        chat_users = sc.users
        chat_users.delete(user)
        users += chat_users
      end
      expect(users.map{|u| u.id}.include?(recipient.id)).to eq true
    end

    it "adds the slyp to the recpients slyps" do
      slyp = user.slyps.first
      user.send_slyp(slyp.id, recipient.id)
      expect(recipient.slyps.map{|s| s.id}.include?(slyp.id)).to eq true
    end

    it "adds multiple slyps to the recpients slyps" do
      slyp = user.slyps.first
      slyp_two = user.slyps[1]
      user.send_slyp(slyp.id, recipient.id)
      user.reload
      user.send_slyp(slyp_two.id, recipient.id)
      expect(recipient.slyps.map{|s| s.id}.include?(slyp.id)).to eq true
      expect(recipient.slyps.map{|s| s.id}.include?(slyp_two.id)).to eq true
    end

    context "when a slyp_chat already exists for the two users" do
      it "does not create a new one" do
        slyp = user.slyps.first

        #send slyp twice
        user.send_slyp(slyp.id, recipient.id)
        user.reload
        user.send_slyp(slyp.id, recipient.id)

        slyp_chats = user.slyp_chats.where(slyp_id: slyp.id)
        users = []
        slyp_chats.each do |sc|
          chat_users = sc.users
          chat_users.delete(user)
          users += chat_users
        end

        expect(users.select{|u| u.id == recipient.id }.length).to eq 1
      end
    end
  end
end