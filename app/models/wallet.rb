class Wallet < ApplicationRecord
  belongs_to :user

  validates :balance, numericality: { greater_than_or_equal_to: 0 }
  
  def credit(amount)
    update!(balance: balance + amount)
  end
  
  def debit(amount)
    debit_amount = [amount, balance].min
    update!(balance: balance - debit_amount)
    debit_amount
  end
  
  def can_debit?(amount)
    balance >= amount
  end
end
