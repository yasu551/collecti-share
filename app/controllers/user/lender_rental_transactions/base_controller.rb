class User::LenderRentalTransactions::BaseController < ApplicationController
  before_action :set_lender_rental_transaction


  private

  def set_lender_rental_transaction
    @lender_rental_transaction = current_user.lender_rental_transactions.find(params[:lender_rental_transaction_id])
  end
end
