---
layout: post
title: 新项目趟坑之旅 ~ TF2.0
category: machine-learning
---

## 开始挖坑 

开始复现[TextScanner](/machine-learning/2020/04/14/ocr-fa-textscanner)论文了，我创建了我的[Github项目](https://github.com/piginzoo/textscanner)，兴冲冲的开始编码。开始之初，就暗暗下定决心，这次一定要用[TF2.0](https://www.tensorflow.org/api_docs/python/)，都已经2.2了，该稳定了！

## 各种填坑之旅

### 趟坑准备

就我以往的经验，上手一个新库，痛苦的经历是不可避免的，最好的方式，是需要提前对你要面对的坑有所了解，也就是要提前学习一下。虽然，大部分学过的东西都是记不住的，但是，至少你是对新坑有所感知，可以明显避免一些极深的、众所都知的坑，而且，也可以迈开入坑开始的步伐。

所以，我去网上搜索了一些不错的TF2.0的教程：

- [官方：Effective TensorFlow 2](https://www.tensorflow.org/guide/effective_tf2?hl=zh-cn)
- [TensorFlow 2.0 简明指南](https://zhuanlan.zhihu.com/p/70232196)
- [最全Tensorflow2.0 入门教程](https://zhuanlan.zhihu.com/p/59507137)

我自己总结一下TF2.0的新特性：
- 剽窃自pytorch的动态图，也就是eger模式
- 自定义的model，可以自己开心的定制模型啦
- 加载方式增加了个tf.data

恩，还有很多细节，但是核心就是这些吧。

### 自定义层plus自定义模型，构建我的新模型

### 如何将预训练的Resnet50焊接到我的层中


### 多个loss的实现，还得带权重


### 对Sequence的怀疑，以及Eger模式的开启

遇到一个新错：

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


## 眼泪总结

这几周的编码和趟坑之旅，让自己对TF2.0，keras，甚至tensorflow本身，都有了很多很多深入的了解和认知。正如我们做事情一样，很多在别人看来你拥有的深入的经验和理解，其实都是你不断钻研的结果，所以，在遇到问题的时候，虽然很纠结，很痛苦，但是，反复深入理解，不断地尝试解决问题的过程，就是你最好的学习过程。

当你几度陷入绝望的时候，最好的方式，就是，持续的搜索，持续的思考，持续的阅读源码，持续的试错，总会有那么一个时刻，你可以收获自己的aha时刻的。这本身就是一种信念。

## 参考