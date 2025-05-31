class ItemsController < ApplicationController
  def index
    @items = Item.all.available.latest
  end
end
