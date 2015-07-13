require 'spec_helper'

RSpec.describe UserSlyp do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:slyp) }
  end

  describe "validations" do
    it { should validate_uniqueness_of(:user_id).scoped_to(:slyp_id)}
  end

end