require "spec_helper"

RSpec.describe FakeCloudinary::Overrides do
  describe ".stub_download_prefix" do
    it "allows to use custom host for cloudinary cdn" do
      host = "http://localhost:3001"
      cloud_name = "test"

      allow(FakeCloudinary).to receive(:host).and_return(host)

      described_class.stub_download_prefix

      result = ::Cloudinary::Utils.
        unsigned_download_url_prefix("", cloud_name, "")

      expect(result).to eq("#{host}/#{cloud_name}")
    end
  end

  describe ".remove_stub_download_prefix" do
    it "calls original method" do
      host = "http://localhost:3001"
      cloud_name = "test"

      allow(FakeCloudinary).to receive(:host).and_return(host)

      described_class.stub_download_prefix

      result = ::Cloudinary::Utils.
        unsigned_download_url_prefix

      expect(result).to eq("#{host}/#{cloud_name}")

      described_class.remove_stub_download_prefix

      # original method will raise argument error
      # because original method expects 8 arguments
      expect { Cloudinary::Utils.unsigned_download_url_prefix }.
        to raise_error(ArgumentError)
    end
  end
end
