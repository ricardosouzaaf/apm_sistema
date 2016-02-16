class RemoveClassFromClient < ActiveRecord::Migration
  def change
    remove_column :clients, :class, :string
  end
end
