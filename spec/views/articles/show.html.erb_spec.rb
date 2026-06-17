require 'rails_helper'

RSpec.describe "articles/show", type: :view do
  before(:each) do
    assign(:article, Article.create!(
      title: "Title",
      excerpt: "MyText",
      wordpress_url: "Wordpress Url",
      wordpress_id: 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Wordpress Url/)
    expect(rendered).to match(/2/)
  end
end
