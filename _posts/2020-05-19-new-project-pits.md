---
layout: post
title: 新项目趟坑之旅 ~ TF2.0
category: machine-learning
---

# 开始挖坑 

开始复现[TextScanner](/machine-learning/2020/04/14/ocr-fa-textscanner)论文了，我创建了我的[Github项目](https://github.com/piginzoo/textscanner)，兴冲冲的开始编码。开始之初，就暗暗下定决心，这次一定要用[TF2.0](https://www.tensorflow.org/api_docs/python/)，都已经2.2了，该稳定了！

# 各种填坑之旅

## 趟坑准备

就我以往的经验，上手一个新库，痛苦的经历是不可避免的，最好的方式，是需要提前对你要面对的坑有所了解，也就是要提前学习一下。虽然大部分内容，学过之后很快都会忘记，但是，至少你会对新坑有所感知，可以明显避免一些深的、众所都知的坑。

所以，我去网上搜索了一些不错的TF2.0的教程：

- [官方：Effective TensorFlow 2](https://www.tensorflow.org/guide/effective_tf2?hl=zh-cn)
- [TensorFlow 2.0 简明指南](https://zhuanlan.zhihu.com/p/70232196)
- [最全Tensorflow2.0 入门教程](https://zhuanlan.zhihu.com/p/59507137)

阅读以及照着教程做了一些demo之后，逐步了解了TF2.0主要的新特性：
- tf2.0“剽窃”了pytorch的动态图，也就是**egear模式**
- 增加自定义的model的方法，可以自己开心地定制自己的模型啦
- 加载方式增加了个tf.data

恩，还有很多细节，但是核心就是这些。

## 我这个这个项目

Textscanner是一个比较新的OCR模型，可以参阅我的[另外一篇博客](/machine-learning/2020/04/14/ocr-fa-textscanner)，详细了解。为了实现这个模型，我需要做以下的工作：
- 实现一个FCN层，使用Resnet50作为FCN的编码的Backbone
- 实现多个自定义层，自定义模型，来完全表达Textscanner模型
- 实现多个loss，组合到一起
- 使用Callback作为可视化，来调试训练过程
- 使用Sequence作为加载数据的方式（没有使用新的tf.data）

## 自定义层plus自定义模型，构建我的新模型

在这个项目中，我们需要定义一个**自定义**模型，模型中包含**自定义**的层，自定义层内部还要加载Resnet50的预训练模型，这一连串的“**自定义**”，以及包含预训练模型，该如何实现呢？

让我们迈出第一步，就是自定模型和自定义层。

自定义模型，[官网](https://www.tensorflow.org/guide/keras/custom_layers_and_models?hl=zh-cn)上有比较详细的例子，不是很难，一般都是`__init__`初始化函数中实例化层，然后再`call`中，使用[Functional](https://keras-cn.readthedocs.io/en/latest/getting_started/functional_API/)方式进行调用，这种写法，基本上和pytorch的模型定义方法非常相像了。

在训练的时候，你既可以使用Model.fit方法，自动的调用训练的过程；也可以通过tf.GradientTape类，来控制训练的细节，两种方式，都可以帮助训练，计算loss，反向传播，优化参数。只不过tf.GradientTape，给你更多的控制，但是在我看来，还是fit方法更简洁。

实现过程中，自定义层中，FCN遇到了最多的问题。

## 如何将预训练的Resnet50焊接到我的FCN层中

在TextScanner中，第一个层，就是一个FCN（可参考我的另一篇博文[语义分割网络:FCN,UNet](/machine-learning/2020/04/23/fcn-unet)），我们都知道，FCN一般需要一个backbone作为编码器（我选择了Resnet50：使用了Keras自带的[ResNet50](https://keras.io/api/applications/resnet/#resnet50-function)），然后使用其中的pool3,pool4和pool5。也就说，我需要在这个FCN的自定义层中，使用Resnet50，然后再加上上采样部分，共同组成这个自定义层。这样一个需求如何实现呢？

一开始，我真的一点思路都没有，搜了无数的例子，都没有能满足我这个需求的，我甚至跑到[Stack Overflow](https://stackoverflow.com/questions/61649083/tf-keras-how-to-reuse-resnet-layers-as-customize-layer-in-customize-model/62113024#62113024)，专门发了帖子寻找方案，无果。

然后我做了很多尝试：

比如，我尝试在自定义层的`call`方法中，调用Resnet50，然后再尝试从模型中得到对应层的输出，这个方法的问题是，运行的时候，总是得到resnet的所有变量无法被梯度下降的警告。而且这个方法不是使用fucntional那样的调用的输出方式，而是从模型层的output上获得输出，这个时候得到肯定是个张量，至于是不是可以再egear模式下，顺达利的转成numpy输出，其实也是个问题。总之，最终放弃了这个方法。

```
x = self.resnet50_model(input_image, training=training)
pool3 = self.resnet50_model.get_layer("conv3_block4_out").output
pool4 = self.resnet50_model.get_layer("conv4_block6_out").output
pool5 = self.resnet50_model.get_layer("conv5_block3_out").output
```

比如，我还尝试过，把Resnet的layers都拿出来，然后挨个调用，一遍通过functional方式得到最终的输出，这样看上去舒坦多了，但是，下面代码演示的写法是有问题的，因为Resnet中有很多分支和shortcut，不能这样顺序的调用，就可以得到他的运行逻辑。实际运行的时候，我就发现经常出现某个层没有按照预想的顺序调用，而是乱序的。最终，这个方法也放弃了。

```
self.resnet_layers = self.resnet50_model.layers

def call(self,input_image):
        x = input_image
        # extract features by Resnet50
        for layer in self.resnet_layers:
            print(layer.name)
            x = layer(x)
```

最终，我找到了一个方法，很诡异，就是再造一个新的Model，这个Model的输入使用的是Resnet的输入，输出是Resnet中对应的：
- `conv3_block4_out`
- `conv4_block6_out`
- `conv5_block3_out`

然后用这个新的模型，嵌入到FCN自定义层中：

```
class FCNLayer(Layer):
    def __init__(self, name, resnet50_model):
        super().__init__(name=name)
        resnet50_model.layers.pop()
        resnet50_model.summary()
        self.resnet50_model = resnet50_model

    def build(self, input_image, FILTER_NUM=4):
        layer_names = [
            "conv3_block4_out",  # 1/8
            "conv4_block6_out",  # 1/16
            "conv5_block3_out",  # 1/32
        ]
        layers = [self.resnet50_model.get_layer(name).output for name in layer_names]
        self.FCN_left = Model(inputs=self.resnet50_model.input, outputs=layers)
        ......


    def call(self, input_image, training=True):

        pool3, pool4, pool5 = self.FCN_left(input_image)
        .......
```

完整代码，可以参考我的[Github的FCN实现](https://github.com/piginzoo/textscanner/blob/master/network/layers/fcn_layer.py)。总结一下，我的最终做法，自定义层中包含一个模型，而这个模型又使用了pretrain的Resnet50模型，很诡异哈，是的！但是，它work，而且，我没有找到更好的方法。如果你能想出更好的办法，请告诉我吧。


## 多个loss的实现，还得带权重

Textscanner模型，是多个损失函数组合而成的，而且每个loss还有自己的对应的权重，这样一个loss，如何实现呢？

```
losses =['categorical_crossentropy','categorical_crossentropy',localization_map_loss()]
loss_weights = [1,10,10] # weight value refer from paper
model.compile(Adam(),loss=losses,loss_weights=loss_weights,metrics=['accuracy'],run_eagerly=True)
```
是的，Keras中是支持多个loss的组合的，只需要将每一个loss的loss函数和他们对应的权重，给`model.compile`方法即可。

其实，还有一些方法，比如可以把所有的loss塞入一个自定义的层，这个层在模型的最后一层，[知乎](https://zhuanlan.zhihu.com/p/74009996)上有一篇文章详细讲解了这个方法。

还有一种方法，就更“变态”了，参考CSDN上的[这篇帖子](https://blog.csdn.net/qq_32623363/article/details/104154418)，他其实就是手工做损失函数的梯度下降，即把损失函数得到的结果，利用tf2.0的tf.GradientTape类，进行方向梯度下降计算。这样，你怎么设计你的loss都可以啦，管你多少个loss组合呢！

我还是选择了最简单`model.compile`传入的方式，简洁！

## 对Sequence的怀疑，以及Eger模式的开启

在运行训练代码的过程中（也就是我调用model.fit的时候），遇到一个异常：

```
File "/Users/piginzoo/workspace/opensource/textscanner/network/layers/fcn_layer.py", line 83, in crop

cx = abs(o1_width - o2_width)
TypeError: unsupported operand type(s) for -: 'NoneType' and 'NoneType'
```

原因是，我推给模型的验证集数据，居然都是空，都是None，我试图打印出来模型的入参，结果也都是\[None,None,None,None\]的一个张量。从表面上看，就是验证集出问题，训练集并没有问题。训练集和验证集，我是分别创建了2个Sequence的实例，但是代码都是一套。

我觉得，是不是，在TF2.0下，`tensorflow.keras.utils.Sequence`出了啥问题了呢？记得之前好像朦胧看到过，说Sequence被废弃了，以后都转向tf.data，来帮着加载数据了。于是，抱着这个执念，就去搜索，试图找到一些证据，来落实自己的这个朦胧回忆。

可是，不幸的是，并没有找到！

我首先去看了Sequence的文档和源码，没有找到任何蛛丝马迹，说Sequence已经被废弃了。然后继续搜索`TF2.0 tf.keras.utils.Sequence deprecated`，还是没有找到Sequence的坏话，偶尔可以看到一些言论说，Sequence不适合分布式训练的加载，而且官方确实也确实逐渐[推荐使用tf.data](https://www.tensorflow.org/tutorials/load_data/images?hl=zh-cn)了，此外，Keras本身也是有[一个包是用来加载数据](https://keras.io/api/preprocessing/image/#loadimg-function)的，这个包里也没用到Sequence，反倒是返回的结果都是tf.data。

所以，虽然tf.data是首选，但是使用Sequence也没啥问题。

然后，我又去看了model.fit的文档，
```python
def fit(self,
          x=None,

	x: Input data. It could be:
	  - A Numpy array (or array-like), or a list of arrays
	    (in case the model has multiple inputs).
	  - A TensorFlow tensor, or a list of tensors
	    (in case the model has multiple inputs).
	  - A dict mapping input names to the corresponding array/tensors,
	    if the model has named inputs.
	  - A `tf.data` dataset. Should return a tuple
	    of either `(inputs, targets)` or
	    `(inputs, targets, sample_weights)`.
	  - A generator or `keras.utils.Sequence` returning `(inputs, targets)`<---- 看到了Sequence了，看来人家官方还是支持的
	    or `(inputs, targets, sample weights)`.
	  A more detailed description of unpacking behavior for iterator types
	  (Dataset, generator, Sequence) is given below.
```

好吧，终于，我不再纠结是不是该放弃Sequence了，况且，这个问题到底是不是因为他引起的，还不好说呢？我的思路有些涣散，立刻抖擞一下，回到这个问题上来。

我们再来观察这个问题，说，模型输入的是一个张量。咦？！不对啊，不是TF2.0都是[Eger模式](https://www.tensorflow.org/guide/eager?hl=zh-cn)了么？Eger末实现，所有的数据都应该可以直接被print出来啊。

难道是因为，keras并没有开启eger模式，不是说默认开启的么？

不管怎么说，我还是死马当活马医，于是我在模型compile的时候，加入`run_eagerly=True`：

```python
model.compile(Adam(),loss=losses,loss_weights=loss_weights,metrics=['accuracy'],run_eagerly=True)
```

再去调试，验证数据终于如我所愿，刷刷刷的正常了。

我勒个去！这个坑有点深吧，让我还和Sequence纠结了半天，差点冤枉了人家。其实，我个人还是非常非常喜欢Sequence的，设计的很清晰，配合fit时候的multiprocess和worker，就可以多进程加载数据，看这篇[Stackoverflow上的关于tf.data和Sequence的对比和评价](https://stackoverflow.com/questions/55852831/tf-data-vs-keras-utils-sequence-performance)：

> Both approaches overlap input data preprocessing with model training. keras.utils.sequence does this by running multiple Python processes, while tf.data does this by running multiple C++ threads

>Some other things to consider:
- tf.data is the recommended approach for building scalable input pipelines for tf.keras
- tf.data is used more widely than keras.utils.sequence, so it may be easier to search for help with getting good performance.

看，Sequence没有丝毫被废弃的迹象啊，不过官方确实是更推荐使用tf.data，好吧，我宽心多了...

不过，回顾这个问题，我有一个还是疑惑的地方，就是我的训练数据，是没有这个问题的，是识别出来各个图片的维度的（如Tensor\[None,64,256,3\]）；只有训练数据，才会出现\[None,None,None,None\]的情况。不过，打印出来的，也不是eger模式开始之后的numpy数据，而也是一个张量。

另外，在启动程序的时候，我还会收到来自tensorflow的警告，让我肝颤：

>WARNING:tensorflow:multiprocessing can interact badly with TensorFlow, causing nondeterministic deadlocks. For high performance data pipelines tf.data is recommended.

呵呵，我不想在折腾了😭（换成tf.data）了，求放过吧

## 训练中的可视化

在训练的过程中，可视化很重要，过去我们使用tensorflow的时候，需要在训练的间隙，定期输出一些中间结果用于调试。现在，在keras中，我们要实现这一点，该如何做呢？（这个方法不是tensorflow2.0/tf.keras才有的，是keras本身就支持的）答案是使用Keras的[Callback机制](https://keras.io/api/callbacks/)。

Keras的Callback，其实就是给你提供了一个回调机制，让你在每个batch、epoch调用结束的时候，可以回调你的自定义Callback类，实现特定的功能。我们就是利用这个特性，创建了一个Callback，然后在固定的1000步的时候，调用训练集中的9张图片，把原始的标注，模型预测的结果，dump成图片，写到tf.summary中，这样，tensorboard，就可以帮助我们收集起来，显示到tensorboard中了。

我在TextScanner中实现的这个[可视化Callback](https://github.com/piginzoo/textscanner/blob/master/utils/visualise_callback.py)，托tf2.0的福，我调用模型来预测图片的方法很简单，就是`pred = self.model(images[i])`，这个self.model，就是Callback父类自动提供的，就是你正在训练的模型，然后通过functional的方式，就这么自然的调用了。但是，如果是tf1.x+keras，调用就不会这么简单，而是要使用K.function，来调用对应的张量，得到运行结果。可以参考我在另外一个项目中的[Callback可视化实现](https://github.com/piginzoo/attention_ocr/blob/master/utils/visualise_attention.py):

```
functor = K.function([self.model.input[0],self.model.input[1],K.learning_phase()], [e_outputs,self.model.output])
e_outputs_data,output_prob = functor([ images,labels[:,:-1,:],True])
```

另外，这个可视化Callback中还有一个trick，就是使用matplotlib.pyplot，来显示概率分布的图。如果不适用pyplot，你需要对概率图（就是每个点值不是0-255，而是一个概率值）进行处理，使之值从[0~1]变换到[0~255]，然后得到一个灰度图。但是pyplot有个神奇的功能，就是你只需要把这个Channel是1的概率图传给他，他会帮你生成一个五颜六色的RGB图（变成3通道了），而且不同的概率值，会按照他的一个映射，映射成某种颜色，使得你观察概率分布变得很方便了（再也不是一个灰度图的模样了）。于是，我使用了他的这个特性，把我的概率图，和原图做了一个merge，然后dump到tf.summary中，这样，我就可以得到一个多彩的可视化结果：

![](/images/20200531/1590913202105.jpg){:class="myimg30"}


## 眼泪总结

这几周的编码和趟坑之旅，让自己对TF2.0，keras，甚至tensorflow本身，都有了很多很多深入的了解和认知。正如我们做事情一样，很多在别人看来你拥有的深入的经验和理解，其实都是你不断钻研的结果，所以，在遇到问题的时候，虽然很纠结，很痛苦，但是，反复深入理解，不断地尝试解决问题的过程，就是你最好的学习过程。

当你几度陷入绝望的时候，最好的方式，就是，持续的搜索，持续的思考，持续的阅读源码，持续的试错，总会有那么一个时刻，你可以收获自己的aha时刻的。这本身就是一种信念。

## 参考