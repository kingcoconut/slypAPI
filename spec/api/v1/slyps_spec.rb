require 'spec_helper'

RSpec.describe API::V1::Users do
  include Rack::Test::Methods

  def app
    API::V1::Base
  end

  describe "GET /v1/slyps" do
    let(:user){ FactoryGirl.create(:user, :with_slyps) }
    context "when cookie credentials are valid" do
      it "returns all of the users slyps" do
        set_cookie "user_id=#{user.id}"
        set_cookie "api_token=#{user.api_token}"
        get "/v1/slyps"
        expect(last_response.body).to eq user.slyps.order('createdon DESC').to_json
        expect(last_response.status).to eq 200
      end
    end
  end
end