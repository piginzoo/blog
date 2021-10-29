---
layout: post
title: 如何评价分类
category: machine-learning
---

# 上来先抛出一堆词，炸死你

- Recall
- Precision
- TPR
- FPR
- 准确率 （Accuracy）
- 混淆矩阵 （Confusion Matrix）
- 精确率（Precision）
- 召回率（Recall）
- 平均正确率（AP）
- mAP（mean Average PrecisionmAP）
- ROC
- AUC

好，都是评价分类效果的词，估计面试的时候，把这些顺序问一遍，就可以干掉90%的面试者。
大部分人估计对这些词都知道，也大概知道啥意思，但是你要是把这些细节都掰吃清楚、清清楚楚，
可不是那么容易。

我倒不是为了面试，主要是实际工作中，不对这些基础、细节概念了如指掌，我没法客观评价我的模型效果啊。
比如人脸识别的时候，为何用AP，而不是用AUC来做为评价标准。所以把这些概念和细节，搞的清清楚楚，就是必须的了。

接下来，我挨个用大白话捋捋这些概念。

# 一堆概念来袭

其实，为了把握这一堆词，我们主要把握住几点核心，就可以把握住他们了：
- 你关注负类么？
因为二分类的时候，你可能不是光关注正类，可能也非常关注负类，这样，就要“平等”对待它们。
但是对目标检测的情形，你更关心的正类，你是带着“偏见”的，体现在指标上，也是有区别的。


## TP、FP、FN、TN

- TP	你预测的正例里面，那些真的正例
- FP	你预测的正例里面，那些假的正例（人家其实是真负例）
- FN	你预测的负例里面，那些假的负例（人家其实是真正例）
- TN	你预测的负例里面，那些真的负例

## 准确率 - accuracy

你全面关注“正类”和“负类”的预测“好不好”:

（ 你预测对的正例+你预测对的负例 ）/ 样本总数

$\begin{equation}\label{equ:accuracy} \mbox{accuracy} = \frac{TP+TN}{TP+TN+FP+FN} = \frac{TP+TN }{\mbox{all data}} \end{equation}$

## 精确率 - precision（查准率）

你重点盯着**“正例”**了，你看**“标签GT”**里的正例里，多少被你正确“发现”出来了：

$\begin{equation}\label{equ:precision} \mbox{precision} = \frac{TP}{TP+FP} = \frac{TP}{\mbox{预测为positive的样本}} \end{equation}$

## 召回率 - recall（查全率）

你还是重点盯着**“正例”**了，你看你自己**“预测”**的正例里，多少是真正正确的：

$\begin{equation}\label{equ:recall} \mbox{recall} = \frac{TP}{TP+FN} = \frac{TP}{\mbox{真实为positive的样本}} \end{equation}$

## F1值

你还是重点盯着**“正例”**，你想平衡一下precision和recall，看看两人都好，才是真好！

为何？为何要两人真好才是真好？因为，我可以造假啊。

比如我为了把recall高，那我都预测成正例就好，肯定recall=100%了；同理，为了造假precision，我尽量都预测成负例，只有特别确信的才预测成正例，我能把precision做到很高。
所以为了平衡他俩，就调和出F1：
$
\begin{equation}\label{equ:f1} F_1 = \frac{2}{\frac{1}{\mbox{precision}}+\frac{1}{\mbox{recall}}} = \frac{2 \cdot \mbox{precision} \cdot \mbox{recall}}{\mbox{precision}+\mbox{recall}} \end{equation}
$

## ROC

二分类的时候，你是通过一个置信度阈值，来一刀切出正例和负例的，这个置信值选择不好，对最终结果影响还是很大的。
一般大家都选0.5，但是你可能选0.4，正例、负例分的更好，所以，光一刀切成0.5，对评价一个分类器好不好不公平啊，

咋办？用ROC曲线！

既然不能光看0.5，甚至0.4，那我就把0.1，0.2，...，0.9，都看一遍吧，
然后，我还不能光看正例的，我还得看负例的，两边都要平衡着看，
所以横坐标就是负类的召回率（不过用的是1-负类召回率），纵坐标用的是正类的召回率，
这样，每个阈值（0.1，0.2，...，0.9）都会对应出一个正类recall和一个（1-负类recall），形成一个坐标点，
这些点挨个画出来，就形成一个曲线，这个曲线就是ROC。

这个ROC下的面积，就是评价你这个分类器的整体状况的重要指标。（为何是面积？！我没有去细想和证明，以后有时间再琢磨吧）。

![](/images/20211028/1635388674348.jpg){:class="myimg100"}

**纵坐标True Positive Rate（TPR）**，其实就是正类的召回率：$recall_+$。

$$
\begin{equation}\label{equ:tpr} 
\begin{split} 
\mbox{TPR}  &= \frac{TP}{TP + FN} \\  
&= \mbox{recall$_{positive}$} 
\end{split} 
\end{equation}
$$

$$

**横坐标False Positive Rate（FPR）**，其实就是1-负类的召回率：1-$recall_{\-}$。

\begin{equation}\label{equ:fpr} 
\begin{split} 
\mbox{FPR} &= \frac{FP}{FP + TN} = \frac{FP + TN -TN}{FP + TN} \\ 
&= 1 - \frac{TN}{FP + TN}  \\ 
&= 1 - \mbox{recall$_{negative}$} 
\end{split} 
\end{equation}
$$


## 混淆矩阵

### 多分类混淆矩阵


## AP

## m-AP



总结一下，

ROC是对二分类的，兼顾了对模型正类和负类判别能力的评价，而且，也考虑了不同置信阈值的影响的一个相对公平的评价方法。

# 参考

- [混淆矩阵、准确率、精确率/查准率、召回率/查全率、F1值、ROC曲线的AUC值](https://www.cnblogs.com/wuliytTaotao/p/9285227.html)
- [深入介紹及比較ROC曲線及PR曲線](https://medium.com/nlp-tsupei/roc-pr-%E6%9B%B2%E7%B7%9A-f3faa2231b8c)
- [分类、目标检测中的评价指标](https://zhuanlan.zhihu.com/p/33273532)
