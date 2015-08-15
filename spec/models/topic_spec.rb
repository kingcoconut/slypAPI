require 'spec_helper'

RSpec.describe Topic do
  describe "associations" do
    it { should have_many(:slyp) }
  end
end