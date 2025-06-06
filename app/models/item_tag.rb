class ItemTag < ApplicationRecord
  scope :latest, -> { order(created_at: :desc, id: :desc) }
end
