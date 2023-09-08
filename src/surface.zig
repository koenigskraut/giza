const svg = @import("surfaces/svg.zig");
const script = @import("surfaces/script.zig");

pub const ImageSurface = @import("surfaces/image.zig").ImageSurface;
pub const RecordingSurface = @import("surfaces/recording.zig").RecordingSurface;
pub const Surface = @import("surfaces/base.zig").Surface;
pub usingnamespace svg;
pub usingnamespace script;
