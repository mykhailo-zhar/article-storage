require 'rails_helper'

RSpec.describe "articles/index", type: :view do
  let(:parent) { Category.create!(id: 5, name: "Parent", slug: "parent") }
  let(:category) { Category.create!(name: "Idea", wordpress_id: 881_417, parent: parent) }
  let(:articles) do
    [
      Article.new(
        title: "SaaS MVP Guide",
        excerpt: "<p>Learn how to build a SaaS MVP.</p>",
        wordpress_url: "https://example.com/blog/building-a-saas-startup",
        wordpress_id: 17_396,
        published_at: DateTime.parse("2026-03-26T15:04:15"),
        categories: [ category ]
      )
    ]
  end
  let(:search_query) { "MVP" }
  let(:type) { :keywords }
  let(:selected_categories) { { parent.id => [ category.id ] } }
  let(:page) { 1 }
  let(:total_pages) { 1 }

  let(:presenter) do
    Articles::ArticlesPresenter.new(
      articles: articles,
      search_query: search_query,
      type: type,
      selected_categories: selected_categories,
      page: page,
      total_pages: total_pages,
      context: view
    )
  end

  before do
    assign(:presenter, presenter)
    assign(:search_query, presenter.search_query)
    assign(:type, presenter.type)
  end

  it "renders the search form" do
    render

    assert_select "form.search-form[action=?][method=get]", articles_path
    assert_select "input.search-form__input[name=search][value=?]", "MVP"
    assert_select "input[type=radio][name='categories_#{parent.id}[]'][value='#{category.id}'][checked=checked]"
    assert_select "input.button[type=submit][value=?]", "Search"
  end

  it "renders article results with a WordPress link" do
    render

    assert_select ".article", count: 1
    assert_select ".article__title", text: "SaaS MVP Guide", count: 1
    assert_select ".article__category-badge", text: "Idea", count: 1
    assert_select "a.article__link[href=?]", "https://example.com/blog/building-a-saas-startup", text: "View the blog post"
  end

  context "with an unsafe wordpress URL" do
    let(:articles) do
      [
        Article.new(
          title: "Unsafe Article",
          excerpt: "<p>Excerpt</p>",
          wordpress_url: "javascript:alert(1)",
          published_at: DateTime.parse("2026-03-26T15:04:15")
        )
      ]
    end

    it "does not render a link" do
      render

      assert_select "a.article__link", count: 0
    end
  end

  context "when there are no articles" do
    let(:articles) { [] }
    let(:search_query) { "nothing" }

    it "renders a no-results message" do
      render

      assert_select "p", text: "No articles found."
    end
  end

  context "when more pages are available" do
    let(:total_pages) { 3 }
    let(:articles) do
      Array.new(12) do |index|
        Article.new(
          title: "Article #{index}",
          excerpt: "<p>Excerpt #{index}</p>",
          published_at: DateTime.parse("2026-03-26T15:04:15"),
          categories: [ category ]
        )
      end
    end

    it "renders centered pagination" do
      render

      assert_select "nav.pagination[aria-label=?]", "Articles pagination"
      assert_select "form.pagination__page-form[action=?][method=get]", articles_path
      assert_select "input[name=search][value=?]", "MVP"
      assert_select "input[type=radio][name='categories_#{parent.id}[]'][value='#{category.id}'][checked=checked]"
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
end
