class AddOvertimeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime, :time
    add_column :attendances, :task_memo, :text
    # add_column :attendances, :change_confirmation_status, :integer
    # add_column :attendances, :change_confirmation_approver_id, :integer
    add_column :attendances, :overwork_status, :string
    #add_column :attendances, :overwork_approver_id, :integer
    add_column :attendances, :overday_check, :boolean, default: false
    add_column :attendances, :overwork_sperior, :integer
    add_column :attendances, :indicater_check, :string #A05add
    #A04 ADD manual
    add_column :attendances, :monthly_confirmation_approver_id, :integer
    add_column :attendances, :monthly_confirmation_status, :integer
    add_column :attendances, :change, :boolean, default: false #A05Add
  end
end
