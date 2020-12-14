ENV["RACK_ENV"] = "test"

require "bundler/setup"
require "webmock/rspec"

require "climate_control"
require "fake_cloudinary"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.after(:each) do
    FakeCloudinary.reset_storage!
  end
end
