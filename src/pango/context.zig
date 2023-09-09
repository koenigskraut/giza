const pango = @import("../pango.zig");
const c = pango.c;
const safety = pango.safety;

pub const Context = opaque {
    // TODO: fix desc
    /// Creates a new `pango.Context` initialized to default values.
    ///
    /// This function is not particularly useful as it should always be
    /// followed by a `pango.Context.setFontMap()` call, and the function
    /// pango_font_map_create_context() does these two steps together and hence
    /// users are recommended to use that.
    ///
    /// If you are using Pango as part of a higher-level system, that system
    /// may have it’s own way of create a `pango.Context`. For instance, the
    /// GTK toolkit has, among others, `gtk_widget_get_pango_context()`. Use
    /// those instead.
    ///
    /// **Returns**
    ///
    /// the newly allocated `pango.Context`.
    ///
    /// **NOTE**: The caller owns the created context and should call
    /// `context.destroy()` when done with it. You can use idiomatic Zig
    /// pattern with `defer`:
    /// ```zig
    /// const context = pango.Context.create();
    /// defer context.destroy();
    /// ```
    pub fn create() !*Context {
        const context = c.pango_context_new() orelse error.NullPointer;
        if (safety.tracing) try safety.markForLeakDetection(@returnAddress(), context);
        return context;
    }

    /// Forces a change in the context, which will cause any PangoLayout using
    /// this context to re-layout.
    ///
    /// This function is only useful when implementing a new backend for Pango,
    /// something applications won’t do. Backends should call this function if
    /// they have attached extra data to the context and such data is changed.
    pub fn changed(self: *Context) void {
        c.pango_context_changed(self);
    }

    pub fn destroy(self: *Context) void {
        c.g_object_unref(self);
        if (safety.tracing) safety.destroy(self);
    }
};
