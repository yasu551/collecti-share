class Items::BaseController < ApplicationController
  before_action :set_item

  private

    def set_item
      @item = Item.find(params[:item_id])
    end
end
