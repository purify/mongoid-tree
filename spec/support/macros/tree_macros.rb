require 'yaml'

module Mongoid::Tree::TreeMacros

  def setup_tree(tree)
    create_tree(YAML.load(tree))
  end

  def node(name)
    @nodes[name].reload
  end

  def print_tree(node, print_ids = false, depth = 0)
    print '  ' * depth
    print '- ' unless depth == 0
    print node.name
    print " (#{node.id})" if print_ids
    print ':' if node.children.any?
    print "\n"
    node.children.each { |c| print_tree(c, print_ids, depth + 1) }
  end

  private

  def create_tree(object)
    case object
      when String: return create_node(object)
      when Array: object.each { |tree| create_tree(tree) }
      when Hash:
        name, children = object.first
        node = create_node(name)
        children.each { |c| node.children << create_tree(c) }
        return node
    end
  end

  def create_node(name)
    @nodes ||= HashWithIndifferentAccess.new
    @nodes[name] = Node.create(:name => name)
  end

end

RSpec.configure do |config|
  config.include Mongoid::Tree::TreeMacros
end
