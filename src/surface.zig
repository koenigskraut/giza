const base = @import("surfaces/base.zig");
const image = @import("surfaces/image.zig");
const svg = @import("surfaces/svg.zig");

pub const ImageSurface = image.ImageSurface;
pub const SvgSurface = svg.SvgSurface;
pub const Surface = base.Surface;

pub const Content = base.Content;
