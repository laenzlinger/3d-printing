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
            up(13) threaded_rod(d2 = 20.7, d1 = 18.635, height = 24, pitch = 1.814);
            cylinder(d = 27, h = 2, center = true);
            down(15) cylinder(d = 22, h = 14, center = false);
        }
        cylinder(d = 10, h = 60, center = true);
        down(12) torus(od = 23.6, id = 19.1);
        down(4) torus(od = 23.6, id = 19.1);
    }
}
