class Transaction < ApplicationRecord
  belongs_to :wallet
  belongs_to :loan
end
