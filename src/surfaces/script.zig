//! Script Surfaces — Rendering to replayable scripts
//!
//! The script surface provides the ability to render to a native script that
//! matches the cairo drawing model. The scripts can be replayed using tools
//! under the util/cairo-script directory, or with cairo-perf-trace.

const cairo = @import("../cairo.zig");
const safety = @import("../safety.zig");
const util = @import("../util.zig");

const CairoError = cairo.CairoError;
const Content = cairo.Content;
const Device = cairo.Device;
const RecordingSurface = cairo.RecordingSurface;
const ScriptMode = cairo.ScriptMode;
const Status = cairo.Status;
const Surface = cairo.Surface;
const WriteFn = cairo.WriteFn;

const base = @import("base.zig");

const SurfaceMixin = base.Base;
const DeviceMixin = @import("../device.zig").Base;

pub const ScriptDevice = opaque {
    pub usingnamespace DeviceMixin(@This());

    /// Creates a output device for emitting the script, used when creating the
    /// individual surfaces.
    ///
    /// **Parameters**
    /// - `filename`: the name (path) of the file to write the script to
    ///
    /// **Returns**
    ///
    /// a pointer to the newly created device.
    ///
    /// **NOTE**: The caller owns the created device and should call
    /// `device.destroy()` when done with it. You can use idiomatic Zig pattern
    /// with `defer`:
    /// ```zig
    /// const device = try cairo.ScriptDevice.create("script.txt");
    /// defer device.destroy();
    /// ```
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Script-Surfaces.html#cairo-script-create)
    pub fn create(filename: [:0]const u8) CairoError!*ScriptDevice {
        const device = cairo_script_create(filename).?;
        try device.status().toErr();
        if (safety.tracing) try safety.markForLeakDetection(@returnAddress(), device);
        return device;
    }

    /// Creates a output device for emitting the script, used when creating the
    /// individual surfaces.
    ///
    /// **Parameters**
    /// - `writer`: pointer to a writeable object, e.g. `std.io.Writer` or
    /// `std.fs.File` (it should have a `.writeAll()` function)
    ///
    /// **Returns**
    ///
    /// a pointer to the newly created device.
    ///
    /// **NOTE**: The caller owns the created device and should call
    /// `device.destroy()` when done with it. You can use idiomatic Zig pattern
    /// with `defer`:
    /// ```zig
    /// var file = try std.fs.cwd().createFile("script.txt");
    /// const device = try cairo.ScriptDevice.createForStream(&file);
    /// defer device.destroy();
    /// ```
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Script-Surfaces.html#cairo-script-create-for-stream)
    pub fn createForStream(writer: anytype) CairoError!*ScriptDevice {
        const writeFn = util.createWriteFn(writer);
        const device = cairo_script_create_for_stream(writeFn, writer).?;
        try device.status().toErr();
        if (safety.tracing) try safety.markForLeakDetection(@returnAddress(), device);
        return device;
    }

    /// Converts the record operations in `recording_surface` into a script.
    ///
    /// **Parameters**
    /// - `recording_surface`: the recording surface to replay
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Script-Surfaces.html#cairo-script-from-recording-surface)
    pub fn fromRecordingSurface(self: *ScriptDevice, recording_surface: *RecordingSurface) CairoError!void {
        return cairo_script_from_recording_surface(self, recording_surface).toErr();
    }

    /// Change the output mode of the script.
    ///
    /// **Parameters**
    /// - `mode`: the new mode
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Script-Surfaces.html#cairo-script-set-mode)
    pub fn setMode(self: *ScriptDevice, mode: ScriptMode) void {
        cairo_script_set_mode(self, mode);
    }

    /// Queries the script for its current output mode.
    ///
    /// **Returns**
    ///
    /// the current output mode of the script.
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Script-Surfaces.html#cairo-script-get-mode)
    pub fn getMode(self: *ScriptDevice) ScriptMode {
        return cairo_script_get_mode(self);
    }

    /// Emit a string verbatim into the script.
    ///
    /// **Parameters**
    /// - `comment`: the string to emit
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Script-Surfaces.html#cairo-script-write-comment)
    pub fn writeComment(self: *ScriptDevice, comment: []const u8) void {
        cairo_script_write_comment(self, comment.ptr, @intCast(comment.len));
    }
};

/// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Script-Surfaces.html)
pub const ScriptSurface = opaque {
    pub usingnamespace SurfaceMixin(@This());

    /// Create a new surface that will emit its rendering through `script`.
    ///
    /// **Parameters**
    /// - `script`: the script (output device)
    /// - `content`: the content of the surface
    /// - `width`: width in pixels
    /// - `height`: height in pixels
    ///
    /// **Returns**
    ///
    /// a pointer to the newly created surface.
    ///
    /// **NOTE**: The caller owns the created surface and should call
    /// `surface.destroy()` when done with it. You can use idiomatic Zig
    /// pattern with `defer`:
    /// ```zig
    /// const device = try cairo.ScriptDevice.create("script.txt");
    /// defer device.destroy();
    /// const surface = try cairo.ScriptSurface.create(device, .ColorAlpha, 100, 100);
    /// defer surface.destroy();
    /// ```
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Script-Surfaces.html#cairo-script-surface-create)
    pub fn create(script: *ScriptDevice, content: Content, width: f64, height: f64) CairoError!*ScriptSurface {
        const surface = cairo_script_surface_create(script, content, width, height).?;
        try surface.status().toErr();
        if (safety.tracing) try safety.markForLeakDetection(@returnAddress(), surface);
        return surface;
    }

    /// Create a proxy surface that will render to target and record the
    /// operations to `device`.
    ///
    /// **Parameters**
    /// - `target`: a target surface to wrap
    ///
    /// **Returns**
    ///
    /// a pointer to the newly created surface.
    ///
    /// **NOTE**: The caller owns the created surface and should call
    /// `surface.destroy()` when done with it. You can use idiomatic Zig
    /// pattern with `defer`:
    /// ```zig
    /// const device = try cairo.ScriptDevice.create("script.txt");
    /// defer device.destroy();
    /// const image = try cairo.ImageSurface.create(.ARGB32, 100, 100);
    /// defer image.destroy();
    /// const surface = try cairo.ScriptSurface.createForTarget(device, surface.asSurface());
    /// defer surface.destroy();
    /// ```
    ///
    /// [Link to Cairo manual](https://www.cairographics.org/manual/cairo-Script-Surfaces.html#cairo-script-surface-create-for-target)
    pub fn createForTarget(script: *ScriptDevice, target: *Surface) CairoError!*ScriptSurface {
        const surface = cairo_script_surface_create_for_target(script, target).?;
        try surface.status().toErr();
        if (safety.tracing) try safety.markForLeakDetection(@returnAddress(), surface);
        return surface;
    }
};

test {
    // @import("std").debug.print("script test\n", .{});
    // const surface = try cairo.ImageSurface.create(.ARGB32, 100, 100);
    // defer surface.destroy();
    // const context = try cairo.Context.create(surface.asSurface());
    // defer context.destroy();

    const device = try ScriptDevice.create("script.txt");
    defer device.destroy();
    device.writeComment("aboba\nkek");
}

extern fn cairo_script_create(filename: [*c]const u8) ?*ScriptDevice;
extern fn cairo_script_create_for_stream(write_func: WriteFn, closure: ?*anyopaque) ?*ScriptDevice;
extern fn cairo_script_from_recording_surface(script: ?*ScriptDevice, recording_surface: ?*RecordingSurface) Status;
extern fn cairo_script_set_mode(script: ?*ScriptDevice, mode: ScriptMode) void;
extern fn cairo_script_get_mode(script: ?*ScriptDevice) ScriptMode;
extern fn cairo_script_surface_create(script: ?*ScriptDevice, content: Content, width: f64, height: f64) ?*ScriptSurface;
extern fn cairo_script_surface_create_for_target(script: ?*ScriptDevice, target: ?*Surface) ?*ScriptSurface;
extern fn cairo_script_write_comment(script: ?*ScriptDevice, comment: [*c]const u8, len: c_int) void;
