const std = @import("std");
const Value = @import("./value.zig").Value;
const Allocator = std.mem.Allocator;

// Will contain the different instructions our VM will deal with.
const OpCode = enum(u8) {
    OP_CONSTANT,
    OP_RETURN, // Return from currenct function.
    TMP_VAL,
};

// Bytecode is a series of instructions, i.e a dynamic list.
const Chunk = struct {
    const Self = @This();
    code: std.ArrayList(u8),
    constants: std.ArrayList(Value),
    lines: std.ArrayList(usize),

    pub fn initChunk(allocator: std.mem.Allocator) Chunk {
        return Chunk{
            .code = std.ArrayList(u8).init(allocator),
            .constants = std.ArrayList(Value).init(allocator),
            .lines = std.ArrayList(usize).init(allocator),
        };
    }

    pub fn freeChunk(self: *Self) void {
        self.code.deinit();
        self.constants.deinit();
        self.lines.deinit();
    }

    pub fn writeChunk(self: *Self, byte: u8, line: usize) !void {
        try self.code.append(byte);
        try self.lines.append(line);
    }

    pub fn addConstant(self: *Self, value: Value) !u8 {
        try self.constants.append(value);
        return @intCast(self.constants.items.len - 1);
    }

    pub fn disassembleChunk(self: *Self, name: []const u8) void {
        std.debug.print("== {s} ==\n", .{name});

        var offset: usize = 0;
        while (offset < self.code.items.len) {
            offset = self.disassembleInstruction(offset);
        }
    }

    fn disassembleInstruction(self: *Self, offset: usize) usize {
        std.debug.print("{:0>4} ", .{offset});

        if (offset > 0 and self.lines.items[offset] == self.lines.items[offset - 1]) {
            std.debug.print("   | ", .{});
        } else {
            std.debug.print("{: >4}", .{self.lines.items[offset]});
        }

        const instruction: OpCode = @enumFromInt(self.code.items[offset]);

        return switch (instruction) {
            .OP_RETURN => self.simpleInstruction(@tagName(instruction), offset),
            .OP_CONSTANT => self.constantInstruction(@tagName(instruction), offset),
            else => {
                std.debug.print("Unknown opcode {d}\n", .{@intFromEnum(instruction)});
                return offset + 1;
            },
        };
    }

    fn constantInstruction(self: *Self, op_code_name: []const u8, offset: usize) usize {
        const constant = self.code.items[offset + 1];
        std.debug.print(" {s}    {}  '{}'\n", .{ op_code_name, constant, self.constants.items[constant].data });
        return offset + 2;
    }

    fn simpleInstruction(self: *Self, op_code_name: []const u8, offset: usize) usize {
        _ = self;
        std.debug.print("{s}\n", .{op_code_name});
        return offset + 1;
    }
};

const expect = std.testing.expect;
// Adding tests here.

test "main flow" {
    const al = std.testing.allocator;
    var ch: Chunk = Chunk.initChunk(al);
    const val = Value.init(12);

    const constant = try ch.addConstant(val);

    // 0 represents a constant op code
    try ch.writeChunk(@intFromEnum(OpCode.OP_CONSTANT), 123);
    try ch.writeChunk(constant, 123);
    try ch.writeChunk(@intFromEnum(OpCode.OP_RETURN), 123);

    try expect(constant == 0);
    try expect(ch.lines.items.len == 3);
    try expect(ch.code.items.len == 3);

    ch.disassembleChunk("kevmain");
    ch.freeChunk();
}

//test "Value tester" {
//    const al = std.testing.allocator;
//    var ch: Chunk = Chunk.initChunk(al);
//    const v: Value = undefined;
// const v2: Value = undefined;
//    try ch.writeChunk(0, 123);
//    try ch.writeChunk(0, 123);
//    try ch.writeChunk(0, 123);
//    try ch.writeChunk(0, 123);

//    const ret_val = try ch.addConstant(v);
//    const ret_val_2 = try ch.addConstant(v);
//    const ret_val_3 = try ch.addConstant(v2);
//   const ret_val_4 = try ch.addConstant(v2);

//    try expect(ret_val == 0);
//    try expect(ret_val_2 == 1);
//  try expect(ret_val_3 == 2);
// try expect(ret_val_4 == 3);
// ch.disassembleChunk("kevchunk");

//    ch.freeChunk();
//}// //

// test "Chunk Tester" {
//    const al = std.testing.allocator;
//   var ch: Chunk = Chunk.initChunk(al);
//  try ch.writeChunk(1, 123);
// try ch.writeChunk(1, 123);
// try ch.writeChunk(2, 111);

//    try expect(ch.code.items.len == 3);
//  try expect(ch.lines.items.len == 3);

// ch.disassembleChunk("kevchunk");
// ch.freeChunk();
// }
