---
layout: post
title: 文字识别的一些研究
category: machine-learning
---

## 最近

最近，苦于要解决文字中生僻字、低频词的识别，以及识别正确率的问题，做了一些研究。

主要看了看aster总的TRN网络，注意力聚焦，以及最近的text scanner，把一些理解和体会记录下来。 

## 先说说Aster的SRN

先贴论文:[Aster:An Attentional Scene Text Recognition with Flexible Rectification](https://www.researchgate.net/publication/325993414_ASTER_An_Attentional_Scene_Text_Recognizer_with_Flexible_Rectification)

论文团队给了一个代码实现：[Github Aster](https://github.com/bgshih/aster)，主要包括了变形纠正的SRN网络和后面的文字识别TRN网络，前面的变形纠正网络，我没有细研究，目前没有需求，略过，主要是看了看文字识别网络，感兴趣主要是因为，他是一个典型的注意力识别模型，是具代表性的，当然这也不是他的原创，[RARE](https://arxiv.org/pdf/1603.03915)里最早提出来的，他只不过借鉴过来。这里我把论文学习的过程的一些理解整理出来：

论文说，CTC的问题是说，他是一个组合概率的$\Sigma$，即所有的排列组合的关系，很难确定字之间的关系，这点不是很特别赞同，因为CRNN其实也是使用了bi-LSTM来捕捉图像前后的顺序贯彻习的，但是CRNN确实不太好确定字的位置，在解码每个字的时候，全靠之前的bi-LSTM抽取的特征，这个时候遇到对齐问题，所以也只好靠B变换，插入空白来解决了。

注意力实际上是另外一种尝试，他用注意力机制，来在输入的bi-LSTM抽取的特种中来回跳转，通过注意力捕捉后的注意力向量，来参考这些信息，“聚焦到”对应的需要解码的图像特征，然后，避免了对齐问题。

不过，金连文教提过，微软亚洲研究院做过评测，注意力是干不过CTC的，特别是在长文本的情况下，论文也提到了，超过11个字就明显干不过了.

> As can be seen, the recogintion accuracy is farely even on words whose lengths are equal to or less than 11. Beyond this length, a drop in accuracy is observed.

### 先说说网络结构

网络结构上，有个细节有些迷惑，第5页里面提到“Next, the feature map is converted into a feature sequence by being split along its row axis. The shape of the feature map is $(h_{conv},w_{conv},d_{conv})$,respectivly its height, with and depth.”，这句很含糊，因为前面提到了，高度已经被卷集成1了，第7也的Table1图中的Block5输出为1，也表明了这点，但是这里有提到了所谓的$h_{conv}$，很矛盾啊？！而且，Fig7中的这张图也没有把高度画成1。

他的Conv用了backbone的网络，我看Table6中，尝试了VGG和ResNet，我是自己搭了一个网络，当然也不是自己啦，是照抄了CRNN的Conv网络部分，但是是从头自己训练的，是不是应该借鉴一下，使用vgg或者resnet初始化呢？鉴于我不收敛的悲惨现状，确实应该去尝试一下。

解码器上有点意思，他用了一个bi-RNN，注意啊，是decoder，encoder也用了，但是这里是decoder。然后他会前向解码一次，后向解码一次，然后各自$\sum$一下，谁大就用谁的答案，这个做法挺有意思。注意，他不是挨个字比较，挑概率高的字，而是整个解码结果sum后比较。所以，他的lost也是逼着前后解码都要好。这个玩法，很有意思。他的Table5，也比较了一下，bi-RNN确实比单向RNN效果要好一些。

### 训练细节

他说了，2天才收敛的，大概是用了100万batchx64张图片，6400万张。使用的数据集包括Synth90K和SynthText，Synth90K是专门为识别训练合成的数据集，大概有900万张；SynthText是为了检测用的，数量我也没查，他们把文档给切出来用的。基本上每个batch，这两种数据一样一半。我看了图，差不多2万个batch以内是明显变化的，差的情况，4万个batch之内，也是明显变化的，这个和我自己写的那个网络不收敛是不一样的，555555。

他提到了个细节，他的图都是直接暴力resize成32x256的，像我那样，保持比例resize然后padding，他说效果反倒次，这个让我有点意外。不过他没又给出差多少的定量分析数据。

### 其他

他提到了，如果用aster的STN获得的变形矫正的点，可以帮助更精确地定位文字，也就是可以帮助提高检测的精度，这个思路也挺有意思的，不过我没有细看，回头有时间研究一下。

我的[Attention OCR](https://github.com/piginzoo/attention_ocr)，也是借鉴了这个思路，不过我没有用backbone的conv，而是照着crnn弄了一个，另外，我也没有用它的bi-rnn的decoder，我训练的过程就是不收敛，我tensorboard观察梯度直方图，根本梯度变化就是0，唉，究竟哪里出了问题呢？至少从他的论文上看，人家训练上来是慢慢收敛的，而不是一开始就跟我那个似的，不停震荡。

## 接下来说说FA（Focus Attention）

先贴论文：[Focusing Attention: Towards Accurate Text Recognition in Natural Images](https://arxiv.org/pdf/1709.02054)

2017.10的论文了，日期有点老，不过，我还是去啃了一下。

上来，他先抛出了“attention drift”的概念，大白话就是说，你解码的时候，你还原出编码器的对应位置，发现，根本不是要解码的那个区域，那还能解码的对啊？！

作者说，他们率先采用了Resnet做backbone，这个听着有点扯啊，anyway，有个预训练的应该是好的，CRNN还用vgg呢。他们还参考人家语音识别的ctc+attention的方法，失败啦。

作者说，传统的AN（attention network）不好train那种海量的样本集，比如800百万（我估计是笔误，是800万）的合成样本集。这句话，让一直train不出来自己撸的网络的我，稍感宽慰。

### FA网络


### 参考

- [图像文字识别初探(二)-FAN(Focusing Attention Network)](https://blog.csdn.net/weixin_42111770/article/details/84881558)

- [Focusing Attention Network（FAN）自然图像文本识别 学习笔记](https://blog.csdn.net/loadqian/article/details/80940924)

## TextScanner

核心就是三个图：

- Character Segmentation：W，H，Class（Class是字符集个数），这个用来分辨是哪个字符
- Order Segmentation：W，H，N（N是序列长度），这个是来分辨字符的从左往右的顺序
- Localization Map：W，H，1，这个是用来告诉那些像素是字符像素
	

### 网络结构

主要参考第3也的第3节:**3.Methodology**

![](/images/20200416/1587021816112.jpg){:class="myimg"}

开始是3个子网络的输出（Character Segmentation，Order Segmentation，Localization Map），后2个子网络输出（Order Segmentation，Localization Map）的结果还要合体（element-wise相乘）成一个新的结果（Order Maps），然后在来一次合体，即Character Segmentation和Order Maps合体，得到最后的Word Formation。

细节是，要搞清楚每个输出的维度：
- Character Segmentation：W，H，Class（Class是字符集个数）
- Order Segmentation：W，H，N（N是序列长度）
- Localization Map：W，H，1
- Order Maps：W，H，N
- Word Formation：？？？？？

#### Class Branch - Charachtor Segmenation（$G(w,h,class)$）

输入是backbone之后的feature，我没细想，应该是resize之后，但肯定是固定size的。
比如vgg，resenet输出都是224x224x3=>7x7x512，那这图会从32x256=>1x8。

所以，这个块是有问题的？！走不通了。

所以，我看了论文里提到了，是用了CA-FCN的结构来抽取feature，只不过是把VGG替成了Resnet50：
>Our model is built on top of the backbone from CA-FCN, in which the character attentions are removed and VGG blocks are replaced with a ResNet-50(He et al. 2016) base model.

这样理解的话，这个就是FCN后的结果，那和原图一样，是64x256。不过是这样的么？这个细节存在疑问？？？
>During training and inference, the input im- ages are resized to 64 × 256.

然后过2个卷积，然后过一个全连接，最后输出（w,h,c），比如（32，256，3370），c是字符分类个数，比如3770的一级字库数。
>The prediction module is composed of two stacked convolutional layers with kernel size 3×3 and 1×1. 

#### Geometry Branch - Localization Map（$G(w,h,1)$）

输入是backbone之后的feature，文中没有提，只是提到了过一个sigmod，所以我推测，是不需要再像Class Branch再过2个卷积的，而是直接Sigmod了。

但是，有一点，我假定backbone抽取出来的是256的维度的，但是，256维度是没办法过sigmod的，必须要变成一个值，才可以算出单个点的sigmoid值来，
所以至少需要过一个全连接啊，所以，我推测，这里需要一个全链接，参数是256x1，这样（w,h,256）x（256，1）=> （w，h，1），然后再过sigmoid函数，
得到了Localization Map（$G(w,h,1)$）。

TODO:这个细节不知道推测的对不对，需要去问一下原论文作者？？？

这些需要停一下，我们得到的G到底是个什么鬼？

是在每个点上计算了概率，我理解是是不是文字的一个概率，这张图就能确定哪些点是文字，那些点是背景。

#### Geometry Branch - Order Segmentation（$S(w,h,N)$）

![](/images/20200415/1586943957097.jpg){:class="myimg"}

这个是最复杂的一个了。

这个很像一个U-Net，3个上卷积（越卷越小）：上卷积变成1/2大小，16应该是卷积核，也就是输出的通道数；然后再来，1/4，32；1/8,64。
为什么会变小？我猜可能是stide是（2，2）的原因吧？？？

然后过一个RNN，维度不变，这个RNN应该隐层个数应该是64，这样才可以保持输出通道数不变。
RNN这块，需要把[h,w,c]=>[w,h\*c]，主要是为了让他成一个保持左右顺序的序列。 

然后再下卷积（越卷越大），第1、2下卷积的后，要融合一下左面上卷积的结果后。
上采样，融合，上采样，融合，上采样，融合，上采样，最后得到一个feature map，大小应该是原图的大小w，h，但是channel数多少，这个可能得自己设计。
但是，在输出之前，得过两个卷基层，然后输出（w，h，N）的结果。最后这个N，是可以由最后一个卷积核的个数的来控制的。
>Following the upsampling path, two convolutional layers are employed to generate the order segmenta- tion maps S。

最后把S（w,h,N）softmax一下。

接下来，要计算Order Map（H）了：

就是把Localitation Map（S - w,h,N）和 Order Segmentation（Q - w，h），两个东西做element-wise乘法，就是对应位置相乘，
成完后，你就得到了N个 w,h的 feature map。也就是H。其中每个w,h形状的图，就是上图中说的$H_k k\in(1,N)$。

这里有个细节， Order Segmentation（Q - w，h）是经过sigmoid计算的，Localitation Map（S - w,h,N）是经过softmax计算的，
他们相乘了，得到了的数应该会非常小，比如在某个点上，sigmoid计算的Q的值，softmax计算的S值，相乘，会变成更小的一个数。

然后，就得到了Order Maps的热力图H（h,w,N）

#### Order Map - H（h,w,N）

这个图表示了啥含义？

还记得前面说过，Order Segmentation（S）代表字符的顺序号，Localization Map（Q）代表一个点是不是文字，那两个“合体”后呢？

每张热力图 Order Map $H_k$就对应一个位置，这张$H_k$里面的像素，就表示这个像素上，是不是一个文字点。

### 最后大合体 Word Formation了

最后，我们还差是哪个字符的信息，他在 Charactor Segmentation（G）中，所以，要在再做一次element-wise（就是对应像素）的乘，这次相乘的是G和$H_k$，挨个乘，得到N张图。

N就是字符的个数，论文里面是提到了N是设成30，也就是最多支持30个字符。

最最最后，我们对每张（注意！是每张），做一个积分：

$p_k  =  \int_{(x,y)\in\Omega} G(x,y) * H_k(x,y)$

来，观察这个积分，特别神奇：

$G(x,y)$是一个$(h,w,C)$的东东，是个三维的，而$H_K(x,y)$是一个一维的，你是把要把这个一维的和三维的相乘后，求积分，就是求和啦，得到一个数，是一个概率值。

发挥你的想象力，$H_k$表示的是第k个位置的情况，里面的点上是sigmoid概率值，是不是前景的值，你可以理解成一个蒙版，蒙在$G$上，关键的来，G是啥来着？
G是每个点可能是某个字符的概率呀，你$H_k$虽然给我规定了很多前景的点，但是这些点不一定都是一个字符，所以这个你求的时候，是大家相当于一起来投票一样。

最终，你得到的是一个维度为C（字符集个数）的概率向量，是不是归一化，我有点想不清楚了，但是看论文上说的意思，应该是。

然后你挑一个最大的，就是这个位置上，的字符。

### 关于损失函数

第四页的公式（4）给出了损失函数：

$$L=\lambda_l * L_l + \lambda_o * L_o + \lambda_m * L_m + L_s$$

好，我们分解开每个子loss，挨个说：

第一个：$L_l$，对应着localization map（Q）的损失，那么localization map是啥来呢？再回忆一下，是这个点是不是文本的概率。

第二个：$L_o$，对应的是Order Map（H）的损失，order map是啥来着？回忆一下，是每个位置上，对应的每个点是文本的概率。

第三个：$L_m$，是互训练的时候的损失，没研究呢，回头补上。

第四个：$L_s$，对应的是Sgementation Map（G）的损失，segmentation map是啥来着？回忆一下，是每个像素，是某个汉字的概率。

好了，我们看到，这些都是概率，那典型的就是

### 关于训练样本



## 附录：优秀的OCR分享

跟文章主题无关，不过，顺道揉到此贴中吧，都是网上优秀的OCR的分享。

- 一个不错的视频：[https://www.bilibili.com/video/av73805100?p=7](https://www.bilibili.com/video/av73805100?p=7) 腾讯云培训上一个女的讲的。
- 我买的july的ocr识别的课程：[http://www.julyedu.com/video/play/136](http://www.julyedu.com/video/play/136)，
- [阿里读光OCR那个女的分享](https://yunqi.aliyun.com/2018/shanghai/review?spm=a2c4e.11153940.blogcont603444.8.5e612cfblAaE9b)，剔除了低频字识别的方法
- 旷视的姚聪的视频：[http://www.mooc.ai/open/course/605](http://www.mooc.ai/open/course/605)
- 旷视最近的一个分享：[https://www.bilibili.com/video/av83837791?t=1889](https://www.bilibili.com/video/av83837791?t=1889)
- [百度小哥的一个分享](https://mp.weixin.qq.com/s/z5hRafxepA4Zj5pbbK8HzA)
- [Valse的学术视频](https://www.iqiyi.com/v_19rvi9r9mo.html#vfrm=8-8-0-1)，[对应的ppt](http://valser.org/webinar/slide/index.php/Home/Index/index/dir/20191017.html)
- 白翔老师的的一系列文章分享：
    - [华科白翔教授团队ECCV2018 OCR论文：Mask TextSpotter](https://mp.weixin.qq.com/s/P80VlmxoWLQ3Ut3tJvRNNQ)
	- [白翔：复杂开放场景中的文本理解](https://mp.weixin.qq.com/s/4Tj92Mmj2-zOHfk1Tk167w)
    - [图像OCR年度进展 VALSE2018之十一](https://mp.weixin.qq.com/s/0ysaJGNslckesv21o752FA)
    - [白翔：趣谈“捕文捉字”-- 场景文字检测 VALSE2017之十](https://mp.weixin.qq.com/s/Y7Xpe1DlhGR9XRB7GunGnA)
- 更早的一起：[https://www.iqiyi.com/w_19rsxii7cp.html](https://www.iqiyi.com/w_19rsxii7cp.html)，不过有点老2014的，参考用。
- CSIG文档图像分析与识别专委会，这个公众号非常赞
- [SFFAI58-文本识别专场，讲了TextScanner，白翔的学生讲的](https://www.bilibili.com/video/BV1Gt4y127S6?t=3319)
- [金连文-基于深度学习的文字识别](https://www.bilibili.com/video/BV1SE411Y7d2)
- [旷视x北大《深度学习实践》之文本识别](https://www.bilibili.com/video/BV1E7411t7ay?p=14)，姚聪讲的，2节课，很系统

