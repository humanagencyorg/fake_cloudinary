module FakeCloudinary
  require "sinatra/base"
  require_relative "bootable"

  class App < Sinatra::Base
    extend FakeCloudinary::Bootable

    post "/v1_1/:client_id/:blob_type/upload" do
      FakeCloudinary.storage[params[:public_id]] = params[:file]

      return {}.to_json
    end

    get "/:client_id/:blob_type/upload/:upload_params/:name" do
      public_id = params[:name].split(".").first

      link_to_file = FakeCloudinary.storage[public_id]

      redirect link_to_file
    end
  end

  def self.boot
    reset_storage!

    stub_requests

    FakeCloudinary::App.boot_once
  end

  def self.host
    "http://localhost:#{App.port}"
  end

  def self.storage
    @storage
  end

  def self.reset_storage!
    @storage = {}
  end

  def self.stub_requests
    WebMock::API.
      stub_request(:post, /api.cloudinary.com/).
      to_rack(FakeCloudinary::App)
  end
end
