const std = @import("std");
const Chunk = @import("./chunk.zig").Chunk;
const VM = @import("./vm.zig").VM;
const Value = @import("./value.zig").Value;
const OpCode = @import("./chunk.zig").OpCode;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var ch = Chunk.initChunk(allocator);
    // Init VM

    defer {
        _ = gpa.deinit();
    }

    try cloxMainLoop(&ch);

    ch.disassembleChunk("main");
    // Interpret
    // Free VM
    ch.freeChunk();
}

fn cloxMainLoop(ch: *Chunk) !void {
    const val = Value.init(12);
    const constant = try ch.addConstant(val);

    // 0 represents a constant op code
    try ch.writeChunk(@intFromEnum(OpCode.OP_CONSTANT), 123);
    try ch.writeChunk(constant, 123);
    try ch.writeChunk(@intFromEnum(OpCode.OP_RETURN), 123);
}
