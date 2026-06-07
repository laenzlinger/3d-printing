// M3 washer / spacer - 2mm thick x4
$fn = 48;
od = 8;
id = 3.4;
h  = 2;

for (i = [0:3])
    translate([i * 12, 0, 0])
        difference() {
            cylinder(d=od, h=h);
            cylinder(d=id, h=h);
        }
