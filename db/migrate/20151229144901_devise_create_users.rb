class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      ## Database authenticatable
      t.string     :name,               null: false
      t.string     :email,              null: false, index: true, unique: true
      t.string     :encrypted_password, null: false
      t.belongs_to :user_status,        null: false, default: 1
      t.boolean    :admin,              null: false, default: false
      t.boolean    :activated,          null: false, index: true, default: false
      ## Recoverable
      t.string     :reset_password_token
      t.datetime   :reset_password_sent_at

      t.timestamps null: false
    end
  end
end
