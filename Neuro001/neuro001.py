# neuro001.py
'''
Simple NeuroNet for recognizing digits 0..9 with three layers:
    1st INPUT aka SOURCE images 28*28 pixels white-on-black
    2nd HIDDEN with 20 neurons aka knots
    3rd OUTPUT with 10 knots aka RESULT numbers 0..9

    After training NeuroNet, check with with a CUSTOM image.

    MIT(C): https://www.youtube.com/@HowdyhoNet
    https://youtu.be/tihq_bLfk08
'''
epochs                  = 3                     # Number of training stages
test_custom_image_name  = "custom9.jpg"         # File name for TESTING our NeuroNet

import numpy as np
import matplotlib.pyplot as plot

import utils

images, labels = utils.load_dataset()           # load NPZ datasets Img=SRC, Lbl=RESULT

weights_input_to_hidden = np.random.uniform(-0.5, 0.5, (20, 784))       # 1st layer 784=28*28 knots
weights_hidden_to_output= np.random.uniform(-0.5, 0.5, (10, 20))        # 2nd layer 20 knots
bias_input_to_hidden    = np.zeroes((20,1))     # Biases for first layer, filled with zeros
bias_hidden_to_output   = np.zeroes((10,1))     # Biases for second OUTPUT; 3rd layer 10 knots

e_loss      = 0                                 # Error coefficient
e_correct   = 0                                 # Correct coefficient
learning_rate = 0.01                            # Learning speed coefficient

for epoch in range(epochs):
    print(f'Epoch #{epoch}')

    for image, label in zip(images, labels):    # Unpack NPZ
        image = np.reshape(image, (-1,1))       # Normalize source values to -1..+1
        label = np.reshape(label, (-1,1))       # Normalize source labels to -1..+1

    # Forward propagation to 2nd (1st hidden) layer
    hidden_raw = bias_input_to_hidden + weights_input_to_hidden @ image # Mult with table IMAGE
    hidden  = 1 / (1 + np.exp(-hidden_raw))     # Sigmoid activation function

    # Forward propagation to 3rd (output) layer
    output_raw = bias_hidden_to_output + weights_hidden_to_output @ hidden # Mult with table HIDDEN
    output  = 1 / (1 + np.exp(-output_raw))     # Sigmoid activation function

    # Loss / Error calculations
    e_loss  += 1 / len(output) * np.sum((output - label) ** 2, axis=0)  # Error coeff.
    e_correct += int(np.argmax(output) == np.argmax(label))             # Correct coeff.

    # Backpropagation for 3rd (output) layer
    delta_output        = output - label        # Matrix difference
    weights_hidden_to_output += -learning_rate * delta_output @ np.transpose(hidden)
    bias_hidden_to_output += -learning_rate * delta_output

    # Backpropagation for 2nd (hidden) layer
    delta_hidden = np.transpose(weights_hidden_to_output) @ delta_output \
        * (hidden * (1 - hidden))
    weights_input_to_hidden += -learning_rate * delta_hidden @ np.transpose(image)
    bias_input_to_hidden += -learning_rate * delta_hidden

    #DONE! di)
    # Print statistics and debug between epochs
    print(f'Loss: {round((e_loss[0] / images.shape[0]) * 100, 3)}%')    # Show Errors coeff.
    print(f'Accuracy: {round((e_correct[0] / images.shape[0]) * 100, 3)}%')     # Show Correct

    e_loss              = 0                     # Reset Error coeff.
    e_correct           = 0                     # Reset Correct coeff.
#//for epoch

# CHECK CUSTOM SOURCE IMAGE
test_image = plot.imread(test_custom_image_name, format="jpeg")                   # Load test image

# Grayscale + Unit RGB + inverse colors (for image black on white)
gray = lambda rgb : np.dot(rgb[... , :3], [0.299, 0.587, 0.114])        # <RGB2GRAY> MAGIC NUMBERS ;)
test_image = 1 - (gray(test_image).astype("float32") / 255)             # Inverse image

# Reshape image [x, y] into [x*y] (flatten)
test_image = np.reshape(test_image, (test_image.shape[0] * test_image.shape[1]))

# Predict aka Normalize SOURCE
image = np.reshape(test_image, (-1, 1))

# Forward propagation SOURCE to HIDDEN
hidden_raw = bias_input_to_hidden + weights_input_to_hidden @ image
hidden = 1 / (1 + np.exp(-hidden_raw))          # Sigmoid activation function

# Forward propagation HIDDEN to OUTPUT
output_raw = bias_hidden_to_output + weights_hidden_to_output @ hidden_raw
output = 1 / (1 + np.exp(-output_raw))          # Sigmoid activation function

plot.imshow(test_image.reshape(28, 28), cmap="Greys")                   # Create PLOTTER
plot.title(f'NeuroNet suggests the CUSTOM image is: {output.argmax()}.')
plot.show()

print('Done.')
