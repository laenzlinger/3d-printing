// DIN Rail Bracket for MKS DLC32 MAX v1.1
// PCB: 100x70mm, mounting holes: 92x62mm (M3)
// Print 2x - one for each short edge of the PCB
//
// Simple snap-fit DIN rail bracket with two M3 mounting holes.
// Clips onto standard 35mm DIN rail from above.

$fn = 60;

// PCB mounting
hole_spacing = 62;       // distance between the 2 holes (across rail)
hole_dia = 3.4;          // M3 clearance hole
standoff_h = 3;          // PCB standoff height above bracket

// DIN rail dimensions (standard 35mm top-hat rail)
rail_w = 35;             // rail width
rail_h = 7.5;            // rail height (depth of channel)
rail_lip = 1.0;          // lip thickness on rail edge
rail_lip_h = 1.5;        // height of the lip fold

// Bracket dimensions
wall = 2.5;              // wall thickness
base_h = 3;              // base plate thickness
clip_gap = 0.3;          // tolerance for rail fit
bracket_len = 18;        // length along the rail (X direction)

// Derived
total_w = hole_spacing + hole_dia + 2 * 4; // width to fit holes with margin
clip_inner = rail_w + 2 * clip_gap;
clip_outer = clip_inner + 2 * wall;

module din_rail_clip() {
    // Base plate that sits on top of the rail
    difference() {
        union() {
            // Main base plate
            translate([-bracket_len/2, -total_w/2, 0])
                cube([bracket_len, total_w, base_h]);

            // Rail clip walls (hang down from base to grip rail)
            // Left wall
            translate([-bracket_len/2, -clip_inner/2 - wall, -rail_h])
                cube([bracket_len, wall, rail_h + base_h]);
            // Right wall
            translate([-bracket_len/2, clip_inner/2, -rail_h])
                cube([bracket_len, wall, rail_h + base_h]);

            // Lip hooks at bottom (snap under rail edges)
            // Left lip
            translate([-bracket_len/2, -clip_inner/2 - wall, -rail_h])
                cube([bracket_len, wall + rail_lip + clip_gap, rail_lip_h]);
            // Right lip
            translate([-bracket_len/2, clip_inner/2 - rail_lip - clip_gap, -rail_h])
                cube([bracket_len, wall + rail_lip + clip_gap, rail_lip_h]);

            // PCB standoffs
            for (y = [-hole_spacing/2, hole_spacing/2]) {
                translate([0, y, base_h])
                    cylinder(d=hole_dia + 4, h=standoff_h);
            }
        }

        // M3 holes through standoffs and base
        for (y = [-hole_spacing/2, hole_spacing/2]) {
            translate([0, y, -1])
                cylinder(d=hole_dia, h=base_h + standoff_h + 2);
        }

        // Flex slot in one clip wall for snap-on (makes one side flexible)
        translate([-bracket_len/4, clip_inner/2 - 0.1, -rail_h - 0.1])
            cube([bracket_len/2, wall + 0.2, rail_h - rail_lip_h]);
    }
}

din_rail_clip();
