# coding: utf-8
require 'ostruct'

describe Hallon::Image, :session => true do
  let(:session) { OpenStruct.new(:pointer => nil) }

  describe "an image instance" do
    let(:image) do
      Hallon::Session.should_receive(:instance).and_return session

      image = Spotify.mock_image(
        "3ad93423add99766e02d563605c6e76ed2b0e450".gsub(/../) { |x| x.to_i(16).chr },
        :jpeg,
        File.size(fixture_image_path),
        File.read(fixture_image_path),
        :ok
      )

      Hallon::Image.new(image)
    end

    subject { image }

    its(:status) { should be :ok }
    its(:format) { should be :jpeg }
    its(:id) { should eq "3ad93423add99766e02d563605c6e76ed2b0e450" }

    describe "#data" do
      subject { image.data }

      it "should correspond to the fixture image" do
        should eq File.open(fixture_image_path, 'r:binary', &:read)
      end

      it "should have a binary encoding" do
        pending "ruby 1.8 does not support String#encoding" unless subject.respond_to?(:encoding)
        subject.encoding.name.should eq 'ASCII-8BIT'
      end
    end

    describe "#to_link" do
      it "should retrieve the Spotify URI" do
        image.to_link.should eq Hallon::Link.new("spotify:image:#{image.id}")
      end
    end
  end

  context "created from an uri" do
    let(:image) { Hallon::Image.new("spotify:image:c78f091482e555bd2ffacfcd9cbdc0714b221663", session) }
    subject { image }
    its(:id) { should eq "c78f091482e555bd2ffacfcd9cbdc0714b221663" }
  end

  describe "callbacks" do
    it "should trigger :load when loaded" do
      pending "waiting for mockspotify event system"

      uri = "spotify:image:c78f091482e555bd2ffacfcd9cbdc0714b221663"
      image = Hallon::Image.new(uri, session)
      image.should_not be_loaded
      image.should_receive(:trigger).with(:load).once

      session.process_events_on { image.loaded? }
    end
  end
end