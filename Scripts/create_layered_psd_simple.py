#!/usr/bin/env python3
"""
This script uses psd-tools and PIL to create a layered PSD file from a YAML configuration.

Usage:
1. Install required packages: pip install pyyaml psd-tools pillow
2. Create a YAML file with layer definitions (see scene_layers.yaml)
3. Run the script: python3 create_layered_psd.py <yaml_file> [scene.psd]
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
        config = yaml.safe_load(f)

    if not config or 'layers' not in config:
        print("Error: Invalid YAML structure. Expected a 'layers' key.")
        return

    layers_config = config['layers']

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

        # Create layer with the specified size
        layer_img = Image.new("RGBA", (width, height), color=color if not text else (0, 0, 0, 0))

        if text:
            draw = ImageDraw.Draw(layer_img)
            if color and color != (0, 0, 0, 0):
                draw.rectangle([0, 0, width, height], fill=color if isinstance(color, tuple) else (255, 255, 255))
            try:
                font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
            except:
                font = ImageFont.load_default()

            draw.text((10, 10), text, fill=text_color, font=font)

        # Save layer as PNG
        png_filename = osed_path = os.path.join(output_dir, f"{name}.png")
        layer_img.save(png_filename)
        print(f"  Saved layer: {png_filename}")

        # Add layer to PSD
        from psd_tools.api.layers import PixelLayer
        pixel_layer = PixelLayer.frompil(layer_img, psd, name, y, x)
        psd.append(pixel_layer)
        print(f"  Layer added to PSD - offset: ({pixel_layer.left}, {pixel_layer.top}), size: ({pixel_layer.width}, {pixel_layer.height})")

    # Save the PSD file
    psd.save(output_file)
    print(f"Created {output_file} with {len(layers_config)} layers")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 create_layered_psd_simple.py <yaml_file> [scene.psd]")
    else:
        create_psd_from_yaml(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else "scene.psd")
