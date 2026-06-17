require "rails_helper"

RSpec.describe Articles::SearchKeywords do
  let(:api_url) { "https://example.com/api/blog-posts" }
  let(:blog_url) { "https://example.com/blog/" }
  let(:service) do
    described_class.new(
      search_query: "MVP",
      categories: [ :idea ],
      page: 1,
      per_page: 12,
      url: api_url,
      blog_url: blog_url
    )
  end

  def stub_wordpress_response(status:, body:)
    response_class = Net::HTTPResponse::CODE_TO_OBJ[status.to_s]
    response = response_class.new("1.1", status.to_s, "Message")
    response.instance_variable_set(:@body, body)
    response.instance_variable_set(:@read, true)
    allow(Net::HTTP).to receive(:get_response).and_return(response)
  end

  describe "#call" do
    context "when the WordPress API responds successfully with articles" do
      let(:wordpress_payload) do
        [
          {
            "id" => 17_396,
            "date" => "2026-03-26T15:04:15",
            "slug" => "building-a-saas-startup",
            "title" => { "rendered" => "SaaS MVP: Building a SaaS Startup in 2026 Guide" },
            "excerpt" => { "rendered" => "<p>Learn how to build a SaaS MVP.</p>\n" },
            "categories" => [ 881_417 ],
            "jetpack_featured_media_url" => "https://example.com/image.jpg"
          }
        ]
      end

      before do
        stub_wordpress_response(status: 200, body: wordpress_payload.to_json)
      end

      it "returns a list of articles" do
        result = service.call

        expect(result).to all(be_a(Article))
        expect(result.size).to eq(1)
      end

      it "maps WordPress fields onto each article" do
        article = service.call.first

        expect(article.wordpress_id).to eq(17_396)
        expect(article.title).to eq("SaaS MVP: Building a SaaS Startup in 2026 Guide")
        expect(article.excerpt).to eq("<p>Learn how to build a SaaS MVP.</p>\n")
        expect(article.wordpress_url).to eq("https://example.com/blog/building-a-saas-startup")
        expect(article.published_at).to eq(DateTime.parse("2026-03-26T15:04:15"))
      end

      it "resolves categories from WordPress IDs" do
        article = service.call.first

        expect(article.categories.map(&:wordpress_id)).to eq([ 881_417 ])
        expect(article.categories.map(&:name)).to eq([ "Idea" ])
      end
    end

    context "when the WordPress API responds successfully with no articles" do
      before do
        stub_wordpress_response(status: 200, body: [].to_json)
      end

      it "returns an empty list" do
        expect(service.call).to eq([])
      end
    end

    context "when the WordPress API responds with a 400 error" do
      before do
        stub_wordpress_response(status: 400, body: { code: "rest_post_invalid_page_number" }.to_json)
      end

      it "returns an empty list" do
        expect(service.call).to eq([])
      end
    end

    context "when the WordPress API responds with an error" do
      before do
        stub_wordpress_response(status: 500, body: { error: "unavailable" }.to_json)
      end

      it "raises an error" do
        expect { service.call }.to raise_error(
          RuntimeError,
          /WordPress API request failed \(500\)/
        )
      end
    end
  end
end
