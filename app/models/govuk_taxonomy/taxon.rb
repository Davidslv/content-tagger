# This is lifted almost verbatim from Whitehall
# If you're changing it, consider extracting to a common Gem first, eh
module GovukTaxonomy
  class Taxon
    attr_reader :name, :content_id, :base_path
    attr_accessor :parent_node, :children

    delegate :map,
             :each,
             :count,
             to: :tree

    def initialize(title:, base_path:, content_id:, **_kwargs)
      @name = title
      @content_id = content_id
      @base_path = base_path
      @children = []
    end

    def tree
      children.each_with_object([self]) do |child, tree|
        tree.concat(child.tree)
      end
    end

    def descendants
      tree.tap(&:shift)
    end

    # Get ancestors of a taxon
    #
    # @return [Array] all taxons in the path from the root of the taxonomy to the parent taxon
    def ancestors
      if parent_node.nil?
        []
      else
        parent_node.ancestors + [parent_node]
      end
    end

    # Get a breadcrumb trail for a taxon
    #
    # @return [Array] all taxons in the path from the root of the taxonomy to this taxon
    def breadcrumb_trail
      ancestors + [self]
    end

    def root?
      parent_node.nil?
    end

    def node_depth
      return 0 if root?

      1 + parent_node.node_depth
    end
  end
end
