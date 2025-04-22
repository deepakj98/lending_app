class LoanAdjustment < ApplicationRecord
  belongs_to :loan
  
  ADJUSTMENT_TYPES = ['initial_request', 'admin_proposal', 'user_counterproposal'].freeze
  
  validates :principal_amount, :interest_rate, :adjustment_type, presence: true
  validates :principal_amount, numericality: { greater_than: 0 }
  validates :interest_rate, numericality: { greater_than: 0 }
  validates :adjustment_type, inclusion: { in: ADJUSTMENT_TYPES }
  
  def made_by_admin?
    adjustment_type == 'admin_proposal'
  end
  
  def made_by_user?
    ['initial_request', 'user_counterproposal'].include?(adjustment_type)
  end
end
