class AddLastResolvedToResolution < ActiveRecord::Migration[6.0]
  def change
    add_column :resolutions, :resolved_at, :datetime
  end
end
