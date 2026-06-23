require "rails_helper"

RSpec.describe "shared/_header", type: :view do
  before do
    allow(view).to receive(:controller_name).and_return("articles")
    allow(view).to receive(:action_name).and_return("index")
    allow(view).to receive(:params).and_return(ActionController::Parameters.new({}))
  end

  it "renders the brand link to root" do
    render partial: "shared/header"

    assert_select "a.site-header__brand[href=?]", root_path, text: "Article Storage"
  end

  it "renders Keywords and Similar nav links" do
    render partial: "shared/header"

    assert_select "nav.site-nav[aria-label=?]", "Search"
    assert_select "a.site-nav__link[href=?]", keywords_articles_path, text: ApplicationHelper::SEARCH_NAV_TYPES[:keywords]
    assert_select "a.site-nav__link[href=?]", similar_articles_path, text: ApplicationHelper::SEARCH_NAV_TYPES[:similar]
  end

  context "when keywords search is active" do
    before do
      allow(view).to receive(:params).and_return(ActionController::Parameters.new(type: "keywords"))
    end

    it "marks the Keywords link as active" do
      render partial: "shared/header"

      assert_select "a.site-nav__link--active[href=?]", keywords_articles_path, text: ApplicationHelper::SEARCH_NAV_TYPES[:keywords]
      assert_select "a.site-nav__link--active[href=?]", similar_articles_path, count: 0
    end
  end

  context "when similar search is active" do
    before do
      allow(view).to receive(:params).and_return(ActionController::Parameters.new(type: "similar"))
    end

    it "marks the Similar link as active" do
      render partial: "shared/header"

      assert_select "a.site-nav__link--active[href=?]", similar_articles_path, text: ApplicationHelper::SEARCH_NAV_TYPES[:similar]
      assert_select "a.site-nav__link--active[href=?]", keywords_articles_path, count: 0
    end
  end

  context "when not on articles index" do
    before do
      allow(view).to receive(:action_name).and_return("show")
    end

    it "does not mark any link as active" do
      render partial: "shared/header"

      assert_select "a.site-nav__link--active", count: 0
    end
  end
end
