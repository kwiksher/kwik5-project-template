#!/usr/bin/env python3
"""
This script uses psd-tools and PIL to create a layered PSD file from a YAML configuration.

Usage:
1. Install required packages: pip install psd-tools pillow pyyaml
2. Create a YAML file with layer definitions (see scene_layers.yaml)
3. Run the script: python3 create_layered_psd.py <yaml_file> [scene.psd]

The script will create a PSD file with layers defined in the YAML file.

YAML format:
- name: layer_name
  x: 0
  y: 0
  width: 100
  height: 100
  color: "#ff0000"  # or color name like "gold"
  text: "Optional text"  # optional
  font_size: 20  # optional, default 12
  text_color: "#000000"  # optional, default black
"""

import sys
import yaml
import os
from psd_tools import PSDImage
from psd_tools.api.layers import PixelLayer
from PIL import Image, ImageDraw, ImageFont

def create_psd_from_yaml(yaml_file, output_file="scene.psd"):
    # Load YAML configuration
    with open(yaml_file, 'r') as f:
        layers_config = yaml.safe_load(f)

    if not layers_config:
        print("Error: Empty or invalid YAML file")
        return

    # Use fixed canvas size of 1920x1080
    canvas_width = 1920
    canvas_height = 1080

    # Create a new PSD document
    psd = PSDImage.new("RGB", (canvas_width, canvas_height))
    print(f"Created PSD canvas: {canvas_width}x{canvas_height}")

    # Create scene directory for PNG layers
    output_dir = os.path.splitext(output_file)[0]
    os.makedirs(output_dir, exist_ok=True)

    # Create layers from YAML configuration
    for layer_config in layers_config:
        name = layer_config.get('name', 'Layer')
        x = layer_config.get('x', 0)
        y = layer_config.get('y', 0)
        width = layer_config.get('width', 100)
        height = layer_config.get('height', 100)
        color = layer_config.get('color', '#ffffff')
        text = layer_config.get('text')
        font_size = layer_config.get('font_size', 12)
        text_color = layer_config.get('text_color', '#000000')

        print(f"\nProcessing layer '{name}':")
        print(f"  Position: ({x}, {y})")
        print(f"  Size: {width}x{height}")
        print(f"  Bounds: right={x+width}, bottom={y+height}")

        # Create layer with the specified size only
        layer_img = Image.new("RGBA", (width, height), color=color if not text else (0, 0, 0, 0))

        if text:
            draw = ImageDraw.Draw(layer_img)

            # Draw background rectangle if color is specified
            if color:
                draw.rectangle([0, 0, width, height], fill=color)

            # Draw text
            try:
                font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
            except:
                font = ImageFont.load_default()

            # Position text in the center of the layer
            text_x = width // 2
            text_y = height // 2
            draw.text((text_x, text_y), text, fill=text_color, font=font, anchor="mm")

        # Save layer as PNG
        png_filename = os.path.join(output_dir, f"{name}.png")
        layer_img.save(png_filename)
        print(f"  Saved layer: {png_filename}")

        # Warn if layer lies outside 1920x1080
        out_of_bounds = []
        if x < 0:
            out_of_bounds.append(f"x < 0 (x={x})")
        if y < 0:
            out_of_bounds.append(f"y < 0 (y={y})")
        if x + width > canvas_width:
            out_of_bounds.append(f"right edge > {canvas_width} (x+width={x+width})")
        if y + height > canvas_height:
            out_of_bounds.append(f"bottom edge > {canvas_height} (y+height={y+height})")
        if out_of_bounds:
            print(f"  Warning: layer '{name}' placed outside 1920x1080: " + "; ".join(out_of_bounds))

        # Add layer to PSD at the specified position
        # Note: frompil expects (image, psd, name, left, top) but seems to swap them
        # So we pass y as the 4th arg (left) and x as the 5th arg (top)
        pixel_layer = PixelLayer.frompil(layer_img, psd, name, y, x)
        psd.append(pixel_layer)
        print(f"  Layer added to PSD - offset: ({pixel_layer.left}, {pixel_layer.top}), size: ({pixel_layer.width}, {pixel_layer.height})")

    # Save the PSD file
    psd.save(output_file)
    print(f"Created {output_file} with {len(layers_config)} layers")
    print(f"Layer PNGs saved in: {output_dir}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 create_layered_psd.py <yaml_file> [scene.psd]")
        print("Using default: scene_layers.yaml")
        yaml_file = "scene_layers.yaml"
        output_file = "scene.psd"
    else:
        yaml_file = sys.argv[1]
        output_file = sys.argv[2] if len(sys.argv) > 2 else "scene.psd"

    create_psd_from_yaml(yaml_file, output_file)
