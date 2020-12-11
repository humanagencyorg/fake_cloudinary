require "spec_helper"

RSpec.describe "Cloudinary::Utils monkey-patch" do
  describe ".unsigned_download_url_prefix" do
    it "allows to use custom host for cloudinary cdn" do
      host = "http://localhost:#{port}"
      cloud_name = "test"

      allow(FakeCloudinary).to receive(:host).and_return(host)

      result = ::Cloudinary::Utils.
        unsigned_download_url_prefix("", cloud_name, "")

      expect(result).to eq("#{host}/#{cloud_name}")
    end
  end
end
