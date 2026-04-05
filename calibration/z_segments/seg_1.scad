$fn = 64;
translate([100, 110, 0])
difference() {
    rotate([0, 0, 46])
        rotate_extrude(angle = 43)
            translate([20, 0]) square([30, 2]);
    
    translate([cos(67.5) * 35, sin(67.5) * 35, -0.1])
        rotate([0, 0, 67.5 - 90])
            linear_extrude(2.2)
                text("-75", size = 5, halign = "center", valign = "center");
}
