class RentalTransaction < ApplicationRecord
  belongs_to :lender, class_name: "User", foreign_key: "lender_id"
  belongs_to :borrower, class_name: "User", foreign_key: "borrower_id"
  belongs_to :item_version
  has_one :requested_rental, dependent: :restrict_with_exception
  has_one :rejected_rental, dependent: :restrict_with_exception
  has_one :approved_rental, dependent: :restrict_with_exception
  has_one :paid_rental, dependent: :restrict_with_exception
  has_one :shipped_rental, dependent: :restrict_with_exception
  has_one :returned_rental, dependent: :restrict_with_exception
  has_one :completed_rental, dependent: :restrict_with_exception
  has_many :qr_codes, dependent: :restrict_with_exception

  validates :starts_on, presence: true
  validates :ends_on, presence: true
  validates :borrower_id, uniqueness: { scope: :item_version_id }

  before_validation :set_lender, on: :create
  before_validation :build_requested_rental, on: :create

  scope :latest, -> { order(created_at: :desc, id: :desc) }

  delegate :name, :bank_account_info, to: :lender, prefix: true
  delegate :name, to: :borrower, prefix: true

  def status
    if rejected_rental.present?
      :rejected
    elsif completed_rental.present?
      :completed
    elsif returned_rental.present?
      :returned
    elsif shipped_rental.present?
      :shipped
    elsif paid_rental.present?
      :paid
    elsif approved_rental.present?
      :approved
    elsif requested_rental.present?
      :requested
    else
      :unknown
    end
  end

  def price
    (item_version.daily_price * (ends_on - starts_on + 1)).to_i
  end

  def create_qr_codes!
    transaction do
      qr_codes.create!(user_id: lender.id)
      qr_codes.create!(user_id: borrower.id)
    end
  end

  def borrower_qr_code
    qr_codes.find_by(user_id: borrower.id)
  end

  def lender_qr_code
    qr_codes.find_by(user_id: lender.id)
  end

  private

    def set_lender
      self.lender = item_version.item.user
    end
end
