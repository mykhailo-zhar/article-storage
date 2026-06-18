require 'rails_helper'

RSpec.describe "articles/show", type: :view do
  before(:each) do
    assign(:article, Article.create!(
      title: "Title",
      excerpt: "<p>MyText</p>",
      wordpress_url: "https://example.com/post",
      wordpress_id: 2
    ))
  end

  it "renders article attributes" do
    render
    expect(rendered).to include("Title")
    expect(rendered).to include("<p>MyText</p>")
    expect(rendered).to have_css(".article")
    expect(rendered).to have_css(".article__title", text: "Title")
  end
end
