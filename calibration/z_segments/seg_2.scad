$fn = 64;
translate([100, 110, 0])
difference() {
    rotate([0, 0, 91])
        rotate_extrude(angle = 43)
            translate([20, 0]) square([30, 2]);
    
    translate([cos(112.5) * 35, sin(112.5) * 35, -0.1])
        rotate([0, 0, 112.5 - 90])
            linear_extrude(2.2)
                text("-50", size = 5, halign = "center", valign = "center");
}
