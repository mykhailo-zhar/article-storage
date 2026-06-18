require "rails_helper"

RSpec.describe UriSanitizerHelper do
  describe ".safe_external_url" do
    it "returns https URLs" do
      expect(UriSanitizerHelper.safe_external_url("https://example.com/blog/post")).to eq("https://example.com/blog/post")
    end

    it "returns http URLs" do
      expect(UriSanitizerHelper.safe_external_url("http://example.com/blog/post")).to eq("http://example.com/blog/post")
    end

    it "rejects javascript URLs" do
      expect(UriSanitizerHelper.safe_external_url("javascript:alert(1)")).to be_nil
    end

    it "rejects data URLs" do
      expect(UriSanitizerHelper.safe_external_url("data:text/html,<script>alert(1)</script>")).to be_nil
    end

    it "rejects blank values" do
      expect(UriSanitizerHelper.safe_external_url(nil)).to be_nil
      expect(UriSanitizerHelper.safe_external_url("")).to be_nil
    end

    it "rejects invalid URIs" do
      expect(UriSanitizerHelper.safe_external_url("not a url")).to be_nil
    end
  end
end
