const pango = @import("../pango.zig");

// glib
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
