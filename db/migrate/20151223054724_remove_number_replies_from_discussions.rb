class RemoveNumberRepliesFromDiscussions < ActiveRecord::Migration
  def change
    remove_column :discussions, :number_replies
  end
end
