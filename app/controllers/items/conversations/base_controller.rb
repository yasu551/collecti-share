class Items::Conversations::BaseController < Items::BaseController
  before_action :set_conversation

  private

    def set_conversation
      @conversation = @item.conversation
    end
end
