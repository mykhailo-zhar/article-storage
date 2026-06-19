require 'rails_helper'

RSpec.describe "articles/index", type: :view do
  before(:each) do
    assign(:search_query, "MVP")
    assign(:selected_categories, [ :idea ])
    assign(:type, :keywords)
    assign(:page, 1)
    category = Category.create!(name: "Idea", wordpress_id: 881_417)
    assign(:articles, [
      Article.new(
        title: "SaaS MVP Guide",
        excerpt: "<p>Learn how to build a SaaS MVP.</p>",
        wordpress_url: "https://example.com/blog/building-a-saas-startup",
        wordpress_id: 17_396,
        published_at: DateTime.parse("2026-03-26T15:04:15"),
        categories: [ category ]
      )
    ])
  end

  it "renders the search form" do
    render

    assert_select "form[action=?][method=get]", articles_path
    assert_select "input[name=search][value=?]", "MVP"
    assert_select "input[name=type][checked=checked][value=keywords]"
    assert_select "input[name=type][value=similar]"
    assert_select "input[name='categories[]'][checked=checked][value=idea]"
    assert_select "input[type=submit][value=?]", "Search"
  end

  it "renders article results with a WordPress link" do
    render

    assert_select ".article", count: 1
    assert_select ".article__title", text: "SaaS MVP Guide", count: 1
    assert_select ".article__category-badge", text: "Idea", count: 1
    assert_select "a.article__link[href=?]", "https://example.com/blog/building-a-saas-startup", text: "View the blog post"
  end

  it "does not render a link for unsafe wordpress URLs" do
    assign(:articles, [
      Article.new(
        title: "Unsafe Article",
        excerpt: "<p>Excerpt</p>",
        wordpress_url: "javascript:alert(1)",
        published_at: DateTime.parse("2026-03-26T15:04:15")
      )
    ])

    render

    assert_select "a.article__link", count: 0
  end

  it "renders a no-results message when articles are empty" do
    assign(:articles, [])
    assign(:search_query, "nothing")

    render

    assert_select "p", text: "No articles found."
  end

  it "renders centered pagination when more pages are available" do
    assign(:total_pages, 3)
    assign(:articles, Array.new(12) do |index|
      Article.new(
        title: "Article #{index}",
        excerpt: "<p>Excerpt #{index}</p>",
        published_at: DateTime.parse("2026-03-26T15:04:15")
      )
    end)

    render

    assert_select "nav.pagination[aria-label=?]", "Articles pagination"
    assert_select "form.pagination__page-form[action=?][method=get]", articles_path
    assert_select "input[name=search][value=?]", "MVP"
    assert_select "input[name='categories[]'][value=idea]"
    assert_select "input[name=type][value=keywords]"
    assert_select "input#page[name=page][type=number][value=?]", "1"
    assert_select "input#page[min=?]", "1"
    assert_select "input#page[max=?]", "3"
    assert_select ".pagination__current", text: /of 3/
    assert_select "input[type=submit][value=?]", "Go"
    assert_select "a.pagination__button", text: "Next"
    assert_select "a.pagination__button", text: "Previous", count: 0
  end
end
