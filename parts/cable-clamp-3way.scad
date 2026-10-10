// Triple cable clamp - screw-down mount
// Holds 3 cables with zip ties, M4 screw mounting
// Adjustable cable diameter

$fn = 60;

// Parameters - adjust to your cable size
cable_d = 6;          // cable diameter (mm)
n_cables = 3;         // number of cable slots
tie_w = 4;            // zip tie slot width
tie_h = 2;            // zip tie slot height
screw_d = 4.5;        // M4 clearance hole
countersink_d = 9;    // M4 countersink diameter
countersink_h = 2.5;  // countersink depth

// Derived
wall = 3;
slot_spacing = cable_d + wall;
body_w = n_cables * slot_spacing + wall;
body_l = cable_d + 2 * wall + 2 * tie_h;
body_h = cable_d/2 + wall;
screw_offset = body_l/2;

module cable_clamp() {
    difference() {
        // Main body
        hull() {
            translate([0, 0, 0])
                cube([body_w, body_l, 0.1]);
            translate([wall/2, wall/2, body_h - wall/2])
                cube([body_w - wall, body_l - wall, 0.1]);
        }

        // Cable channels (semi-circular)
        for (i = [0:n_cables-1]) {
            x = wall + slot_spacing/2 + i * slot_spacing;
            translate([x, body_l/2, body_h])
                rotate([0, 0, 0])
                    cylinder(d=cable_d + 0.5, h=body_h + 1, center=true);
        }

        // Zip tie slots (through channels on each side of cables)
        for (i = [0:n_cables-1]) {
            x = wall + slot_spacing/2 + i * slot_spacing;
            // Front tie slot
            translate([x - tie_w/2, -0.1, wall])
                cube([tie_w, tie_h + 0.1, body_h]);
            // Rear tie slot
            translate([x - tie_w/2, body_l - tie_h, wall])
                cube([tie_w, tie_h + 0.1, body_h]);
        }

        // Screw hole (center)
        translate([body_w/2, body_l/2, -0.1])
            cylinder(d=screw_d, h=body_h + 1);
        // Countersink
        translate([body_w/2, body_l/2, -0.1])
            cylinder(d1=countersink_d, d2=screw_d, h=countersink_h);
    }
}

cable_clamp();
