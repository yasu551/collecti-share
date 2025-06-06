class Items::ConversationsController < Items::BaseController
  def show
    @conversation = @item.conversation
  end
end
