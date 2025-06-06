class Conversation < ApplicationRecord
  belongs_to :item
  has_many :conversation_participants, dependent: :restrict_with_exception
  has_many :users, through: :conversation_participants
  has_many :messages, through: :users
end
