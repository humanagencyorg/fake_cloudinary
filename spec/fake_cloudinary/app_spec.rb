# frozen_string_literal: true

require "rack/test"
require "spec_helper"

RSpec.describe FakeCloudinary::App do
  module RSpecMixin
    include Rack::Test::Methods

    def app
      described_class
    end
  end

  before do
    FakeCloudinary.reset_storage!

    RSpec.configure do |c|
      c.include(RSpecMixin)
    end
  end

  describe "CDN requests" do
    describe "GET /:client_id/:blob_type/upload/:upload_params/:name" do
      it "redirects to a stored link" do
        public_id = "qwerty12asdf34"
        redirect_link = "http://example.com"
        FakeCloudinary.storage[public_id] = redirect_link

        get "/client_id/video/upload/upload_params/#{public_id}.mp4"
        expect(last_response).to be_redirect
        expect(last_response.location).to eq(redirect_link)
      end
    end
  end

  describe "API requests" do
    describe "POST /v1_1/:client_id/:blob_type/upload" do
      it "returns status 200" do
        public_id = "uniqueKey"
        file_path = "http://link.to/file/somewhere/else.mp4"
        params = {
          public_id: public_id,
          file: file_path,
        }

        post "/v1_1/client_id/video/upload", params

        expect(last_response.status).to eq(200)
      end

      it "stores provided file" do
        public_id = "uniqueKey"
        file_path = "http://link.to/file/somewhere/else.mp4"
        params = {
          public_id: public_id,
          file: file_path,
        }

        post "/v1_1/client_id/video/upload", params

        result = FakeCloudinary.storage[public_id]

        expect(result).to eq(file_path)
      end
    end
  end
end
