//! `cairo.FontFace` — Base class for font faces
//!
//! `cairo.FontFace` represents a particular font at a particular weight,
//! slant, and other characteristic but no size, transformation, or size.
//!
//! Font faces are created using *font-backend*-specific constructors,
//! typically of the form cairo_backend_font_face_create(), or implicitly using
//! the toy text API by way of `cairo.Context.selectFontFace()`. The resulting
//! face can be accessed using `cairo.Context.getFontFace()`.
// TODO: fix desc

const cairo = @import("../cairo.zig");

const safety = @import("../safety.zig");

const CairoError = cairo.CairoError;
const FontType = cairo.FontType;
const Status = cairo.Status;
const UserDataKey = cairo.UserDataKey;
const DestroyFn = cairo.DestroyFn;

/// A `cairo.FontFace` specifies all aspects of a font other than the size or
/// font matrix (a font matrix is used to distort a font by shearing it or
/// scaling it unequally in the two directions). A font face can be set on a
/// `cairo.Context` by using `ctx.setFontFace()` on it; the size and font
/// matrix are set with `ctx.setFontSize()` and `ctx.setFontMatrix()`.
///
/// There are various types of font faces, depending on the *font backend* they
/// use. The type of a font face can be queried using `fontFace.getType()`.
///
/// Memory management of `cairo.FontFace` is done with `fontFace.reference()`
/// and `fontFace.destroy()`
pub const FontFace = opaque {
    /// Increases the reference count on `self` by one. This prevents `self`
    /// from being destroyed until a matching call to `.destroy()` is made.
    ///
    /// Use `cairo.FontFace.getReferenceCount()` to get the number of
    /// references to a `cairo.FontFace`.
    ///
    /// **Returns**
    ///
    /// the referenced `cairo.FontFace`.
    ///
    /// [Link to Cairo documentation](https://www.cairographics.org/manual/cairo-cairo-font-face-t.html#cairo-font-face-reference)
    pub fn reference(self: *FontFace) *FontFace {
        if (safety.tracing) safety.reference(@returnAddress(), self);
        return cairo_font_face_reference(self).?;
    }

    /// Decreases the reference count on `self` by one. If the result is zero,
    /// then `self` and all associated resources are freed. See
    /// `cairo.FontFace.reference()`.
    ///
    /// [Link to Cairo documentation](https://www.cairographics.org/manual/cairo-cairo-font-face-t.html#cairo-font-face-destroy)
    pub fn destroy(self: *FontFace) void {
        cairo_font_face_destroy(self);
        if (safety.tracing) safety.destroy(self);
    }

    /// Checks whether an error has previously occurred for this font face.
    ///
    /// [Link to Cairo documentation](https://www.cairographics.org/manual/cairo-cairo-font-face-t.html#cairo-font-face-status)
    pub fn status(self: *FontFace) Status {
        return cairo_font_face_status(self);
    }

    /// This function returns the type of the backend used to create a font
    /// face. See `cairo.FontType` for available types.
    ///
    /// **Returns**
    ///
    /// the type of `self`.
    ///
    /// [Link to Cairo documentation](https://www.cairographics.org/manual/cairo-cairo-font-face-t.html#cairo-font-face-get-type)
    pub fn getType(self: *FontFace) FontType {
        return cairo_font_face_get_type(self);
    }

    /// Returns the current reference count of `self`.
    ///
    /// [Link to Cairo documentation](https://www.cairographics.org/manual/cairo-cairo-font-face-t.html#cairo-font-face-get-reference-count)
    pub fn getReferenceCount(self: *FontFace) usize {
        return @intCast(cairo_font_face_get_reference_count(self));
    }

    /// Attach user data to `font_face`. To remove user data from a font face,
    /// call this function with the key that was used to set it and `null` for
    /// `data`.
    ///
    /// **Parameters**
    /// - `key`: the address of a `cairo.UserDataKey` to attach the user data
    /// to
    /// - `user_data`: the user data to attach to the font face
    /// - `destroyFn`: a `cairo.DestroyFn` which will be called when the font
    /// face is destroyed or when new user data is attached using the same key.
    ///
    /// The only possible error is `error.OutOfMemory` if a slot could not be
    /// allocated for the user data.
    ///
    /// [Link to Cairo documentation](https://www.cairographics.org/manual/cairo-cairo-font-face-t.html#cairo-font-face-get-user-data)
    pub fn setUserData(self: *FontFace, key: *const UserDataKey, user_data: ?*anyopaque, destroyFn: DestroyFn) CairoError!void {
        try cairo_font_face_set_user_data(self, key, user_data, destroyFn).toErr();
    }

    /// Return user data previously attached to `self` using the specified key.
    /// If no user data has been attached with the given key this function
    /// returns `null`.
    ///
    /// **Parameters**
    /// - `key`: the address of the `cairo.UserDataKey` the user data was
    /// attached to
    ///
    /// **Returns**
    ///
    /// the user data previously attached or `null`.
    ///
    /// [Link to Cairo documentation](https://www.cairographics.org/manual/cairo-cairo-font-face-t.html#cairo-font-face-set-user-data)
    pub fn getUserData(self: *FontFace, key: *const UserDataKey) ?*anyopaque {
        cairo_font_face_get_user_data(self, key);
    }
};

extern fn cairo_font_face_reference(font_face: ?*FontFace) ?*FontFace;
extern fn cairo_font_face_destroy(font_face: ?*FontFace) void;
extern fn cairo_font_face_status(font_face: ?*FontFace) Status;
extern fn cairo_font_face_get_type(font_face: ?*FontFace) FontType;
extern fn cairo_font_face_get_reference_count(font_face: ?*FontFace) c_uint;
extern fn cairo_font_face_set_user_data(font_face: ?*FontFace, key: [*c]const UserDataKey, user_data: ?*anyopaque, destroy: DestroyFn) Status;
extern fn cairo_font_face_get_user_data(font_face: ?*FontFace, key: [*c]const UserDataKey) ?*anyopaque;
