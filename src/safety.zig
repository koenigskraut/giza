const std = @import("std");
const builtin = @import("builtin");

const util = @import("util.zig");

var arena: ?std.heap.ArenaAllocator = undefined;
pub const tracing = builtin.mode == .Debug;

const ibT = if (tracing) [16 * 16]usize else [0]usize;
var instructionsBuffer: ibT = undefined;
var ibEnd: usize = 0;

const LeakInfo = struct {
    count: usize,
    st: std.builtin.StackTrace,
    typeName: []const u8,
    ptr: *anyopaque,
};
const liT = if (tracing) [16]LeakInfo else [0]LeakInfo;
var leakInfos: liT = undefined;
var liEnd: usize = 0;

var instructions: []usize = undefined;
var leaks: std.AutoArrayHashMap(usize, LeakInfo) = undefined;

const LeaksWriter = union(enum) {
    FileWriter: std.fs.File.Writer,
    BufferWriter: std.io.FixedBufferStream([]u8).Writer,

    pub fn toAny(self: LeaksWriter) *anyopaque {
        return switch (self) {
            inline else => |val| @ptrCast(val),
        };
    }

    pub fn print(self: LeaksWriter, comptime format: []const u8, args: anytype) anyerror!void {
        return switch (self) {
            inline else => |val| val.print(format, args),
        };
    }

    pub fn writeAll(self: LeaksWriter, bytes: []const u8) anyerror!void {
        return switch (self) {
            inline else => |val| val.writeAll(bytes),
        };
    }

    pub fn writeByte(self: LeaksWriter, byte: u8) anyerror!void {
        return switch (self) {
            inline else => |val| val.writeByte(byte),
        };
    }

    pub fn writeByteNTimes(self: LeaksWriter, byte: u8, n: usize) anyerror!void {
        return switch (self) {
            inline else => |val| val.writeByteNTimes(byte, n),
        };
    }
};

var leaksWriter: LeaksWriter = undefined;
var ttyConfig: ?std.io.tty.Config = null;

fn init() void {
    arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    instructions = arena.?.allocator().alloc(usize, 512) catch unreachable;
    ttyConfig = ttyConfig orelse std.io.tty.detectConfig(std.io.getStdErr());
    leaks = @TypeOf(leaks).init(arena.?.allocator());
    leaksWriter = LeaksWriter{ .FileWriter = std.io.getStdErr().writer() };
    _ = atexit(&detectLeaks);
}

pub fn markForLeakDetection(address: usize, ptr: anytype) !void {
    if (arena == null) init();

    if (ibEnd >= instructions.len) {
        const newSlice = try arena.?.allocator().alloc(usize, instructions.len * 2);
        @memcpy(newSlice[0..instructions.len], instructions);
        instructions = newSlice;
    }

    var leakInfo: LeakInfo = undefined;
    leakInfo.count = 1;
    leakInfo.st.instruction_addresses = instructions[ibEnd..];
    leakInfo.typeName = util.trimmedTypeName(@TypeOf(ptr));
    leakInfo.ptr = ptr;

    std.debug.captureStackTrace(address, &(leakInfo.st));

    try leaks.put(@intFromPtr(ptr), leakInfo);
    ibEnd += leakInfo.st.index;
    liEnd += 1;
}

pub fn reference(address: usize, ptr: anytype) void {
    var entry = leaks.getPtr(@intFromPtr(ptr));
    if (entry) |e| {
        e.*.count += 1;
        return;
    }
    markForLeakDetection(address, ptr) catch |e| std.debug.panic("{any}", .{e});
}

pub fn destroy(ptr: *anyopaque) void {
    var entry = leaks.getPtr(@intFromPtr(ptr)) orelse std.debug.panic("Double free!", .{});
    entry.*.count -= 1;
    if (entry.count == 0) {
        _ = leaks.swapRemove(@intFromPtr(ptr));
    }
}

pub fn markAsDestroyed(ptr: *anyopaque) void {
    _ = leaks.swapRemove(@intFromPtr(ptr));
}

pub export fn detectLeaks() void {
    var error_state = false;
    defer {
        if (arena) |a| a.deinit();
        arena = null;
        leakInfos = undefined;
        ibEnd = 0;
        liEnd = 0;
        if (error_state) @panic("giza safety check failure");
    }
    const writer = leaksWriter;
    var it = leaks.iterator();
    while (it.next()) |pair| {
        error_state = true;
        const debugInfo = std.debug.getSelfDebugInfo() catch |err| {
            writer.print("\nUnable to print stack trace: Unable to open debug info: {s}\n", .{@errorName(err)}) catch return;
            return;
        };
        const li = pair.value_ptr;
        writer.print("[giza] (err): Leak detected! {s}@{x} leaked:\n", .{ li.typeName, @intFromPtr(li.ptr) }) catch |err| {
            writer.print("Unable to print stack trace: {s}\n", .{@errorName(err)}) catch return;
        };
        std.debug.writeStackTrace(li.st, writer, arena.?.allocator(), debugInfo, ttyConfig.?) catch |err| {
            writer.print("Unable to print stack trace: {s}\n", .{@errorName(err)}) catch return;
        };
        writer.print("\n", .{}) catch unreachable;
    }
}

extern fn atexit(?*const fn () callconv(.C) void) c_int;
