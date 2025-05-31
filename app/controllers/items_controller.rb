class ItemsController < ApplicationController
  def index
    @items = Item.all.available.partial_match(params[:keyword]).latest
  end

  def show
    @item = Item.find(params[:id])
  end
end
