class User::LenderRentalTransactions::PaidRentalsController < User::LenderRentalTransactions::BaseController
  def create
    @lender_rental_transaction.create_paid_rental!
    redirect_to user_lender_rental_transaction_url(@lender_rental_transaction), notice: "貸出リクエストを支払い済みにしました"
  end
end
