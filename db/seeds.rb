# db/seeds.rb

require 'securerandom'

# ---------------------------------------------------
# 【1】ItemTag を先に insert_all で投入（レコード数は少ない想定）
# ---------------------------------------------------
tag_names = %w[フィギュア 会議 カード CD]
# tag_attrs = tag_names.map { |name|
#   { name: name, created_at: Time.current, updated_at: Time.current }
# }
# ItemTag.insert_all(tag_attrs)
all_tag_ids = ItemTag.pluck(:id)

# ---------------------------------------------------
# 【2】User, UserProfile, UserProfileVersion をまとめて一括投入
# ---------------------------------------------------
USER_COUNT = 5_000
# user_attrs = USER_COUNT.times.map { |i|
#   {
#     name:       "User#{i + 1}",
#     email:      "user#{i + 1}@example.com",
#     google_uid: "google_uid_#{i + 1}",
#     created_at: Time.current,
#     updated_at: Time.current
#   }
# }

# # トランザクションでまとめて COMMIt
# ActiveRecord::Base.transaction do
#   # 2-1. User をまとめて insert_all
#   User.insert_all(user_attrs)
#   user_ids = User.pluck(:id)  # 5,000件
#
#   # 2-2. UserProfile をまとめて作成（user_id が NOT NULL のみ想定）
#   up_attrs = user_ids.map { |uid|
#     { user_id: uid, created_at: Time.current, updated_at: Time.current }
#   }
#   UserProfile.insert_all(up_attrs)
#   up_ids = UserProfile.pluck(:id)  # 5,000件
#
#   # 2-3. UserProfileVersion をまとめて作成
#   upv_attrs = up_ids.each_with_index.map { |upid, i|
#     {
#       user_profile_id:    upid,
#       address:            "〒000-000#{i % 10} 東京都〇〇区サンプル#{i + 1}番地",
#       phone_number:       "090-0000-#{format('%04d', i % 10_000)}",
#       bank_account_info:  "銀行口座情報#{i + 1}",
#       created_at:         Time.current,
#       updated_at:         Time.current
#     }
#   }
#   # バッチで小分けに実行
#   upv_attrs.each_slice(1_000) { |batch| UserProfileVersion.insert_all(batch) }
# end
#
# puts "=> Users: #{User.count}, UserProfiles: #{UserProfile.count}, UserProfileVersions: #{UserProfileVersion.count}"

# ---------------------------------------------------
# 【3】Item, ItemVersion, ItemTagging をバッチで投入
# ---------------------------------------------------
ITEMS_PER_USER = 6
user_ids = User.pluck(:id)  # 5,000件
# item_attrs = user_ids.flat_map do |uid|
#   ITEMS_PER_USER.times.map do
#     {
#       user_id:    uid,
#       created_at: Time.current,
#       updated_at: Time.current
#       # → 必須カラムがあれば追加
#     }
#   end
# end

# ActiveRecord::Base.transaction do
#   # 3-1. Item をまとめて挿入 (30,000件)
#   Item.insert_all(item_attrs)
#   item_ids = Item.pluck(:id)  # 30,000件
#
#   # 3-2. ItemVersion をまとめて挿入 (30,000 × 3 = 90,000件)
#   item_version_attrs = item_ids.flat_map do |itid|
#     (1..3).map do |k|
#       {
#         item_id:             itid,
#         name:                "Item#{itid}_Version#{k}",
#         description:         "説明テキスト for Item#{itid} のバージョン #{k}",
#         condition:           %i[acceptable good very_good like_new].sample,
#         daily_price:         500 + (itid % 1000),
#         availability_status: %w[available unavailable].sample,
#         created_at:          Time.current,
#         updated_at:          Time.current
#       }
#     end
#   end
#
#   item_version_attrs.each_slice(10_000) { |batch| ItemVersion.insert_all(batch) }
#   iv_ids = ItemVersion.pluck(:id)  # 90,000件
#
#   # 3-3. ItemTagging をまとめて挿入 (約120,000件)
#   tagging_attrs = iv_ids.flat_map do |ivid|
#     4.times.map do
#       {
#         item_id:      ItemVersion.find(ivid).item_id,
#         item_tag_id:  all_tag_ids.sample,
#         created_at:   Time.current,
#         updated_at:   Time.current
#       }
#     end
#   end
#   tagging_attrs.each_slice(10_000) { |batch| ItemTagging.insert_all(batch) }
# end
#
# puts "=> Items: #{Item.count}, ItemVersions: #{ItemVersion.count}, ItemTaggings: #{ItemTagging.count}"

# ---------------------------------------------------
# 【4】RentalTransaction と各ステータスをバルク投入
# ---------------------------------------------------
TXNS_PER_VERSION = 2
user_ids = User.pluck(:id)
iv_ids   = ItemVersion.pluck(:id)

ActiveRecord::Base.transaction do
  # 4-1. RentalTransaction の作成属性をまずメモリ上で生成
  rt_attrs = iv_ids.flat_map do |ivid|
    TXNS_PER_VERSION.times.map do
      lender   = user_ids.sample
      borrower = (user_ids - [lender]).sample
      {
        lender_id:        lender,
        borrower_id:      borrower,
        item_version_id:  ivid,
        starts_on:        Date.today - rand(1..30),
        ends_on:          Date.today + rand(1..30),
        created_at:       Time.current,
        updated_at:       Time.current
      }
    end
  end

  # 4-2. RentalTransaction をまとめて挿入 (約180,000件)
  rt_attrs.each_slice(10_000) { |batch| RentalTransaction.insert_all(batch) }
  rt_ids = RentalTransaction.pluck(:id)

  # 4-3. 各ステータス（Requested, Approved, …）属性の生成
  requested_attrs = []
  approved_attrs  = []
  rejected_attrs  = []
  shipped_attrs   = []
  completed_attrs = []
  returned_attrs  = []
  paid_attrs      = []

  RentalTransaction.find_each(batch_size: 10_000) do |rt|
    requested_attrs << {
      rental_transaction_id: rt.id,
      requested_at:          rt.starts_on - rand(1..5),
      created_at:            Time.current,
      updated_at:            Time.current
    }
    approved_attrs << {
      rental_transaction_id: rt.id,
      approved_at:           rt.starts_on - rand(0..2),
      created_at:            Time.current,
      updated_at:            Time.current
    }
    # 10% の確率で RejectedRental
    if rand < 0.10
      rejected_attrs << {
        rental_transaction_id: rt.id,
        rejected_at:           rt.starts_on - rand(0..2),
        created_at:            Time.current,
        updated_at:            Time.current
      }
    end
    # 80% の確率で ShippedRental
    shipped_attrs << {
      rental_transaction_id: rt.id,
      shipped_at:            rt.starts_on + rand(0..3),
      created_at:            Time.current,
      updated_at:            Time.current
    } if rand < 0.80

    # CompletedRental の条件
      completed_attrs << {
        rental_transaction_id: rt.id,
        completed_at:          rt.ends_on - rand(0..3),
        created_at:            Time.current,
        updated_at:            Time.current
      }

    # ReturnedRental の条件
      returned_attrs << {
        rental_transaction_id: rt.id,
        returned_at:           rt.ends_on + rand(0..3),
        created_at:            Time.current,
        updated_at:            Time.current
      }

    # PaidRental の条件
    paid_attrs << {
      rental_transaction_id: rt.id,
      paid_at:               rt.ends_on - rand(0..2),
      created_at:            Time.current,
      updated_at:            Time.current
    } if rand < 0.90
  end

  # 4-4. 各ステータステーブルにバッチで insert_all
  RequestedRental.insert_all(requested_attrs.each_slice(10_000).to_a.flatten)
  ApprovedRental.insert_all(approved_attrs.each_slice(10_000).to_a.flatten)
  RejectedRental.insert_all(rejected_attrs.each_slice(10_000).to_a.flatten) unless rejected_attrs.empty?
  ShippedRental.insert_all(shipped_attrs.each_slice(10_000).to_a.flatten) unless shipped_attrs.empty?
  CompletedRental.insert_all(completed_attrs.each_slice(10_000).to_a.flatten) unless completed_attrs.empty?
  ReturnedRental.insert_all(returned_attrs.each_slice(10_000).to_a.flatten) unless returned_attrs.empty?
  PaidRental.insert_all(paid_attrs.each_slice(10_000).to_a.flatten) unless paid_attrs.empty?
end

puts "=> RentalTransactions: #{RentalTransaction.count}"
puts "   RequestedRentals: #{RequestedRental.count}"
puts "   ApprovedRentals : #{ApprovedRental.count}"
puts "   RejectedRentals : #{RejectedRental.count}"
puts "   ShippedRentals  : #{ShippedRental.count}"
puts "   CompletedRentals: #{CompletedRental.count}"
puts "   ReturnedRentals : #{ReturnedRental.count}"
puts "   PaidRentals     : #{PaidRental.count}"

# ---------------------------------------------------
# 【5】QrCode, Review, Conversation, ConversationParticipant, Message を同様にバルク処理
# ---------------------------------------------------

# 例: QrCode & Review
puts "\n=== Bulk insert QrCodes & Reviews… ==="
QrCodeAttrs = []
ReviewAttrs = []

RentalTransaction.pluck(:id, :borrower_id, :starts_on, :ends_on).each do |rt_id, borrower_id, starts_on, ends_on|
  QrCodeAttrs << {
    rental_transaction_id: rt_id,
    user_id:               borrower_id,
    payload:               { code: "QR#{rt_id}-#{SecureRandom.hex(4)}", info: "RentalTransaction##{rt_id}" }.to_json,
    created_at:            Time.current,
    updated_at:            Time.current
  }
  if rand < 0.50
    ReviewAttrs << {
      rental_transaction_id: rt_id,
      user_id:               borrower_id,
      rating:                rand(1..5),
      comment:               "レビュー: RentalTransaction #{rt_id}",
      created_at:            Time.current,
      updated_at:            Time.current
    }
  end
end

QrCode.insert_all(QrCodeAttrs.each_slice(10_000).to_a.flatten)
Review.insert_all(ReviewAttrs.each_slice(10_000).to_a.flatten)

# 例: Conversation (Item → Conversation → ConversationParticipant → Message)
puts "\n=== Bulk insert Conversations & Participants & Messages… ==="
conv_attrs = Item.pluck(:id).map { |item_id|
  { item_id: item_id, created_at: Time.current, updated_at: Time.current }
}
Conversation.insert_all(conv_attrs)
conv_ids = Conversation.pluck(:id)

cp_attrs = []
m_attrs  = []

conv_ids.each do |conv_id|
  2.times { |i| cp_attrs << { conversation_id: conv_id, user_id: User.pluck(:id).sample, created_at: Time.current, updated_at: Time.current } }
  4.times { |m| m_attrs << { conversation_id: conv_id, user_id: ConversationParticipant.find_by(conversation_id: conv_id).user_id, content: "Message##{m + 1} in Conversation##{conv_id}", created_at: Time.current, updated_at: Time.current } }
end

ConversationParticipant.insert_all(cp_attrs.each_slice(10_000).to_a.flatten)
Message.insert_all(m_attrs.each_slice(10_000).to_a.flatten)

puts "=> Conversations: #{Conversation.count}"
puts "=> Participants:  #{ConversationParticipant.count}"
puts "=> Messages:      #{Message.count}"
