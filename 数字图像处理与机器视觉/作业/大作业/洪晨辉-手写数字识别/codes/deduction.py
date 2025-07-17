import torch
from torchvision import transforms
from PIL import Image, ImageOps
from mnist_fcnn import FCNN
from mnist_cnn import Net
import matplotlib.pyplot as plt
import os

def process_image(image_path):
    img = Image.open(image_path).convert("L")

    # optional: Invert if your image is black background
    img = ImageOps.invert(img)

    # Crop + resize + center
    bbox = img.getbbox()
    img = img.crop(bbox)
    img = img.resize((20, 20), Image.ANTIALIAS)
    new_img = Image.new('L', (28, 28), (0))
    new_img.paste(img, (4, 4))

    # ToTensor + Normalize
    img_tensor = transform(new_img).unsqueeze(0)

    return img, img_tensor

# 加载模型
# model = Net()
# model.load_state_dict(torch.load("mnist_cnn.pt", map_location=torch.device("cpu")))
# model.eval()

model = FCNN()
model.load_state_dict(torch.load("mnist_fcnn.pt", map_location=torch.device("cpu")))
model.eval()

transform = transforms.Compose([
    transforms.Resize((28, 28)),
    transforms.ToTensor(),
    transforms.Normalize((0.1307,), (0.3081,))
])

img = Image.open("hand_written/A.png").convert("L")
img = ImageOps.invert(img)

threshold = 100

img = transform(img).unsqueeze(0)  

plt.imshow(img.squeeze().numpy(), cmap='gray')
plt.title("Model Input")
plt.show()

with torch.no_grad():
    output = model(img)
    pred = output.argmax(dim=1, keepdim=True)

print(f"预测结果是: {pred.item()}")

threshold = 100

img_paths = []
for row in range(10):
    for col in range(10):
        img_paths.append(f"hand_written/{row}.{col}.png")

batch_size = 10
num_batches = len(img_paths) // batch_size

for batch_idx in range(num_batches):
    fig, axes = plt.subplots(1, batch_size, figsize=(20, 4))
    fig.suptitle(f"Batch {batch_idx + 1} / {num_batches}", fontsize=20)
    
    for i in range(batch_size):
        img_idx = batch_idx * batch_size + i
        img_path = img_paths[img_idx]
        
        # img = Image.open(img_path).convert("L")
        # img = ImageOps.invert(img)
        # img_tensor = transform(img).unsqueeze(0)
        
        img, img_tensor = process_image(img_path)
        
        with torch.no_grad():
            output = model(img_tensor)
            pred = output.argmax(dim=1, keepdim=True)
        
        ax = axes[i]
        ax.imshow(img, cmap='gray')
        ax.set_title(f"{os.path.basename(img_path)}\nPred: {pred.item()}", fontsize=12)
        ax.axis('off')
    
    plt.tight_layout()
    plt.show()
    
    input("Press Enter to continue to next batch...")