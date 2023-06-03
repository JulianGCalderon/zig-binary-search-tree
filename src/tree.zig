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
        less_than: *const fn (T, T) Comparison,

        pub fn init(allocator: Allocator, comptime less_than: Comparator) Self {
            return Self{
                .allocator = allocator,
                .less_than = less_than,
            };
        }

        pub fn deinit(self: *Self) void {
            if (self.root) |root| {
                root.deinit();
            }
        }
    };
}

pub fn Node(comptime T: type) type {
    return struct {
        const Self = @This();

        element: T,
        left: ?*Self,
        right: ?*Self,
        allocator: Allocator,

        pub fn init(allocator: Allocator, element: T) Self {
            var self = allocator.create(Self);

            self.element = element;
            self.left = null;
            self.right = null;
            self.allocator = allocator;

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
    };
}
