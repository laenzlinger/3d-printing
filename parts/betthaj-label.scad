include <BOSL2/std.scad>

$fn = 100;
ff = 0.02;

label_text = "Risottoreis";
outer_radius = 37.5;
inner_radius = 14;
font_size = 12;
text_radius = 20;
thickness = 2;

label();

module label() {
  difference() {
    cylinder(h=thickness, r=outer_radius, center=true);
    cylinder(h=thickness + ff, r=inner_radius, center=true);
    text_on_cyl(label_text, radius=text_radius, height=thickness + ff, font_size=font_size);
  }
}
module text_on_cyl(txt, radius, height, font_size) {
  chars = len(txt);
  angle_step = 20;
  for (i = [0:chars - 1]) {
    char = str(txt[i]);
    rotate([0, 0, -i * angle_step])
      translate([radius, 0, -height / 2])
        linear_extrude(height=height)
          rotate([0, 0, -90]) text(char, size=font_size, font="Allerta Stencil", valign="", halign="center");
  }
}
