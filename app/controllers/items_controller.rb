class ItemsController < ApplicationController
  def index
    @items = Item.all.available.partial_match(params[:keyword]).latest
  end
end
