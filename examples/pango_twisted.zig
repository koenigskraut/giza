//! Example code to show how to use pangocairo to render text projected on a path.
//! https://gitlab.gnome.org/GNOME/pango/-/blob/main/examples/cairotwisted.c
const std = @import("std");
const pi = std.math.pi;
const sqrt = std.math.sqrt;
const cairo = @import("cairo");
const pango = @import("pango");

fn fancyStroke(cr: *cairo.Context) !void {
    try _fancyStroke(cr, false);
}

fn fancyStrokePreserve(cr: *cairo.Context) !void {
    try _fancyStroke(cr, true);
}

// A fancy cairo_stroke[_preserve]() that draws points and control
// points, and connects them together.
fn _fancyStroke(cr: *cairo.Context, preserve: bool) !void {
    const dash = [_]f64{ 10, 10 };

    cr.save();
    defer cr.restore();
    cr.setSourceRgb(1.0, 0.0, 0.0);

    const line_width = cr.getLineWidth();
    const path = try cr.copyPath();
    defer path.destroy();
    const path_data = path.items();
    cr.newPath();

    cr.save();
    cr.setLineWidth(line_width / 3);
    cr.setDash(&dash, 0);

    var i: usize = 0;
    while (i < path_data.len) : (i += @intCast(path_data[i].header.length)) {
        switch (path_data[i].header.h_type) {
            .LineTo, .MoveTo => cr.moveTo(path_data[i..][1].point.x, path_data[i..][1].point.y),
            .CurveTo => {
                cr.lineTo(path_data[i..][1].point.x, path_data[i..][1].point.y);
                cr.moveTo(path_data[i..][2].point.x, path_data[i..][2].point.y);
                cr.lineTo(path_data[i..][3].point.x, path_data[i..][3].point.y);
            },
            else => {},
        }
    }

    cr.stroke();
    cr.restore();

    cr.save();
    cr.setLineWidth(line_width * 4);
    cr.setLineCap(.Round);

    i = 0;
    while (i < path_data.len) : (i += @intCast(path_data[i].header.length)) {
        switch (path_data[i].header.h_type) {
            .MoveTo => cr.moveTo(path_data[i..][1].point.x, path_data[i..][1].point.y),
            .LineTo => {
                cr.relLineTo(0, 0);
                cr.moveTo(path_data[i..][1].point.x, path_data[i..][1].point.y);
            },
            .CurveTo => {
                cr.relLineTo(0, 0);
                cr.moveTo(path_data[i..][1].point.x, path_data[i..][1].point.y);
                cr.relLineTo(0, 0);
                cr.moveTo(path_data[i..][2].point.x, path_data[i..][2].point.y);
                cr.relLineTo(0, 0);
                cr.moveTo(path_data[i..][3].point.x, path_data[i..][3].point.y);
            },
            .ClosePath => {
                cr.relLineTo(0, 0);
            },
        }
    }
    cr.relLineTo(0, 0);
    cr.stroke();
    cr.restore();

    i = 0;
    while (i < path_data.len) : (i += @intCast(path_data[i].header.length)) {
        switch (path_data[i].header.h_type) {
            .MoveTo => cr.moveTo(path_data[i..][1].point.x, path_data[i..][1].point.y),
            .LineTo => cr.lineTo(path_data[i..][1].point.x, path_data[i..][1].point.y),
            .CurveTo => cr.curveTo(path_data[i..][1].point.x, path_data[i..][1].point.y, path_data[i..][2].point.x, path_data[i..][2].point.y, path_data[i..][3].point.x, path_data[i..][3].point.y),
            .ClosePath => cr.closePath(),
        }
    }
    cr.stroke();

    if (preserve) cr.appendPath(path);
}

// Returns Euclidean distance between two points
fn twoPointsDistance(a: cairo.PathData, b: cairo.PathData) f64 {
    const dx = b.point.x - a.point.x;
    const dy = b.point.y - a.point.y;
    return @sqrt(dx * dx + dy * dy);
}

// Returns length of a Bezier curve.
// Seems like computing that analytically is not easy. The code just flattens
// the curve using cairo and adds the length of segments.
fn curveLength(x0: f64, y0: f64, x1: f64, y1: f64, x2: f64, y2: f64, x3: f64, y3: f64) !f64 {
    const surface = try cairo.ImageSurface.create(.a8, 0, 0);
    defer surface.destroy();
    const cr = try cairo.Context.create(surface.asSurface());
    defer cr.destroy();

    cr.moveTo(x0, y0);
    cr.curveTo(x1, y1, x2, y2, x3, y3);

    var length: f64 = 0;
    const path = try cr.copyPathFlat();
    defer path.destroy();

    var i: usize = 0;
    var current_point: cairo.PathData = undefined;
    const data = path.items();

    while (i < data.len) : (i += @intCast(data[i].header.length)) {
        const header = data[i].header;
        switch (header.h_type) {
            .MoveTo => current_point = data[i + 1],
            .LineTo => {
                length += twoPointsDistance(current_point, data[i + 1]);
                current_point = data[i + 1];
            },
            else => unreachable,
        }
    }

    return length;
}

const parametrizationT = f64;
const alloc = std.heap.c_allocator;

// Compute parametrization info. That is, for each part of the cairo path, tags
// it with its length.
//
// Free returned value.
fn parametrizePath(path: *cairo.Path) ![]parametrizationT {
    const parametrization = try alloc.alloc(parametrizationT, @intCast(path.num_data));

    const data = path.items();
    var i: usize = 0;
    var last_move_to: cairo.PathData = undefined;
    var current_point: cairo.PathData = undefined;

    while (i < data.len) : (i += @intCast(data[i].header.length)) {
        parametrization[i] = 0;
        switch (data[i].header.h_type) {
            .MoveTo => {
                last_move_to = data[i..][1];
                current_point = data[i..][1];
            },
            .ClosePath, .LineTo => |tag| {
                // .ClosePath: make it look like it's a line_to to last_move_to
                const point = if (tag == .ClosePath) last_move_to else data[i..][1];
                parametrization[i] = twoPointsDistance(current_point, point);
                current_point = point;
            },

            // naive curve-length, treating bezier as three line segments:
            // parametrization[i] = two_points_distance (&current_point, &data[1])
            //            + two_points_distance (&data[1], &data[2])
            //            + two_points_distance (&data[2], &data[3]);
            .CurveTo => {
                parametrization[i] = try curveLength(
                    current_point.point.x,
                    current_point.point.y,
                    data[i..][1].point.x,
                    data[i..][1].point.y,
                    data[i..][2].point.x,
                    data[i..][2].point.y,
                    data[i..][3].point.x,
                    data[i..][3].point.y,
                );
                current_point = data[i..][3];
            },
        }
    }
    return parametrization;
}

const TransformPointFn = *const fn (closure: *ParametrizedPath, x: *f64, y: *f64) void;

// Project a path using a function.  Each point of the path (including Bezier
// control points) is passed to the function for transformation.
fn transformPath(path: *cairo.Path, f: TransformPointFn, closure: *ParametrizedPath) void {
    var i: usize = 0;
    const data = path.items();
    while (i < data.len) : (i += @intCast(data[i].header.length)) {
        const tag = data[i].header.h_type;
        if (tag == .ClosePath) continue;
        if (tag == .CurveTo) {
            f(closure, &data[i..][3].point.x, &data[i..][3].point.y);
            f(closure, &data[i..][2].point.x, &data[i..][2].point.y);
        }
        f(closure, &data[i..][1].point.x, &data[i..][1].point.y);
    }
}

// Simple struct to hold a path and its parametrization
const ParametrizedPath = struct {
    path: *cairo.Path,
    parametrization: []parametrizationT,
};

// Project a point X,Y onto a parameterized path. The final point is where you
// get if you walk on the path forward from the beginning for X units, then
// stop there and walk another Y units perpendicular to the path at that point.
// In more detail:
//
// There's three pieces of math involved:
//
//   - The parametric form of the Line equation
//     http://en.wikipedia.org/wiki/Line
//
//   - The parametric form of the Cubic Bézier curve equation
//     http://en.wikipedia.org/wiki/B%C3%A9zier_curve
//
//   - The Gradient (aka multi-dimensional derivative) of the above
//     http://en.wikipedia.org/wiki/Gradient
//
// The parametric forms are used to answer the question of "where will I be if
// I walk a distance of X on this path". The Gradient is used to answer the
// question of "where will I be if then I stop, rotate left for 90 degrees and
// walk straight for a distance of Y".
fn pointOnPath(param: *ParametrizedPath, x: *f64, y: *f64) void {
    var ratio: f64 = undefined;
    var the_y: f64 = y.*;
    var the_x: f64 = x.*;
    var dx: f64 = undefined;
    var dy: f64 = undefined;

    const path = param.path;
    const data = path.items();
    const parametrization = param.parametrization;

    var i: usize = 0;
    var last_move_to: cairo.PathData = undefined;
    var current_point: cairo.PathData = undefined;

    while (i + @as(usize, @intCast(data[i].header.length)) < data.len and
        (the_x > parametrization[i] or data[i].header.h_type == .MoveTo)) : (i += @intCast(data[i].header.length))
    {
        the_x -= parametrization[i];
        switch (data[i].header.h_type) {
            .MoveTo => {
                current_point = data[i..][1];
                last_move_to = data[i..][1];
            },
            .LineTo => current_point = data[i..][1],
            .CurveTo => current_point = data[i..][3],
            .ClosePath => {},
        }
    }

    switch (data[i].header.h_type) {
        .ClosePath, .LineTo => |tag| {
            // On .ClosePath make it look like it's a line_to to last_move_to
            const point = if (tag == .ClosePath) last_move_to.point else data[i..][1].point;
            ratio = the_x / parametrization[i];

            // Line polynomial
            x.* = current_point.point.x * (1 - ratio) + point.x * ratio;
            y.* = current_point.point.y * (1 - ratio) + point.y * ratio;

            // Line gradient
            dx = -(current_point.point.x - point.x);
            dy = -(current_point.point.y - point.y);

            // optimization for: ratio = the_y / sqrt (dx * dx + dy * dy);
            ratio = the_y / parametrization[i];
            x.* += -dy * ratio;
            y.* += dx * ratio;
        },
        .CurveTo => {
            // FIXME the formulas here are not exactly what we want, because
            // the Bezier parametrization is not uniform. But I don't know how
            // to do better. The caller can do slightly better though, by
            // flattening the Bezier and avoiding this branch completely. That
            // has its own cost though, as large y values magnify the
            // flattening error drastically.
            var ratio_1_0: f64 = undefined;
            var ratio_0_1: f64 = undefined;
            var ratio_2_0: f64 = undefined;
            var ratio_0_2: f64 = undefined;
            var ratio_3_0: f64 = undefined;
            var ratio_2_1: f64 = undefined;
            var ratio_1_2: f64 = undefined;
            var ratio_0_3: f64 = undefined;
            var _1__4ratio_1_0_3ratio_2_0: f64 = undefined;
            var _2ratio_1_0_3ratio_2_0: f64 = undefined;

            ratio = the_x / parametrization[i];

            ratio_1_0 = ratio;
            ratio_0_1 = 1 - ratio;

            ratio_2_0 = ratio_1_0 * ratio_1_0; //      ratio  *      ratio
            ratio_0_2 = ratio_0_1 * ratio_0_1; // (1 - ratio) * (1 - ratio)

            ratio_3_0 = ratio_2_0 * ratio_1_0; //      ratio  *      ratio  *      ratio
            ratio_2_1 = ratio_2_0 * ratio_0_1; //      ratio  *      ratio  * (1 - ratio)
            ratio_1_2 = ratio_1_0 * ratio_0_2; //      ratio  * (1 - ratio) * (1 - ratio)
            ratio_0_3 = ratio_0_1 * ratio_0_2; // (1 - ratio) * (1 - ratio) * (1 - ratio)

            _1__4ratio_1_0_3ratio_2_0 = 1 - 4 * ratio_1_0 + 3 * ratio_2_0;
            _2ratio_1_0_3ratio_2_0 = 2 * ratio_1_0 - 3 * ratio_2_0;

            // Bezier polynomial
            x.* = current_point.point.x * ratio_0_3 + 3 * data[i..][1].point.x * ratio_1_2 + 3 * data[i..][2].point.x * ratio_2_1 + data[i..][3].point.x * ratio_3_0;
            y.* = current_point.point.y * ratio_0_3 + 3 * data[i..][1].point.y * ratio_1_2 + 3 * data[i..][2].point.y * ratio_2_1 + data[i..][3].point.y * ratio_3_0;

            // Bezier gradient
            dx = -3 * current_point.point.x * ratio_0_2 + 3 * data[i..][1].point.x * _1__4ratio_1_0_3ratio_2_0 + 3 * data[i..][2].point.x * _2ratio_1_0_3ratio_2_0 + 3 * data[i..][3].point.x * ratio_2_0;
            dy = -3 * current_point.point.y * ratio_0_2 + 3 * data[i..][1].point.y * _1__4ratio_1_0_3ratio_2_0 + 3 * data[i..][2].point.y * _2ratio_1_0_3ratio_2_0 + 3 * data[i..][3].point.y * ratio_2_0;

            ratio = the_y / sqrt(dx * dx + dy * dy);
            x.* += -dy * ratio;
            y.* += dx * ratio;
        },
        else => {},
    }
}

// Projects the current path of cr onto the provided path.
fn mapPathOnto(cr: *cairo.Context, path: *cairo.Path) !void {
    var param: ParametrizedPath = .{
        .path = path,
        .parametrization = try parametrizePath(path),
    };

    const current_path = try cr.copyPath();
    defer current_path.destroy();
    cr.newPath();

    transformPath(current_path, &pointOnPath, &param);

    cr.appendPath(current_path);

    alloc.free(param.parametrization);
}

fn drawText(cr: *cairo.Context, x: f64, y: f64, font: [:0]const u8, text: [:0]const u8) !void {
    const font_options = try cairo.FontOptions.create();
    defer font_options.destroy();

    font_options.setHintStyle(.None);
    font_options.setHintMetrics(.Off);

    cr.setFontOptions(font_options);

    const layout: *pango.Layout = try cr.createLayout();
    defer layout.destroy();

    const desc = try pango.FontDescription.fromString(font);
    defer desc.free();
    layout.setFontDescription(desc);

    layout.setText(text);

    // Use pango.Layout.getLine() instead of pango.Layout.getLineReadonly()
    // for older versions of pango
    const line = try layout.getLineReadonly(0);

    cr.moveTo(x, y);
    cr.layoutLinePath(line);
}

fn drawTwisted(cr: *cairo.Context, x: f64, y: f64, font: [:0]const u8, text: [:0]const u8) !void {
    cr.save();
    defer cr.restore();

    // Decrease tolerance a bit, since it's going to be magnified
    cr.setTolerance(0.01);

    // Using cairo.Context.copyPath() here shows our deficiency in handling
    // Bezier curves, specially around sharper curves.
    //
    // Using cairo.Context.copyPathFlat() on the other hand, magnifies the
    // flattening error with large off-path values. We decreased tolerance for
    // that reason. Increase tolerance to see that artifact.
    const path = try cr.copyPathFlat();
    // const path = try cr.copyPath();
    defer path.destroy();

    cr.newPath();
    try drawText(cr, x, y, font, text);
    try mapPathOnto(cr, path);

    cr.fillPreserve();

    cr.save();
    cr.setSourceRgb(0.1, 0.1, 0.1);
    cr.stroke();
    cr.restore();
}

pub fn drawDream(cr: *cairo.Context) !void {
    cr.moveTo(50, 650);

    cr.relLineTo(250, 50);
    cr.relCurveTo(250, 50, 600, -50, 600, -250);
    cr.relCurveTo(0, -400, -300, -100, -800, -300);

    cr.setLineWidth(1.5);
    cr.setSourceRgba(0.3, 0.3, 1.0, 0.3);

    try fancyStrokePreserve(cr);

    try drawTwisted(cr, 0, 0, "Serif 72", "It was a dream... Oh Just a dream...");
}

fn drawWow(cr: *cairo.Context) !void {
    cr.moveTo(400, 780);

    cr.relCurveTo(50, -50, 150, -50, 200, 0);

    cr.scale(1.0, 2.0);
    cr.setLineWidth(2.0);
    cr.setSourceRgba(0.3, 1.0, 0.3, 1.0);

    try fancyStrokePreserve(cr);

    try drawTwisted(cr, -20, -150, "Serif 60", "WOW!");
}

pub fn main() !void {
    const surface = try cairo.ImageSurface.create(.argb32, 1000, 800);
    defer surface.destroy();

    const cr = try cairo.Context.create(surface.asSurface());
    defer cr.destroy();

    cr.setSourceRgb(1, 1, 1);
    cr.paint();

    try drawDream(cr);
    try drawWow(cr);

    try surface.writeToPng("examples/generated/pango_twisted.png");
}
