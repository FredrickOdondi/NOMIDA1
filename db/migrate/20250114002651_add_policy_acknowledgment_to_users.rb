class AddPolicyAcknowledgmentToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :terms_accepted, :boolean
    add_column :users, :privacy_accepted, :boolean
  end
end
