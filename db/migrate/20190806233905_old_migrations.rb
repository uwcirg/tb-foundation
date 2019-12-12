#Cleaned up these old migraions on December 12th 2019
#Following guidance from https://medium.com/clutter-engineering/cleaning-up-old-rails-migrations-1b55b638abb5
class OldMigrations < ActiveRecord::Migration[5.1]
  REQUIRED_VERSION = 20190806233905
  def up
    if ActiveRecord::Migrator.current_version < REQUIRED_VERSION
      raise StandardError, "`rails db:schema:load` must be run prior to `rails db:migrate`"
    end
  end
end
