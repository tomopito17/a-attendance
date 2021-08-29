class AddColumnToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :affiliation, :string
    add_column :users, :employee_number, :integer
    add_column :users, :uid, :integer
    add_column :users, :basic_work_time, :datetime, default: Time.current.change(hour: 8, min: 0, sec: 0)
    add_column :users, :designated_work_start_time, :time, default: Time.current.change(hour: 9, min: 0, sec: 0) #A05
    add_column :users, :designated_work_end_time, :time, default: Time.current.change(hour: 18, min: 0, sec: 0) #A05
    add_column :users, :superior, :boolean  #A06
    add_column :users, :password, :string
    #add_column :attendances, :overtime_finished_at, :datetime #A05
  end
end
