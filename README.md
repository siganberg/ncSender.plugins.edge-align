# Edge Align Plugin

> **IMPORTANT DISCLAIMER:** This plugin is part of my personal ncSender project. If you choose to use it, you do so entirely at your own risk. I am not responsible for any damage, malfunction, or personal injury that may result from the use or misuse of this plugin. Use it with caution and at your own discretion.

Material alignment by edge probing — find the angle of rotation and apply XY offset compensation to your G-code. This plugin probes two points along a material edge to determine how much the workpiece is rotated, then compensates by rotating your G-code program.

## Features

- **Edge Probing** - Probe two points along any edge (Left, Right, Front, Back) to measure material rotation
- **Angle Calculation** - Automatically calculates the rotation angle from the two probed points
- **G-code Rotation** - Applies rotation matrix to all XY coordinates (including arc I/J offsets) to compensate
- **Jog Controls** - Built-in jog dial for positioning the probe without leaving the plugin
- **Live Coordinates** - Real-time machine coordinate display
- **Persistent Settings** - Probe settings are saved between sessions

## Use Cases

- Aligning CNC programs to a workpiece that's slightly rotated on the table
- Compensating for fixture misalignment
- Precision work where material edge alignment is critical

## Configuration

Access settings via **Plugins > Edge Align** in the toolbar menu.

### Edge Selection

| Setting | Description |
|---------|-------------|
| **Probe Edge Side** | Which edge of the material to probe: Left (-X), Right (+X), Front (-Y), Back (+Y) |
| **Measurement Distance** | Distance between the two probe points along the edge |

### Probe Settings

| Setting | Description | Default |
|---------|-------------|---------|
| **Probe Feed Rate** | Speed for probing toward the edge | 100 mm/min |
| **Travel Feed Rate** | Speed for moving between probe points | 2000 mm/min |
| **Clearance Height** | Distance to retract after each probe | 5 mm |
| **Max Probe Distance** | Maximum distance the probe will travel toward the edge | 20 mm |

## How It Works

### 1. Position the Probe
Use the built-in jog controls to position the probe near the material edge you want to measure.

### 2. Select Edge and Distance
Choose which edge to probe and how far apart the two measurement points should be. A larger distance gives a more accurate angle measurement.

### 3. Run Probing
The plugin will:
1. Probe toward the edge at the current position (Point 1)
2. Retract and travel along the edge by the measurement distance
3. Probe toward the edge again (Point 2)
4. Calculate the angle from the two points

### 4. Apply Compensation
Review the calculated angle on the Results tab, then click **Apply Rotation** to create a new G-code file with rotated XY coordinates.

## Probing Direction

| Edge | Probe Direction | Travel Direction |
|------|----------------|-----------------|
| Left | -X | +Y |
| Right | +X | +Y |
| Front | -Y | +X |
| Back | +Y | +X |

## Angle Calculation

For a Left/Right edge probe:
- `angle = atan2(X2 - X1, measurement_distance)`

For a Front/Back edge probe:
- `angle = atan2(Y2 - Y1, measurement_distance)`

Where X1/Y1 and X2/Y2 are the probed edge positions at the two points.

## G-code Rotation

The rotation is applied using a standard 2D rotation matrix around the work origin (0,0):

```
newX = X * cos(-angle) - Y * sin(-angle)
newY = X * sin(-angle) + Y * cos(-angle)
```

Arc center offsets (I, J) in G2/G3 commands are also rotated.

## Requirements

- ncSender v2.0.0 or later
- Touch probe or edge finder
- Probe input configured in GRBL/grblHAL

## Installation

Install this plugin in ncSender through the **Plugins** interface.

## Development

This plugin is part of the ncSender ecosystem: https://github.com/siganberg/ncSender

## License

See main ncSender repository for license information.
