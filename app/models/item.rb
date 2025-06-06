class Item < ApplicationRecord
  belongs_to :user
  has_one :current_item_version, -> { latest }, class_name: "ItemVersion"
  has_one :conversation, dependent: :restrict_with_exception
  has_many :item_versions, dependent: :restrict_with_exception
  accepts_nested_attributes_for :item_versions, reject_if: :all_blank

  after_create do
    self.conversation = build_conversation
    conversation.conversation_participants.build(user:)
    conversation.save!
  end

  delegate :name, :description, :condition, :daily_price, :availability_status, to: :current_item_version, allow_nil: true
  delegate :name, :bank_account_info, to: :user, prefix: true

  scope :latest, -> { order(created_at: :desc) }
  scope :available, -> do
    latest_versions = ItemVersion.select("DISTINCT ON (item_id) id, item_id, availability_status")
                                 .order("item_id, created_at DESC")
    join_clause = <<~SQL
      INNER JOIN (#{latest_versions.to_sql}) AS available_latest_versions
              ON items.id = available_latest_versions.item_id
    SQL
    joins(join_clause).where("available_latest_versions.availability_status = ?", ItemVersion.availability_status.available)
  end
  scope :partial_match, ->(keyword) do
    return all if keyword.blank?

    latest_versions = ItemVersion.select("DISTINCT ON (item_id) id, item_id, name, description")
                                 .order("item_id, created_at DESC")
    join_clause = <<~SQL
      INNER JOIN (#{latest_versions.to_sql}) AS partial_match_latest_versions
              ON items.id = partial_match_latest_versions.item_id
    SQL
    pattern = "%#{sanitize_sql_like(keyword)}%"
    where_clause = <<~SQL
        partial_match_latest_versions.name ILIKE :pattern
      OR partial_match_latest_versions.description ILIKE :pattern
    SQL
    joins(join_clause).where(where_clause, pattern:)
  end

  def build_from_current_item_version
    item_versions.build(name:, description:, condition:, daily_price:, availability_status:)
  end
end
