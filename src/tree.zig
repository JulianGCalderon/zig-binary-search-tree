const std = @import("std");
const Allocator = std.mem.Allocator;

pub const AllocatorError = std.mem.Allocator.Error;

pub const Comparison = enum {
    Lesser,
    Greater,
    Equal,
};

pub const Order = enum {
    Inorder,
    Preorder,
    Postorder,
};

pub const Error = error{ElementDoesNotExist} || AllocatorError;

pub fn BinarySearchTree(comptime T: type) type {
    return struct {
        const Self = @This();
        const Comparator = *const fn (T, T) Comparison;

        allocator: Allocator,
        root: ?*Node = null,
        comparator: *const fn (T, T) Comparison,
        size: usize = 0,

        pub fn init(allocator: Allocator, comptime comparator: Comparator) Self {
            return Self{
                .allocator = allocator,
                .comparator = comparator,
            };
        }

        pub fn deinit(self: *Self) void {
            if (self.root) |root| {
                root.deinit();
            }
        }

        pub fn insert(self: *Self, element: T) Error!void {
            if (self.root) |root| {
                try root.insert(element);
            } else {
                self.root = try Node.init(self.allocator, element, self.comparator);
            }
            self.size += 1;
        }

        pub fn contains(self: *Self, element: T) bool {
            if (self.root) |root| {
                return root.contains(element);
            }

            return false;
        }

        pub fn empty(self: *Self) bool {
            return self.size == 0;
        }

        pub fn remove(self: *Self, element: T) Error!void {
            if (self.root) |root| {
                self.root = try root.remove(element);
                self.size -= 1;
            } else {
                return Error.ElementDoesNotExist;
            }
        }

        pub fn for_each_element(self: *Self, order: Order, context: anytype, callback: *const fn (T, @TypeOf(context)) bool) void {
            if (self.root) |root| {
                var stop = false;
                switch (order) {
                    Order.Inorder => return root.for_each_element_inorder(&stop, context, callback),
                    Order.Preorder => return root.for_each_element_preorder(&stop, context, callback),
                    Order.Postorder => return root.for_each_element_postorder(&stop, context, callback),
                }
            }
        }

        const Node = struct {
            element: T,
            left: ?*Node,
            right: ?*Node,
            allocator: Allocator,
            comparator: Comparator,

            pub fn init(allocator: Allocator, element: T, comparator: Comparator) Error!*Node {
                var self = try allocator.create(Node);

                self.element = element;
                self.left = null;
                self.right = null;
                self.allocator = allocator;
                self.comparator = comparator;

                return self;
            }

            pub fn deinit(self: *Node) void {
                if (self.left) |left| {
                    left.deinit();
                }
                if (self.right) |right| {
                    right.deinit();
                }

                self.allocator.destroy(self);
            }

            pub fn destroy(self: *Node) void {
                self.allocator.destroy(self);
            }

            pub fn insert(self: *Node, element: T) Error!void {
                if (self.comparator(element, self.element) == .Lesser) {
                    try self.insert_rec(&self.left, element);
                } else {
                    try self.insert_rec(&self.right, element);
                }
            }

            pub fn insert_rec(self: *Node, node: *?*Node, element: T) Error!void {
                if (node.*) |_node| {
                    try _node.insert(element);
                } else {
                    node.* = try Node.init(self.allocator, element, self.comparator);
                }
            }

            pub fn contains(self: *Node, element: T) bool {
                switch (self.comparator(element, self.element)) {
                    Comparison.Equal => return true,
                    Comparison.Lesser => return (self.left orelse return false).contains(element),
                    Comparison.Greater => return (self.right orelse return false).contains(element),
                }
            }

            pub fn remove(self: *Node, element: T) Error!?*Node {
                switch (self.comparator(element, self.element)) {
                    Comparison.Equal => {
                        return self.delete();
                    },
                    Comparison.Greater => {
                        try self.remove_(&self.right, element);
                    },
                    Comparison.Lesser => {
                        try self.remove_(&self.right, element);
                    },
                }
                return self;
            }

            pub fn remove_(self: *Node, node: *?*Node, element: T) Error!void {
                _ = self;
                if (node.*) |_node| {
                    node.* = try _node.remove(element);
                } else {
                    return Error.ElementDoesNotExist;
                }
            }

            pub fn delete(self: *Node) ?*Node {
                defer self.destroy();

                if (self.left) |left| {
                    var max: *Node = undefined;
                    self.left = left.extract_max(&max);
                    max.left = self.left;
                    max.right = self.right;
                    return max;
                } else if (self.right) |right| {
                    return right;
                } else {
                    return null;
                }
            }

            pub fn extract_max(self: *Node, store: **Node) ?*Node {
                if (self.right) |right| {
                    self.right = right.extract_max(store);
                    return self;
                } else {
                    store.* = self;
                    return self.left;
                }
            }

            pub fn for_each_element_inorder(self: *Node, stop: *bool, context: anytype, callback: *const fn (T, @TypeOf(context)) bool) void {
                if (self.left) |left| {
                    left.for_each_element_inorder(stop, context, callback);
                    if (stop.*) {
                        return;
                    }
                }
                stop.* = !callback(self.element, context);
                if (stop.*) {
                    return;
                }

                if (self.right) |right| {
                    right.for_each_element_inorder(stop, context, callback);
                    if (stop.*) {
                        return;
                    }
                }
            }

            pub fn for_each_element_preorder(self: *Node, stop: *bool, context: anytype, callback: *const fn (T, @TypeOf(context)) bool) void {
                stop.* = !callback(self.element, context);
                if (stop.*) {
                    return;
                }

                if (self.left) |left| {
                    left.for_each_element_preorder(stop, context, callback);
                    if (stop.*) {
                        return;
                    }
                }

                if (self.right) |right| {
                    right.for_each_element_preorder(stop, context, callback);
                    if (stop.*) {
                        return;
                    }
                }
            }
            pub fn for_each_element_postorder(self: *Node, stop: *bool, context: anytype, callback: *const fn (T, @TypeOf(context)) bool) void {
                if (self.left) |left| {
                    left.for_each_element_postorder(stop, context, callback);
                    if (stop.*) {
                        return;
                    }
                }

                if (self.right) |right| {
                    right.for_each_element_postorder(stop, context, callback);
                    if (stop.*) {
                        return;
                    }
                }

                stop.* = !callback(self.element, context);
                if (stop.*) {
                    return;
                }
            }
        };
    };
}
