---
layout: post
title: VGG的fine tunning
category: machine-learning
---

我们都知道，VGG模型是一个简单易用的模型，你可以用它来做fine-tuning，也就是微调。把图像管给他，然后他得到一个抽象的向量，你用这个向量来做其他的任务。这个网络已经有人做过很好的训练了，里面的那些权重都已经接近极致，所以你也不需要再大改了，拿来直接用就好。

# 问题

我正好手头有个项目需要用vgg作为基础，来训练我的任务，于是，我兴冲冲的就搭了一个vgg网络：

```
def vgg16_2(inputs, scope='vgg_16'):
    with tf.variable_scope(scope, 'vgg_16', [inputs]) as sc:
        with slim.arg_scope([slim.conv2d, slim.fully_connected],
                      activation_fn=tf.nn.relu,
                      weights_initializer=tf.truncated_normal_initializer(0.0, 0.01),
                      weights_regularizer=slim.l2_regularizer(0.0005)):
            net = slim.repeat(inputs, 2, slim.conv2d, 64, [3, 3], scope='conv1')
            net = slim.max_pool2d(net, [2, 2], scope='pool1')
            net = slim.repeat(net, 2, slim.conv2d, 128, [3, 3], scope='conv2')
            net = slim.max_pool2d(net, [2, 2], scope='pool2')
            net = slim.repeat(net, 3, slim.conv2d, 256, [3, 3], scope='conv3')
            net = slim.max_pool2d(net, [2, 2], scope='pool3')
            net = slim.repeat(net, 3, slim.conv2d, 512, [3, 3], scope='conv4')
            net = slim.max_pool2d(net, [2, 2], scope='pool4')
            net = slim.repeat(net, 3, slim.conv2d, 512, [3, 3], scope='conv5')
            net = slim.max_pool2d(net, [2, 2], scope='pool5')
            net = slim.fully_connected(net, 4096, scope='fc6') <----------------全链接层
            net = slim.dropout(net, 0.5, scope='dropout6')
            net = slim.fully_connected(net, 4096, scope='fc7')
            return net
```

用的是slim，是一个简化你用tensorflow low api的工具package，我想当然的的就加入上了上面说的“全连接层”，然后跑起来，然后，就报错了啦：

说我的fc7层有问题，恩？怎么维度不一致呢？lhs shape= [4096,4096] rhs shape= [1,1,4096,4096]
lhs是我的图定义，也就是我的代码中定义的维度；而rhs是模型文件中的维度。不一致！

```
Assign requires shapes of both tensors to match. lhs shape= [4096,4096] rhs shape= [1,1,4096,4096]
	 [[node save/Assign_29 (defined at /Users/piginzoo/software/python3/lib/python3.6/site-packages/tensorflow/contrib/framework/python/ops/variables.py:748)  = Assign[T=DT_FLOAT, _class=["loc:@vgg_16/fc7/weights"], use_locking=true, validate_shape=true, _device="/job:localhost/replica:0/task:0/device:CPU:0"](vgg_16/fc7/weights, save/RestoreV2:29)]]
```

难道是我的输入有问题？还是，啥问题？馒头雾水

# slim的vgg实现

然后，我看了[这篇](https://gist.github.com/omoindrot/dedc857cdc0e680dfb1be99762990c9c/)，噢~，原来slim中就有vgg的实现，

```
logits, _ = vgg.vgg_16(images, num_classes=num_classes, is_training=is_training, dropout_keep_prob=args.dropout_keep_prob)
variables_to_restore = tf.contrib.framework.get_variables_to_restore(exclude=['vgg_16/fc8’])
init_fn = tf.contrib.framework.assign_from_checkpoint_fn(model_path, variables_to_restore)
init_fn(sess)
fc8_variables = tf.contrib.framework.get_variables('vgg_16/fc8’)
fc8_init = tf.variables_initializer(fc8_variables)
sess.run(fc8_init)
_ = sess.run(fc8_train_op, {is_training: True})
```

原来，人家只用到了fc7，fc8没有加载，而是自己初始化，用来训练自己的东西。

然后我一跑，恩，没问题，好了。于是，我修改了自己的代码，也没问题。

可是，我不想用slim的vgg，我自己写的究竟跟他差在什么地方，于是点进去看了slim的vgg实现：

```
            net = slim.conv2d(net, 4096, [7, 7], padding='VALID', scope='fc6')
            net = slim.dropout(net, 0.5,scope='dropout6')
            net = slim.conv2d(net, 4096, [1, 1], scope='fc7') <--------看这里！

```

什么？居然不是全连接，而是做了一个1x1的卷积，从而实现了全连接的效果。怪不得是[1,1,4096,4096]呢！原来是卷积的结果。靠！
可是，你去看人家的VGG定义：

![](/images/20190428/1556444778797.png){:class="myimg"}

其实，就是卷积啊，是自己学艺不精，没彻底搞清楚，就动手了，惭愧~

# 照着修改自己的vgg图

那好吧，于是，理解了原因那就好办了，我还是用自己的vgg的图定义把，然后加上一个神奇操作 tf.squeeze

```
vgg_fc7 = tf.squeeze(vgg_fc7,axis=[1,2])
```

这个squeeze，可以帮助我们把多余的1维的去掉，就是把[1,1,4096,4096]=>[4096,4096]了，赞！
可是为何是axis=[1,2]，而没有[0]呢？恩，0位置是batch。

# keras来fine-turning vgg

一不做，二不休，我顺道看了一下，我搜到的关于keras如何fine-tuning vgg的[文章](https://www.learnopencv.com/keras-tutorial-fine-tuning-using-pre-trained-models/)：

```
from keras.applications import VGG16
vgg_conv = VGG16(weights='imagenet', include_top=False, input_shape=(image_size, image_size, 3))
```

- 靠的是include_top来去掉fc层。
- 通过trainable来frozen一些层