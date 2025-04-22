class WalletsController < ApplicationController
  before_action :authenticate_user!
  
  def show
    @wallet = current_user.wallet
    @loans = current_user.loans.where(state: 'open')
  end
end
