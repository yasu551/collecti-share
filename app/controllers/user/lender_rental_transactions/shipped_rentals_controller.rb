class User::LenderRentalTransactions::ShippedRentalsController < User::LenderRentalTransactions::BaseController
  def create
    @lender_rental_transaction.create_shipped_rental!
    redirect_to user_lender_rental_transaction_url(@lender_rental_transaction), notice: "貸出リクエストを発送済みにしました"
  end
end
