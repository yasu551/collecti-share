class User::BorrowerRentalTransactionsController < ApplicationController
  before_action :set_borrower_rental_transaction, only: %i[show]

  def index
    @borrower_rental_transactions = current_user.borrower_rental_transactions.latest.page(params[:page])
  end

  def show
  end

  private

  def set_borrower_rental_transaction
    @borrower_rental_transaction = current_user.borrower_rental_transactions.find(params[:id])
  end
end
