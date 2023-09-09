const std = @import("std");

pub const safety = @import("safety.zig");
pub usingnamespace @import("enums.zig");
pub usingnamespace @import("util.zig");

pub usingnamespace @import("surface.zig");
pub const Device = @import("device.zig").Device;

pub usingnamespace @import("context.zig");
pub usingnamespace @import("drawing/pattern.zig");
const path = @import("drawing/paths.zig");
pub const Path = path.Path;
pub const PathData = path.PathData;
pub const Region = @import("drawing/regions.zig").Region;

const text = @import("drawing/text.zig");
pub const Glyph = text.Glyph;
pub const TextCluster = text.TextCluster;
pub const FontFace = @import("fonts/font_face.zig").FontFace;
pub const ToyFontFace = text.ToyFontFace;
pub usingnamespace @import("fonts/font_options.zig");
pub usingnamespace @import("fonts/scaled_font.zig");

pub const c = @import("c.zig");

test {
    std.testing.refAllDeclsRecursive(@This());
}
