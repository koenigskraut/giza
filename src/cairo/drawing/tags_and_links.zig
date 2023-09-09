//! Tags and Links — Hyperlinks and document structure
//!
//! The tag functions provide the ability to specify hyperlinks and document
//! logical structure on supported backends. The following tags are supported:
//! - [Link](https://www.cairographics.org/manual/cairo-Tags-and-Links.html#link) — Create a hyperlink
//! - [Destinations](https://www.cairographics.org/manual/cairo-Tags-and-Links.html#dest) — Create a hyperlink destination
//! - [Document Structure Tags](https://www.cairographics.org/manual/cairo-Tags-and-Links.html#doc-struct) — Create PDF Document Structure
//!
//! ## Link Tags
//!
//! A hyperlink is specified by enclosing the hyperlink text with the
//! `cairo.TagLink` tag.
//!
//! For example:
//! ```zig
//! // ctx is cairo.Context
//! ctx.tagBegin(cairo.TagLink, "uri='https://cairographics.org'");
//! ctx.moveTo(50, 50);
//! ctx.showText("This is a link to the cairo website.");
//! ctx.tagEnd(cairo.TagLink);
//! ```
//!
//! The PDF backend uses one or more rectangles to define the clickable area of
//! the link. By default cairo will use the extents of the drawing operations
//! enclosed by the begin/end link tags to define the clickable area. In some
//! cases, such as a link split across two lines, the default rectangle is
//! undesirable.
//!
//! `rect`: [optional] The "rect" attribute allows the application to specify
//! one or more rectangles that form the clickable region. The value of this
//! attribute is an array of floats. Each rectangle is specified by four
//! elements in the array: x, y, width, height. The array size must be a
//! multiple of four.
//!
//! An example of creating a link with user specified clickable region:
//! ```zig
//! // ctx is cairo.Context
//! const text1 = "This link is split";
//! const text2 = "across two lines";
//! const font_extents = ctx.fontExtents(); // ?
//! _ = font_extents;
//! ctx.moveTo(450, 50);
//! const text1_extents = ctx.textExtents(text1);
//! ctx.moveTo(50, 70);
//! const text2_extents = ctx.textExtents(text2);
//! var attribsBuf: [1024]u8 = undefined;
//! const attribs = try std.fmt.bufPrintZ(&attribsBuf, "rect=[ {d:.3} {d:.3} {d:.3} {d:.3} {d:.3} {d:.3} {d:.3} {d:.3}] uri='https://cairographics.org'", .{
//!     text1_extents.x_bearing,
//!     text1_extents.y_bearing,
//!     text1_extents.width,
//!     text1_extents.height,
//!     text2_extents.x_bearing,
//!     text2_extents.y_bearing,
//!     text2_extents.width,
//!     text2_extents.height,
//! });
//! std.debug.print("{s}\n", .{attribs});
//! ctx.tagBegin(TagLink, attribs);
//! ctx.showText("This is a link to the cairo website");
//! ctx.moveTo(450, 50);
//! ctx.showText(text1);
//! ctx.moveTo(50, 70);
//! ctx.showText(text2);
//! ctx.tagEnd(TagLink);
//! ```
//!
//! additional documentation is at https://www.cairographics.org/manual/cairo-Tags-and-Links.html

const cairo = @import("../../cairo.zig");
const c = cairo.c;
const Context = cairo.Context;

/// Marks the beginning of the `tagName` structure. Call `ctx.tagEnd()` with
/// the same `tagName` to mark the end of the structure.
///
/// The `attributes` string is of the form `"key1=value2 key2=value2 ..."`.
/// Values may be boolean (true/false or 1/0), integer, float, string, or an
/// array.
///
/// String values are enclosed in single quotes (`'`). Single quotes and
/// backslashes inside the string should be escaped with a backslash.
///
/// Boolean values may be set to true by only specifying the key. eg the
/// attribute string `"key"` is the equivalent to `"key=true"`.
///
/// Arrays are enclosed in `[]`. eg `"rect=[1.2 4.3 2.0 3.0]"`.
///
/// If no attributes are required, `attributes` can be an empty string or
/// `null`.
///
/// See [Tags and Links Description](https://www.cairographics.org/manual/cairo-Tags-and-Links.html#cairo-Tags-and-Links.description)
/// for the list of tags and attributes.
///
/// **Parameters**
/// - `tagName`: tag name
/// - `attributes`: tag attributes
///
/// [Link to Cairo documentation](https://www.cairographics.org/manual/cairo-Tags-and-Links.html#cairo-tag-begin)
pub fn tagBegin(self: *Context, tagName: [:0]const u8, attributes: ?[:0]const u8) void {
    c.cairo_tag_begin(self, tagName, attributes orelse null);
}

/// Marks the end of the `tagName` structure.
///
/// Invalid nesting of tags will cause `self` to shutdown with a status of
/// `cairo.Status.TagError`.
///
/// See `cairo.Context.tagBegin()`.
///
/// **Parameters**
/// - `tagName`: tag name
///
/// [Link to Cairo documentation](https://www.cairographics.org/manual/cairo-Tags-and-Links.html#cairo-tag-end)
pub fn tagEnd(self: *Context, tagName: [:0]const u8) void {
    c.cairo_tag_end(self, tagName);
}

pub const TagDest = "cairo.dest";
pub const TagLink = "Link";
