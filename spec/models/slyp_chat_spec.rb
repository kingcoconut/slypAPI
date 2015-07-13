require 'spec_helper'

RSpec.describe SlypChat do
  describe "associations" do
    it { should have_many(:slyp_chat_messages) }
    it { should have_many(:slyp_chat_users) }
    it { should have_many(:users).through(:slyp_chat_users) }
  end
end