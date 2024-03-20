require_relative './lib/bst.rb'

tree = Tree.new(Array.new(15) { rand(1..100) })
p tree.balanced?
p tree.level_order
p tree.traverse_preorder
p tree.traverse_inorder
p tree.traverse_postorder
tree.pretty_print

tree.insert(100)
tree.insert(101)
tree.insert(200)
tree.insert(201)
tree.insert(1002)
tree.insert(2376)
tree.pretty_print

p tree.balanced?
tree.rebalance
tree.pretty_print
p tree.balanced?

p tree.level_order
p tree.traverse_preorder
p tree.traverse_inorder
p tree.traverse_postorder
