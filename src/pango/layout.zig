const std = @import("std");
const pango = @import("../pango.zig");
const safety = @import("safety");
const c = pango.c;

pub const Layout = opaque {
    /// Create a new `pango.Layout` object with attributes initialized to
    /// default values for a particular PangoContext.
    ///
    /// **Parameters**
    ///
    /// - `context`: a `pango.Context`.
    ///
    /// **Returns**
    ///
    /// the newly allocated `pango.Layout`.
    ///
    /// **NOTE**: The caller owns the created layout and should call
    /// `layout.destroy()` when done with it. You can use idiomatic Zig pattern
    /// with `defer`:
    /// ```zig
    /// const layout = try pango.Layout.create(pango_context);
    /// defer layout.destroy();
    /// ```
    ///
    pub fn create(context: *pango.Context) !*Layout {
        const layout = c.pango_layout_new(context) orelse return error.NullPointer;
        if (safety.tracing) try safety.markForLeakDetection(@returnAddress(), layout);
        return layout;
    }

    pub fn copy(self: *Layout) !*Layout {
        const layout = c.pango_layout_copy(self) orelse return error.NullPointer;
        if (safety.tracing) try safety.markForLeakDetection(@returnAddress(), layout);
        return layout;
    }

    pub fn getContext(self: *Layout) !*pango.Context {
        return c.pango_layout_get_context(self) orelse return error.NullPointer;
    }

    // pub fn setAttributes
    // pub fn getAttributes

    /// Sets the text of the layout.
    ///
    /// This function validates `text` and renders invalid UTF-8 with a
    /// placeholder glyph.
    ///
    /// Note that if you have used `pango.Layout.setMarkup()` or
    /// `pango.Layout.setMarkupWithAccel()` on layout before, you may want to
    /// call `pango.Layout.setAttributes()` to clear the attributes set on the
    /// layout from the markup as this function does not clear attributes.
    ///
    /// **Parameters**
    /// - `text`: the text as a `const u8` slice.
    pub fn setText(self: *Layout, text: []const u8) void {
        c.pango_layout_set_text(self, text.ptr, @intCast(text.len));
    }

    /// Gets the text in the layout.
    ///
    /// The returned text should not be freed or modified.
    pub fn getText(self: *Layout) []const u8 {
        return std.mem.span(c.pango_layout_get_text(self));
    }

    /// Returns the number of Unicode characters in the the text of `self`.
    pub fn getCharacterCount(self: *Layout) u32 {
        return @intCast(c.pango_layout_get_character_count(self));
    }

    // pub fn setMarkup
    // pub fn setMarkupWithAccel
    // pub fn setFontDescription
    // pub fn getFontDescription

    /// Sets the width to which the lines of the `pango.Layout` should wrap or
    /// ellipsized.
    ///
    ///The default value is -1: no width set.
    ///
    /// **Parameters**
    /// - `width`: the desired width in Pango units, or -1 to indicate that no
    /// wrapping or ellipsization should be performed.
    pub fn setWidth(self: *Layout, width: i32) void {
        c.pango_layout_set_width(self, @intCast(width));
    }

    /// Gets the width to which the lines of the `pango.Layout` should wrap.
    ///
    /// **Returns**
    ///
    /// the width in Pango units, or -1 if no width set.
    pub fn getWidth(self: *Layout) i32 {
        return @intCast(c.pango_layout_get_width(self));
    }

    /// Sets the height to which the PangoLayout should be ellipsized at.
    ///
    /// There are two different behaviors, based on whether height is positive
    /// or negative.
    ///
    /// If `height` is positive, it will be the maximum height of the layout.
    /// Only lines would be shown that would fit, and if there is any text
    /// omitted, an ellipsis added. At least one line is included in each
    /// paragraph regardless of how small the height value is. A value of zero
    /// will render exactly one line for the entire layout.
    ///
    /// If `height` is negative, it will be the (negative of) maximum number of
    /// lines per paragraph. That is, the total number of lines shown may well
    /// be more than this value if the layout contains multiple paragraphs of
    /// text. The default value of -1 means that the first line of each
    /// paragraph is ellipsized. This behavior may be changed in the future to
    /// act per layout instead of per paragraph. File a bug against pango at
    /// https://gitlab.gnome.org/gnome/pango if your code relies on this
    /// behavior.
    ///
    /// Height setting only has effect if a positive width is set on layout and
    /// ellipsization mode of layout is not `pango.EllipsizeMode.None`. The
    /// behavior is undefined if a height other than -1 is set and
    /// ellipsization mode is set to `pango.EllipsizeMode.None`, and may change
    /// in the future.
    ///
    /// **Parameters**
    /// - `height`: The desired height of the layout in Pango units if
    /// positive, or desired number of lines if negative.
    pub fn setHeight(self: *Layout, width: i32) void {
        c.pango_layout_set_height(self, @intCast(width));
    }

    /// Gets the height of layout used for ellipsization.
    ///
    /// See `pango.Layout.setHeight()` for details.
    ///
    /// **Returns**
    ///
    /// the height, in Pango units if positive, or number of lines if negative.
    pub fn getHeight(self: *Layout) i32 {
        return @intCast(c.pango_layout_get_height(self));
    }

    /// Sets the wrap mode.
    ///
    /// The wrap mode only has effect if a width is set on the layout with
    /// `pango.Layout.setWidth()`. To turn off wrapping, set the width to -1.
    ///
    /// The default value is `pango.WrapMode.Word`.
    ///
    /// **Parameters**
    /// - `wrap`: wrap mode.
    pub fn setWrap(self: *Layout, wrap: pango.WrapMode) void {
        c.pango_layout_set_wrap(self, wrap);
    }

    /// Gets the wrap mode for the layout.
    ///
    /// Use `pango.Layout.isWrapped()` to query whether any paragraphs were
    /// actually wrapped.
    ///
    /// **Returns**
    ///
    /// active wrap mode.
    pub fn getWrap(self: *Layout) pango.WrapMode {
        return c.pango_layout_get_wrap(self);
    }

    /// Queries whether the layout had to wrap any paragraphs.
    ///
    /// This returns `true` if a positive width is set on layout, ellipsization
    /// mode of layout is set to `.None`, and there are paragraphs exceeding
    /// the layout width that have to be wrapped.
    ///
    /// **Returns**
    /// `true` if any paragraphs had to be wrapped, `false` otherwise.
    pub fn isWrapped(self: *Layout) bool {
        return c.pango_layout_is_wrapped(self) != 0;
    }

    /// Sets the width in Pango units to indent each paragraph.
    ///
    /// A negative value of `indent` will produce a hanging indentation. That
    /// is, the first line will have the full width, and subsequent lines will
    /// be indented by the absolute value of `indent`.
    ///
    /// The indent setting is ignored if layout alignment is set to
    /// `pango.Align.Center`.
    ///
    /// The default value is 0.
    ///
    /// **Parameters**
    /// - `indent`: the amount by which to indent.
    pub fn setIndent(self: *Layout, indent: i32) void {
        c.pango_layout_set_indent(self, @intCast(indent));
    }

    /// Gets the paragraph indent width in Pango units.
    ///
    /// A negative value indicates a hanging indentation.
    ///
    /// **Returns**
    ///
    /// the indent in Pango units.
    pub fn getIndent(self: *Layout) i32 {
        return @intCast(c.pango_layout_get_indent(self));
    }

    /// Sets the amount of spacing in Pango units between the lines
    /// of the layout.
    ///
    /// When placing lines with spacing, Pango arranges things so that
    /// ```
    /// line2.top = line1.bottom + spacing
    /// ```
    /// The default value is 0.
    ///
    /// Note: Since 1.44, Pango is using the line height (as determined by the
    /// font) for placing lines when the line spacing factor is set to a
    /// non-zero value with `pango.Layout.setLineSpacing()`. In that case, the
    /// spacing set with this function is ignored.
    ///
    /// Note: for semantics that are closer to the CSS line-height property,
    /// see pango_attr_line_height_new().
    ///
    /// **Parameters**
    /// - `spacing`: the amount of spacing.
    pub fn setSpacing(self: *Layout, spacing: i32) void {
        // TODO: fix desc
        c.pango_layout_set_spacing(self, @intCast(spacing));
    }

    /// Gets the amount of spacing between the lines of the layout.
    ///
    /// **Returns**
    ///
    /// the spacing in Pango units.
    pub fn getSpacing(self: *Layout) i32 {
        return @intCast(c.pango_layout_get_spacing(self));
    }

    /// Sets a factor for line spacing.
    ///
    /// Typical values are: 0, 1, 1.5, 2. The default values is 0.
    ///
    /// If factor is non-zero, lines are placed so that
    /// ```
    /// baseline2 = baseline1 + factor * height2
    /// ```
    /// where height2 is the line height of the second line (as determined by
    /// the font(s)). In this case, the spacing set with
    /// `pango.Layout.setSpacing()` is ignored.
    ///
    /// If factor is zero (the default), spacing is applied as before.
    ///
    /// Note: for semantics that are closer to the CSS line-height property,
    /// see pango_attr_line_height_new().
    ///
    /// **Parameters**
    /// - `factor`: the new line spacing factor.
    pub fn setLineSpacing(self: *Layout, factor: f32) void {
        // TODO: fix desc
        c.pango_layout_set_line_spacing(self, factor);
    }

    /// Gets the line spacing factor of `self`.
    ///
    /// See `pango.Layout.setLineSpacing()`.
    pub fn getLineSpacing(self: *Layout) f32 {
        return c.pango_layout_get_line_spacing(self);
    }

    /// Sets whether each complete line should be stretched to fill the entire
    /// width of the layout.
    ///
    /// Stretching is typically done by adding whitespace, but for some scripts
    /// (such as Arabic), the justification may be done in more complex ways,
    /// like extending the characters.
    ///
    /// Note that tabs and justification conflict with each other:
    /// Justification will move content away from its tab-aligned positions.
    ///
    /// The default value is `false.
    ///
    /// Also see `pango.Layout.setJustifyLastLine()`.
    ///
    /// **Parameters**:
    /// - `justify`: whether the lines in the layout should be justified.
    pub fn setJustify(self: *Layout, justify: bool) void {
        c.pango_layout_set_justify(self, if (justify) 1 else 0);
    }

    /// Gets whether each complete line should be stretched to fill the entire
    /// width of the layout.
    pub fn getJustify(self: *Layout) bool {
        return c.pango_layout_get_justify(self) != 0;
    }

    /// Sets whether the last line should be stretched to fill the entire width
    /// of the layout.
    ///
    /// This only has an effect if `pango.Layout.setJustify()` has been called
    /// as well.
    ///
    /// The default value is `false`.
    ///
    /// **Parameters**:
    /// - `justify`: whether the last line in the layout should be justified.
    pub fn setJustifyLastLine(self: *Layout, justify: bool) void {
        c.pango_layout_set_justify_last_line(self, if (justify) 1 else 0);
    }

    /// Gets whether the last line should be stretched to fill the entire width
    /// of the layout.
    pub fn getJustifyLastLine(self: *Layout) bool {
        return c.pango_layout_get_justify_last_line(self) != 0;
    }

    /// Sets whether to calculate the base direction for the layout according
    /// to its contents.
    ///
    /// When this flag is on (the default), then paragraphs in layout that
    /// begin with strong right-to-left characters (Arabic and Hebrew
    /// principally), will have right-to-left layout, paragraphs with letters
    /// from other scripts will have left-to-right layout. Paragraphs with only
    /// neutral characters get their direction from the surrounding paragraphs.
    ///
    /// When `false`, the choice between left-to-right and right-to-left layout
    /// is done according to the base direction of the layout’s
    /// `pango.Context`. (See `pango.Context.setBaseDir()`).
    ///
    /// When the auto-computed direction of a paragraph differs from the base
    /// direction of the context, the interpretation of `pango.Align.Left` and
    /// `pango.Align.Right` are swapped.
    ///
    /// **Parameters**:
    /// - `auto_dir`: if TRUE, compute the bidirectional base direction from
    /// the layout’s contents.
    pub fn setAutoDir(self: *Layout, auto_dir: bool) void {
        c.pango_layout_set_auto_dir(self, if (auto_dir) 1 else 0);
    }

    /// Gets whether to calculate the base direction for the layout according
    /// to its contents.
    ///
    /// See `pango.Layout.setAutoDir()`.
    ///
    /// **Returns**
    ///
    /// `true` if the bidirectional base direction is computed from the
    /// layout’s contents, `false` otherwise.
    pub fn getAutoDir(self: *Layout) bool {
        return c.pango_layout_get_auto_dir(self) != 0;
    }

    /// Sets the alignment for the layout: how partial lines are positioned
    /// within the horizontal space available.
    ///
    /// The default alignment is `pango.Align.Left`.
    ///
    /// **Parameters**
    /// - `alignment`: the alignment
    pub fn setAlignment(self: *Layout, alignment: pango.Alignment) void {
        c.pango_layout_set_alignment(self, alignment);
    }

    /// Gets the alignment for the layout: how partial lines are positioned
    /// within the horizontal space available.
    pub fn getAlignment(self: *Layout) pango.Alignment {
        return c.pango_layout_get_alignment(self);
    }

    /// Increases the reference count of `self`.
    ///
    /// **Returns**
    ///
    /// the same object.
    pub fn reference(self: *Layout) *Layout {
        if (safety.tracing) safety.reference(@returnAddress(), self);
        return @ptrCast(c.g_object_ref(self).?);
    }

    /// Decreases the reference count on layout by one. If the result is zero,
    /// then `self` and all associated resources are freed. See
    /// `cairo.Layout.reference()`.
    pub fn destroy(self: *Layout) void {
        if (safety.tracing) safety.destroy(self);
        c.g_object_unref(self);
    }
};
