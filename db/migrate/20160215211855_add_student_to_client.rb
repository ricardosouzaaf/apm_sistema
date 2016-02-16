class AddStudentToClient < ActiveRecord::Migration
  def change
    add_column :clients, :student, :string
  end
end
