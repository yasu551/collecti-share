item_tag_names = %w[フィギュア 会議 カード CD]
item_tag_names.each do |name|
  ItemTag.find_or_create_by(name:)
end
