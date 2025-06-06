class User::BorrowerRentalTransactions::ReturnedRentalsController < User::BorrowerRentalTransactions::BaseController
  def create
    @borrower_rental_transaction.create_returned_rental!
    redirect_to user_borrower_rental_transaction_url(@borrower_rental_transaction), notice: "貸出リクエストを返却済みにしました"
  end
end
