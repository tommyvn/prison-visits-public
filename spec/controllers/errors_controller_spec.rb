require 'rails_helper'

RSpec.describe ErrorsController do
  render_views

  %w[ 404 406 500 503 ].each do |status_code|
    it "renders #{status_code} page with the given status" do
      get :show, status_code: status_code
      expect(response.status).to eq(status_code.to_i)
    end
  end

  it 'raises exception on test page' do
    expect {
      get :test
    }.to raise_exception('This is an test exception')

    expect {
      post :test
    }.to raise_exception('This is an test exception')
  end
end
