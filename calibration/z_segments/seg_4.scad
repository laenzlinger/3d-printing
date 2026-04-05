$fn = 64;
r = 50;
gap = 2;
angle_start = 4 * 45 + gap/2;
angle_mid = 4 * 45 + 22.5;

// Segment base
rotate([0, 0, angle_start])
    rotate_extrude(angle = 45 - gap)
        translate([5, 0]) square([r - 5, 0.4]);

// Label raised
translate([cos(angle_mid) * 30, sin(angle_mid) * 30, 0.4])
    rotate([0, 0, angle_mid - 90])
        linear_extrude(0.2)
            text("0", size = 5, halign = "center", valign = "center");
