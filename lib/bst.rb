require_relative "queue.rb"

class Node
    include Comparable

    attr_accessor :data, :left_child, :right_child

    def <=>(other_node)
        data <=> other_node.data
    end

    def initialize(data, left = nil, right = nil)
        @data = data
        @left_child = left
        @right_child = right
    end
end

class Tree 
    attr_reader :root
    def initialize(array)
        @root = build_tree(array)
    end

    def build_tree(array)
        #Sort the array and remove duplicates
        return unless array.size > 0
        array = array.sort.uniq

        # find middle index
        mid = array.length/2

        # make the middle element the root
        root = Node.new(array[mid])

        # left subtree of root has all
        # values <arr[mid]
        root.left_child = build_tree(array[0, mid])

        # right subtree of root has all
        # values >arr[mid]
        root.right_child = build_tree(array[(mid+1), array.size])
        return root
    end
    def pretty_print(node = @root, prefix = '', is_left = true)
        pretty_print(node.right_child, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right_child
        puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
        pretty_print(node.left_child, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left_child
    end
    def insert(value, node = root)
        if value < node.data
            if node.left_child.nil?
                node.left_child = Node.new(value)
            else
                insert(value, node.left_child)
            end
        end
        if value > node.data
            if node.right_child.nil?
                node.right_child = Node.new(value)
            else
                insert(value, node.right_child)
            end
        end
    end
    
    def delete(value_to_delete, node = root)
        
        # The base case is when we've hit the bottom of the tree,
        # and the parent node has no children:
        if node.nil?
            return nil 
        # If the value we're deleting is less or greater than the current node,
        # we set the left or right child respectively to be
        # the return value of a recursive call of this
        # very method on the current
        # node's left or right subtree.
        elsif value_to_delete < node.data
            node.left_child = delete(value_to_delete, node.left_child)
            # We return the current node (and its subtree if existent) to
            # be used as the new value of its parent's left or right child:
            return node
        elsif value_to_delete > node.data
            node.right_child = delete(value_to_delete, node.right_child)
            return node
            # If the current node is the one we want to delete:
        elsif value_to_delete == node.data
            # If the current node has no left child, we delete it by
            # returning its right child (and its subtree if existent)
            # to be its parent's new subtree:
            if node.left_child.nil?
                return node.right_child
                # (If the current node has no left OR right child, this ends up
                # being None as per the first line of code in this function.)
            elsif node.right_child.nil?
                return node.left_child
            # If the current node has two children, we delete the current node
            # by calling the lift function (below),
            # which changes the current node's
            # value to the value of its successor node:
            else
                node.right_child = lift(node.right_child, node)
                return node
            end
        end
    end

    def lift(node, node_to_delete)
        # If the current node of this function has a left child,
        # we recursively call this function to continue down
        # the left subtree to find the successor node.
        if node.left_child
            node.left_child = lift(node.left_child, node_to_delete)
            return node
        # If the current node has no left child, that means the current node
        # of this function is the successor node, and we take its value
        # and make it the new value of the node that we're deleting:
        else
            node_to_delete.data = node.data
            # We return the successor node's right child to be now used
            # as its parent's left child:
            return node.right_child
        end
    end

    def find(search_value, node = root)
        # Base case: If the node is nonexistent
        # or we've found the value we're looking for:
        if node.nil? or node.value == search_value
            return node
        # If the value is less than the current node, perform
        # search on the left child:
        elsif search_value < node.value
            return find(search_value, node.left_child)
        # If the value is greater than the current node, perform
        # search on the right child:
        else # search_value > node.value
            return find(search_value, node.right_child)
        end
    end
    def level_order(node = @root, &block)
        return if node.nil?
        queue = Queue.new
        queue.enqueue(node)
        visited_nodes = []

        while queue.read
            current_node = queue.dequeue
            if block_given?
                block.call(current_node)
            else
                visited_nodes << current_node.data
            end
            if current_node.left_child
                queue.enqueue(current_node.left_child)
            end
            if current_node.right_child
                queue.enqueue(current_node.right_child)
            end
        end

        return visited_nodes unless block_given?
    end
    def level_order_recursion(node = @root, queue = Queue.new, values = [], &block)
        return unless node
        if block_given?
          block.call(node)
        else
          values << node.data
        end
        queue.enq(node.left) if node.left
        queue.enq(node.right) if node.right
        if !block_given? && queue.empty? 
          return values
        end
        level_order_recursion(queue.deq, queue, &block) 
      end
    def traverse_inorder(node = root, inorder_array = [], &block)
        return node if node.nil?
        traverse_inorder(node.left_child, inorder_array)
        if block_given?
            block.call(node)
        else
            inorder_array << node.data
        end
        traverse_inorder(node.right_child, inorder_array)
        return inorder_array
    end
    def traverse_preorder(node = root, preorder_array = [], &block)
        return node if node.nil?
        if block_given?
            block.call(node)
        else
            preorder_array << node.data
        end
        traverse_preorder(node.left_child, preorder_array)
        traverse_preorder(node.right_child, preorder_array)
        return preorder_array
    end
    def traverse_postorder(node = root, postorder_array = [], &block)
        return node if node.nil?
        traverse_postorder(node.left_child, postorder_array)
        traverse_postorder(node.right_child, postorder_array)
        if block_given?
            block.call(node)
        else
            postorder_array << node.data
        end
        return postorder_array
    end
    def height(node = root)
        # We create this hash to record the levels of each node in our tree
        level_order = {}
        #We'll traverse the tree in breadth-first order
        queue = Queue.new
        queue.enqueue(node)
        # the node given as argument has a level of 0
        level_order[node.data] = 0
        while queue.read
            current_node = queue.dequeue
            if current_node.left_child
                queue.enqueue(current_node.left_child)
                level_order[current_node.left_child.data] = 
                                        level_order[current_node.data] + 1
            end
            if current_node.right_child
                queue.enqueue(current_node.right_child)
                level_order[current_node.right_child.data] =
                                        level_order[current_node.data] + 1
            end
        end
        p level_order
        return level_order.values.max
    end
    def depth(target_node)
        # We use this hash to record all the depths of nodes 
        # until we find our target_node's depth
        level_order = {}
        # We'll traverse the node in breadth-first order
        queue = Queue.new
        # We start from the root node which has a depth of 0
        queue.enqueue(root)
        level_order[root.data] = 0
        # We run this loop until we find our node 
        while queue.read && !level_order[target_node.data]
            current_node = queue.dequeue
            if current_node.left_child
                queue.enqueue(current_node.left_child)
                level_order[current_node.left_child.data] = 
                                        level_order[current_node.data] + 1
            end
            if current_node.right_child
                queue.enqueue(current_node.right_child)
                level_order[current_node.right_child.data] =
                                        level_order[current_node.data] + 1
            end
        end
        return "Node not found" unless  level_order[target_node.data]
        return level_order[target_node.data]
    end
    def depth_recurse(target_node = @root, current_node = @root, node_depth_recurse = 0)
        return nil if target_node.nil?
        return "Node not found" unless current_node
        return node_depth_recurse if current_node.data == target_node.data
        if target_node.data < current_node.data
          return depth_recurse(target_node, current_node.left, node_depth_recurse + 1)
        else
          return depth_recurse(target_node, current_node.right, node_depth_recurse + 1)
        end
    end
    def balanced?
        if root.left_child.nil? 
            if height(root.right_child) > 1
                return false
            else
                return true
            end        
        end
        if root.right_child.nil? 
            if height(root.left_child) > 1
                return false
            else
                return true
            end   
        end
        (height(root.left_child) - height(root.right_child)).abs <= 1
    end
    def rebalance
        self.initialize(self.traverse_inorder)
    end
end

