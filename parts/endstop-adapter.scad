include <BOSL2/screws.scad>
include <BOSL2/std.scad>
include <BOSL2/threading.scad>

$fn = 100;

ff = 0.01;

adapter();

module adapter()
{
    difference()
    {
        cube([ 50, 80, 16 ], center = true);
        translate([ -6, -20, 10 ]) holes() cylinder(d = 5, h = 16, center = true);
        translate([ 6, 20, 8 ]) holes() screw_hole("M3,20", head = "flat", counterbore = 0, anchor = TOP);
        translate([ -14, 34, 0 ]) cube([ 40, 40, 20 ], center = true);
    }
}

module holes()
{
    for (x = [ -1, 1 ], y = [ -1, 1 ])
    {
        translate([ x * 7.5, y * 14, 0 ]) children();
    }
}
