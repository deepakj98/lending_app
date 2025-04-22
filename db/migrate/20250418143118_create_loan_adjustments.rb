class CreateLoanAdjustments < ActiveRecord::Migration[7.2]
  def change
    create_table :loan_adjustments do |t|
      t.references :loan, null: false, foreign_key: true
      t.decimal :principal_amount
      t.decimal :interest_rate
      t.string :adjustment_type
      t.text :notes

      t.timestamps
    end
  end
end
