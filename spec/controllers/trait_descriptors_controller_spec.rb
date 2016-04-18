require 'rails_helper'

RSpec.describe TraitDescriptorsController do
  context '#index' do
    it 'returns search results' do
      descriptors = create_list(:trait_descriptor, 2).map(&:descriptor_name)
      get :index, format: :json, search: { descriptor_name: descriptors[0][1..-2] }
      expect(response.content_type).to eq 'application/json'
      json = JSON.parse(response.body)
      expect(json['results'].size).to eq 1
      expect(json['results'][0]['descriptor_name']).to eq descriptors[0]
    end
  end

  it 'filters forbidden results out' do
    create(:trait_descriptor, user: create(:user), published: false, descriptor_name: 'tdn_private')
    create(:trait_descriptor, descriptor_name: 'tdn_public')
    get :index, format: :json, search: { descriptor_name: 'tdn' }
    expect(response.content_type).to eq 'application/json'
    json = JSON.parse(response.body)
    expect(json['results'].size).to eq 1
    expect(json['results'][0]['descriptor_name']).to eq 'tdn_public'
  end
end
