od = 32;
id = 6.5;
h = 10;
nob_d = 1.4;
nob_h = 1.0;
nob_circle_d = 24;
nobs = 24;

difference() {
    union() {
        // Main body
        cylinder(h=h, d=od, $fn=100);
        // Nobs on top (rounded)
        for (i = [0:nobs-1])
            rotate([0, 0, i * 360/nobs])
                translate([nob_circle_d/2, 0, h])
                    scale([1, 1, nob_h/(nob_d/2)])
                        sphere(d=nob_d, $fn=20);
    }
    // Center hole
    translate([0, 0, -1])
        cylinder(h=h+nob_h+2, d=id, $fn=60);
    // Holes on bottom (recesses for nobs to fit into)
    for (i = [0:nobs-1])
        rotate([0, 0, i * 360/nobs])
            translate([nob_circle_d/2, 0, -0.01])
                cylinder(h=3+0.01, d=3, $fn=20);
}
