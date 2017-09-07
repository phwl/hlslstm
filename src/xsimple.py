# Copyright 2015 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================

import numpy as np
from random import shuffle
import tensorflow as tf
from lstmgen import cgen
from tensorflow.python import debug as tf_debug

# this function generates an input set (there is no output in this example)
def generate_sequence_data(input_length, batch_size, sequence_length):
    train_input = []
    for i in range(batch_size):
        batch = []
        for j in range(sequence_length):
			# generate a input vector of small numbers
            inp = np.random.rand(input_length) / 3
			# add it to the input set
            batch.append(inp)
		# add the training set generated to the batch
        train_input.append(batch)
    return train_input


def run():
    # this function generates input and creates a very basic graph
    # the graph consists of an input placeholder and the LSTM cell
    #
    batch_size = 1
    sequence_length = 4
    num_hidden = 3
    input_length = 2
    train_input = generate_sequence_data(input_length, batch_size, sequence_length)

    # PHASE 1 - build the computation graph (just feedforward part of LSTM)
    # create a placeholder for the inputs
    input_placeholder = tf.placeholder(tf.float32, shape=(batch_size, sequence_length, input_length))
    # create the RNN cell
    cell = tf.contrib.rnn.BasicLSTMCell(num_hidden)
    # output is the outputs of the cell for each input
    # state is the final state of the cell
    output, state = tf.nn.dynamic_rnn(cell, input_placeholder, dtype=tf.float32)
    # PHASE 2 - run the graph using DNA sequences that we generated above
    init_op = tf.global_variables_initializer()

    with tf.Session() as sess:
        sess.run(init_op)
        inp = train_input[0:batch_size]

        outputs = sess.run(output, {input_placeholder: inp})
        print("output values: ")
        print(outputs)
        states = sess.run(state,{input_placeholder: inp})
        print("internal states: ")
        print(states)

    # print weights
        cg = cgen(input_length, num_hidden, 
		tf.get_collection(tf.GraphKeys.TRAINABLE_VARIABLES))
        state = [np.zeros(num_hidden), np.zeros(num_hidden)]
        for p in train_input[0]:
            output, state = cg.ff(p, state)
        cg.gen((np.array(train_input))[0], outputs[0])

if __name__ == "__main__":
    run()
