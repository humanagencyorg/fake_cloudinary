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
end
