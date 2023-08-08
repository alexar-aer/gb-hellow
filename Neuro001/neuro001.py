import numpy as np
import matplotlib.pyplot as plot

import utils

images, labels = utils.load_dataset()

weights_input_to_hidden = np.random.uniform(-0.5, 0.5, (20,784)) # first layer
weights_hidden_to_output = np.random.uniform(-0.5, 0.5, (10,20)) # second layer
bias_input_to_hidden = np.zeroes((20,1)) # Biases for first layer
bias_hidden_to_input = np.zeroes((10,1)) # Biases for second layer
