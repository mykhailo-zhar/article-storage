require 'rails_helper'

RSpec.describe "/articles", type: :request do
  let(:article) { FactoryBot.create(:article) }

  describe "GET /index" do
    it "renders a successful response" do
      article
      get articles_url
      expect(response).to be_successful
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
