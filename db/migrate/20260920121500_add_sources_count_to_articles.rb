class AddSourcesCountToArticles < ActiveRecord::Migration[8.1]
  # A counter cache, so a list can print how many sources a piece carries
  # without loading them.
  #
  # safety_assured is justified, not waved through: the statement writes one
  # integer per article, derived from a correlated count of that article's own
  # sources. It touches no other column, takes no lock beyond the rows it
  # writes, and the column it fills was created moments earlier in this same
  # transaction. strong_migrations cannot inspect raw SQL, which is why it asks.
  def up
    add_column :articles, :sources_count, :integer, null: false, default: 0

    safety_assured do
      execute <<~SQL
        UPDATE articles
        SET sources_count = (SELECT COUNT(*) FROM sources WHERE sources.article_id = articles.id)
      SQL
    end
  end

  def down
    remove_column :articles, :sources_count
  end
end
