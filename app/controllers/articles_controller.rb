class ArticlesController < ApplicationController
  FORBIDDEN_ACTIONS = %i[ new create edit destroy ].freeze

  before_action :forbid_mutations, only: FORBIDDEN_ACTIONS
  before_action :set_article, only: %i[ show edit update destroy ]

  # GET /articles or /articles.json
  def index
    @search_query = params[:search].to_s
    @selected_categories = selected_categories
    @page = [ params[:page].to_i, 1 ].max
    @type = params[:type]&.to_sym || :keywords

    result = Articles::SearchFactory.call(
      search_query: @search_query,
      categories: @selected_categories.values.flatten,
      page: @page,
      type: @type
    )

    @articles = result[:articles]
    @total_pages = result[:total_pages]
  rescue RuntimeError => e
    flash.now[:alert] = e.message
    @articles = []
    @total_pages = 0
  ensure
    @presenter = Articles::ArticlesPresenter.new(
      articles: @articles,
      search_query: @search_query,
      type: @type,
      selected_categories: @selected_categories,
      page: @page,
      total_pages: @total_pages,
      context: self
    )

    respond_to do |format|
      format.html { render :index }
      format.json { render json: @presenter }
    end
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

    def selected_categories
      params.to_unsafe_h.filter_map do |key,  value|
        [ key.to_s.gsub("categories_", "").to_i, Array(value).filter_map { |v| v.to_i if v.present? } ] if key.start_with?("categories_")
      end.to_h
    end

    # Only allow a list of trusted parameters through.
    def article_params
      params.expect(article: [ :title, :excerpt, :wordpress_url, :wordpress_id, :published_at, { category_ids: [] } ])
    end
end
