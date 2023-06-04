const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Comparison = enum {
    Lesser,
    Greater,
    Equal,
};

pub fn BinarySearchTree(comptime T: type) type {
    return struct {
        const Self = @This();
        const TNode = Node(T);
        const Comparator = *const fn (T, T) Comparison;

        allocator: Allocator,
        root: ?*TNode = null,
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

        pub fn insert(self: *Self, element: T) !void {
            if (self.root) |root| {
                try root.insert(element);
            } else {
                self.root = try TNode.init(self.allocator, element, self.comparator);
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
    };
}

pub fn Node(comptime T: type) type {
    return struct {
        const Self = @This();
        const Comparator = *const fn (T, T) Comparison;

        element: T,
        left: ?*Self,
        right: ?*Self,
        allocator: Allocator,
        comparator: Comparator,

        pub fn init(allocator: Allocator, element: T, comparator: Comparator) !*Self {
            var self = try allocator.create(Self);

            self.element = element;
            self.left = null;
            self.right = null;
            self.allocator = allocator;
            self.comparator = comparator;

            return self;
        }

        pub fn deinit(self: *Self) void {
            if (self.left) |left| {
                left.deinit();
            }
            if (self.right) |right| {
                right.deinit();
            }

            self.allocator.destroy(self);
        }

        pub fn insert(self: *Self, element: T) !void {
            if (self.comparator(self.element, element) == .Lesser) {
                if (self.left) |left| {
                    try left.insert(element);
                } else {
                    self.left = try Self.init(self.allocator, element, self.comparator);
                }
            } else {
                if (self.right) |right| {
                    try right.insert(element);
                } else {
                    self.right = try Self.init(self.allocator, element, self.comparator);
                }
            }
        }

        pub fn contains(self: *Self, element: T) bool {
            switch (self.comparator(self.element, element)) {
                Comparison.Equal => return true,
                Comparison.Lesser => return (self.left orelse return false).contains(element),
                Comparison.Greater => return (self.right orelse return false).contains(element),
            }
        }
    };
}
