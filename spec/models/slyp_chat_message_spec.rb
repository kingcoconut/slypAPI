require 'spec_helper'

RSpec.describe SlypChatMessage do
  describe "associations" do
    it { should belong_to(:slyp_chat) }
    it { should belong_to(:user) }
  end
end