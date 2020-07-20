require 'rails_helper'

describe "get all questions route", :type => :request do
    organization = FactoryBot.create(:organization)
    practitioner = FactoryBot.create(:practitioner,organization: organization)
  let!(:patients) {FactoryBot.create_list(:random_patients, 20,organization: organization)}
before {get 'patients'}
it 'returns all questions' do
    expect(JSON.parse(response.body).size).to eq(20)
  end
it 'returns status code 200' do
    expect(response).to have_http_status(:success)
  end
end