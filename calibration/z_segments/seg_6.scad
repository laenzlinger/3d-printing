$fn = 64;
translate([100, 110, 0])
difference() {
    rotate([0, 0, 271])
        rotate_extrude(angle = 43)
            translate([20, 0]) square([30, 2]);
    
    translate([cos(292.5) * 35, sin(292.5) * 35, -0.1])
        rotate([0, 0, 292.5 - 90])
            linear_extrude(2.2)
                text("+75", size = 5, halign = "center", valign = "center");
}
