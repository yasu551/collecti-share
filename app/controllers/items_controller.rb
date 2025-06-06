class ItemsController < ApplicationController
  def index
    @items = Item.all.available.partial_match(params[:keyword]).latest.page(params[:page])
  end

  def show
    @item = Item.find(params[:id])
  end
end
