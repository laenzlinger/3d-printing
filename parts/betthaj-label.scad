include <BOSL2/std.scad>

$fn = 100;
ff = 0.02;

font = "Allerta Stencil";
label_text = "Basmatireis";
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

// --- 1. The Recursive Function ---
function calculate_text_angles(chars, index = 0, current_angle = 0) =
  index >= len(chars) ? []
  : let (
    // Measure current character
    tm = textmetrics(chars[index], size=font_size, font=font),
    w = tm.size.x,

    // Convert linear width to angular width
    // Formula: (width / circumference) * 360 degrees
    char_angle = -(w / (2 * PI * text_radius)) * 360,

    // The point where this character is placed
    // We add half the angle to center the glyph on its arc segment
    placed_angle = current_angle + (char_angle / 2),

    // The starting point for the NEXT character
    next_start_angle = current_angle + char_angle - 2.5
  ) concat([placed_angle], calculate_text_angles(chars, index + 1, next_start_angle));

module text_on_cyl(txt, radius, height, font_size) {
  angles = calculate_text_angles(txt);
  chars = len(txt);
  for (i = [0:chars - 1]) {
    char = str(txt[i]);
    rotate([0, 0, angles[i]])
      translate([radius, 0, -height / 2])
        linear_extrude(height=height)
          rotate([0, 0, -90]) text(char, size=font_size, font=font, valign="", halign="center");
  }
}
