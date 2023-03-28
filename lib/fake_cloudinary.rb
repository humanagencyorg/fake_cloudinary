# frozen_string_literal: true

module FakeCloudinary
  require "webmock"
  require_relative "fake_cloudinary/overrides"
  require_relative "fake_cloudinary/app"

  CDN_HOST = "http://localhost"
  DEFAULT_CLOUDINARY_URL = "cloudinary://224582571721794:KjttkIKm-WPchDLqY26b-oM2f_g@test_cloud_name" # rubocop:disable Metrics/LineLength

  def self.boot
    # TODO: improve error
    raise ArgumentError unless block_given?

    reset_storage!

    stub_requests

    FakeCloudinary::App.boot_once

    RSpec::Mocks.with_temporary_scope do
      Overrides.stub_download_prefix
      yield
      Overrides.remove_stub_download_prefix
    end
  end

  def self.host
    "#{CDN_HOST}:#{App.port}"
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
