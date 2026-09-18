class CreatePages < ActiveRecord::Migration[8.1]
  def change
    create_table :pages do |t|
      t.string :slug, null: false
      t.string :title, null: false
      t.string :subtitle
      t.text :body
      t.string :meta_title
      t.string :meta_description
      t.boolean :show_in_footer, null: false, default: false
      t.integer :position, null: false, default: 0
      t.datetime :published_at
      t.datetime :discarded_at
      t.timestamps
    end

    add_index :pages, :slug, unique: true
    add_index :pages, [ :position, :title ]
    add_index :pages, :discarded_at
  end
end
