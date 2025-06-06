class Conversation < ApplicationRecord
  belongs_to :item
  has_many :conversation_participants, dependent: :restrict_with_exception
end
