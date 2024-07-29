require 'rails_helper'

RSpec.describe Message, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:room) }
    it { should have_many_attached(:attachments) }
  end

  describe "callbacks" do
    let(:room) { create(:room) }
    let(:user) { create(:user) }
    let(:message) { build(:message, user: user, room: room) }

    context "after_create_commit" do
      it "broadcasts to the room" do
        expect { message.save! }.to have_broadcasted_to(room).from_channel("MessagesChannel")
      end
    end   

    context "before_create" do
      let(:private_room) { create(:room, is_private: true) }

      it "aborts if user is not a participant in a private room" do
        private_message = build(:message, user: user, room: private_room)
        expect(private_message.save).to be_falsey
      end

      it "saves if user is a participant in a private room" do
        Participant.create!(user: user, room: private_room)
        private_message = build(:message, user: user, room: private_room)
        expect(private_message.save).to be_truthy
      end
    end
  end

  describe "#chat_attachment" do
    let(:message) { create(:message) }
    let(:image_file) { fixture_file_upload(Rails.root.join('spec/fixtures/test_image.png'), 'image/png') }
    let(:video_file) { fixture_file_upload(Rails.root.join('spec/fixtures/test_video.mp4'), 'video/mp4') }

    before do
      message.attachments.attach(image_file, video_file)
    end

    it "returns the URL of an image attachment" do
      expect(message.chat_attachment(0)).to include('test_image.png')
    end

    it "returns the URL of a video attachment" do
      expect(message.chat_attachment(1)).to include('test_video.mp4')
    end
  end
end
