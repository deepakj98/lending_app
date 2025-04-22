class Loan < ApplicationRecord
  belongs_to :user
  has_many :loan_adjustments, dependent: :destroy
  
  # STATES = %w[requested approved open closed rejected waiting_for_adjustment_acceptance readjustment_requested].freeze
  
  validates :principal_amount, :interest_rate, presence: true
  validates :principal_amount, numericality: { greater_than: 0 }
  validates :interest_rate, numericality: { greater_than: 0 }
  # validates :state, inclusion: { in: STATES }
  
  before_create :set_initial_state
  after_create :create_initial_adjustment
  
  scope :pending_admin_review, -> { where(state: ['requested', 'readjustment_requested']) }
  scope :pending_user_action, -> { where(state: ['approved', 'waiting_for_adjustment_acceptance']) }
  scope :active, -> { where(state: 'open') }
  
  def total_amount_due
    return 0 if state == 'closed'
    principal_amount + accrued_interest
  end
  
  def calculate_interest
    return if state != 'open'
    
    # Calculate interest for 5 minutes period
    # Interest rate is annual, so divide by (365*24*12) to get 5-minute interest
    interest_for_period = principal_amount * (interest_rate / 100) / (365 * 24 * 12)
    update(accrued_interest: accrued_interest + interest_for_period)
  end
  
  def request_adjustment(amount, rate)
    return false unless ['requested', 'readjustment_requested'].include?(state)
    
    loan_adjustments.create(
      principal_amount: amount,
      interest_rate: rate,
      adjustment_type: 'admin_proposal'
    )
    
    update(state: 'waiting_for_adjustment_acceptance')
  end
  
  def approve
    latest_adjustment = loan_adjustments.order(created_at: :desc).first

    # return false unless state == 'requested'
    # update(state: 'approved')
    if state == 'requested' || state == 'readjustment_requested'
      update( state: 'approved',
              principal_amount: latest_adjustment.principal_amount,
              interest_rate: latest_adjustment.interest_rate
            )
    else
      return false
    end
  end
  
  def reject
    return false unless ['requested', 'readjustment_requested'].include?(state)
    update(state: 'rejected')
  end
  
  def accept_adjustment
    return false unless state == 'waiting_for_adjustment_acceptance'
    
    latest_adjustment = loan_adjustments.order(created_at: :desc).first
    update(
      principal_amount: latest_adjustment.principal_amount,
      interest_rate: latest_adjustment.interest_rate,
      state: 'open',
      opened_at: DateTime.now
    )
    
    # Transfer the loan amount from admin to user
    admin = User.find_by(role: 'admin')
    admin_wallet = admin.wallet
    user_wallet = user.wallet
    
    admin_wallet.debit(principal_amount)
    user_wallet.credit(principal_amount)
    
    true
  end
  
  def accept_approval
    return false unless state == 'approved'
    update(state: 'open', opened_at: DateTime.now)
    
    # Transfer the loan amount from admin to user
    admin = User.find_by(role: 'admin')
    admin_wallet = admin.wallet
    user_wallet = user.wallet
    
    admin_wallet.debit(principal_amount)
    user_wallet.credit(principal_amount)
    
    true
  end
  
  def reject_approval
    return false unless ['approved', 'waiting_for_adjustment_acceptance'].include?(state)
    update(state: 'rejected')
  end
  
  def request_readjustment(amount, rate)
    return false unless state == 'waiting_for_adjustment_acceptance'
    
    loan_adjustments.create(
      principal_amount: amount,
      interest_rate: rate,
      adjustment_type: 'user_counterproposal'
    )
    
    update(state: 'readjustment_requested')
  end
  
  def repay
    return false unless state == 'open'
    
    amount_due = total_amount_due
    admin = User.find_by(role: 'admin')
    admin_wallet = admin.wallet
    user_wallet = user.wallet
    
    actual_amount_paid = user_wallet.debit(amount_due)
    admin_wallet.credit(actual_amount_paid)
    
    update(state: 'closed', repaid_amount: actual_amount_paid)
    true
  end
  
  private
  
  def set_initial_state
    self.state = 'requested'
    self.accrued_interest = 0
  end
  
  def create_initial_adjustment
    loan_adjustments.create(
      principal_amount: principal_amount,
      interest_rate: interest_rate,
      adjustment_type: 'initial_request'
    )
  end
end
