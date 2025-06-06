class User::LenderRentalTransactionsController < ApplicationController
  before_action :set_lender_rental_transaction, only: %i[show]

  def index
    @lender_rental_transactions = current_user.lender_rental_transactions.latest.page(params[:page])
  end

  def show
  end

  private

    def set_lender_rental_transaction
      @lender_rental_transaction = current_user.lender_rental_transactions.find(params[:id])
    end
end
