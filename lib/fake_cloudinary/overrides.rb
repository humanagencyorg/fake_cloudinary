module FakeCloudinary
  module Overrides
    require "cloudinary"
    require "rspec/mocks"
    extend RSpec::Mocks::ExampleMethods
    extend self

    def stub_download_prefix
      cloud_name = "test" # TODO: make it dynamic
      test_url_prefix = "#{FakeCloudinary.host}/#{cloud_name}"

      allow(Cloudinary::Utils).
        to receive(:unsigned_download_url_prefix).
        and_return(test_url_prefix)
    end

    def remove_stub_download_prefix
      RSpec::Mocks.space.proxy_for(Cloudinary::Utils).reset
    end
  end
end

