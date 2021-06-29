class AddOvertimeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime, :datetime
    add_column :attendances, :task_memo, :text
    add_column :attendances, :change_confirmation_status, :integer
    add_column :attendances, :change_confirmation_approver_id, :integer
    add_column :attendances, :overwork_status, :integer
    add_column :attendances, :overwork_approver_id, :integer
  end
end
