#!/bin/zsh
set -euo pipefail

# Run from the repository root after editing the original USD or SVG sources.
asset_directory="Sources/StudySwiftUI/MechanicalRocker/Resources"

# USDZ is an uncompressed ZIP archive whose first entry is the root USD
# layer. `zip -0 -j` keeps that entry at the archive root and stores it without
# compression, which is required by USDZ readers such as RealityKit.
rm -f "$asset_directory/MechanicalRocker.usdz"
zip -0 -j "$asset_directory/MechanicalRocker.usdz" "$asset_directory/MechanicalRocker.usda" >/dev/null
usdchecker "$asset_directory/MechanicalRocker.usdz"
sips -s format png "$asset_directory/MechanicalRocker-off.svg" --out "$asset_directory/MechanicalRocker-off.png"
sips -s format png "$asset_directory/MechanicalRocker-on.svg" --out "$asset_directory/MechanicalRocker-on.png"
