---
layout: post
title: Batch Normalization
category: machine-learning
---

## Batch Normalization

同事遇到一个奇怪的现象，她训练的模型看loss的表现挺好的，在验证的时候，如果同一批次的图片如果差异性比较大，预测出拉来的结果也很好。但是，如果同一批次图片长的很像（比如就是同一图片的略微变化的增强图片），预测结果就是非常不好。

她怀疑是由于Batch Normalization的问题，于是，一起对Batch Normalization进行了研究，写下这篇博客，对其中的一些收获进行总结和记录。

## 为何要做Normailization

首先，一个问题是，为什么要做Normalization，也就是中文“正则化”？

这个是来自于机器学习，上来先给结论“是因为，这样可以防止过拟合”。

为了解释这一点，需要从模型的容量、偏差和方差的关系、过拟合欠拟合等诸多方面讨论，我给出的本节的参考部分，里面包含了好几篇专门讨论这方面的文章，感兴趣的同学可以深入研究。

这里，我只想用比较通俗易懂的语言，来解释一下这件事：

使用复杂（跟$x$的高阶多项式、表达能力更强、深度网络中更多的参数、模型容量更大差不多都是一个意思）的模型，来去拟合数据的分布的话，特别容易过拟合；但是你要是用太简单的模型，你又无法拟合出接近数据的真实分布。所以，你得权衡，不能太复杂也不能太简单。

一个解决的办法是，你先整一个复杂的模型，然后再想办法去约束他。

约束的办法就是，就是尽量通过调整参数$w$变小，甚至是0，从而是模型中的维度降低，在传统的机器学习中的L1、L2正则，就是这样的一个调整思路。

而在深度学习中，我一直有个困惑，就是Dropout和Batch Normalization如何和L1、L2对应呢？

我自己的理解是：**他们对应不上**。

看知乎上关于L1、L2 VS Dropout和BatchNormalization的讨论，可大致理解： 

[神经网络中 L1 正则化和 dropout 正则化对weights 稀疏化的实质区别是什么？](https://www.zhihu.com/question/278256208)
>L1正则化和Dropout，二者的目标不一致，一个是减少权重项，实际上是追求降低复杂度，一个是增加随机扰动构造ensemble optimization的效果，目标是追求系统鲁棒性，但本质也是一个能量约束。

>dropout提出的初衷是在神经网络上模拟bagging，原理比较模糊、数学上不大明确。

[关于batch_normalization和正则化的一些问题？](https://www.zhihu.com/question/288370837)
>关于它的理论研究其实还不怎么充分。BN的计算涉及用基于mini batch计算的均值、方差代替真实均值、方差，这就起到了正则化的作用。但正则化只是BN顺带的一个作用。

所以，作为工程党，我能做的就是用L1、L2去约束常见的机器学习；使用Dropout和BatchNormalization去约束深度神经网络。

**【参考】**

- [模型评估与模型调优](https://machine-learning-from-scratch.readthedocs.io/zh_CN/latest/%E6%A8%A1%E5%9E%8B%E8%AF%84%E4%BC%B0%E4%B8%8E%E6%A8%A1%E5%9E%8B%E8%B0%83%E4%BC%98.html)
- [谈谈 Bias-Variance Tradeoff](https://liam.page/2017/03/25/bias-variance-tradeoff/)
- 花书的5.2节[《容量、过拟合和欠拟合》](https://cloud.tencent.com/developer/article/1164231)

## L1、L2正则化

L1和L2的推导一直都是面试必考，大致就是2个思路：

参考这篇：[深入理解L1、L2正则化](https://zhuanlan.zhihu.com/p/29360425)：
- 1、正则化理解之基于约束条件的最优化：加上对参数$w$进行范数的约束，用$l_0,l_1$范数小于$C$来作为约束条件，利用拉格朗日算子法来解这个带条件的优化问题，就可以退出L1、L2公式。
- 2、正则化理解之最大后验概率估计：假设参数$w$属于拉普拉斯分布，就可以推导出L1；$w$属于高斯分布，就可以推导出L2正则公式。
- L1会趋向于产生少量的特征，而其他的特征都是0，而L2会选择更多的特征，这些特征都会接近于0

因为L1、L2不是深度学习中重点关注的内容，这就捎带着提一下，感兴趣，可以去阅读参考中的文章，它们都已经给出了非常详细的公式推导和讲解。

**【参考】**

- [Laplace（拉普拉斯）先验与L1正则化](https://www.cnblogs.com/heguanyou/p/7688344.html)
- [机器学习中常常提到的正则化到底是什么意思？](https://www.zhihu.com/question/20924039/answer/240037674)
- [深度学习（五）正则化之L1和L2](https://www.shuzhiduo.com/A/B0zqlyXrdv/)
- [L1正则化和L2正则化](https://www.cnblogs.com/nxf-rabbit75/p/9954394.html)

## 深度学习中的Batch Normalization

Dropout也是一种正则化方法，你可以通俗地理解为bagging的朴素应用，因为这篇文章主要讲BatchNormailization，这里就不多讲了。

我们终于迎来了我们这篇博客的猪脚：【**Batch Normalization**】

### 为什么Batch Normalization管用

原理啥的，参考的文章们讲了一通，我还是原因用我的大白话谈谈我的理解：

- 他们说的ICS（Internal Covariate Shift），就是说，你浅层的参数细微调整，会对后面层参数产生蝴蝶效应，导致不收敛。
- 他说ICS的原因是因为你数据导致的，你数据的每个维度上的值变换太剧烈，就会导致参数的调整剧烈，所以要尽量让输入的数据保持稳定，就是尽量让他们在一个尺度上
- 怎么保持一个尺度呢？就是通过Normailization，使得维度上值均值为0，方差为1
- 引入$\gamma,\beta$，说是，怕正则限制了模型的表达，给他一些弹性。不过我搜遍全网，也没有讲的特别明白的。

	这篇《[Batch Normalization详解](https://www.cnblogs.com/shine-lee/p/11989612.html)》的解释是我看到的可能最明白点的：

	>没有scale and shift过程可不可以？
	BatchNorm有两个过程，Standardization和scale and shift，前者是机器学习常用的数据预处理技术，在浅层模型中，只需对数据进行Standardization即可，Batch Normalization可不可以只有Standardization呢？
	答案是可以，但网络的表达能力会下降。
	直觉上理解，浅层模型中，只需要模型适应数据分布即可。对深度神经网络，每层的输入分布和权重要相互协调，强制把分布限制在zero mean unit variance并不见得是最好的选择，加入参数𝛾和𝛽，对输入进行scale and shift，有利于分布与权重的相互协调，特别地，令𝛾=1,𝛽=0等价于只用Standardization，令𝛾=𝜎,𝛽=𝜇等价于没有BN层，scale and shift涵盖了这2种特殊情况，在训练过程中决定什么样的分布是适合的，所以使用scale and shift增强了网络的表达能力。
	表达能力更强，在实践中性能就会更好吗？并不见得，就像曾经参数越多不见得性能越好一样。在caffenet-benchmark-batchnorm中，作者实验发现没有scale and shift性能可能还更好一些。

### 怎么做Batch Normailization

好吧，理论差不多了，我们实战一下：

看例子：

![](/images/20200517/1589720623208.jpg){:class="myimg"}

上图里是个全连接网络，怎么做Batch Normalization呢？

很简单，就是对绿框中的8个数据求均值和方法，然后正则化每个数。

细节来了，这$\color{green}{绿框}$里的数，是一个批次（8个）中的第一个维度的值，所以，你算的结果，是**8个批次在第一个维度的均值和方差**。

然后你还要依次计算其他维度的，最后把方差$\mu$和均值$\sigma$带入到这个公式：

$\hat{x} = \gamma \* \frac{x-\mu}{\sqrt{\sigma^2+\epsilon}} + \beta$

当然$\gamma,\beta$是需要学习的。

### 那CNN如何做Batch Normailization呢？

参考[这篇](https://kiddie92.github.io/2019/03/06/%E5%8D%B7%E7%A7%AF%E7%A5%9E%E7%BB%8F%E7%BD%91%E7%BB%9C%E4%B9%8BBatch-Normalization%EF%BC%88%E4%B8%80%EF%BC%89%EF%BC%9AHow%EF%BC%9F/#%E5%AF%B9%E5%8D%B7%E7%A7%AF%E5%B1%82%E5%81%9A%E6%89%B9%E9%87%8F%E5%BD%92%E4%B8%80%E5%8C%96)：
>对卷积层来说，批量归一化发生在卷积计算之后、应用激活函数之前。如果卷积计算输出多个通道，我们需要对这些通道的输出分别做批量归一化，且每个通道都拥有独立的拉伸和偏移参数，且均为标量。设小批量中有 m 个样本。在单个通道上，假设卷积计算输出的高和宽分别为 p 和 q。我们需要对该通道中 m×p×q 个元素同时做批量归一化。对这些元素做标准化计算时，我们使用相同的均值和方差，即该通道中 m×p×q 个元素的均值和方差。

![](/images/20200517/1589722001451.jpg){:class="myimg30"}

如上图，我们再去算均值和方差，用的是所有批次的同样通道里的所有的数，也就是图中所形容的，“把N个批次的面包片的数据一起来算”，一个面包片比喻一个通道。

比如我的这个是某一层的CNN的结果，Feature Map假设是\[N,H,W,C\]，计算完成的均值$\mu$是\[C\]个，方差$\sigma$也是\[C\]个。

然后，我们用这个$\mu,\sigma$，对这N个面包片里面的数进行归一化，得到的结果，作为Batch Normalization的结果。

### 训练时候和测试时候的Batch Normalization

训练的时候，需要每个批次的数据，来算$\mu,\sigma$，然后梯度下降$\gamma,\beta$，下一个批次再算下一个批次的，不过，训练的时候，还需要记住这些均值，怎么记住呢，使用移动平均法不停的计算，在网络中记住这个移动平均值。

*这里有个小疑问❓训练的方差和均值，用的是这个批次计算出来的，还是移动平均出来呢？我自己推断，是移动平均出来的，这样更接近全局的样本的平均值。*

测试的时候，由于数据量很少，你用这个批次的均值和方差来Batch Normalization数据意义不大，所以使用网络中已经记住的所有数据（也就是训练的时候）的**全局移动平均值**后的均值和方差，来带入Batch Normalization公式进行计算。

所以，这个是训练和测试的时候的一个**重大**区别。

所以，你自己也可以脑补，这些移动平均均值、方差跟参数类似，也是要记录在网络当中的，跟参数$\gamma,\beta$一样。所以，我们甚至可以说，在Batch Normalization这个环节，参数有$\gamma,\beta,移动平均\mu,移动平均\sigma$4类。

【 参考】
- [Batch Normalization原理与实战](https://zhuanlan.zhihu.com/p/34879333)，这篇讲的超赞
- [Batch Normalization详解](https://www.cnblogs.com/shine-lee/p/11989612.html)
- [深度学习中 Batch Normalization为什么效果好？](https://www.zhihu.com/question/38102762)
- [关于batch_normalization和正则化的一些问题？](https://www.zhihu.com/question/288370837)

## 写在最后

好，我们已经捋了一遍了正则化、Batch Normalization了，我们来总结一下。

正则化就是为了解决过拟合问题，传统机器学习使用L1、L2，而深度学习使用Dropout和Batch Normalization。Batch Normalization，在训练的时候使用当前批次的均值和方差计算，要学习$\gamma,\beta$两个参数，而到了测试阶段，均值和方差就要使用训练时候的移动平均均值和方差来计算了。

最后，让我们再回到同事说的训练的时候，同样类型图片的预测结果不好的现象上来，我们可以大胆的推测，这批图片因为缺乏了多样性，导致他们和之前遇到的那些图片的平均值偏差太大，导致网络无法适应，才导致了最终识别的效果不佳。这个其实是正常的现象，只要图片足够多，不断地训练，这个问题就可以被消除。当然，训练的时候也应该避免这种一类图片同时喂给网络的情况，尽量的随机化才好。