const std = @import("std");
const tree = @import("tree.zig");

const BinarySearchTree = tree.BinarySearchTree(u8);
const Comparison = tree.Comparison;
const testing = std.testing;
const allocator = testing.allocator;


fn comparator(e1: u8, e2: u8) Comparison {
    if (e1 < e2) {
        return Comparison.Lesser;
    } else if (e1 > e2) {
        return Comparison.Greater;
    }
    return Comparison.Equal;
}

fn new_tree() BinarySearchTree {
    return BinarySearchTree.init(allocator, comparator);
}

test "Can create a BST" {
    var bst = new_tree();
    defer bst.deinit();
}

test "Given an empty tree, can insert an element" {
    var bst = new_tree();
    _ = bst;

    //bst.insert(5);
    //bst.testing.contains(5);
}
