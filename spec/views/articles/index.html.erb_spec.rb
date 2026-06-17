require 'rails_helper'

RSpec.describe "articles/index", type: :view do
  before(:each) do
    assign(:articles, [
      Article.create!(
        title: "Title",
        excerpt: "MyText",
        wordpress_url: "Wordpress Url",
        wordpress_id: 1
      ),
      Article.create!(
        title: "Title",
        excerpt: "MyText",
        wordpress_url: "Wordpress Url",
        wordpress_id: 2
      )
    ])
  end

  it "renders a list of articles" do
    render
    assert_select "div#article_#{Article.first.id} strong", text: "Title:", count: 1
    assert_select "div#article_#{Article.second.id} strong", text: "Title:", count: 1
  end
end
