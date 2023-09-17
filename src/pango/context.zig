const build = @import("build_options");
const pango = @import("../pango.zig");
const c = pango.c;
const safety = pango.safety;

const Direction = pango.Direction;

/// A `pango.Context` stores global information used to control the itemization
/// process.
///
/// The information stored by `pango.Context` includes the fontmap used to look
/// up fonts, and default values such as the default language, default gravity,
/// or default font.
///
/// To obtain a `pango.Context`, use `pango.FontMap.createContext()`.
pub const Context = opaque {
    pub usingnamespace @import("pangocairo").pango_context;

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
        const context = c.pango_context_new() orelse return error.NullPointer;
        if (safety.tracing) try safety.markForLeakDetection(@returnAddress(), context);
        return context;
    }

    pub fn destroy(self: *Context) void {
        c.g_object_unref(self);
        if (safety.tracing) safety.destroy(self);
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

    /// Sets the font map to be searched when fonts are looked-up in this
    /// context.
    ///
    /// This is only for internal use by Pango backends, a `pango.Context`
    /// obtained via one of the recommended methods should already have a
    /// suitable font map.
    ///
    /// **Parameters**
    /// - `font_map`: the `pango.FontMap` to set, can be `null`, the data is
    /// owned by the caller of the method.
    pub fn setFontMap(self: *Context, font_map: ?*pango.FontMap) void {
        c.pango_context_set_font_map(self, font_map);
    }

    /// Gets the `pango.FontMap` used to look up fonts for this context.
    ///
    /// **Returns**
    ///
    /// the font map for the `pango.Context` This value is owned by Pango and
    /// should not be destroyed. The data is owned by the instance of
    /// `pango.Context`. The return value can be NULL.
    pub fn getFontMap(self: *Context) ?*pango.FontMap {
        return c.pango_context_get_font_map(self).?;
    }

    /// Returns the current serial number of `self`.
    ///
    /// The serial number is initialized to an small number larger than zero
    /// when a new context is created and is increased whenever the context is
    /// changed using any of the setter functions, or the `pango.FontMap` it
    /// uses to find fonts has changed. The serial may wrap, but will never
    /// have the value 0. Since it can wrap, never compare it with “less than”,
    /// always use “not equals”.
    ///
    /// This can be used to automatically detect changes to a `pango.Context`,
    /// and is only useful when implementing objects that need update when
    /// their `pango.Context` changes, like `pango.Layout`.
    ///
    /// **Returns**
    ///
    /// the current serial number of `self`.
    pub fn getSerial(self: *Context) u32 {
        return @intCast(c.pango_context_get_serial(self));
    }

    // /// List all families for a context.
    // ///
    // /// **Parameters**
    // /// - `families`:
    // pub fn listFamilies(self: *Context) void {

    // }
    // pango_context_list_families(context: ?*pango.Context, families: [*c][*c][*c]pango.FontFamily, n_families: [*c]c_int) void;

    /// Sets the base direction for the context.
    ///
    /// The base direction is used in applying the Unicode bidirectional
    /// algorithm; if the direction is `pango.Direction` `.Ltr` or `.Rtl`, then
    /// the value will be used as the paragraph direction in the Unicode
    /// bidirectional algorithm. A value of `.WeakLtr` or `Weak.Rtl` is used
    /// only for paragraphs that do not contain any strong characters
    /// themselves.
    ///
    /// **Parameters**
    /// - `direction`: the new base direction.
    pub fn setBaseDir(self: *Context, direction: Direction) void {
        c.pango_context_set_base_dir(self, direction);
    }

    /// Retrieves the base direction for the context.
    ///
    /// See `pango.setBaseDir()`.
    ///
    /// **Returns**
    ///
    /// the base direction for the context.
    pub fn getBaseDir(self: *Context) Direction {
        return c.pango_context_get_base_dir(self);
    }
};
