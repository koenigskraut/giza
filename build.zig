const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    _ = target;
    const optimize = b.standardOptimizeOption(.{});
    _ = optimize;

    const opts = b.addOptions();
    opts.addOption(bool, "no-pango", b.option(bool, "no-pango", "disable pango support") orelse false);

    var safety_module = b.addModule("safety", .{ .source_file = .{ .path = "src/safety.zig" } });

    var cairo_module = b.addModule("cairo", .{
        .source_file = .{ .path = "src/cairo.zig" },
        .dependencies = &.{
            .{ .name = "build_options", .module = opts.createModule() },
            .{ .name = "safety", .module = safety_module },
        },
    });
    var pango_module = b.addModule("pango", .{
        .source_file = .{ .path = "src/pango.zig" },
        .dependencies = &.{
            .{ .name = "build_options", .module = opts.createModule() },
            .{ .name = "cairo", .module = cairo_module },
            .{ .name = "safety", .module = safety_module },
        },
    });
    var pangocairo_module = b.addModule("pangocairo", .{
        .source_file = .{ .path = "src/pangocairo.zig" },
        .dependencies = &.{
            .{ .name = "build_options", .module = opts.createModule() },
            .{ .name = "cairo", .module = cairo_module },
            .{ .name = "pango", .module = pango_module },
            .{ .name = "safety", .module = safety_module },
        },
    });
    cairo_module.dependencies.put("pangocairo", pangocairo_module) catch @panic("OOM");
}
