class User::LenderRentalTransactions::ReviewsController < User::LenderRentalTransactions::BaseController
  def new
    @review = @lender_rental_transaction.reviews.build
  end

  def create
    @review = @lender_rental_transaction.reviews.build(review_params)
    if @review.save
      redirect_to user_lender_rental_transaction_url(@lender_rental_transaction), notice: "レビューしました"
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def review_params
    params.expect(review: %i[rating comment]).merge(user_id: @lender_rental_transaction.lender.id)
  end
end
