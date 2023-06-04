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

fn tree_with_one_element(element: u8) !BinarySearchTree {
    var bst = new_tree();
    try bst.insert(element);
    return bst;
}

test "Can create a BST" {
    var bst = new_tree();
    defer bst.deinit();
}

test "Given an empty tree, can insert an element" {
    var bst = try tree_with_one_element(5);
    defer bst.deinit();


    try testing.expect(bst.contains(5));
    try testing.expect(!bst.empty());

    const expected_size: usize = 1;
    try testing.expectEqual(expected_size, bst.size);
}

test "Given a tree with one element, can insert a higher element" {
    var bst = try tree_with_one_element(5);
    defer bst.deinit();


    try bst.insert(10);
    try testing.expect(bst.contains(10));
    try testing.expect(bst.contains(5));

    const expected_size: usize = 2;
    try testing.expectEqual(expected_size, bst.size);
}

test "Given a tree with one element, can insert a lower element" {
    var bst = try tree_with_one_element(5);
    defer bst.deinit();


    try bst.insert(0);
    try testing.expect(bst.contains(0));
    try testing.expect(bst.contains(5));

    const expected_size: usize = 2;
    try testing.expectEqual(expected_size, bst.size);
}

test "Given an empty tree, can insert up to a complete 3-depth binary tree" {
    var bst = new_tree();
    defer bst.deinit();

    const elements = [_]u8{10, 12, 11, 13, 8, 9, 7};

    for (elements) |element| {
        try bst.insert(element);
    }

    try testing.expectEqual(elements.len, bst.size);

    for (elements) |element| {
        try testing.expect(bst.contains(element));
    }
}
