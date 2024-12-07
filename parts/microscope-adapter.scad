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
        union()
        {
            up(6.49) cyl(h = 13, d = 12, rounding2 = 6);
            down(6.49) cyl(h = 13, d = 12, texture = "trunc_diamonds", tex_depth = 0.3);
        }
        down(12) screw_hole(spec = "1/4", l = 10, thread = true);
        up(10) fwd(13) cube(20, 20, 20);
        up(10) back(13) cube(20, 20, 20);
        up(7) cyl(h = 8, d = 4, orient = BACK);
    }
}
