const base = @import("surfaces/base.zig");
const image = @import("surfaces/image.zig");
const svg = @import("surfaces/svg.zig");

pub const ImageSurface = image.ImageSurface;
pub const SvgSurface = svg.SvgSurface;
pub const RecordingSurface = @import("surfaces/recording.zig").RecordingSurface;
pub const Surface = base.Surface;
pub usingnamespace @import("surfaces/script.zig");
