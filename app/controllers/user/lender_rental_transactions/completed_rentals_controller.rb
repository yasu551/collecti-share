class User::LenderRentalTransactions::CompletedRentalsController < User::LenderRentalTransactions::BaseController
  def create
    @lender_rental_transaction.create_completed_rental!
    redirect_to user_lender_rental_transaction_url(@lender_rental_transaction), notice: "貸出リクエストを完了済みにしました"
  end
end
