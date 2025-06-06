class ItemTagging < ApplicationRecord
  belongs_to :item
  belongs_to :item_tag
end
