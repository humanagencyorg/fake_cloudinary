module FakeCloudinary
  require "cloudinary"

  # TODO: comment this

  module ::Cloudinary
    class Utils
      def self.unsigned_download_url_prefix(_, cloud_name, *_)
        "#{FakeCloudinary.host}/#{cloud_name}"
      end
    end
  end
end
