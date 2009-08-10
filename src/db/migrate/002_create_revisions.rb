class CreateRevisions < ActiveRecord::Migration
  def self.up
    create_table :revisions do |t|
      t.column :pageid, :integer
      t.column :version, :integer
      t.column :title, :string
      t.column :content, :text
      t.column :when, :date
      t.column :author, :string
    end
  end

  def self.down
    drop_table :revisions
  end
end
