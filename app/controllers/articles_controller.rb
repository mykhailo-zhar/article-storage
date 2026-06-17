class ArticlesController < ApplicationController
  FORBIDDEN_ACTIONS = %i[ new create edit destroy ].freeze

  before_action :forbid_mutations, only: FORBIDDEN_ACTIONS
  before_action :set_article, only: %i[ show edit update destroy ]

  # GET /articles or /articles.json
  def index
    @articles = Article.all
  end

  # GET /articles/1 or /articles/1.json
  def show
  end

  # GET /articles/new
  def new
  end

  # GET /articles/1/edit
  def edit
  end

  # POST /articles or /articles.json
  def create
  end

  # PATCH/PUT /articles/1 or /articles/1.json
  def update
  end

  # DELETE /articles/1 or /articles/1.json
  def destroy
  end

  private
    def forbid_mutations
      head :forbidden
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def article_params
      params.expect(article: [ :title, :excerpt, :wordpress_url, :wordpress_id, :published_at, { category_ids: [] } ])
    end
end
