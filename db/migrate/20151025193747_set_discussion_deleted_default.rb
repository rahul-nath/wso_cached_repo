class SetDiscussionDeletedDefault < ActiveRecord::Migration
  def change
    change_column :discussions, :deleted, :boolean, default: false
  end
end
