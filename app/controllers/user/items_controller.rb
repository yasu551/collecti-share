class User::ItemsController < ApplicationController
  before_action :set_item, only: %i[show edit]

  def index
    @items = current_user.items.latest
  end

  def show
  end

  def new
    @item = current_user.items.build
    @item.item_versions.build
  end

  def create
    @item = current_user.items.build(new_item_params)
    if @item.save
      redirect_to user_item_path(@item), notice: "アイテムを作成しました"
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @item_version = @item.build_from_current_item_version
  end

  def update
    @item_version = @item.item_versions.build(edit_item_params)
    if @item_version.save
      redirect_to user_item_path(@item), notice: "アイテムを更新しました"
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

    def set_item
      @item = current_user.items.find(params[:id])
    end

    def item_version_keys
      %i[name description condition daily_price availability_status]
    end

    def new_item_params
      params.expect(item: { item_versions_attributes: [ item_version_keys ] })
    end

    def edit_item_params
      params.expect(item_version: item_version_keys)
    end
end
