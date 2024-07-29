require 'rails_helper'

RSpec.describe Room, type: :model do
  describe "validations" do
    it { should validate_uniqueness_of(:name) }
  end

  describe "associations" do
    it { should have_many(:participants).dependent(:destroy) }
    it { should have_many(:messages) }
  end

  describe "scopes" do
    describe ".public_rooms" do
      let!(:public_room) { create(:room, is_private: false) }
      let!(:private_room) { create(:room, is_private: true) }

      it "returns only public rooms" do
        expect(Room.public_rooms).to include(public_room)
        expect(Room.public_rooms).not_to include(private_room)
      end
    end
  end

  describe "callbacks" do
    context "after_create_commit" do
      it "broadcasts to rooms if the room is public" do
        expect { create(:room, is_private: false) }.to have_broadcasted_to('rooms')
      end

      it "does not broadcast to rooms if the room is private" do
        expect { create(:room, is_private: true) }.not_to have_broadcasted_to('rooms')
      end
    end
  end

  describe "#broadcast_if_public" do
    let(:room) { build(:room, is_private: false) }

    it "broadcasts to rooms if the room is public" do
      expect(room).to receive(:broadcast_append_to).with('rooms')
      room.broadcast_if_public
    end

    it "does not broadcast to rooms if the room is private" do
      room.is_private = true
      expect(room).not_to receive(:broadcast_append_to)
      room.broadcast_if_public
    end
  end

  describe ".create_private_room" do
    let(:users) { create_list(:user, 2) }
    let(:room_name) { "Private Room" }

    it "creates a private room with the specified name" do
      room = Room.create_private_room(users, room_name)
      expect(room).to be_persisted
      expect(room.name).to eq(room_name)
      expect(room.is_private).to be true
    end

    it "creates participants for each user" do
      room = Room.create_private_room(users, room_name)
      expect(room.participants.count).to eq(users.count)
      users.each do |user|
        expect(room.participants.where(user: user)).to exist
      end
    end
  end
end
