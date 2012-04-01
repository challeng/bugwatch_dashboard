module TagsHelper

  def tags_by_date(tags)
    valid_tags = tags.select(&method(:tag_date))
    valid_tags.sort_by(&method(:tag_date)).reverse
  end

  private

  def tag_date(tag)
    tag.commit.authored_date
  rescue => e
    Rails.logger.info e
    nil
  end

end
