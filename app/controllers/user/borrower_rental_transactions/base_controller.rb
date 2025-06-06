class User::BorrowerRentalTransactions::BaseController < ApplicationController
  before_action :set_borrower_rental_transaction


  private

  def set_borrower_rental_transaction
    @borrower_rental_transaction = current_user.borrower_rental_transactions.find(params[:borrower_rental_transaction_id])
  end
end
