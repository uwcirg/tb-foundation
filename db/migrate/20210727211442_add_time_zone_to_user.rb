class AddTimeZoneToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :time_zone, :string, default: "America/Argentina/Buenos_Aires"
  end
end
