class ChangeEmailAndUsernameFieldToCitext < ActiveRecord::Migration[7.0]
  def change
    enable_extension("citext")

    change_column :users, :email, :citext
    change_column :users, :username, :citext
  end
end
