# db/seeds.rb

# ============================================
# 1. 固定タグを登録（ItemTag）
# ============================================
item_tag_names = %w[フィギュア 会議 カード CD]
item_tag_names.each do |name|
  ItemTag.find_or_create_by!(name: name)
end
tags = ItemTag.all.to_a  # ランダムに紐づける用

# ============================================
# 2. ユーザー関連
# ============================================
# 2.1. Userを5,000件作成
USER_COUNT = 5_000

puts "=== Creating #{USER_COUNT} Users, UserProfiles, UserProfileVersions… ==="
users = []
USER_COUNT.times do |i|
  u = User.create!(
    name:  "User#{i + 1}",
    email: "user#{i + 1}@example.com",
    google_uid: "google_uid_#{i + 1}"
  )
  users << u

  # 2.2. UserProfile を作成
  profile = UserProfile.create!(user: u)

  # 2.3. UserProfileVersion を1件作成（バージョン履歴として）
  UserProfileVersion.create!(
    user_profile: profile,
    address:      "〒000-000#{i % 10} 東京都〇〇区サンプル#{i + 1}番地",
    phone_number: "090-0000-#{format('%04d', i % 10_000)}",
    bank_account_info: "銀行口座情報#{i + 1}"
  )
end
puts "=> Users: #{User.count}, UserProfiles: #{UserProfile.count}, UserProfileVersions: #{UserProfileVersion.count}"

# ============================================
# 3. アイテム関連
# ============================================
# 3.1. 1ユーザーあたり平均6アイテムずつ作成 => 合計 30,000件
ITEMS_PER_USER = 6
puts "=== Creating Items (#{users.size * ITEMS_PER_USER} 件)… ==="
items = []
users.each do |u|
  ITEMS_PER_USER.times do |j|
    it = Item.create!(user: u)
    items << it
  end
end
puts "=> Items: #{Item.count}"

# 3.2. 1アイテムあたり3バージョンずつ作成 => 合計 90,000件
VERSIONS_PER_ITEM = 3
puts "=== Creating ItemVersions (#{items.size * VERSIONS_PER_ITEM} 件)… ==="
item_versions = []
items.each do |it|
  VERSIONS_PER_ITEM.times do |k|
    iv = ItemVersion.create!(
      item:        it,
      name:        "Item#{it.id}_Version#{k + 1}",
      description: "説明テキスト for Item#{it.id} のバージョン #{k + 1}",
      condition:   %w[good fair worn].sample,
      daily_price: (500 + (it.id % 1000)),  # ダミー価格
      availability_status: %w[available unavailable].sample
    )
    item_versions << iv
  end
end
puts "=> ItemVersions: #{ItemVersion.count}"

# 3.3. ItemTagging をランダムに付与（1アイテムあたり平均4タグずつ、合計約120,000件）
TAGGINGS_PER_ITEM = 4
puts "=== Creating ItemTaggings (約#{items.size * TAGGINGS_PER_ITEM} 件)… ==="
item_versions.each do |iv|
  TAGGINGS_PER_ITEM.times do
    ItemTagging.create!(item: iv.item, item_tag: tags.sample)
  end
end
puts "=> ItemTaggings: #{ItemTagging.count}"

# ============================================
# 4. レンタル取引関連
# ============================================
# 4.1. 1バージョンあたり2件の取引を作成 => 合計 90,000 * 2 = 180,000件
TXNS_PER_VERSION = 2
puts "=== Creating RentalTransactions (#{item_versions.size * TXNS_PER_VERSION} 件)… ==="
rental_transactions = []
item_versions.each do |iv|
  TXNS_PER_VERSION.times do |l|
    # ランダムに貸し手・借り手を選択（ユーザー同士が重複しないように簡易的に sample）
    lender   = users.sample
    borrower = (users - [lender]).sample

    rt = RentalTransaction.create!(
      lender_id:       lender.id,
      borrower_id:     borrower.id,
      item_version_id: iv.id,
      starts_on:       Date.today - rand(1..30),
      ends_on:         Date.today + rand(1..30)
    )
    rental_transactions << rt
  end
end
puts "=> RentalTransactions: #{RentalTransaction.count}"

# 4.2. 各ステータステーブルに1件ずつ紐づけ（概ね合計約360,000件）
puts "=== Creating Rental Status Records (Requested, Approved, Rejected, Shipped, Completed, Returned, Paid) … ==="
rental_transactions.each do |rt|
  # RequestedRental はすべてに作成
  RequestedRental.create!(rental_transaction: rt, requested_at: rt.starts_on - rand(1..5))

  # ApprovedRental はすべてに作成
  ApprovedRental.create!(rental_transaction: rt, approved_at: rt.starts_on - rand(0..2))

  # RejectedRental はランダムで 10% のみ作成
  if rand < 0.10
    RejectedRental.create!(rental_transaction: rt, rejected_at: rt.starts_on - rand(0..2))
  end

  # ShippedRental は借り手が存在するもののうち 80% に作成
  if rand < 0.80
    ShippedRental.create!(rental_transaction: rt, shipped_at: rt.starts_on + rand(0..3))
  end

  # CompletedRental は shipped があるもののうち 80% に作成
  if rt.shipped_rental.present? || rand < 0.80
    CompletedRental.create!(rental_transaction: rt, completed_at: rt.ends_on - rand(0..3))
  end

  # ReturnedRental は completed があるもののうち 70% に作成
  if rt.completed_rental.present? || rand < 0.70
    ReturnedRental.create!(rental_transaction: rt, returned_at: rt.ends_on + rand(0..3))
  end

  # PaidRental は借り手が支払いをした想定で 90% に作成
  if rand < 0.90
    PaidRental.create!(rental_transaction: rt, paid_at: rt.ends_on - rand(0..2))
  end
end

puts "=> RequestedRentals: #{RequestedRental.count}"
puts "=> ApprovedRentals: #{ApprovedRental.count}"
puts "=> RejectedRentals: #{RejectedRental.count}"
puts "=> ShippedRentals: #{ShippedRental.count}"
puts "=> CompletedRentals: #{CompletedRental.count}"
puts "=> ReturnedRentals: #{ReturnedRental.count}"
puts "=> PaidRentals: #{PaidRental.count}"

# ============================================
# 5. QRコードとレビュー
# ============================================
puts "=== Creating QrCodes and Reviews for each RentalTransaction … ==="
rental_transactions.each do |rt|
  # QrCode を 1 件ずつ作成
  QrCode.create!(
    rental_transaction: rt,
    user:               rt.borrower,   # 借り手として紐づけ
    payload:            {
      code:  "QR#{rt.id}-#{SecureRandom.hex(4)}",
      info:  "RentalTransaction##{rt.id} 用 QR"
    }
  )

  # レビューをランダムに 50% の確率で作成
  if rand < 0.50
    Review.create!(
      rental_transaction: rt,
      user:               rt.borrower,
      rating:             rand(1..5),
      comment:            "レビューコメント for RentalTransaction #{rt.id}"
    )
  end
end
puts "=> QrCodes: #{QrCode.count}"
puts "=> Reviews: #{Review.count}"

# ============================================
# 6. 会話・メッセージ関連
# ============================================
# 6.1. 1アイテムあたり1件 Conversation（30,000件）
puts "=== Creating Conversations (#{items.size} 件)… ==="
conversations = []
items.each do |it|
  conv = Conversation.create!(item: it)
  conversations << conv
end
puts "=> Conversations: #{Conversation.count}"

# 6.2. ConversationParticipant を 1 会話あたり 2 人で紐づけ（60,000件）
puts "=== Creating ConversationParticipants ( 約#{conversations.size * 2} 件)… ==="
conversations.each do |conv|
  participants = users.sample(2)
  participants.each do |u|
    ConversationParticipant.create!(conversation: conv, user: u)
  end
end
puts "=> ConversationParticipants: #{ConversationParticipant.count}"

# 6.3. 1会話あたり 4 件ずつ Message を作成（約120,000件）
MESSAGES_PER_CONVERSATION = 4
puts "=== Creating Messages (約#{conversations.size * MESSAGES_PER_CONVERSATION} 件)… ==="
conversations.each do |conv|
  MESSAGES_PER_CONVERSATION.times do |m|
    # ランダムに参加者のいずれかを投稿者とする
    author = conv.conversation_participants.sample.user
    Message.create!(
      conversation: conv,
      user:         author,
      content:      "Message##{m + 1} in Conversation##{conv.id}"
    )
  end
end
puts "=> Messages: #{Message.count}"

# ============================================
# 7. 最終確認
# ============================================
puts "\n=== Summary ==="
puts "Users              : #{User.count}"
puts "UserProfiles       : #{UserProfile.count}"
puts "UserProfileVersions: #{UserProfileVersion.count}"
puts "Items              : #{Item.count}"
puts "ItemVersions       : #{ItemVersion.count}"
puts "ItemTaggings       : #{ItemTagging.count}"
puts "ItemTags           : #{ItemTag.count}"
puts "RentalTransactions : #{RentalTransaction.count}"
puts "RequestedRentals   : #{RequestedRental.count}"
puts "ApprovedRentals    : #{ApprovedRental.count}"
puts "RejectedRentals    : #{RejectedRental.count}"
puts "ShippedRentals     : #{ShippedRental.count}"
puts "CompletedRentals   : #{CompletedRental.count}"
puts "ReturnedRentals    : #{ReturnedRental.count}"
puts "PaidRentals        : #{PaidRental.count}"
puts "QrCodes            : #{QrCode.count}"
puts "Reviews            : #{Review.count}"
puts "Conversations      : #{Conversation.count}"
puts "Participants       : #{ConversationParticipant.count}"
puts "Messages           : #{Message.count}"

puts "\n✅ Seed complete! Total records: #{User.count + UserProfile.count + UserProfileVersion.count + Item.count + ItemVersion.count + ItemTagging.count + RentalTransaction.count + RequestedRental.count + ApprovedRental.count + RejectedRental.count + ShippedRental.count + CompletedRental.count + ReturnedRental.count + PaidRental.count + QrCode.count + Review.count + Conversation.count + ConversationParticipant.count + Message.count}"
