class Admin::LoansController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin
  before_action :set_loan, only: [:show, :approve, :reject, :adjust]
  
  def index
    @pending_loans = Loan.pending_admin_review
    @active_loans = Loan.active
    @all_loans = Loan.all
  end
  
  def show
    @adjustments = @loan.loan_adjustments.order(created_at: :asc)
  end
  
  def approve
    if @loan.approve
      redirect_to admin_loans_path, notice: 'Loan approved successfully.'
    else
      redirect_to admin_loan_path(@loan), alert: 'Unable to approve loan.'
    end
  end
  
  def reject
    if @loan.reject
      redirect_to admin_loans_path, notice: 'Loan rejected successfully.'
    else
      redirect_to admin_loan_path(@loan), alert: 'Unable to reject loan.'
    end
  end
  
  def adjust
    if @loan.request_adjustment(adjustment_params[:principal_amount], adjustment_params[:interest_rate])
      redirect_to admin_loans_path, notice: 'Loan adjustment proposed successfully.'
    else
      redirect_to admin_loan_path(@loan), alert: 'Unable to propose loan adjustment.'
    end
  end
  
  private
  
  def authorize_admin
    redirect_to root_path, alert: 'Access denied.' unless current_user.admin?
  end
  
  def set_loan
    @loan = Loan.find(params[:id])
  end
  
  def adjustment_params
    params.require(:loan).permit(:principal_amount, :interest_rate)
  end
end
