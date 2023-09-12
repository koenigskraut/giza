const pango = @import("../pango.zig");

// glib
pub extern fn g_object_ref(object: ?*anyopaque) ?*anyopaque;
pub extern fn g_object_unref(object: ?*anyopaque) void;

pub extern fn pango_context_new() ?*pango.Context;
pub extern fn pango_context_changed(context: ?*pango.Context) void;
// pub extern fn pango_context_set_font_map(context: ?*pango.Context, font_map: [*c]PangoFontMap) void;
// pub extern fn pango_context_get_font_map(context: ?*pango.Context) [*c]PangoFontMap;
// pub extern fn pango_context_get_serial(context: ?*pango.Context) guint;
// pub extern fn pango_context_list_families(context: ?*pango.Context, families: [*c][*c][*c]PangoFontFamily, n_families: [*c]c_int) void;
// pub extern fn pango_context_load_font(context: ?*pango.Context, desc: ?*const PangoFontDescription) [*c]PangoFont;
// pub extern fn pango_context_load_fontset(context: ?*pango.Context, desc: ?*const PangoFontDescription, language: ?*PangoLanguage) [*c]PangoFontset;
// pub extern fn pango_context_get_metrics(context: ?*pango.Context, desc: ?*const PangoFontDescription, language: ?*PangoLanguage) [*c]PangoFontMetrics;
// pub extern fn pango_context_set_font_description(context: ?*pango.Context, desc: ?*const PangoFontDescription) void;
// pub extern fn pango_context_get_font_description(context: ?*pango.Context) ?*PangoFontDescription;
// pub extern fn pango_context_get_language(context: ?*pango.Context) ?*PangoLanguage;
// pub extern fn pango_context_set_language(context: ?*pango.Context, language: ?*PangoLanguage) void;
// pub extern fn pango_context_set_base_dir(context: ?*pango.Context, direction: PangoDirection) void;
// pub extern fn pango_context_get_base_dir(context: ?*pango.Context) PangoDirection;
// pub extern fn pango_context_set_base_gravity(context: ?*pango.Context, gravity: PangoGravity) void;
// pub extern fn pango_context_get_base_gravity(context: ?*pango.Context) PangoGravity;
// pub extern fn pango_context_get_gravity(context: ?*pango.Context) PangoGravity;
// pub extern fn pango_context_set_gravity_hint(context: ?*pango.Context, hint: PangoGravityHint) void;
// pub extern fn pango_context_get_gravity_hint(context: ?*pango.Context) PangoGravityHint;
// pub extern fn pango_context_set_matrix(context: ?*pango.Context, matrix: [*c]const PangoMatrix) void;
// pub extern fn pango_context_get_matrix(context: ?*pango.Context) [*c]const PangoMatrix;
// pub extern fn pango_context_set_round_glyph_positions(context: ?*pango.Context, round_positions: gboolean) void;
// pub extern fn pango_context_get_round_glyph_positions(context: ?*pango.Context) gboolean;

// layout
pub extern fn pango_layout_new(context: ?*pango.Context) ?*pango.Layout;
pub extern fn pango_layout_copy(src: ?*pango.Layout) ?*pango.Layout;
pub extern fn pango_layout_get_context(layout: ?*pango.Layout) ?*pango.Context;
// pub extern fn pango_layout_set_attributes(layout: ?*pango.Layout, attrs: ?*PangoAttrList) void;
// pub extern fn pango_layout_get_attributes(layout: ?*pango.Layout) ?*PangoAttrList;
pub extern fn pango_layout_set_text(layout: ?*pango.Layout, text: [*c]const u8, length: c_int) void;
pub extern fn pango_layout_get_text(layout: ?*pango.Layout) [*c]const u8;
pub extern fn pango_layout_get_character_count(layout: ?*pango.Layout) c_int;
// pub extern fn pango_layout_set_markup(layout: ?*pango.Layout, markup: [*c]const u8, length: c_int) void;
// pub extern fn pango_layout_set_markup_with_accel(layout: ?*pango.Layout, markup: [*c]const u8, length: c_int, accel_marker: gunichar, accel_char: [*c]gunichar) void;
pub extern fn pango_layout_set_font_description(layout: ?*pango.Layout, desc: ?*const pango.FontDescription) void;
pub extern fn pango_layout_get_font_description(layout: ?*pango.Layout) ?*const pango.FontDescription;
pub extern fn pango_layout_set_width(layout: ?*pango.Layout, width: c_int) void;
pub extern fn pango_layout_get_width(layout: ?*pango.Layout) c_int;
pub extern fn pango_layout_set_height(layout: ?*pango.Layout, height: c_int) void;
pub extern fn pango_layout_get_height(layout: ?*pango.Layout) c_int;
pub extern fn pango_layout_set_wrap(layout: ?*pango.Layout, wrap: pango.WrapMode) void;
pub extern fn pango_layout_get_wrap(layout: ?*pango.Layout) pango.WrapMode;
pub extern fn pango_layout_is_wrapped(layout: ?*pango.Layout) c_int; // bool
pub extern fn pango_layout_set_indent(layout: ?*pango.Layout, indent: c_int) void;
pub extern fn pango_layout_get_indent(layout: ?*pango.Layout) c_int;
pub extern fn pango_layout_set_spacing(layout: ?*pango.Layout, spacing: c_int) void;
pub extern fn pango_layout_get_spacing(layout: ?*pango.Layout) c_int;
pub extern fn pango_layout_set_line_spacing(layout: ?*pango.Layout, factor: f32) void;
pub extern fn pango_layout_get_line_spacing(layout: ?*pango.Layout) f32;

pub extern fn pango_layout_set_justify(layout: ?*pango.Layout, justify: c_int) void; // bool
pub extern fn pango_layout_get_justify(layout: ?*pango.Layout) c_int; // bool
pub extern fn pango_layout_set_justify_last_line(layout: ?*pango.Layout, justify: c_int) void; // bool
pub extern fn pango_layout_get_justify_last_line(layout: ?*pango.Layout) c_int; // bool
pub extern fn pango_layout_set_auto_dir(layout: ?*pango.Layout, auto_dir: c_int) void; // bool
pub extern fn pango_layout_get_auto_dir(layout: ?*pango.Layout) c_int; // bool
pub extern fn pango_layout_set_alignment(layout: ?*pango.Layout, alignment: pango.Alignment) void;
pub extern fn pango_layout_get_alignment(layout: ?*pango.Layout) pango.Alignment;
// pub extern fn pango_layout_set_tabs(layout: ?*pango.Layout, tabs: ?*PangoTabArray) void;
// pub extern fn pango_layout_get_tabs(layout: ?*pango.Layout) ?*PangoTabArray;
// pub extern fn pango_layout_set_single_paragraph_mode(layout: ?*pango.Layout, setting: gboolean) void;
// pub extern fn pango_layout_get_single_paragraph_mode(layout: ?*pango.Layout) gboolean;
// pub extern fn pango_layout_set_ellipsize(layout: ?*pango.Layout, ellipsize: PangoEllipsizeMode) void;
// pub extern fn pango_layout_get_ellipsize(layout: ?*pango.Layout) PangoEllipsizeMode;
// pub extern fn pango_layout_is_ellipsized(layout: ?*pango.Layout) gboolean;
// pub extern fn pango_layout_get_unknown_glyphs_count(layout: ?*pango.Layout) c_int;
// pub extern fn pango_layout_get_direction(layout: ?*pango.Layout, index: c_int) PangoDirection;
// pub extern fn pango_layout_context_changed(layout: ?*pango.Layout) void;
// pub extern fn pango_layout_get_serial(layout: ?*pango.Layout) guint;
// pub extern fn pango_layout_get_log_attrs(layout: ?*pango.Layout, attrs: [*c]?*PangoLogAttr, n_attrs: [*c]gint) void;
// pub extern fn pango_layout_get_log_attrs_readonly(layout: ?*pango.Layout, n_attrs: [*c]gint) ?*const PangoLogAttr;
// pub extern fn pango_layout_index_to_pos(layout: ?*pango.Layout, index_: c_int, pos: [*c]PangoRectangle) void;
// pub extern fn pango_layout_index_to_line_x(layout: ?*pango.Layout, index_: c_int, trailing: gboolean, line: [*c]c_int, x_pos: [*c]c_int) void;
// pub extern fn pango_layout_get_cursor_pos(layout: ?*pango.Layout, index_: c_int, strong_pos: [*c]PangoRectangle, weak_pos: [*c]PangoRectangle) void;
// pub extern fn pango_layout_get_caret_pos(layout: ?*pango.Layout, index_: c_int, strong_pos: [*c]PangoRectangle, weak_pos: [*c]PangoRectangle) void;
// pub extern fn pango_layout_move_cursor_visually(layout: ?*pango.Layout, strong: gboolean, old_index: c_int, old_trailing: c_int, direction: c_int, new_index: [*c]c_int, new_trailing: [*c]c_int) void;
// pub extern fn pango_layout_xy_to_index(layout: ?*pango.Layout, x: c_int, y: c_int, index_: [*c]c_int, trailing: [*c]c_int) gboolean;
// pub extern fn pango_layout_get_extents(layout: ?*pango.Layout, ink_rect: [*c]PangoRectangle, logical_rect: [*c]PangoRectangle) void;
// pub extern fn pango_layout_get_pixel_extents(layout: ?*pango.Layout, ink_rect: [*c]PangoRectangle, logical_rect: [*c]PangoRectangle) void;
// pub extern fn pango_layout_get_size(layout: ?*pango.Layout, width: [*c]c_int, height: [*c]c_int) void;
// pub extern fn pango_layout_get_pixel_size(layout: ?*pango.Layout, width: [*c]c_int, height: [*c]c_int) void;
// pub extern fn pango_layout_get_baseline(layout: ?*pango.Layout) c_int;
// pub extern fn pango_layout_get_line_count(layout: ?*pango.Layout) c_int;
// pub extern fn pango_layout_get_line(layout: ?*pango.Layout, line: c_int) ?*pango.LayoutLine;
// pub extern fn pango_layout_get_line_readonly(layout: ?*pango.Layout, line: c_int) ?*pango.LayoutLine;
// pub extern fn pango_layout_get_lines(layout: ?*pango.Layout) [*c]GSList;
// pub extern fn pango_layout_get_lines_readonly(layout: ?*pango.Layout) [*c]GSList;

// FontDescription
pub extern fn pango_font_description_new() ?*pango.FontDescription;
pub extern fn pango_font_description_copy(desc: ?*const pango.FontDescription) ?*pango.FontDescription;
pub extern fn pango_font_description_copy_static(desc: ?*const pango.FontDescription) ?*pango.FontDescription;
pub extern fn pango_font_description_hash(desc: ?*const pango.FontDescription) c_uint;
pub extern fn pango_font_description_equal(desc1: ?*const pango.FontDescription, desc2: ?*const pango.FontDescription) c_int; // bool
pub extern fn pango_font_description_free(desc: ?*pango.FontDescription) void;
// pub extern fn pango_font_descriptions_free(descs: [*c]?*pango.FontDescription, n_descs: c_int) void;
pub extern fn pango_font_description_set_family(desc: ?*pango.FontDescription, family: [*c]const u8) void;
pub extern fn pango_font_description_set_family_static(desc: ?*pango.FontDescription, family: [*c]const u8) void;
pub extern fn pango_font_description_get_family(desc: ?*const pango.FontDescription) [*c]const u8;
// pub extern fn pango_font_description_set_style(desc: ?*pango.FontDescription, style: PangoStyle) void;
// pub extern fn pango_font_description_get_style(desc: ?*const pango.FontDescription) PangoStyle;
// pub extern fn pango_font_description_set_variant(desc: ?*pango.FontDescription, variant: PangoVariant) void;
// pub extern fn pango_font_description_get_variant(desc: ?*const pango.FontDescription) PangoVariant;
// pub extern fn pango_font_description_set_weight(desc: ?*pango.FontDescription, weight: PangoWeight) void;
// pub extern fn pango_font_description_get_weight(desc: ?*const pango.FontDescription) PangoWeight;
// pub extern fn pango_font_description_set_stretch(desc: ?*pango.FontDescription, stretch: PangoStretch) void;
// pub extern fn pango_font_description_get_stretch(desc: ?*const pango.FontDescription) PangoStretch;
pub extern fn pango_font_description_set_size(desc: ?*pango.FontDescription, size: c_int) void;
pub extern fn pango_font_description_get_size(desc: ?*const pango.FontDescription) c_int;
pub extern fn pango_font_description_set_absolute_size(desc: ?*pango.FontDescription, size: f64) void;
pub extern fn pango_font_description_get_size_is_absolute(desc: ?*const pango.FontDescription) c_int; // bool
// pub extern fn pango_font_description_set_gravity(desc: ?*pango.FontDescription, gravity: PangoGravity) void;
// pub extern fn pango_font_description_get_gravity(desc: ?*const pango.FontDescription) PangoGravity;
pub extern fn pango_font_description_set_variations_static(desc: ?*pango.FontDescription, variations: [*c]const u8) void;
pub extern fn pango_font_description_set_variations(desc: ?*pango.FontDescription, variations: [*c]const u8) void;
pub extern fn pango_font_description_get_variations(desc: ?*const pango.FontDescription) [*c]const u8;
// pub extern fn pango_font_description_get_set_fields(desc: ?*const pango.FontDescription) PangoFontMask;
// pub extern fn pango_font_description_unset_fields(desc: ?*pango.FontDescription, to_unset: PangoFontMask) void;
pub extern fn pango_font_description_merge(desc: ?*pango.FontDescription, desc_to_merge: ?*const pango.FontDescription, replace_existing: c_int) void; // bool
pub extern fn pango_font_description_merge_static(desc: ?*pango.FontDescription, desc_to_merge: ?*const pango.FontDescription, replace_existing: c_int) void; // bool
pub extern fn pango_font_description_better_match(desc: ?*const pango.FontDescription, old_match: ?*const pango.FontDescription, new_match: ?*const pango.FontDescription) c_int; // bool
pub extern fn pango_font_description_from_string(str: [*c]const u8) ?*pango.FontDescription;
pub extern fn pango_font_description_to_string(desc: ?*const pango.FontDescription) [*c]u8;
pub extern fn pango_font_description_to_filename(desc: ?*const pango.FontDescription) [*c]u8;
