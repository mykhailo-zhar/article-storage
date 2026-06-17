require 'rails_helper'

RSpec.describe "articles/new", type: :view do
  before(:each) do
    assign(:article, Article.new(
      title: "MyString",
      excerpt: "MyText",
      wordpress_url: "MyString",
      wordpress_id: 1
    ))
  end

  it "renders new article form" do
    render

    assert_select "form[action=?][method=?]", articles_path, "post" do

      assert_select "input[name=?]", "article[title]"

      assert_select "textarea[name=?]", "article[excerpt]"

      assert_select "input[name=?]", "article[wordpress_url]"

      assert_select "input[name=?]", "article[wordpress_id]"
    end
  end
end
