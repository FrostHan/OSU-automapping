import tensorflow as tf
import scipy.io as sio
import matplotlib.pyplot as plt
import os
import numpy as np
import shutil
from datetime import datetime
now = datetime.now()

shutil.rmtree('../Train/log/', ignore_errors=True)

sess = tf.Session()

learning_rate = 1e-4
channels_input = 128
channels_output = 128
gamma = 0.1 # relative strength of 4-D term

fc_input_dim = int(128*128*channels_output/2**4/2/2/2/2)
fc_hidden1_dim = 256
fc_hidden2_dim = 256

print(fc_input_dim)


def conv2d(x, W, dy=1, dx=1):
    return tf.nn.conv2d(x, W, strides=[1, dx, dy, 1], padding='SAME')


def weight_variable(shape):
    initial = tf.truncated_normal(shape, stddev=0.1)
    return tf.Variable(initial)


def max_pool_axb(x, a, b):
    return tf.nn.max_pool(x, ksize=[1, a, b, 1], strides=[1, a, b, 1], padding='SAME')


def bias_variable(shape):
    initial = tf.constant(0.1, shape=shape)
    return tf.Variable(initial)


def variable_summaries(var):
    """Attach a lot of summaries to a Tensor (for TensorBoard visualization)."""


#     with tf.name_scope('summaries'):
#         mean = tf.reduce_mean(var)
#         tf.summary.scalar('mean', mean)
#         with tf.name_scope('stddev'):
#             stddev = tf.sqrt(tf.reduce_mean(tf.square(var - mean)))
#         tf.summary.scalar('stddev', stddev)
#         tf.summary.scalar('max', tf.reduce_max(var))
#         tf.summary.scalar('min', tf.reduce_min(var))
#         tf.summary.histogram('histogram', var)

def conv_layer(input_tensor, filter_height, filter_width, channels_input, channels_output, layer_name, act=tf.nn.relu):
    # Adding a name scope ensures logical grouping of the layers in the graph.
    with tf.name_scope(layer_name):
        # This Variable will hold the state of the weights for the layer
        with tf.name_scope('weights'):
            weights = weight_variable([filter_height, filter_width, channels_input, channels_output])
            variable_summaries(weights)
        with tf.name_scope('biases'):
            biases = bias_variable([channels_output])
            variable_summaries(biases)
        with tf.name_scope('Wx_plus_b'):
            preactivate = conv2d(input_tensor, weights, 2, 1) + biases
        #             tf.summary.histogram('pre_activations', preactivate)
        activations = act(preactivate, name='activation')
        #         tf.summary.histogram('activations', activations)
        return activations


def fc_layer(input_tensor, input_dim, output_dim, layer_name, act=tf.nn.relu):
    # Adding a name scope ensures logical grouping of the layers in the graph.
    with tf.name_scope(layer_name):
        # This Variable will hold the state of the weights for the layer
        with tf.name_scope('weights'):
            weights = weight_variable([input_dim, output_dim])
            variable_summaries(weights)
        with tf.name_scope('biases'):
            biases = bias_variable([output_dim])
            variable_summaries(biases)
        with tf.name_scope('Wx_plus_b'):
            preactivate = tf.matmul(input_tensor, weights) + biases
        #             tf.summary.histogram('pre_activations', preactivate)
        activations = act(preactivate, name='activation')
        #         tf.summary.histogram('activations', activations)
        return activations


def output_layer(input_tensor, input_dim, output_dim, layer_name, act=tf.nn.softmax):
    # Adding a name scope ensures logical grouping of the layers in the graph.
    with tf.name_scope(layer_name):
        # This Variable will hold the state of the weights for the layer
        with tf.name_scope('weights'):
            weights = weight_variable([input_dim, output_dim])
            variable_summaries(weights)
        with tf.name_scope('biases'):
            biases = bias_variable([output_dim])
            variable_summaries(biases)
        with tf.name_scope('Wx_plus_b'):
            preactivate = tf.matmul(input_tensor, weights) + biases
        #             tf.summary.histogram('pre_activations', preactivate)
        activations = act(preactivate, name='activation')
        #         tf.summary.histogram('activations', activations)
        return activations


def batch_norm_layer(x, train_phase, scope_bn):
    with tf.variable_scope(scope_bn):
        beta = tf.Variable(tf.constant(0.0, shape=[x.shape[-1]]), name='beta', trainable=True)
        gamma = tf.Variable(tf.constant(1.0, shape=[x.shape[-1]]), name='gamma', trainable=True)
        axises = np.arange(len(x.shape) - 1)
        batch_mean, batch_var = tf.nn.moments(x, axises, name='moments')
        ema = tf.train.ExponentialMovingAverage(decay=0.5)

        def mean_var_with_update():
            ema_apply_op = ema.apply([batch_mean, batch_var])
            with tf.control_dependencies([ema_apply_op]):
                return tf.identity(batch_mean), tf.identity(batch_var)

        mean, var = tf.cond(train_phase, mean_var_with_update,
                            lambda: (ema.average(batch_mean), ema.average(batch_var)))
        normed = tf.nn.batch_normalization(x, mean, var, beta, gamma, 1e-3)
    return normed


########################   Structure   ##############################

with tf.name_scope('spectrogram_input'):
    x = tf.placeholder("float", shape=[None, 128 * 128], name='flat_input')
with tf.name_scope('target'):
    y_2 = tf.placeholder("float", shape=[None, 2], name='target_2')
    y_4 = tf.placeholder("float", shape=[None, 4], name='target_4')
with tf.name_scope('input'):
    x_image = tf.reshape(x, [-1, 128, 128, 1], name='2D_input')

h_conv1 = conv_layer(x_image, 16, 4, 1, channels_output, 'conv_layer_1', act=tf.nn.relu)
h_conv1_pl = max_pool_axb(h_conv1, 2, 1)

h_conv2 = conv_layer(h_conv1_pl, 4, 16, channels_input, channels_output, 'conv_layer_2', act=tf.nn.relu)
h_conv2_pl = max_pool_axb(h_conv2, 2, 1)

h_conv3 = conv_layer(h_conv2_pl, 16, 4, channels_input, channels_output, 'conv_layer_3', act=tf.nn.relu)
h_conv3_pl = max_pool_axb(h_conv3, 2, 1)

h_conv4 = conv_layer(h_conv3_pl, 4, 16, channels_input, channels_output, 'conv_layer_4', act=tf.nn.relu)
h_conv4_pl = max_pool_axb(h_conv4, 2, 1)

with tf.name_scope('reshape'):
    h_before_fc = tf.reshape(h_conv4_pl, [-1, fc_input_dim])

h_fc1 = fc_layer(h_before_fc, fc_input_dim, fc_hidden1_dim, 'hidden_layer_1', act=tf.nn.relu)
h_fc2 = fc_layer(h_fc1, fc_hidden1_dim, fc_hidden2_dim, 'hidden_layer_2', act=tf.nn.relu)

with tf.name_scope('dropout'):
    keep_prob = tf.placeholder("float")
    h_fc_drop = tf.nn.dropout(h_fc2, keep_prob)

with tf.name_scope('output'):
    y2 = output_layer(h_fc_drop, fc_hidden2_dim, 2, 'output_layer_2D', act=tf.nn.softmax)
    y4 = output_layer(h_fc_drop, fc_hidden2_dim, 4, 'output_layer_4D', act=tf.nn.sigmoid)
    # tf.summary.histogram('y',y)

with tf.name_scope('loss'):
    with tf.name_scope('cross_entropy'):
        diff2 = - y_2 * tf.log(tf.clip_by_value(y2, 1e-20, 1.0))
    with tf.name_scope('mean_squared_error'):
        diff4 = tf.losses.mean_squared_error(y_4, y4)

    cross_entropy = tf.reduce_mean(diff2)
    mse = tf.reduce_mean(diff4)
    loss = cross_entropy + gamma * mse

# tf.summary.histogram('cross_entropy_individual',diff)
tf.summary.scalar('cross_entropy', cross_entropy)
tf.summary.scalar('mse', mse)
tf.summary.scalar('loss', loss)

with tf.name_scope('train'):
    train_step = tf.train.AdamOptimizer(learning_rate).minimize(loss)

with tf.name_scope('accuracy'):
    with tf.name_scope('correct_prediction_2'):
        correct_prediction_2 = tf.equal(tf.argmax(y2, 1), tf.argmax(y_2, 1))
    with tf.name_scope('accuracy_2'):
        accuracy_2 = tf.reduce_mean(tf.cast(correct_prediction_2, tf.float32))
    tf.summary.scalar('accuracy_2', accuracy_2)

    with tf.name_scope('correct_prediction_4'):
        correct_prediction_4 = tf.equal(tf.argmax(y4, 1), tf.argmax(y_4, 1))
    with tf.name_scope('accuracy_4'):
        accuracy_4 = tf.reduce_mean(tf.cast(correct_prediction_4, tf.float32))
    tf.summary.scalar('accuracy_4', accuracy_4)

############################## Initialization & Read Data  #######################

summaries_dir = '../Train/log/train' + now.strftime("%Y%m%d-%H%M%S") + "/"

merged = tf.summary.merge_all()
train_writer = tf.summary.FileWriter(summaries_dir + '/train', sess.graph)
test_writer = tf.summary.FileWriter(summaries_dir + '/test')
sess.run(tf.global_variables_initializer())

saver = tf.train.Saver()

# Test Data

testData = sio.loadmat('../songMat/Test/532522 SakiZ - osu!memories.mat')
inputTest = testData['input'].reshape(-1, 128 * 128)
targetTest = testData['target'].reshape(-1, 4)

targetTest2 = np.zeros([targetTest.shape[0], 2])
targetTest2[:, 0] = targetTest[:, 0] + targetTest[:, 1] + targetTest[:, 2]
targetTest2[:, 1] = targetTest[:, 3]

targetTest4 = np.zeros([targetTest.shape[0], 4])
targetTest4[:, 0] = targetTest[:, 0] + 0.5 * targetTest[:, 1] + 0.5 * targetTest[:, 2]
targetTest4[:, 1] = 0.5 * targetTest[:, 0] + targetTest[:, 1] + 0.25 * targetTest[:, 2]
targetTest4[:, 2] = 0.5 * targetTest[:, 0] + 0.25 * targetTest[:, 1] + targetTest[:, 2]
targetTest4[:, 3] = targetTest[:, 3]

NTest = targetTest2.shape[0]

############################## Training  #######################

# batch_size = 20
step_size = 100
dataList = os.listdir('../songMat/Train/')
# acc=np.zeros([1000,1])

n = 1
total_steps = 0
while n < np.size(dataList) - 18:
    n = n + 3
    inputOsu = np.empty([0, 128 * 128])
    targetOsu = np.empty([0, 4])
    for k in range(n, n + 15):
        data = sio.loadmat('../songMat/Train/' + dataList[k])
        inputOsu = np.append(inputOsu, data['input1'].reshape(-1, 128 * 128), axis=0)
        targetOsu = np.append(targetOsu, data['target1'].reshape(-1, 4), axis=0)

    targetOsu2 = np.zeros([targetOsu.shape[0], 2]);
    targetOsu2[:, 0] = targetOsu[:, 0] + targetOsu[:, 1] + targetOsu[:, 2]
    targetOsu2[:, 1] = targetOsu[:, 3]

    targetOsu4 = np.zeros([targetOsu.shape[0], 4])
    targetOsu4[:, 0] = targetOsu[:, 0] + 0.5 * targetOsu[:, 1] + 0.5 * targetOsu[:, 2]
    targetOsu4[:, 1] = 0.5 * targetOsu[:, 0] + targetOsu[:, 1] + 0.25 * targetOsu[:, 2]
    targetOsu4[:, 2] = 0.5 * targetOsu[:, 0] + 0.25 * targetOsu[:, 1] + targetOsu[:, 2]
    targetOsu4[:, 3] = targetOsu[:, 3]

    N = inputOsu.shape[0]
    print(N)

    # shuffle the order
    order = np.arange(N - step_size)
    np.random.shuffle(order)
    orderAcc = np.arange(NTest)
    np.random.shuffle(orderAcc)

    for i in range(N - step_size):
        if i % step_size == 0:
            summary, _ = sess.run([merged, train_step], feed_dict={x: inputOsu[order[i:i + step_size], :],
                                                                   y_2: targetOsu2[order[i:i + step_size], :],
                                                                   y_4: targetOsu4[order[i:i + step_size], :],
                                                                   keep_prob: 0.5})
            test_writer.add_summary(summary, i + total_steps)
        #         else:
        #             summary = sess.run(merged, feed_dict={x: inputOsu[order[i:i+step_size],:], y_2: targetOsu2[order[i:i+step_size],:], y_4: targetOsu4[order[i:i+step_size],:], keep_prob: 0.5})
        #             train_writer.add_summary(summary, i + total_steps)
        if i % 1000 == 0:
            accMemory_2 = accuracy_2.eval(
                feed_dict={x: inputTest[orderAcc[0:300], :], y_2: targetTest2[orderAcc[0:300], :],
                           y_4: targetTest4[orderAcc[0:300], :], keep_prob: 1.0})
            accMemory_4 = accuracy_4.eval(
                feed_dict={x: inputTest[orderAcc[0:300], :], y_2: targetTest2[orderAcc[0:300], :],
                           y_4: targetTest4[orderAcc[0:300], :], keep_prob: 1.0})
            print("step %6.5d, memory accuracy (2D) %7.5g, memory accuracy (4D) %7.5g" % (i, accMemory_2, accMemory_4))
    #             print(y.eval(feed_dict={x: inputTest[orderAcc[1122:1130],:], keep_prob: 1.0}))

    total_steps += i



save_path = saver.save(sess, "../results/save/2.7/",global_step=n)

############################## Save the output of new maps ##############################

dataList = os.listdir('../songMat/Create/')
# inputOsuNew=np.empty([0,128*128]);
for i in range(np.size(dataList)):
    if not dataList[i][0] == 'y':
        data = sio.loadmat('../songMat/Create/' + dataList[i])
        print(data['osuFolder'])

        inputOsuNew = data['input'].reshape(-1, 128 * 128)
        outputOsuNew = data['target']
        outputOsu2New = np.zeros([outputOsuNew.shape[0], 2]);
        outputOsu2New[:, 0] = outputOsuNew[:, 0] + outputOsuNew[:, 1] + outputOsuNew[:, 2]
        outputOsu2New[:, 1] = outputOsuNew[:, 3]

        y_result_2 = np.empty([0, 2])
        y_result_4 = np.empty([0, 4])
        step_size = 200
        cursor = 0

        print ("test accuracy %g" % accuracy.eval(
            feed_dict={x: inputOsuNew[-300:, :], y_: outputOsu2New[-300:, :], keep_prob: 1.0}))
        while cursor < inputOsuNew.shape[0]:
            if inputOsuNew[cursor:, :].shape[0] > step_size:
                y_result_2_1 = y2.eval(feed_dict={x: inputOsuNew[cursor:(cursor + step_size):1, :], keep_prob: 1.0})
                y_result_4_1 = y4.eval(feed_dict={x: inputOsuNew[cursor:(cursor + step_size):1, :], keep_prob: 1.0})
                y_result_2 = np.append(y_result_2, y_result_2_1, axis=0)
                y_result_4 = np.append(y_result_2, y_result_4_1, axis=0)
            else:
                y_result_2_1 = y2.eval(feed_dict={x: inputOsuNew, keep_prob: 1.0})
                y_result_4_1 = y4.eval(feed_dict={x: inputOsuNew, keep_prob: 1.0})
                y_result_2 = np.append(y_result_2, y_result_2_1, axis=0)
                y_result_4 = np.append(y_result_2, y_result_4_1, axis=0)
            cursor += step_size

        data_save = {'y2': y_result_2, 'y4': y_result_4}

        sio.savemat('../songMat/Create/y_' + dataList[i], data_save)

