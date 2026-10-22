#!/bin/zsh
set -euo pipefail

# Run from the repository root after editing the original USD or SVG sources.
asset_directory="Sources/StudySwiftUI/MechanicalRocker/Resources"

usdzip --checkCompliance "$asset_directory/MechanicalRocker.usdz" "$asset_directory/MechanicalRocker.usda"
sips -s format png "$asset_directory/MechanicalRocker-off.svg" --out "$asset_directory/MechanicalRocker-off.png"
sips -s format png "$asset_directory/MechanicalRocker-on.svg" --out "$asset_directory/MechanicalRocker-on.png"
