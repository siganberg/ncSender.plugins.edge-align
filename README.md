# Edge Align Plugin

> **IMPORTANT DISCLAIMER:** This plugin is part of my personal ncSender project. If you choose to use it, you do so entirely at your own risk. I am not responsible for any damage, malfunction, or personal injury that may result from the use or misuse of this plugin. Use it with caution and at your own discretion.

Material alignment by edge probing — measure the rotation angle of your workpiece and apply XY compensation to your G-code. This plugin probes two points along a material edge to determine how much the workpiece is rotated, then compensates by rotating your G-code program.

## Features

- **Interactive Edge Selection** — Click directly on the visual edge diagram to select which side to probe (Left, Right, Front, Back)
- **Two-Point Edge Probing** — Probes two points along the selected edge to calculate the material's angle of rotation
- **Safe Travel** — Uses G38.3 (probe-away) for travel between probe points to prevent collision damage
- **G-code Rotation** — Applies rotation matrix to all XY coordinates (including arc I/J offsets) around the work origin
- **Original File Preservation** — Always rotates from the original source file, never stacking transformations. Supports "Reset to Original" in the visualizer
- **Persistent Probe Results** — Last measured angle is saved between sessions for re-applying rotation without re-probing
- **Built-in Jog Controls** — Position the probe without leaving the plugin dialog
- **Live Coordinates** — Real-time machine coordinate display
- **Alarm Recovery** — Unlock button appears automatically when machine enters alarm state (soft reset + $X)
- **Safety Controls** — All inputs disabled during probing; Stop button issues soft reset to halt immediately
- **Unit Support** — Works in both metric (mm) and imperial (in) units

## How It Works

### 1. Position the Probe
Use the built-in jog controls to position the probe near the material edge you want to measure.

### 2. Select Edge and Configure
Click on the edge in the visual diagram (Left, Right, Front, Back). Configure the measurement distance — a larger distance gives a more accurate angle measurement.

### 3. Probe
Click **Probe**. Settings are automatically saved. The plugin will:
1. Probe toward the edge at the current position (Point 1)
2. Retract by the configured clearance distance
3. Travel along the edge using G38.3 (safe probe-away move)
4. Probe toward the edge again (Point 2)
5. Calculate the rotation angle from the two points

### 4. Apply Rotation
Review the calculated angle in the Probe Results card, then click **Apply Rotation** to create a rotated G-code file. The original file is preserved — use "Reset to Original" in the visualizer to revert.

## Configuration

| Setting | Description | Default |
|---------|-------------|---------|
| **Measurement Distance** | Distance between the two probe points along the edge | 50 mm |
| **Max Probe Distance** | Maximum distance the probe will travel toward the edge | 20 mm |
| **Probe Feed Rate** | Speed for probing toward the edge | 100 mm/min |
| **Travel Feed Rate** | Speed for moving between probe points | 2000 mm/min |
| **Retract Clearance** | Distance to retract after each probe before traveling | 5 mm |

## Angle Calculation

The angle is calculated using `atan2(deviation * direction, distance)` where the deviation factor accounts for probe direction, ensuring consistent angle results regardless of which edge is probed. All four sides of a rectangular workpiece will report the same angle.

## G-code Rotation

The rotation is applied using a standard 2D rotation matrix around the work origin (0,0):

```
newX = X * cos(angle) - Y * sin(angle)
newY = X * sin(angle) + Y * cos(angle)
```

- Arc center offsets (I, J) in G2/G3 commands are also rotated
- When a line only has X or Y, the missing axis is added to ensure proper rotation
- G53 (machine coordinate) moves and comments are skipped
- Incremental (G91) moves are not rotated

## Requirements

- ncSender Pro v2.0.0 or later
- Touch probe or edge finder
- Probe input configured in GRBL/grblHAL/FluidNC

## Installation

Install from the **Plugins** tab in ncSender settings, or download from [Releases](https://github.com/siganberg/ncSender.plugins.edge-align/releases).

## License

See main ncSender repository for license information.
