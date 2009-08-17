class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.column :title, :string
      t.column :url, :string
      t.column :lastChanged, :date
      t.column :content, :text
      t.column :original,:text
      t.column :lastAuthor, :string
      t.column :version, :int
    end
  end

  def self.down
    drop_table :pages
  end
end
