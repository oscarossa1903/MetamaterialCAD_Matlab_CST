# MetamaterialCAD MATLAB-CST

Parametric metamaterial CAD framework using MATLAB and CST.

## Features

- Gielis supershapes
- Square SRR
- SRR / CSRR
- NxM arrays
- CST COM automation

## Architecture

```text
GUI
 ├── Shared Params
 ├── Geometry Params
 ├── Preview
 └── Export

Geometry Engine
 ├── Gielis
 └── SSRR

CST Engine
 ├── Curves
 ├── Sheets
 ├── Boolean operations
 └── Materials
