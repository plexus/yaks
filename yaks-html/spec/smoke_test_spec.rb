require 'spec_helper'
require_relative 'support/test_app'

RSpec.describe Yaks::Format::HTML, type: :yaks_integration do
  before do
    Capybara.app = TestApp
  end

  let(:rel_prefix) { 'http://myapi.example.com/rel/' }

  it 'should allow browsing the api' do
    visit '/'

    expect(page).to have_content 'GET /'
    expect(page).to have_content 'generated with Yaks'

    click_rel('friends')

    expect(current_path).to eql '/friends'

    expect(page).to have_content 'GET /friends'
    expect(page).to have_content 'Matt'

    submit_form(:poke) do
      fill_in :message, with: 'Free the means of production'
    end

    expect(current_path).to eql '/poke/Matt'

    expect(page).to have_content 'You poked Matt: Free the means of production'
  end
end
