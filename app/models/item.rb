class Item < ApplicationRecord
  belongs_to :user
  has_one :current_item_version, -> { latest }, class_name: "ItemVersion"
  has_many :item_versions, dependent: :restrict_with_exception
  accepts_nested_attributes_for :item_versions, reject_if: :all_blank

  delegate :name, :description, :condition, :daily_price, :availability_status, to: :current_item_version, allow_nil: true

  scope :latest, -> { order(created_at: :desc) }

  class << self
    def available
      item_ids = all.filter_map { _1.id if _1.current_item_version&.available? }
      where(id: item_ids)
    end
  end

  def build_from_current_item_version
    item_versions.build(name:, description:, condition:, daily_price:, availability_status:)
  end
end
