require "rails_helper"

RSpec.describe "shared/_footer", type: :view do
  it "renders a link to the GitHub repository" do
    render partial: "shared/footer"

    assert_select "footer.site-footer"
    assert_select "a.site-footer__link[href=?][target=?][rel=?]",
      "https://github.com/mykhailo-zhar/article-storage",
      "_blank",
      "noopener",
      text: "GitHub"
  end
end
