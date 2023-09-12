const pango = @import("../pango.zig");
const c = pango.c;

pub const FontDescription = opaque {
    pub fn new() !*FontDescription {
        return c.pango_font_description_new() orelse error.NullPointer;
    }

    pub fn copy(self: *const FontDescription) !*FontDescription {
        return c.pango_font_description_copy(self) orelse error.NullPointer;
    }

    pub fn copyStatic(self: *const FontDescription) !*FontDescription {
        return c.pango_font_description_copy_static(self) orelse error.NullPointer;
    }

    pub fn hash(self: *const FontDescription) u32 {
        return @intCast(c.pango_font_description_hash(self));
    }

    pub fn equal(self: *const FontDescription, other: *const FontDescription) bool {
        return c.pango_font_description_equal(self, other) != 0;
    }

    pub fn free(self: *FontDescription) void {
        c.pango_font_description_free(self);
    }

    pub fn freeMany(descs: []?*FontDescription) void {
        c.pango_font_descriptions_free(descs.ptr, @intCast(descs.len));
    }

    pub fn setFamily(self: *FontDescription, family: [*c]const u8) void {
        c.pango_font_description_set_family(self, family);
    }

    pub fn setFamilyStatic(self: *FontDescription, family: [*c]const u8) void {
        c.pango_font_description_set_family_static(self, family);
    }

    pub fn getFamily(self: *const FontDescription) [*c]const u8 {
        return c.pango_font_description_get_family(self);
    }

    pub fn setStyle(self: *FontDescription, style: pango.Style) void {
        c.pango_font_description_set_style(self, style);
    }

    pub fn getStyle(self: *const FontDescription) pango.Style {
        return c.pango_font_description_get_style(self);
    }

    pub fn setVariant(self: *FontDescription, variant: pango.Variant) void {
        c.pango_font_description_set_variant(self, variant);
    }

    pub fn getVariant(self: *const FontDescription) pango.Variant {
        return c.pango_font_description_get_variant(self);
    }

    pub fn setWeight(self: *FontDescription, weight: pango.Weight) void {
        c.pango_font_description_set_weight(self, weight);
    }

    pub fn getWeight(self: *const FontDescription) pango.Weight {
        return c.pango_font_description_get_weight(self);
    }

    pub fn setStretch(self: *FontDescription, stretch: pango.Stretch) void {
        c.pango_font_description_set_stretch(self, stretch);
    }

    pub fn getStretch(self: *const FontDescription) pango.Stretch {
        return c.pango_font_description_get_stretch(self);
    }

    pub fn setSize(self: *FontDescription, size: i32) void {
        c.pango_font_description_set_size(self, @intCast(size));
    }

    pub fn getSize(self: *const FontDescription) i32 {
        return @intCast(c.pango_font_description_get_size(self));
    }

    pub fn setAbsoluteSize(self: *FontDescription, size: f64) void {
        c.pango_font_description_set_absolute_size(self, size);
    }

    pub fn getSizeIsAbsolute(self: *const FontDescription) bool {
        return c.pango_font_description_get_size_is_absolute(self) != 0;
    }

    pub fn setGravity(self: *FontDescription, gravity: pango.Gravity) void {
        c.pango_font_description_set_gravity(self, gravity);
    }

    pub fn getGravity(self: *const FontDescription) pango.Gravity {
        return c.pango_font_description_get_gravity(self);
    }

    pub fn setVariationsStatic(self: *FontDescription, variations: [*c]const u8) void {
        c.pango_font_description_set_variations_static(self, variations);
    }

    pub fn setVariations(self: *FontDescription, variations: [*c]const u8) void {
        c.pango_font_description_set_variations(self, variations);
    }

    pub fn getVariations(self: *const FontDescription) [*c]const u8 {
        return c.pango_font_description_get_variations(self);
    }

    pub fn getSetFields(self: *const FontDescription) pango.FontMask {
        return c.pango_font_description_get_set_fields(self);
    }

    pub fn unsetFields(self: *FontDescription, to_unset: pango.FontMask) void {
        c.pango_font_description_unset_fields(self, to_unset);
    }

    pub fn merge(self: *FontDescription, desc_to_merge: *const FontDescription, replace_existing: bool) void {
        c.pango_font_description_merge(self, desc_to_merge, if (replace_existing) 1 else 0);
    }

    pub fn mergeStatic(self: *FontDescription, desc_to_merge: *const FontDescription, replace_existing: bool) void {
        c.pango_font_description_merge_static(self, desc_to_merge, if (replace_existing) 1 else 0);
    }

    pub fn betterMatch(self: *const FontDescription, old_match: *const FontDescription, new_match: *const FontDescription) bool {
        return c.pango_font_description_better_match(self, old_match, new_match) != 0;
    }

    pub fn fromString(str: [*c]const u8) !*FontDescription {
        return c.pango_font_description_from_string(str) orelse error.NullPointer;
    }

    pub fn toString(self: *const FontDescription) [*c]u8 {
        return c.pango_font_description_to_string(self);
    }

    pub fn toFilename(self: *const FontDescription) [*c]u8 {
        return c.pango_font_description_to_filename(self);
    }
};
