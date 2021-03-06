class Api::V1::BoardsController < BaseApiController
  before_action :authenticate_user_from_token!
  before_action :set_board, only: [:show, :update, :destroy]

  swagger_controller :boards, 'Board Management'

  swagger_model :Board do
    property :depth, :integer, "depth"
    property :board_type, :integer, :optional, "board_type"
    property :category_id, :integer, :optional, "카테고리 아이디"
    property :title, :string, :required, "제목"
    property :body, :string, :required, "본문"
    property :publish, :boolean, :optional, "게시물 공개"
    property :tag_list, :array, :optional, "태그 리스트"
  end

  swagger_api :index do |api|
    summary '게시글 리스트'
    notes '게시글 리스트'
    BaseApiController.add_common_params(api)
    param :query, 'category_id', :integer, :optional, 'category_id'
    # param :query, 'tags', :string, :optional, '쉼표(,)로 구분'
    param :query, 'order', :string, :optional, 'like, bookmark, comment'
    param :query, 'page', :integer, :optional, 'page'
    param :query, 'per_page', :integer, :optional, 'per_page'
    BaseApiController.add_common_response(api)
  end

  swagger_api :show do |api|
    summary '게시글 상세'
    notes '게시글 상세'
    BaseApiController.add_common_params(api)
    param :path, 'id', :integer, :rquired, "id"
    BaseApiController.add_common_response(api)
  end

  swagger_api :create do |api|
    summary '게시글 글 작성'
    notes '게시글 글 작성'
    BaseApiController.add_common_params(api)
    param :form, "board[group_id]", :integer, "group_id"
    param :form, "board[depth]", :integer, "depth"
    param :form, "board[board_type]", :integer, :optional, "board_type"
    param :form, "board[category_id]", :integer, :optional, "카테고리 아이디"
    param :form, "board[title]", :string, :required, "제목"
    param :form, "board[body]", :string, :required, "본문"
    param :form, "board[publish]", :integer, :optional, "게시물 공개"
    param :form, "board[tag_list]", :array, :optional, "태그 리스트"
    BaseApiController.add_common_response(api)
  end

  def index
    @boards = Board.all
    @boards = @boards.post_open
    @boards = @boards.page(params[:page]).per(params[:per_page])

    render_json resource: @boards, meta: get_page_info(@boards).merge(meta_status)
  end

  def show
    render_json resource: @board, meta: meta_status
  end

  def create
    @board = Board.new(board_params)

    # 기본은 qna 타입으로 세팅
    @board.board_type = 'qna'
    @board.board_type = board_params[:board_type] if board_params[:board_type].present?
    @board.attachments = board_params[:attachments].to_json if board_params[:attachments].present?

    if @board.save
      render_json resource: @board, meta: default_meta
    else
      render_error :unprocessable_entity, @board.errors
    end
  end

  private

  def set_board
    @board = Board.find(params[:id])
  end

  def board_params
    params.require(:board).permit(
      :group_id,
      :seq,
      :depth,
      :title,
      :body,
      :board_type,
      :category_id,
      tag_list: [],
      attachments: [],
    ).merge(user_id: current_user.id)
  end
end
