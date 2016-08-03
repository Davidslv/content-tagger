class TagMapping < ActiveRecord::Base
  belongs_to :tagging_spreadsheet
  scope :by_content_base_path, -> { order(content_base_path: :asc) }
  scope :by_link_title, -> { order(link_title: :asc) }

  def self.update_publish_completed_at(tag_mapping_ids)
    where(id: Array(tag_mapping_ids)).update_all(publish_completed_at: Time.zone.now)
  end

  def self.publish_confirmed
    where("publish_requested_at < publish_completed_at")
  end

  def publish_confirmed?
    return false unless publish_requested_at
    publish_requested_at <= (publish_completed_at || DateTime.new(0))
  end
end
