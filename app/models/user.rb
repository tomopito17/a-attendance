class User < ApplicationRecord
  has_many :attendances, dependent: :destroy
  # 「remember_token」という仮想の属性を作成します。
  attr_accessor :remember_token
  before_save { self.email = email.downcase }
  
  validates :name, presence: true, length: { maximum: 50 }
  
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  validates :department, length: { in: 2..30 }, allow_blank: true #9.1
  validates :basic_time, presence: true #9.2
  validates :work_time, presence: true #9.2
  has_secure_password #4.5
  validates :password, presence: true, length: { minimum: 2 }, allow_nil: true#8.12allow

  # 渡された文字列のハッシュ値を返します。
  def User.digest(string)
    cost = 
      if ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end
    BCrypt::Password.create(string, cost: cost)
  end
  
    # ランダムなトークンを返します。
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためハッシュ化したトークンをデータベースに記憶します。
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # トークンがダイジェストと一致すればtrueを返します。
  def authenticated?(remember_token)
    # ダイジェストが存在しない場合はfalseを返して終了します。
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

    # ユーザーのログイン情報を破棄します。
  def forget
    update_attribute(:remember_digest, nil)
  end

  def self.search(search) #ここでのself.はUser.を意味する No9ユーザ検索
    if search
      where(['name LIKE ?', "%#{search}%"]) #検索とnameの部分一致を表示。User.は省略
    else
      all #全て表示。User.は省略
    end
  end

# def self.import_csv(file)
#   CSV.foreach(file.path, 'r:cp932:utf8', headers:true) do |row|
#     user = new
#     user.attributes = row.to_hash.slice(*csv_attributes)
#     user.save!
#   end
# end
  #CSVインポート A01
  def self.csv_attributes
    ["name", "email", "role", "employee_number", "card_id", "base_attendance_time", "start_attendance_time","end_attendance_time", "admin","password"]
  end

  def self.import_csv(file)
    CSV.foreach(file.path,'r:cp932:utf8',headers:true) do |row|
      #ID 見つかればレコード入力、なければ新規作成
      user = find_by(id: row["id"]) || new
      #CSVファイル取得、値入力
      user.csv_attributes = row.to_hash.slice(*updatable_attributes)
      user.save
    end
  end

end


=begin
  validates :name,  presence: true, length: { maximum: 50 }#validates(:name, presence: true)
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 100 },format: { with: VALID_EMAIL_REGEX },uniqueness: true 
=end