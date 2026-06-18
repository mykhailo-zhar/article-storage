class ArticlesController < ApplicationController
  FORBIDDEN_ACTIONS = %i[ new create edit destroy ].freeze

  before_action :forbid_mutations, only: FORBIDDEN_ACTIONS
  before_action :set_article, only: %i[ show edit update destroy ]

  # GET /articles or /articles.json
  def index
    @search_query = params[:search].to_s
    @selected_categories = Array(params[:categories]).map(&:to_sym)
    @page = [ params[:page].to_i, 1 ].max

    search_keywords = Articles::SearchKeywords.new(
      search_query: @search_query,
      categories: @selected_categories,
      page: @page
    )

    @articles = search_keywords.call
    @total_pages = search_keywords.total_pages

    respond_to do |format|
      format.html
      format.json { render json: { articles: @articles, total_pages: @total_pages } }
    end
  rescue RuntimeError => e
    flash.now[:alert] = e.message
    @articles = []
    @total_pages = 0
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
