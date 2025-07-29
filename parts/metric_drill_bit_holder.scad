//=================================================================
// Ultimate Metric Drill bit holder
//
//
// Glen Foley CC 2022
// Remixed by laenzi
//=================================================================

//-----------------------------------------------------------------
// Customizable Values
//-----------------------------------------------------------------
$fn = 41; // Number of faces per hole

$base_height = 15;    // Also the height of each row step (mm)
$fit_tolerance = 0.6; // Extra space given per drill bit (mm)

$bit_min_size = 1;        // Smallest drill bit in (mm)
$bit_max_size = 13;       // Largest drill bit in (mm)
$bit_increment = 0.5;     // Difference between each bit (mm)
$bit_depth = 14;          // Depth the drill bit goes into holder
$bit_max_shaft_size = 10; // Larger drill bits might have smaller shaft

$bit_chamfer_depth = 2.0; // depth of the cone which forms the chamfer around the bit
$bit_chamfer_size = 1.2;  // the size of the bit chamfer

$gap_between_bits = 8; // Gap between bits (mm)

$rows = 1;        // Number of rows of bits
$row_padding = 7; // Padding between holes between rows
$row_height = 15; // Height the the steps (0 if not desired)

$chamfer_size = 15; // Length of chamfer on front for numbers

//-----------------------------------------------------------------
// Calculated Values
//-----------------------------------------------------------------

// Calcuale total number of bits
$total_bits = (($bit_max_size - $bit_min_size) / $bit_increment) + 1;
echo(str("Total bits: ", $total_bits));

// Calulate chamfer sides
$chamfer_side = $chamfer_size * sin(45);
echo(str("Chamfer sides: ", $chamfer_side));

// Calulate row depth
$row_depth = $row_padding + $bit_max_size;
echo(str("Row depth: ", $row_depth));

// Calculate the width of the base
$base_width = (getX($bit_max_size / $bit_increment) - getX($bit_min_size / $bit_increment)) + ($gap_between_bits * 2) +
              $bit_min_size + ($bit_max_size / 2); // + getBitSize($total_bits);
echo(str("Base width: ", $base_width));

// Calculate the depth of the base
$base_depth = ($row_depth * $rows) + $chamfer_side;
echo(str("Base depth: ", $base_depth));

//-----------------------------------------------------------------
// Helper Functions
//-----------------------------------------------------------------

function getX(bitNumber = 0) = (bitNumber * (($bit_min_size + getBitSize(bitNumber)) / 2)) +
                               ($gap_between_bits * (bitNumber));

function getBitSize(bitNumber = 0) = (bitNumber * $bit_increment);

//-----------------------------------------------------------------
// Drawing Process
//-----------------------------------------------------------------

union()
{
    difference()
    {
        difference()
        {
            // Draw the base model which every thing else is subtracted from
            union()
            {
                cube([ $base_width, $base_depth, $base_height ]);
                for (a = [1:1:$rows - 1])
                {
                    translate([ 0, (a * $row_depth) + $chamfer_side, $base_height ])
                        cube([ $base_width, $row_depth, a * $row_height ]);
                }
            }

            // for the chamfer at front
            translate([ -1, 0, $base_height - $chamfer_side ]) rotate([ 45, 0, 0 ])
                cube([ $base_width + 2, $chamfer_size, $chamfer_size ]);
        }
        // Loop through bit holes
        for (a = [$bit_min_size:$bit_increment:$bit_max_size], b = [0:1:$rows - 1])
        {

            $bit_size = getBitSize(a);
            $bit_radius = ((min(a, $bit_max_shaft_size) + $fit_tolerance) / 2);

            $x = getX(a / $bit_increment) - getX($bit_min_size / $bit_increment) + ($gap_between_bits) + $bit_min_size;
            $y = $chamfer_side + (b * $row_depth) + ($row_depth / 2);
            $z = $base_height + (b * $row_height);

            echo(str("Drawing bit (mm): ", a));
            echo(str("Drawing bit radius (mm): ", $bit_radius));

            // For bit holes

            rotate([ 10, 0, 0 ]) translate([ $x, $y + 2, $z - ($bit_depth / 2) ])
                cylinder(r = $bit_radius, h = $bit_depth, center = true);

            // For hole chamfer
            translate([ $x, $y, $z - ($bit_chamfer_depth / 2) + 0.1 ])
                cylinder(r1 = $bit_radius, r2 = $bit_radius + $bit_chamfer_size, h = $bit_chamfer_depth, center = true);
        }
    }

    // Write out the labels
    for (a = [$bit_min_size:$bit_increment:$bit_max_size])
    {

        translate([
            getX(a / $bit_increment) - getX($bit_min_size / $bit_increment) + ($gap_between_bits) + $bit_min_size,
            $chamfer_side * 0.60, $base_height - ($chamfer_side * 0.39)
        ]) rotate([ 45, 0, 0 ]) color([ 0, 0, 1 ]) linear_extrude(+2)

            if (a % 1 == 0)
        {
            text(str(a), font = "Arial Style:Bold", size = $chamfer_size * 0.54, halign = "center", valign = "top");
        }
        else
        {
            text(str(a), font = "Arial Style:Bold", size = $chamfer_size * 0.22, halign = "center", valign = "bottom");
        }
    }
}
