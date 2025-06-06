class Items::RentalTransactionsController < Items::BaseController
  def new
    @rental_transaction = current_user.borrower_rental_transactions.build
  end

  def create
    @rental_transaction = current_user.borrower_rental_transactions.build(rental_transaction_params)
    if @rental_transaction.save
      redirect_to user_borrower_rental_transaction_url(@rental_transaction), notice: "貸出リクエストしました"
    else
      render :new, status: :unprocessable_content
    end
  end

  private

    def rental_transaction_params
      params.expect(rental_transaction: %i[starts_on ends_on])
            .merge(item_version: @item.current_item_version)
    end
end
