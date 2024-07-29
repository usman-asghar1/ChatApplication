require 'rails_helper'

RSpec.feature 'Room Management', type: :feature, js: true do
  let!(:user) { create(:user) }

  before do
    login_as(user, scope: :user)
  end

  scenario 'User creates a new room' do
    visit root_path
    

    fill_in 'room_name', with: 'Test Room'
    click_button 'Create'
    debugger
    page.body

    # Ensure Turbo Stream updates are handled
    expect(page).to have_content 'Test Room'
    expect(Room.find_by(name: 'Test Room')).not_to be_nil
  end
end