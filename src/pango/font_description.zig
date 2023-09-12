const pango = @import("../pango.zig");
const c = pango.c;

pub const FontDescription = opaque {
    pub fn new() !*pango.FontDescription {
        return c.pango_font_description_new() orelse error.NullPointer;
    }

    pub fn copy(self: *const pango.FontDescription) !*pango.FontDescription {
        return c.pango_font_description_copy(self) orelse error.NullPointer;
    }

    pub fn copyStatic(self: *const pango.FontDescription) !*pango.FontDescription {
        return c.pango_font_description_copy_static(self) orelse error.NullPointer;
    }

    pub fn hash(self: *const pango.FontDescription) u32 {
        return @intCast(c.pango_font_description_hash(self));
    }

    pub fn equal(self: *const pango.FontDescription, other: *const pango.FontDescription) bool {
        return c.pango_font_description_equal(self, other) != 0;
    }

    pub fn free(self: *pango.FontDescription) void {
        c.pango_font_description_free(self);
    }

    // pub extern fn pango_font_descriptions_free(descs: [*c]?*pango.FontDescription, n_descs: c_int) void;

    pub fn setFamily(self: *pango.FontDescription, family: [*c]const u8) void {
        c.pango_font_description_set_family(self, family);
    }

    pub fn setFamilyStatic(self: *pango.FontDescription, family: [*c]const u8) void {
        c.pango_font_description_set_family_static(self, family);
    }

    pub fn getFamily(self: *const pango.FontDescription) [*c]const u8 {
        return c.pango_font_description_get_family(self);
    }

    // pub extern fn pango_font_description_set_style(desc: ?*pango.FontDescription, style: PangoStyle) void;
    // pub extern fn pango_font_description_get_style(desc: ?*const pango.FontDescription) PangoStyle;
    // pub extern fn pango_font_description_set_variant(desc: ?*pango.FontDescription, variant: PangoVariant) void;
    // pub extern fn pango_font_description_get_variant(desc: ?*const pango.FontDescription) PangoVariant;
    // pub extern fn pango_font_description_set_weight(desc: ?*pango.FontDescription, weight: PangoWeight) void;
    // pub extern fn pango_font_description_get_weight(desc: ?*const pango.FontDescription) PangoWeight;
    // pub extern fn pango_font_description_set_stretch(desc: ?*pango.FontDescription, stretch: PangoStretch) void;
    // pub extern fn pango_font_description_get_stretch(desc: ?*const pango.FontDescription) PangoStretch;

    pub fn setSize(self: *pango.FontDescription, size: i32) void {
        c.pango_font_description_set_size(self, @intCast(size));
    }

    pub fn getSize(self: *const pango.FontDescription) i32 {
        return @intCast(c.pango_font_description_get_size(self));
    }

    pub fn setAbsoluteSize(self: *pango.FontDescription, size: f64) void {
        c.pango_font_description_set_absolute_size(self, size);
    }

    pub fn getSizeIsAbsolute(self: *const pango.FontDescription) bool {
        return c.pango_font_description_get_size_is_absolute(self) != 0;
    }

    // pub extern fn pango_font_description_set_gravity(desc: ?*pango.FontDescription, gravity: PangoGravity) void;
    // pub extern fn pango_font_description_get_gravity(desc: ?*const pango.FontDescription) PangoGravity;

    pub fn setVariationsStatic(self: *pango.FontDescription, variations: [*c]const u8) void {
        c.pango_font_description_set_variations_static(self, variations);
    }

    pub fn setVariations(self: *pango.FontDescription, variations: [*c]const u8) void {
        c.pango_font_description_set_variations(self, variations);
    }

    pub fn getVariations(self: *const pango.FontDescription) [*c]const u8 {
        return c.pango_font_description_get_variations(self);
    }

    // pub extern fn pango_font_description_get_set_fields(desc: ?*const pango.FontDescription) PangoFontMask;
    // pub extern fn pango_font_description_unset_fields(desc: ?*pango.FontDescription, to_unset: PangoFontMask) void;

    pub fn merge(self: *pango.FontDescription, desc_to_merge: *const pango.FontDescription, replace_existing: bool) void {
        c.pango_font_description_merge(self, desc_to_merge, if (replace_existing) 1 else 0);
    }

    pub fn mergeStatic(self: *pango.FontDescription, desc_to_merge: *const pango.FontDescription, replace_existing: bool) void {
        c.pango_font_description_merge_static(self, desc_to_merge, if (replace_existing) 1 else 0);
    }

    pub fn betterMatch(self: *const pango.FontDescription, old_match: *const pango.FontDescription, new_match: *const pango.FontDescription) bool {
        return c.pango_font_description_better_match(self, old_match, new_match) != 0;
    }

    pub fn fromString(str: [*c]const u8) !*pango.FontDescription {
        return c.pango_font_description_from_string(str) orelse error.NullPointer;
    }

    pub fn toString(self: *const pango.FontDescription) [*c]u8 {
        return c.pango_font_description_to_string(self);
    }

    pub fn toFilename(self: *const pango.FontDescription) [*c]u8 {
        return c.pango_font_description_to_filename(self);
    }
};
