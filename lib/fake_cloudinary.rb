module FakeCloudinary
  require "webmock"
  require_relative "fake_cloudinary/cloudinary_patch"
  require_relative "fake_cloudinary/app"

  def self.boot
    reset_storage!

    stub_requests

    App.boot_once
  end

  def self.host
    "localhost:#{App.port}"
  end

  def self.storage
    @storage ||= {}
  end

  def self.reset_storage!
    @storage = {}
  end

  def self.stub_requests
    WebMock::API.
      stub_request(:post, /api.cloudinary.com/).
      to_rack(App)
  end
end
