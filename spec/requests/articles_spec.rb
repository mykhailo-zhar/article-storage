require 'rails_helper'

RSpec.describe "/articles", type: :request do
  let(:article) { FactoryBot.create(:article) }
  let(:search_result) do
  [
    Article.new(
      title: "SaaS MVP Guide",
      excerpt: "<p>Learn how to build a SaaS MVP.</p>",
      wordpress_url: "https://example.com/blog/building-a-saas-startup",
      wordpress_id: 17_396,
      published_at: DateTime.parse("2026-03-26T15:04:15")
    )
  ]
  end

  describe "GET /index" do
    before do
      allow(Articles::SearchKeywords).to receive(:call).and_return(search_result)
    end

    it "renders a successful response" do
      get articles_url
      expect(response).to be_successful
    end

    it "calls SearchKeywords with search params" do
      get articles_url, params: { search: "MVP", categories: [ "idea" ], page: "2" }

      expect(Articles::SearchKeywords).to have_received(:call).with(
        search_query: "MVP",
        categories: [ :idea ],
        page: 2
      )
    end

    it "calls SearchKeywords with defaults when params are absent" do
      get articles_url

      expect(Articles::SearchKeywords).to have_received(:call).with(
        search_query: "",
        categories: [],
        page: 1
      )
    end

    context "when SearchKeywords raises an error" do
      before do
        allow(Articles::SearchKeywords).to receive(:call).and_raise(
          RuntimeError, "WordPress API request failed (500): unavailable"
        )
      end

      it "renders a successful response with an alert" do
        get articles_url

        expect(response).to be_successful
        expect(response.body).to include("WordPress API request failed (500)")
      end
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      get article_url(article)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "returns forbidden" do
      get new_article_url
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /edit" do
    it "returns forbidden" do
      get edit_article_url(article)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /create" do
    it "returns forbidden" do
      post articles_url, params: { article: { title: "Blocked" } }
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /destroy" do
    it "returns forbidden" do
      delete article_url(article)
      expect(response).to have_http_status(:forbidden)
    end
  end
end
