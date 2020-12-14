require "spec_helper"

RSpec.describe FakeCloudinary do
  before do
    FakeCloudinary.reset_storage!
  end

  describe ".boot" do
    it "resets storage" do
      FakeCloudinary.storage[:key] = "value"
      stub_web_mock
      allow(described_class::App).to receive(:boot_once)

      expect { described_class.boot {} }.
        to change { described_class.storage.empty? }.
        from(false).
        to(true)
    end

    it "stubs api requests" do
      webmock_stub = stub_web_mock
      allow(described_class::App).to receive(:boot_once)

      described_class.boot {}

      expect(WebMock::API).
        to have_received(:stub_request).
        with(:post, /api.cloudinary.com/)
      expect(webmock_stub).
        to have_received(:to_rack).
        with(described_class::App)
    end

    it "boots App" do
      stub_web_mock
      allow(described_class::App).to receive(:boot_once)

      described_class.boot {}

      expect(described_class::App).to have_received(:boot_once)
    end

    it "stubs Cloudinary with overrides" do
      stub_web_mock
      allow(described_class::App).to receive(:boot_once)
      allow(described_class::Overrides).to receive(:stub_download_prefix)

      described_class.boot {}

      expect(described_class::Overrides).to have_received(:stub_download_prefix)
    end

    it "unstubs Cloudinary with overrides" do
      stub_web_mock
      allow(described_class::App).to receive(:boot_once)
      allow(described_class::Overrides).to receive(:remove_stub_download_prefix)

      described_class.boot {}

      expect(described_class::Overrides).
        to have_received(:remove_stub_download_prefix)
    end

    it "removes Cloudinary overrides after block execution" do
      stub_web_mock
      allow(described_class::App).to receive(:boot_once)

      given_block = -> { Cloudinary::Utils.unsigned_download_url_prefix }

      expect { described_class.boot &given_block }.not_to raise_error

      expect { given_block.call }.to raise_error(ArgumentError)
    end

    context "if no CLOUDINARY_URL provided" do
      it "modifies cloudinary env variable with default" do
        stub_web_mock
        allow(described_class::App).to receive(:boot_once)

        expected_variable = "cloudinary://username:api_key@test_cloud_name"

        given_block = lambda do
          expect(ENV["CLOUDINARY_URL"]).to eq(expected_variable)
        end

        expect { described_class.boot &given_block }.not_to raise_error
      end
    end

    context "if CLOUDINARY_URL provided" do
      it "uses provided variable" do
        stub_web_mock
        allow(described_class::App).to receive(:boot_once)

        custom_url = "custom_url"

        given_block = lambda do
          expect(ENV["CLOUDINARY_URL"]).to eq(custom_url)
        end

        ClimateControl.modify(CLOUDINARY_URL: custom_url) do
          described_class.boot &given_block
        end
      end
    end
  end

  describe ".host" do
    it "returns stub host" do
      port = 12345
      allow(described_class::App).to receive(:port).and_return(port)
      expected_host = "http://localhost:#{port}"

      result = described_class.host

      expect(result).to eq(expected_host)
    end
  end

  describe "storage" do
    context "if storage empty" do
      it "returns empty hash" do
        result = described_class.storage

        expect(result).to eq({})
      end
    end

    context "if data present" do
      it "allows you to manipulate hash" do
        data_key = "uniqueKey"
        value = "value"

        described_class.storage[data_key] = value

        result = described_class.storage[data_key]

        expect(result).to eq(value)
      end
    end
  end

  describe ".reset_storage!" do
    it "resets storage ot empty hash" do
      data_key = "uniqueKey"
      value = "value"

      described_class.storage[data_key] = value

      expect(described_class.storage).not_to eq({})
      expect { described_class.reset_storage! }.
        to change { described_class.storage.empty? }.
        from(false).
        to(true)
      expect(described_class.storage).to eq({})
    end
  end

  describe ".stub_requests" do
    it "stubs requests" do
      webmock_stub = stub_web_mock

      described_class.stub_requests

      expect(WebMock::API).
        to have_received(:stub_request).
        with(:post, /api.cloudinary.com/)
      expect(webmock_stub).
        to have_received(:to_rack).
        with(described_class::App)
    end
  end

  def stub_web_mock
    webmock_stub = instance_double("WebMock Stub", to_rack: nil)
    allow(WebMock::API).to receive(:stub_request).and_return(webmock_stub)
    webmock_stub
  end
end
