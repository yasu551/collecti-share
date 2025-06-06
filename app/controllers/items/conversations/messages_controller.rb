class Items::Conversations::MessagesController < Items::Conversations::BaseController
  def create
    @message = current_user.messages.build(message_params)
    @message.save!
    redirect_to item_conversation_path(@item), notice: "メッセージを送信しました"
  end

  private

    def message_params
      params.expect(message: %i[content]).merge(conversation_id: @conversation.id)
    end
end
