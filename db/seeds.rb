# db/seeds.rb

###
# 本ファイルでは、
#  - モデル定義の belongs_to / validates を満たす順序・属性を与えつつ、
#  - 合計レコード数が約 1,000,000 行前後になるように各種ダミーデータを作成します。
#
# 実行前に、以下を確認してください：
#  1) 各モデル（app/models/*.rb）の必須カラム（NOT NULL / presence バリデーション）を把握する
#  2) 一度に大量データを投入するときのパフォーマンス上の工夫（insert_all や activerecord-import 等）を検討する
#  3) 再度実行する場合は db:reset などで事前にデータをクリアする
###

require 'securerandom'

# ================================================================
# 1. ItemTag を先に登録しておく（ItemTagging の外部キー制約を満たすため）
# ================================================================
tag_names = %w[フィギュア 会議 カード CD]
tag_names.each do |name|
  # すでに存在すれば無視、それ以外は作成
  ItemTag.find_or_create_by!(name: name)
end
all_tags = ItemTag.all.to_a  # ItemTagging でランダム紐付けに使う

puts "=> ItemTag: #{ItemTag.count}"

# ================================================================
# 2. ユーザー周りのデータを作成
#   User → UserProfile → UserProfileVersion
# ================================================================
USER_COUNT = 5_000

puts "\n=== Creating Users, UserProfiles, UserProfileVersions… ==="
users = []

USER_COUNT.times do |i|
  # --------------------------
  # 2.1. User を作成
  #  - 必須カラム：name, email, google_uid (仮定)
  # --------------------------
  u = User.create!(
    name:       "User#{i + 1}",
    email:      "user#{i + 1}@example.com",
    google_uid: "google_uid_#{i + 1}"
  )
  users << u

  # --------------------------
  # 2.2. UserProfile を作成
  #  - UserProfile モデルで必須の欄があればここで追加
  #    （例：profile_picture_url, bio などが無ければ特になし）
  # --------------------------
  up = UserProfile.create!(
    user: u
  # → もし UserProfile に必須バリデーションがあれば、
  #    ここで image_url: "", bio: "" などを与える
  )

  # --------------------------
  # 2.3. UserProfileVersion を 1件作成
  #  - app/models/user_profile_version.rb にて、
  #    - belongs_to :user_profile（外部キー必須）
  #    - validates :address, :phone_number, :bank_account_info, presence: true
  #  のため、必須属性を全て与える
  # --------------------------
  UserProfileVersion.create!(
    user_profile:    up,
    address:         "〒000-000#{i % 10} 東京都〇〇区サンプル#{i + 1}番地",
    phone_number:    "090-0000-#{format('%04d', i % 10_000)}",
    bank_account_info: "銀行口座情報#{i + 1}"
  )
end

puts "=> Users: #{User.count}"
puts "=> UserProfiles: #{UserProfile.count}"
puts "=> UserProfileVersions: #{UserProfileVersion.count}"

# ================================================================
# 3. Item 周りのデータを作成
#   Item → ItemVersion → ItemTagging
# ================================================================
#  3.1. 1ユーザーあたり平均6アイテム（ITEMS_PER_USER）ずつ作成 ⇒ 約30,000件
ITEMS_PER_USER = 6
puts "\n=== Creating Items… ==="
items = []

users.each do |u|
  ITEMS_PER_USER.times do |j|
    # --------------------------
    # 3.1.1. Item を作成
    #  - app/models/item.rb にて必須カラムがないか要確認
    #  - ここでは、user_id 以外に必須バリデーションがないものと仮定
    # --------------------------
    it = Item.create!(
      user:       u
    # → もし Item に title, description など必須があれば追記
    )
    items << it
  end
end
puts "=> Items: #{Item.count}"

#  3.2. 1アイテムあたり3バージョン（VERSIONS_PER_ITEM）ずつ作成 ⇒ 約90,000件
VERSIONS_PER_ITEM = 3
puts "\n=== Creating ItemVersions… ==="
item_versions = []

items.each do |it|
  VERSIONS_PER_ITEM.times do |k|
    # --------------------------
    # 3.2.1. ItemVersion を作成
    #  - app/models/item_version.rb にて、必須バリデーションを満たす属性を与える
    #    (例: name, description, condition, daily_price, availability_status)
    # --------------------------
    iv = ItemVersion.create!(
      item:                it,
      name:                "Item#{it.id}_Version#{k + 1}",
      description:         "説明テキスト for Item#{it.id} のバージョン #{k + 1}",
      condition:           %i[acceptable good very_good like_new].sample,               # 仮定：presence
      daily_price:         500 + (it.id % 1000),                     # 仮定：presence/numericality
      availability_status: %w[available unavailable].sample          # 仮定：presence
    # → もし他に必須カラムがあればここに追記
    )
    item_versions << iv
  end
end
puts "=> ItemVersions: #{ItemVersion.count}"

#  3.3. ItemTagging をランダムに付与（1アイテムあたり平均で4件ずつ ⇒ 約120,000件）
TAGGINGS_PER_ITEM = 4
puts "\n=== Creating ItemTaggings… ==="
item_versions.each do |iv|
  TAGGINGS_PER_ITEM.times do
    # --------------------------
    # 3.3.1. ItemTagging を作成
    #  - belongs_to :item, belongs_to :item_tag を満たす
    # --------------------------
    ItemTagging.create!(
      item:     iv.item,
      item_tag: all_tags.sample
    # → もし ItemTagging に他のバリデーション(例: uniqueness)があれば要注意
    )
  end
end
puts "=> ItemTaggings: #{ItemTagging.count}"


# ================================================================
# 4. RentalTransaction 周りのデータを作成
#   ItemVersion → RentalTransaction → 各種ステータステーブル
# ================================================================
#  4.1. 1バージョンあたり2件（TXNS_PER_VERSION）の取引を作成 ⇒ 約180,000件
TXNS_PER_VERSION = 2
puts "\n=== Creating RentalTransactions… ==="
rental_transactions = []

item_versions.each do |iv|
  TXNS_PER_VERSION.times do
    # 借り手と貸し手をランダムに選ぶ（重複しないようにサンプル）
    lender   = users.sample
    borrower = (users - [lender]).sample

    # --------------------------
    # 4.1.1. RentalTransaction を作成
    #  - belongs_to :lender (User), belongs_to :borrower (User), belongs_to :item_version
    #  - 開始日・終了日（starts_on, ends_on）が必須
    #  - もし他に必須カラムがあれば追記
    # --------------------------
    rt = RentalTransaction.create!(
      lender_id:       lender.id,
      borrower_id:     borrower.id,
      item_version:    iv,
      starts_on:       Date.today - rand(1..30),
      ends_on:         Date.today + rand(1..30)
    )
    rental_transactions << rt
  end
end
puts "=> RentalTransactions: #{RentalTransaction.count}"

#  4.2. 各種ステータステーブル（RequestedRental, ApprovedRental, …）に紐づけて作成 ⇒ 約360,000件
puts "\n=== Creating Rental Status Records… ==="
rental_transactions.each do |rt|
  # --------------------------
  # RequestedRental（必須: rental_transaction_id, requested_at）
  # --------------------------
  RequestedRental.create!(
    rental_transaction: rt,
    requested_at:       rt.starts_on - rand(1..5)
  )

  # --------------------------
  # ApprovedRental（必須: rental_transaction_id, approved_at）
  # --------------------------
  ApprovedRental.create!(
    rental_transaction: rt,
    approved_at:        rt.starts_on - rand(0..2)
  )

  # --------------------------
  # RejectedRental（任意: 10% のみ作成）
  # --------------------------
  if rand < 0.10
    RejectedRental.create!(
      rental_transaction: rt,
      rejected_at:        rt.starts_on - rand(0..2)
    )
  end

  # --------------------------
  # ShippedRental（任意: 80% のみ作成）
  # --------------------------
  if rand < 0.80
    ShippedRental.create!(
      rental_transaction: rt,
      shipped_at:         rt.starts_on + rand(0..3)
    )
  end

  # --------------------------
  # CompletedRental（任意: shipped があれば 100%、なければ 80% の確率）
  # --------------------------
  if rt.shipped_rental.present? || rand < 0.80
    CompletedRental.create!(
      rental_transaction: rt,
      completed_at:       rt.ends_on - rand(0..3)
    )
  end

  # --------------------------
  # ReturnedRental（任意: completed があれば 100%、なければ 70% の確率）
  # --------------------------
  if rt.completed_rental.present? || rand < 0.70
    ReturnedRental.create!(
      rental_transaction: rt,
      returned_at:        rt.ends_on + rand(0..3)
    )
  end

  # --------------------------
  # PaidRental（任意: 90% の確率）
  # --------------------------
  if rand < 0.90
    PaidRental.create!(
      rental_transaction: rt,
      paid_at:            rt.ends_on - rand(0..2)
    )
  end
end

puts "=> RequestedRentals: #{RequestedRental.count}"
puts "=> ApprovedRentals:  #{ApprovedRental.count}"
puts "=> RejectedRentals:  #{RejectedRental.count}"
puts "=> ShippedRentals:   #{ShippedRental.count}"
puts "=> CompletedRentals: #{CompletedRental.count}"
puts "=> ReturnedRentals:  #{ReturnedRental.count}"
puts "=> PaidRentals:      #{PaidRental.count}"


# ================================================================
# 5. QrCode & Review を作成
#   RentalTransaction → QrCode, Review
# ================================================================
puts "\n=== Creating QrCodes and Reviews… ==="
rental_transactions.each do |rt|
  # --------------------------
  # QrCode（必須: rental_transaction_id, user_id, payload）
  #  - payload が JSON 型のカラムと仮定し、ハッシュを与える
  # --------------------------
  QrCode.create!(
    rental_transaction: rt,
    user:               rt.borrower,
    payload: {
      code: "QR#{rt.id}-#{SecureRandom.hex(4)}",
      info: "RentalTransaction##{rt.id} の QR コード"
    }
  )

  # --------------------------
  # Review（任意: 50% の確率で作成）
  #  - 必須: rental_transaction_id, user_id, rating, comment
  # --------------------------
  if rand < 0.50
    Review.create!(
      rental_transaction: rt,
      user:               rt.borrower,
      rating:             rand(1..5),
      comment:            "レビュー: RentalTransaction #{rt.id} に対するコメント"
    )
  end
end

puts "=> QrCodes: #{QrCode.count}"
puts "=> Reviews: #{Review.count}"


# ================================================================
# 6. Conversation & Message 系を作成
#   Item → Conversation → ConversationParticipant → Message
# ================================================================
#  6.1. 1アイテムにつき1件 Conversation（約30,000件）
puts "\n=== Creating Conversations… ==="
conversations = []

items.each do |it|
  # --------------------------
  # Conversation（必須: item_id）
  # --------------------------
  conv = Conversation.create!(
    item: it
  # → もし Conversation にタイトルやステータス必須があれば追記
  )
  conversations << conv
end
puts "=> Conversations: #{Conversation.count}"

#  6.2. 1会話につき2人の参加者を ConversationParticipant で作成（約60,000件）
puts "\n=== Creating ConversationParticipants… ==="
conversations.each do |conv|
  participants = users.sample(2)
  participants.each do |u|
    # --------------------------
    # ConversationParticipant（必須: conversation_id, user_id）
    # --------------------------
    ConversationParticipant.create!(
      conversation: conv,
      user:         u
    )
  end
end
puts "=> ConversationParticipants: #{ConversationParticipant.count}"

#  6.3. 1会話につき4件の Message（約120,000件）
MESSAGES_PER_CONVERSATION = 4
puts "\n=== Creating Messages… ==="
conversations.each do |conv|
  MESSAGES_PER_CONVERSATION.times do |m|
    # ランダムに参加者のいずれかを投稿者とする
    author = conv.conversation_participants.sample.user
    # --------------------------
    # Message（必須: conversation_id, user_id, content）
    # --------------------------
    Message.create!(
      conversation: conv,
      user:         author,
      content:      "Message ##{m + 1} in Conversation ##{conv.id}"
    )
  end
end
puts "=> Messages: #{Message.count}"


# ================================================================
# 7. 最終サマリー
# ================================================================
puts "\n=== Seed Summary ==="
puts "Users              : #{User.count}"
puts "UserProfiles       : #{UserProfile.count}"
puts "UserProfileVersions: #{UserProfileVersion.count}"
puts "Items              : #{Item.count}"
puts "ItemVersions       : #{ItemVersion.count}"
puts "ItemTags           : #{ItemTag.count}"
puts "ItemTaggings       : #{ItemTagging.count}"
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

puts "\n✅ db:seed 完了！総レコード数: #{[
  User.count,
  UserProfile.count,
  UserProfileVersion.count,
  Item.count,
  ItemVersion.count,
  ItemTag.count,
  ItemTagging.count,
  RentalTransaction.count,
  RequestedRental.count,
  ApprovedRental.count,
  RejectedRental.count,
  ShippedRental.count,
  CompletedRental.count,
  ReturnedRental.count,
  PaidRental.count,
  QrCode.count,
  Review.count,
  Conversation.count,
  ConversationParticipant.count,
  Message.count
].sum } 件"
