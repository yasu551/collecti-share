class User::BorrowerRentalTransactions::ReviewsController < User::BorrowerRentalTransactions::BaseController
  def new
    @review = @borrower_rental_transaction.reviews.build
  end

  def create
    @review = @borrower_rental_transaction.reviews.build(review_params)
    if @review.save
      redirect_to user_borrower_rental_transaction_url(@borrower_rental_transaction), notice: "レビューしました"
    else
      render :new, status: :unprocessable_content
    end
  end

  private

    def review_params
      params.expect(review: %i[rating comment]).merge(user_id: @borrower_rental_transaction.borrower.id)
    end
end
