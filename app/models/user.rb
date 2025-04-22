class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :wallet, dependent: :destroy
  has_many :loans, dependent: :destroy
  has_many :loan_adjustments, through: :loans
  
  after_create :create_wallet
  
  def admin?
    role == 'admin'
  end
  
  def create_wallet
    # Admin starts with 10 lakh rupees, users with 10k
    initial_balance = admin? ? 1_000_000 : 10_000
    build_wallet(balance: initial_balance).save
  end
end
