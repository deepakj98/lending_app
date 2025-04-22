class CreateLoans < ActiveRecord::Migration[7.2]
  def change
    create_table :loans do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :principal_amount
      t.decimal :interest_rate
      t.decimal :accrued_interest
      t.decimal :repaid_amount
      t.string :state
      t.datetime :opened_at
      t.datetime :closed_at

      t.timestamps
    end
  end
end
