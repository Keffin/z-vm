const std = @import("std");
const Chunk = @import("./chunk.zig").Chunk;
const OpCode = @import("./chunk.zig").OpCode;
const Value = @import("./value.zig").Value;

pub const InterpretResult = enum(u2) {
    OK,
    COMPILE_ERR,
    RUNTIME_ERR,
};

pub const VM = struct {
    const Self = @This();
    chunk: *Chunk,
    ip: [*]u8,

    pub fn interpret(self: *Self, ch: *Chunk) void {
        self.chunk = ch;
        self.ip = self.chunk.code;

        // return run();
    }

    pub fn init(ch: *Chunk) VM {
        return VM{
            .chunk = ch,
        };
    }

    pub fn freeVM(self: *Self) void {
        self.chunk.freeChunk();
    }

    fn run(self: *Self) InterpretResult {
        // Each iteration, read + exec single bytecode instruction
        while (true) {
            const instruction: OpCode = @enumFromInt(self.readByte());
            switch (instruction) {
                .OP_CONSTANT => {
                    const constant: Value = self.readConstant();
                    std.debug.print("Constant: {}\n", .{constant});
                    break;
                },
                .OP_RETURN => return InterpretResult.OK,
                else => unreachable,
            }
        }
    }

    fn readByte(self: *Self) u8 {
        // Iterate through opcodes, one byte at a time.
        // Point to first byte of code in the chunk.
        const byte = self.ip[0];
        self.ip += 1;
        return byte;
    }

    fn readConstant(self: *Self) Value {
        return self.chunk.constants.items[self.readByte()];
    }
};
