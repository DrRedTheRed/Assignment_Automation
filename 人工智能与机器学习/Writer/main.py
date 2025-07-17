import torch
import torch.nn as nn
import jieba as jb

# Define the path to the pre-trained model and load its configuration, mapping to CPU.
model_path = 'results/test_model.pth'  
config = torch.load(model_path, map_location=torch.device('cpu'))  

# Retrieve the word-to-index mapping dictionary and index-to-author mapping list from the configuration, and calculate the number of words.
word2int = config['word2int']  
int2author = config['int2author']  
word_num = len(word2int)  

# Construct a sequential neural network model with linear layers and ReLU activation functions.
model = nn.Sequential(  
    nn.Linear(word_num, 512),  
    nn.ReLU(),  
    nn.Linear(512, 1024),  
    nn.ReLU(),  
    nn.Linear(1024, 6),  
)  
# Load the pre-trained model's parameters into the constructed model.
model.load_state_dict(config['model'])  
# Append the first author to the index-to-author mapping list to handle potential out-of-bounds errors.
int2author.append(int2author[0])  

def predict(text):  
    """
    Predict the author of the input text.
    :param text: Input text string.
    :return: Predicted author name.
    """  
    # Initialize a zero vector of length equal to the number of words to count word frequencies in the text.
    feature = torch.zeros(word_num)  
    for word in jb.lcut(text):  
        if word in word2int:  
            # Increment the count at the corresponding position if the word is in the vocabulary.
            feature[word2int[word]] += 1  
    # Normalize the feature vector to represent word frequency distribution.
    feature /= feature.sum()  
    # Set the model to evaluation mode, disabling training-related operations like gradient calculation.
    model.eval()  
    # Add a batch dimension to the feature vector and pass it through the model to obtain the prediction output.
    out = model(feature.unsqueeze(0))  
    # Get the index of the maximum value in the output, representing the predicted author.
    pred = out.argmax().item()  
    return int2author[pred]  