class User::LenderRentalTransactions::RejectedRentalsController < User::LenderRentalTransactions::BaseController
  def create
    @lender_rental_transaction.create_rejected_rental!
    redirect_to user_lender_rental_transaction_url(@lender_rental_transaction), notice: "貸出リクエストを拒否しました"
  end
end
