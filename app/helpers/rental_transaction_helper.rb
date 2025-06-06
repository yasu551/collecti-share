module RentalTransactionHelper
  def rental_transaction_status_label(rental_transaction:)
    case rental_transaction.status
    when :requested then "リクエスト中"
    when :rejected then "拒否済み"
    when :approved then "承認済み"
    when :paid then "支払い済み"
    when :unknown then "不明"
    else
      raise ArgumentError, "Invalid status: #{status}"
    end
  end
end
