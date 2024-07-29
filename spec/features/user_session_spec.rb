require 'rails_helper'

RSpec.feature 'User Login', type: :feature do
  let!(:user) { create(:user, email: 'test@example.com', password: 'password') }

  scenario 'User logs in successfully' do
    visit new_user_session_path

    fill_in 'Email', with: 'test@example.com'
    fill_in 'Password', with: 'password'

    click_button 'Log in'

    expect(page).to have_content 'Signed in successfully.'
    expect(page).to have_current_path(root_path)
  end

  scenario 'User enters invalid credentials' do
    visit new_user_session_path

    fill_in 'Email', with: 'invalid@example.com'
    fill_in 'Password', with: 'wrongpassword'

    click_button 'Log in'

    expect(page).to have_content 'Invalid Email or password.'
    expect(page).to have_current_path(new_user_session_path)
  end
end
