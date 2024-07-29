# spec/models/user_spec.rb

require 'rails_helper'

RSpec.describe User, type: :model do
  it "has a valid factory" do
    expect(build(:user)).to be_valid
  end

  describe "associations" do
    it { should have_many(:messages) }
  end

  describe "validations" do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:password) }
  end

  describe "scopes" do
    describe ".all_except" do
      let!(:user1) { create(:user) }
      let!(:user2) { create(:user) }

      it "returns all users except the specified one" do
        expect(User.all_except(user1)).to include(user2)
        expect(User.all_except(user1)).not_to include(user1)
      end
    end
  end

  describe "callbacks" do
    it "broadcasts to users after create" do
      expect { create(:user) }.to have_broadcasted_to("users")
    end
  end

  describe "Devise modules" do
    let(:user) { build(:user) }

    it "authenticates with a valid password" do
      user.save
      expect(user.valid_password?('password')).to be true
    end

    it "does not authenticate with an invalid password" do
      user.save
      expect(user.valid_password?('wrong_password')).to be false
    end

    it "is recoverable" do
      expect(User).to respond_to(:send_reset_password_instructions)
    end

    it "is rememberable" do
      expect(user).to respond_to(:remember_me)
    end
  end
end
