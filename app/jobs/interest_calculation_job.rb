class InterestCalculationJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    Loan.active.each(&:calculate_interest)
    # InterestCalculationJob.set(wait: 5.minutes).perform_later
  end
end
