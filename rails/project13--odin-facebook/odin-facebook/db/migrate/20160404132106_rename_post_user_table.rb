class RenamePostUserTable < ActiveRecord::Migration
  def change
  	rename_table :user_posts, :likes
  end
end

