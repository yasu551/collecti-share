class User::LenderRentalTransactions::ApprovedRentalsController < User::LenderRentalTransactions::BaseController
  def create
    @lender_rental_transaction.create_approved_rental!
    redirect_to user_lender_rental_transaction_url(@lender_rental_transaction), notice: "貸出リクエストを承認しました"
  end
end
