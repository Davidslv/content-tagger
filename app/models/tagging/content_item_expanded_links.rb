module Tagging
  class ContentItemExpandedLinks
    include ActiveModel::Model
    attr_accessor :content_id, :previous_version

    TAG_TYPES = %i(
      taxons
      ordered_related_items
      mainstream_browse_pages
      parent
      topics
      organisations
      meets_user_needs
    ).freeze

    attr_accessor(*TAG_TYPES)

    # Find the links for a content item by its content ID
    def self.find(content_id)
      data = Services.publishing_api.get_expanded_links(content_id).to_h

      links = data.fetch('expanded_links', {})

      tags = TAG_TYPES.each_with_object({}) do |tag_type, current_tags|
        current_tags[tag_type] = links.fetch(tag_type.to_s, [])
      end

      new(
        content_id: content_id,
        previous_version: data.fetch('version', 0),
        **tags
      )
    end
  end
end