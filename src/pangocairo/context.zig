const cairo = @import("cairo");
const pango = @import("pango");
const pangocairo = @import("../pangocairo.zig");
const c = pangocairo.c;

pub fn createPangoContext(self: *cairo.Context) cairo.CairoError!*pango.Context {
    return c.pango_cairo_create_context(self) orelse error.NullPointer;
}

pub fn updatePangoContext(self: *cairo.Context, context: *pango.Context) void {
    c.pango_cairo_update_context(self, context);
}

pub fn createLayout(self: *cairo.Context) cairo.CairoError!*pango.Layout {
    return c.pango_cairo_create_layout(self) orelse error.NullPointer;
}

pub fn updatePangoLayout(self: *cairo.Context, context: *pango.Context) void {
    c.pango_cairo_update_layout(self, context);
}
