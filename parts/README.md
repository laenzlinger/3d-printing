# Custom 3D Parts

OpenSCAD source files for custom 3D printed parts.

## Workflow

1. Edit `.scad` files in this directory
2. Render to STL using OpenSCAD
3. Output files go to `../generated/`
4. Generated STL files are gitignored (build artifacts)

## Dependencies

- [BOSL2](https://github.com/BelfrySCAD/BOSL2) - Included as submodule for advanced OpenSCAD features

## Usage

```bash
# Render a part
openscad -o ../generated/part-name.stl part-name.scad

# Or use OpenSCAD GUI for interactive development
```
