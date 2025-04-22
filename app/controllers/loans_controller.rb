class LoansController < ApplicationController
  before_action :authenticate_user!
  before_action :set_loan, only: [:show, :accept_approval, :reject_approval, 
                                 :accept_adjustment, :reject_adjustment, 
                                 :request_readjustment, :repay]
  
  def index
    @loans = current_user.loans
  end
  
  def show
    @adjustments = @loan.loan_adjustments.order(created_at: :asc)
  end
  
  def new
    @loan = current_user.loans.new
  end
  
  def create
    @loan = current_user.loans.new(loan_params)
    
    if @loan.save
      redirect_to loans_path, notice: 'Loan request submitted successfully.'
    else
      render :new
    end
  end
  
  def accept_approval
    if @loan.accept_approval
      redirect_to @loan, notice: 'Loan approved and funds have been transferred to your wallet.'
    else
      redirect_to @loan, alert: 'Unable to process loan approval.'
    end
  end
  
  def reject_approval
    if @loan.reject_approval
      redirect_to loans_path, notice: 'Loan approval rejected.'
    else
      redirect_to @loan, alert: 'Unable to reject loan approval.'
    end
  end
  
  def accept_adjustment
    if @loan.accept_adjustment
      redirect_to @loan, notice: 'Loan adjustment accepted and funds have been transferred to your wallet.'
    else
      redirect_to @loan, alert: 'Unable to process loan adjustment.'
    end
  end
  
  def reject_adjustment
    if @loan.reject_approval
      redirect_to loans_path, notice: 'Loan adjustment rejected.'
    else
      redirect_to @loan, alert: 'Unable to reject loan adjustment.'
    end
  end
  
  def request_readjustment
    if @loan.request_readjustment(readjustment_params[:principal_amount], readjustment_params[:interest_rate])
      redirect_to @loan, notice: 'Readjustment request submitted.'
    else
      redirect_to @loan, alert: 'Unable to submit readjustment request.'
    end
  end
  
  def repay
    if @loan.repay
      redirect_to loans_path, notice: 'Loan repaid successfully.'
    else
      redirect_to @loan, alert: 'Unable to repay loan.'
    end
  end
  
  private
  
  def set_loan
    @loan = current_user.loans.find(params[:id])
  end
  
  def loan_params
    params.require(:loan).permit(:principal_amount, :interest_rate)
  end
  
  def readjustment_params
    params.require(:loan).permit(:principal_amount, :interest_rate)
  end
end
