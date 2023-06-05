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

fn tree_with_elements(elements: []const u8) !BinarySearchTree {
    var bst = new_tree();
    for (elements) |element| {
        try bst.insert(element);
    }

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
    const elements = [_]u8{ 10, 12, 11, 13, 8, 9, 7 };
    var bst = try tree_with_elements(&elements);
    defer bst.deinit();

    try testing.expectEqual(elements.len, bst.size);

    for (elements) |element| {
        try testing.expect(bst.contains(element));
    }
}

test "Given an empty tree, can insert the same element twice" {
    var bst = try tree_with_one_element(5);
    defer bst.deinit();

    try bst.insert(5);

    try testing.expect(bst.contains(5));
    const expected_size: usize = 2;
    try testing.expectEqual(expected_size, bst.size);
}

test "Given a tree with one element, can remove it" {
    var bst = try tree_with_one_element(5);
    defer bst.deinit();

    try bst.remove(5);

    try testing.expect(!bst.contains(5));
    const expected_size: usize = 0;
    try testing.expectEqual(expected_size, bst.size);
}

test "Given a tree with a central node and a right leaf, can remove the right node" {
    const elements = [_]u8{ 10, 12 };
    var bst = try tree_with_elements(&elements);
    defer bst.deinit();

    try bst.remove(12);

    try testing.expect(!bst.contains(12));
    try testing.expect(bst.contains(10));

    const expected_size: usize = 1;
    try testing.expectEqual(expected_size, bst.size);
}

test "Given a tree with a central node and a left leaf, can remove the left node" {
    const elements = [_]u8{ 10, 12 };
    var bst = try tree_with_elements(&elements);
    defer bst.deinit();

    try bst.remove(10);

    try testing.expect(!bst.contains(10));
    try testing.expect(bst.contains(12));
}

test "Given a tree with a central node and a left leaf, can remove the central node" {
    const elements = [_]u8{ 10, 8 };
    var bst = try tree_with_elements(&elements);
    defer bst.deinit();

    try bst.remove(10);

    try testing.expect(!bst.contains(10));
    try testing.expect(bst.contains(8));
}

test "Given a tree with a central node and a complete left branch, can remove the central node" {
    const elements = [_]u8{ 10, 8, 7, 9 };
    var bst = try tree_with_elements(&elements);
    defer bst.deinit();

    try bst.remove(10);

    try testing.expect(!bst.contains(10));
    try testing.expect(bst.contains(8));
    try testing.expect(bst.contains(7));
    try testing.expect(bst.contains(9));
}

test "Given a tree with full 3-depth tree, can remove the central node" {
    const elements = [_]u8{ 10, 8, 7, 9, 12, 11, 13 };
    var bst = try tree_with_elements(&elements);
    defer bst.deinit();

    try bst.remove(10);

    try testing.expect(!bst.contains(10));
    try testing.expect(bst.contains(8));
    try testing.expect(bst.contains(7));
    try testing.expect(bst.contains(9));
    try testing.expect(bst.contains(12));
    try testing.expect(bst.contains(11));
    try testing.expect(bst.contains(13));
}
