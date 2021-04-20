class AddOrganizationIdToChannels < ActiveRecord::Migration[6.0]
  def change
    add_reference :channels, :organization, null: true, foreign_key: true
  end
end
