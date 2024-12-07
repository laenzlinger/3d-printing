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
        down(10) screw(spec = "1/4", l = 10);
        up(10) fwd(11.5) cube(20, 20, 20);
        up(10) back(11.5) cube(20, 20, 20);
        up(7) cyl(h = 6, d = 4, orient = BACK);
    }
}
