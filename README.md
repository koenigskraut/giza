# giza

An attempt to make a binding for the popular [cairo](https://gitlab.freedesktop.org/cairo/cairo) graphics library with some idiomatic Zig elements (and some that will make true Zig enjoyers' skin crawl).

Many thanks to [jackdbd](https://github.com/jackdbd) for his [implementation](https://github.com/jackdbd/zig-cairo) of such binding.

Zig version is 0.11.0.

## Killer features

There are just the two of them, but what are these two!

### Safety checks

**cairo** sometimes returns allocated objects with user-managed lifetime, take for example:
```zig
const surface = try cairo.ImageSurface.create(.ARGB32, 600, 400); // cairo.ImageSurface with alpha 600x400px
```
`surface` is owned by user and should be destroyed at some point with `surface.destroy()`. It can be done nicely with Zig `defer` pattern:
```zig
const surface = try cairo.ImageSurface.create(.ARGB32, 600, 400);
defer surface.destroy();
```
But what if it cannot? Let's see some example:
```zig
const cairo = @import("cairo");

test "safety" {
    const surface = try cairo.ImageSurface.create(.ARGB32, 600, 400);
    _ = surface;
}
```
Run it:
```bash
$ zig build test
run test: error: [giza] (err): Leak detected! ImageSurface@1cc4470 leaked:
/some/path/to/safety_test.zig:4:50: 0x235821 in test.safety (test)
    const surface = try cairo.ImageSurface.create(.ARGB32, 600, 400);
                                                 ^
...
Build Summary: 1/3 steps succeeded; 1 failed; 1/1 tests passed (disable with --summary none)
test transitive failure
└─ run test failure
```
Yes, **giza** detected a leak, printed stacktrace and panicked at return of the program, just like if it was a native Zig allocator leak!

Since we are linking libc anyway, I just interject some pointer counting in `create()`/`.reference()`/`.destroy()` functions and check for leaks with `atexit()` at the end. This happens only in debug and shouldn't be a performance issue then.

### `opaque` types

We have a C object, but what we want is a native one. Popular pattern: pointer to C object is stored as a field of the native struct/class and passed under the hood to C functions. That's fine, but can we do better?

Thanks to Zig's easy C interop, in **giza** there is no such pattern. All C objects behave like native ones. What are advantages and should you care? Let's see. 

Every function in **giza**, that returns object with `.status()` method **and** could set it into an error state, checks its status and raises error immediately. It's not always the intended behavoir: **cairo** safely allows errors to propagate in these cases, plus it's overhead.

So for example let's create `ImageSurface` unsafely and manage it manually:
```zig
const std = @import("std");
const cairo = @import("cairo");
const c = @cImport(@cInclude("cairo.h"));

test "interop 1" {
    const surface_c = c.cairo_image_surface_create_from_png("does_not_exist.png").?; // cairo usually don't return null objects
    defer c.cairo_surface_destroy(surface_c);

    const image: *cairo.ImageSurface = @ptrCast(surface_c);
    try std.testing.expect(image.status() == .FileNotFound);
}
```
We can use prepared C functions from `cairo` module to avoid pointer casting:
```zig
test "interop 2" {
    const image = cairo_image_surface_create_from_png("does_not_exist.png").?;
    defer cairo.c.cairo_surface_destroy(image);
    try std.testing.expect(image.status() == .FileNotFound);
}
```
**giza**'s matrix functions return matrices by value:
```zig
var m = cairo.Matrix.identity();
```
`m` is `cairo.Matrix` which is an `extern struct` of 6 `f64` fields. But if you want, you can use underlying C function directly:
```zig
const cairo = @import("cairo");
const c = @cImport(@cInlude("cairo.h"));

test "interop 3" {
    var m: cairo.Matrix = undefined;
    c.cairo_matrix_init_identity(@ptrCast(&m));
    ...
}
```
or with `giza`'s prepared `extern fn`s:
```zig
test "interop 4" {
    var m: cairo.Matrix = undefined;
    cairo.c.cairo_matrix_init_identity(&m);
    ...
}
```
Every C object in **giza** is a valid Zig `opaque`/`extern struct`/`enum`, so you can call C functions with them like nothing yourself!

## Coverage and progress

You can find coverage info [here](https://github.com/koenigskraut/giza/blob/master/coverage_cairo.md). Current progress is 80.6% regarding **cairo** functionality, __*but*__ it generally should work already. The only two parts that are missing are fonts and real devices (other than script one). If you only need cairo to write some PNG/PDF/SVG files, that is already covered. There are other surfaces, devices and fonts coverage planned, but that would require using header files, which this wrapping has avoided so far, so we'll see.

Also pango support is planned, probably as part of this repo.
