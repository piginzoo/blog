---
layout: post
title: 从Word2Vec到BERT
category: machine-learning
---


### 从Word Embedding到Bert模型

这篇文档主要是受[从Word Embedding到Bert模型—自然语言处理中的预训练技术发展史](http://www.zhuanzhi.ai/document/908b7558689d219ea456210f9aedb9f3)启发，来梳理这条路线上涉及到的word2vec,glove,attention,transformer,elmo,gpt,birt等一系列概念。

这篇文章的一些摘要：

        Word Embedding矩阵Q其实就是网络Onehot层到embedding层映射的网络参数矩阵。所以你看到了，使用Word Embedding等价于什么？等价于把Onehot层到embedding层的网络用预训练好的参数矩阵Q初始化了。这跟前面讲的图像领域的低层预训练过程其实是一样的，区别无非Word Embedding只能初始化第一层网络参数，再高层的参数就无能为力了。下游NLP任务在使用Word Embedding的时候也类似图像有两种做法，一种是Frozen，就是Word Embedding那层网络参数固定不动；另外一种是Fine-Tuning，就是Word Embedding这层参数使用新的训练集合训练也需要跟着训练过程更新掉。

        Word Embedding头上笼罩了好几年的乌云是什么？是多义词问题。word embedding无法区分多义词的不同语义，这就是它的一个比较严重的问题。

        对近义词，ELMO提供了一种简洁优雅的解决方案，ELMO是“Embedding from Language Models”，ELMO的本质思想是：我事先用语言模型学好一个单词的Word Embedding，此时多义词无法区分，不过这没关系。在我实际使用Word Embedding的时候，单词已经具备了特定的上下文了，这个时候我可以根据上下文单词的语义去调整单词的Word Embedding表示，这样经过调整后的Word Embedding更能表达在这个上下文中的具体含义，自然也就解决了多义词的问题了。
        https://www.jianshu.com/p/a6bc14323d77

        Bert采用和GPT完全相同的两阶段模型，首先是语言模型预训练；其次是使用Fine-Tuning模式解决下游任务。和GPT的最主要不同在于在预训练阶段采用了类似ELMO的双向语言模型，当然另外一点是语言模型的数据规模要比GPT大。

        Bert本身在模型和方法角度有什么创新呢？就是论文中指出的Masked 语言模型和Next Sentence Prediction。Masked就是，随机扔掉15%的词让丫预测；NextSentence是让他预测后一句(随机找的）是不是真的是第一句的后续（因为有真实的后一句的对比）。

        Bert的输入部分，也算是有些特色。它的输入部分是个线性序列，两个句子通过分隔符分割，最前面和最后增加两个标识符号。每个单词有三个embedding:位置信息embedding，这是因为NLP中单词顺序是很重要的特征，需要在这里对位置信息进行编码；单词embedding,这个就是我们之前一直提到的单词embedding；第三个是句子embedding，因为前面提到训练数据都是由两个句子构成的，那么每个句子有个句子整体的embedding项对应给每个单词。把单词对应的三个embedding叠加，就形成了Bert的输入。

$\color{red}{}$

## Attention

之前的就写过一篇关于word2vec的[文章](/machine-learning/2018/01/20/rnn-lstm-attention)，提到过attention，这里需要在复习一二：



```
Attentin机制的发家史
Attention机制最早是应用于图像领域的，九几年就被提出来的思想。随着谷歌大佬的一波研究鼓捣，2014年google mind团队发表的这篇论文《Recurrent Models of Visual Attention》让其开始火了起来，他们在RNN模型上使用了attention机制来进行图像分类，然后取得了很好的性能。然后就开始一发不可收拾了。。。随后Bahdanau等人在论文《Neural Machine Translation by Jointly Learning to Align and Translate》中，使用类似attention的机制在机器翻译任务上将翻译和对齐同时进行，他们的工作算是第一个将attention机制应用到NLP领域中。接着attention机制就被广泛应用在基于RNN/CNN等神经网络模型的各种NLP任务中去了，效果看样子是真的好，仿佛谁不用谁就一点都不fashion一样。2017年，google机器翻译团队发表的《Attention is all you need》中大量使用了自注意力（self-attention）机制来学习文本表示。这篇论文引起了超大的反应，本身这篇paper写的也很赞，很是让人大开眼界。因而自注意力机制也自然而然的成为了大家近期的研究热点，并在各种NLP任务上进行探索，纷纷都取得了很好的性能。
```
[引]
- [Attentin机制](https://zhuanlan.zhihu.com/p/35571412)
- [《Neural Machine Translation by Jointly Learning to Align and Translate》](https://arxiv.org/abs/1409.0473)
- [《Recurrent Models of Visual Attention》](https://arxiv.org/abs/1406.6247)
- [《Attention is all you need》](https://arxiv.org/abs/1706.03762)


[]![](/images/20181218/1545111900623.png)


`这张图里，得说明几点`

* 就是attention是每一次（啥叫每一次，就是没预测一个新的$y_i$）都需要生成一次
* 怎么生成呢？
    * 先是$s_{i-1}$和$h_j$搞一下，$s_{i-1}$是$y_{i-1}$的隐含层输出啊，$h_j$是encoder中的某个隐含层输出啊，呵呵，俩隐含层输出搅到一起
    * 然后每个$h_j$都和这个$s_{i-1}$搞一下，然后归一化成softmax：$\alpha_{ij}$，注意一下，下标$i$ 是不变的，$i$是decoder的第几步
    * 然后，用每个j的softmax值$\alpha_{ij}$，再乘以$h_j$，得到这个$\color{red}{注意力}$$c_i$
    * 最后，把这个$c_i$ + $y_{i-1}$ + $s_{i-1}$，三个一搞，搞出最后的$y_i$，论文里面提到了还有一步，这里写出来，$s_i=f(s_{i-1},y_{i-1},ci)$
    * 最最后，我们要的就是$y_i = p( y_i \| y_1, ... , y_{i-1} , s_i )$

总结一下，就是，decoder的每一步，都要全面扫描所有的输入(encoder)中的每个元素，来得到一个注意力值，参与最后的decoder结果判定。    

这里要复习一下attention，主要是，接下去讨论的transformer中的attention，被作者做了一个变形，引入了K (( Key)) ,Q ((Query)),V((Value))的概念，很晕，这里把原有的attention，朴素的讲解过一遍，方便后面最对照。


## Transformer

好，说transformer了，第一次是由谷歌6位大神在经典文章[《Attention is all you need》](https://arxiv.org/abs/1706.03762)提出的概念。

下面还有些中文小文，供参考：
- <https://zhuanlan.zhihu.com/p/34781297>
- <https://www.jianshu.com/p/3f2d4bc126e6>
- <http://nlp.seas.harvard.edu/2018/04/03/attention.html>
- <https://jalammar.github.io/illustrated-transformer/>
- <https://www.jianshu.com/p/3f2d4bc126e6>
- <https://jalammar.github.io/illustrated-transformer/> 陈楠推荐的一篇e文的

都不如这篇讲的最好：

<https://kexue.fm/archives/4765>

卧槽！这篇讲的真好，讲出了很多insight:

* RNN无法很好地学习到全局的结构信息，因为它本质是一个马尔科夫决策过程。
* 所谓“多头”（Multi-Head），就是只多做几次同样的事情（参数不共享），然后把结果拼接。
* 如果做阅读理解的话，Q可以是篇章的词向量序列，取K=V为问题的词向量序列，那么输出就是所谓的Aligned Question Embedding。
* 在Google的论文中，大部分的Attention都是Self Attention，即“自注意力”，或者叫内部注意力。
* 所谓Self Attention，其实就是Attention(X,X,X)Attention(X,X,X)，XX就是前面说的输入序列。也就是说，在序列内部做Attention，寻找序列内部的联系。
* 它表明了内部注意力在机器翻译（甚至是一般的Seq2Seq任务）的序列编码上是相当重要的，而之前关于Seq2Seq的研究基本都只是把注意力机制用在解码端
* Self-Attention模型并不能捕捉序列的顺序！换句话说，如果将K,V按行打乱顺序（相当于句子中的词序打乱），那么Attention的结果还是一样的。这就表明了，到目前为止，Attention模型顶多是一个非常精妙的“词袋模型”而已。（什么叫打乱顺序？？结果一样呢？？没理解）
* Google再祭出了一招——Position Embedding，也就是“位置向量”，将每个位置编号，然后每个编号对应一个向量，通过结合位置向量和词向量，就给每个词都引入了一定的位置信息，这样Attention就可以分辨出不同位置的词了
* 结合位置向量和词向量有几个可选方案，可以把它们拼接起来作为一个新向量，也可以把位置向量定义为跟词向量一样大小，然后两者加起来。FaceBook的论文和Google论文中用的都是后者。直觉上相加会导致信息损失，似乎不可取，但Google的成果说明相加也是很好的方案。看来我理解还不够深刻。
* 无法对位置信息进行很好地建模，这是硬伤。尽管可以引入Position Embedding，但我认为这只是一个缓解方案，并没有根本解决问题。举个例子，用这种纯Attention机制训练一个文本分类模型或者是机器翻译模型，效果应该都还不错，但是用来训练一个序列标注模型（分词、实体识别等），效果就不怎么好了。那为什么在机器翻译任务上好？我觉得原因是机器翻译这个任务并不特别强调语序

视频讲解的，好像国内还没有，只有油管上有个<https://www.youtube.com/watch?v=iDulhoQ2pro>，B站上也是转的这个，你就不用遍大街再找了，不难，听一遍大致就明白了。

![](/images/20181218/1545116998474.png){:width="30%"}

* 典型的翻译场景里，原文（英文）是左面的输入(input embedding)，而翻译出来的（中文）是右面(outputs embedding)的输入

#### 说说Attention

这里，attention变成了这个样子：

最左面是一个基础的attention，然后聚合起来就成了Multihead Attention了，然后这个 Multihead Attention才组成了Transformer。

![](/images/20181218/1545118005270.png)

* 在上面提到的翻译“I am watching cat eating.”的场景里：Key,Value,Query怎么理解呢？
    * 我理解的

陈楠给的这篇讲Transformer的真好，虽然是e文的，讲的恨透：
<https://jalammar.github.io/illustrated-transformer/>

        Don’t be fooled by me throwing around the word “self-attention” like it’s a concept everyone should be familiar with. I had personally never came across the concept until reading the Attention is All You Need paper. Let us distill how it works.

文中的这两张图真的很帅，可耻地盗链了：

![](https://jalammar.github.io/images/t/transformer_decoding_1.gif){:width="60%"} 

---------

![](https://jalammar.github.io/images/t/transformer_decoding_2.gif){:width="60%"}

一图，还TM的是动图，一言不合就上图，胜千言啊~~~
- 看，貌似输入算一遍之后，就再也不用了，不像之前的attention，还要不断地使用$s_{i-1}$，[ ![](/images/20181218/1545132114347.png) ]，看，每次算注意力，还都要扯上decoder的内容。现在呢？一次算完encoder内容，形成K、V。然后就不用折腾了，以后的decoder都用这个K、V

问题：beam search的时候，输入下一个的$y_i$应该用哪一个，是beam search出来的那个？还是概率最大的那个？

BERT
===========
http://www.zhuanzhi.ai/document/e723926b9bc236ee6e636600eae5982a