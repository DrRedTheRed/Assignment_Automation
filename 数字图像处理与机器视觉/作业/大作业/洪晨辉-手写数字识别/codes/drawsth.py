import numpy as np
from PIL import Image, ImageDraw, ImageFont

img = Image.new('L', (28, 28), color=255)

draw = ImageDraw.Draw(img)

try:
    font = ImageFont.truetype("Arial.ttf", 20)
except:
    font = ImageFont.load_default()

draw.text((7, 4), "7", fill=0, font=font)

img.save("my_digit.png")
img.show()
