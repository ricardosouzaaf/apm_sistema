class AddTurmaToClient < ActiveRecord::Migration
  def change
    add_column :clients, :turma, :string
  end
end
