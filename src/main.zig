const std = @import("std");

const Allocator = std.mem.Allocator;

pub fn main() !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
}

// Will contain the different instructions our VM will deal with.
const OpCode = enum(u8) {
    OP_RETURN, // Return from currenct function.
    TMP_VAL,
    TMP_VAL_2,
};

// Bytecode is a series of instructions, i.e a dynamic list.
const Chunk = struct {
    const Self = @This();
    code: std.ArrayList(u8),

    pub fn initChunk(allocator: std.mem.Allocator) Chunk {
        return Chunk{
            .code = std.ArrayList(u8).init(allocator),
        };
    }

    pub fn freeChunk(self: *Self) void {
        self.code.deinit();
    }

    pub fn writeChunk(self: *Self, byte: u8) !void {
        try self.code.append(byte);
    }

    pub fn disassembleChunk(self: *Self, name: []const u8) void {
        std.debug.print("\n== {s} ==\n", .{name});

        var offset: usize = 0;
        while (offset < self.code.items.len) {
            offset = self.disassembleInstruction(offset);
        }
    }

    fn disassembleInstruction(self: *Self, offset: usize) usize {
        std.debug.print("{:0>4} ", .{offset});

        const instruction: OpCode = @enumFromInt(self.code.items[offset]);

        return switch (instruction) {
            .OP_RETURN => self.simpleInstruction(@tagName(instruction), offset),
            else => {
                std.debug.print("Unknown opcode {d}\n", .{@intFromEnum(instruction)});
                return offset + 1;
            },
        };
    }

    fn simpleInstruction(self: *Self, name: []const u8, offset: usize) usize {
        _ = self;
        std.debug.print("{s}\n", .{name});
        return offset + 1;
    }
};

const expect = std.testing.expect;
// Adding tests here.
test "Chunk Tester" {
    const al = std.testing.allocator;
    var ch: Chunk = Chunk.initChunk(al);
    try ch.writeChunk(0);
    try ch.writeChunk(1);
    try ch.writeChunk(2);

    try expect(ch.code.items.len == 3);
    try expect(ch.code.items[0] == 0);

    ch.disassembleChunk("kevchunk");
    ch.freeChunk();
}
