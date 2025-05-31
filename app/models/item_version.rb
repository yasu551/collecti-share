class ItemVersion < ApplicationRecord
  extend Enumerize

  enumerize :condition, in: %i[acceptable good very_good like_new]
  enumerize :availability_status, in: %i[unavailable available]

  belongs_to :item

  validates :name, presence: true
  validates :daily_price, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :latest, -> { order(created_at: :desc) }
end
