module TagsHelper

  def tags_by_date(tags)
    valid_tags = tags.select(&method(:tag_date))
    valid_tags.sort_by(&:tag_date).reverse
  end

  private

  def tag_date(tag)
    tag.tag_date
  rescue Errno::EISDIR
    nil
  end

end
