---
layout: post
title: 知识图谱
category: machine-learning
---

`自己的一些零星的关于知识图谱的笔记，比较散，放到网上，备忘用。`

#### 小象学院 - 王昊奋老师的《知识图谱》笔记

第一课

	Palantir：神秘独角兽，提出了动态本体建模方式
	Kensho：金融口的一个著名的知识图谱
	自然语言理解系统：SHRDLU - 的作者Terry Winograd搞的一个比赛：
	Winogard schema challenge:一个比SODUA专业的理解比赛：
	纯NLP：50%，NLP+KB：60%+，及格线要达到90%，真人才满意。
	图匹配，
	NP hard
	memex，
	推理补全，
	cyc：50w terms，700w Assertion
	conceptNet: 三元组
	先用pattern，直接抽取，抽取后在作为已知样本，再去学习，发现新的patterns，这种叫bootstrap方法。
	描述逻辑：基于一阶查询重写的方案、产生式规则的算法、Datalog转化

第二课 知识表示和建模

	OWL:在RDFS基础上，支持复杂概念描述，和属性约束
	OWL的词汇是否可以用来描述付钱拉业务？
	医疗的用OWL EL，适合做概念多，实例少的场景

	答：据我所知，没有用OWL来做工业知识图谱，基本都是RDF(s)+规则来完成实际的需求的。
	不过在国外医学领域，会有OWL构建的本体，也是很轻量级的OWL语言。例如SNOMED-CT

	通过本体推理，可以改写SparkQL，
	通过规则来改写 SparkQL

	问：像schema层的构建，那些上下位关系，，有自动化构建的方法么？ 或者说节省人工成本的方法
	答：schema层的上下位关系构建，有半自动的方法。全自动精度太差了，论文灌水可能还行。

	答：规则可以看出是if then语法。规律看起来简单，不过当你管理上千条规则的时候，就不是一件容易的事情了。另外还要保证其推理的高效性。

	SPARQL可以做跨知识库查询，而且很简单，参考老师的新药的查询。

	PlantData是胡芳槐博士研发的知识图谱的平台，做得还是比较早的。文因互联重点在金融领域，领头人鲍捷确实很厉害，博后导师就是在MIT跟着Tim Berners-Lee做研究的。

	Neo4j property graph

	JoyJedi钟敬德21:48:09
	schema层半自动化的构建方法，，老师有文章推荐么
	直播答疑老师21:52:59
	图谱构建的话，yago和BabelNet可以了解一下。不过可能对你行业需求用处不大。垂直领域，现在主要还是人工构建schema的方法居多。

	问题：
	业界的，不如明略的知识库用的是titan，他的难点在哪里？
	问句映射成sparkql有啥好方法？

	直播答疑老师20:24:55
	知识图谱里用"属性"或者"关系"这样的术语比较多，"特征"这个术语在机器学习中用得较多，它们本质上没有区别。

	对于一个团队来说：需要有人熟悉本体或者知识图谱的表示形式，这里表示形式不仅仅指的是三元组，而且抽象层面对概念与属性的刻画能力，即图谱的Schema。需要有人掌握图的存储，至少要掌握一门图数据库或者能有效存储三元组的关系型数据库例如neo4j或者AllegroGraph。对于数据是非结构化或者半结构化的情况，还需要有熟悉NLP技术的工程师对数据进行处理，抽取出结构化的数据，甚至需要对多个图谱进行融合。最后，基于图谱的推理，需要有人熟练掌握开源的规则推理工具例如Drools或者Jena。《知识图谱》这门课程都会对上述知识点以及相关的应用进行讲解，并附有一定的实践作业来帮助大家来理解，希望大家能够学以致用。实践出真知！

	生成问题模板
	DSM，孪生网络
	LTP，依存分析，耗时大，online避免使用，
	主要还是靠词向量，句法分析在线用的不多，离线才会用用。
	neo4j的property graph
	Datahub


第三课 知识抽取

	htlm5,macromark,
	抽取什么：三元组，事件和时序信息
	从现有知识库中通过图映射里面提到的“数据对齐”是什么概念?
	从半结构化转知识，需要包装器，我理解就是一个爬虫和解析程序。
	从文本抽取，难点在准确率和覆盖率？这两个概念需要进一步理解。。。
	非结构化抽取一般都在特定领域，开放领域太难了
	一般抽取分为几个子任务：
	        - 命名识别，实体检测，识别的时候就会涉及到分类，比如库克是一个人物，
	        - 术语抽取，从预料中获得相关术语
	        - 关系抽取，二元关系，实际上就是三元组，比如 王建林---<父子关系>---王思聪
	事件抽取：
	        一般有个触发词，事件关系是个多元关系，事件的属性，有个特殊的词，叫slot，说白了就是事件的各种属性。？？？问题：这个slot是事先人为给定的么？
	        还有长句中，还要指代消解，比如前面提到特朗普，后面的他，就是指特朗普
	美国有一对竞赛、组织来规定知识抽取都包含那些子任务：
	        MUC竞赛和数据集；ACE竞赛；KBP任务标准；SemEval；
	            MUC比较老了，ACE有5个任务，比MUC多
	            NER - 命名实体识别
	            CR - 共指消解
	            （以下是ACE的任务）
	            数值检测和识别
	            时间表达检测和识别
	            关系检测和识别
	            事件检测和识别
	            （以下是TAC的KBP任务）
	            实体发现和链接（链接就是要把实体链接到存在的知识库里的概念URI/ID）
	            槽填取 - 这个其实就是事件的各种属性的填充
	            信念和情感
	老师说了一下他的知识抽取的任务分类，其实和米国这些人规定的差不多：
	        人名、组织机构、地理位置、时间日期、字符值、金额值
	        问题？？？就这些么？这个知识范畴是自动扩充么？                 
	要找的话，老师说可以使用机器学习的序列标注，就是通过学习的方法，来可以区别出来哪个词是要抽取的内容，我的理解。用HMM、CRF、LSTM+CRF等机器学习方法，来生成lable序列，序列就是组织呀还是地点还是上面提到的属性，老师提到了IOB，IO标注体系。
	实体链接，就是连接到知识库去，比如连接到schema.org上的rdf:type，确定概念后，还要去某个音乐KG中找到对应的这个歌曲的实例。
	http://www.opencalais.com/opencalais-demo/ 这个可以直观感受一个商业实体识别的效果，calais是一个商业的实体识别的服务，被路透买了。其他的老师说的开源的都不怎么样。
	关系抽取：
	    基于触发词的模板来抽取，这种只是词法分析。
	    基于依存的句法分析，分析出来动宾，主谓啥的，这样的模式可以识别出非连续的词之间的关系。往往以动词为起始点。
	事件识别
	    都是使用各类分类或者深度学习的方法，使用pipeline方法 ，也就是分解成触发词识别->元素分类器->属性分类等一步步深化识别。深度学习提到了一个叫“动态多池化CNN”的方法。
	-------------------------
	关系数据库到知识库的映射，w3c有个标准叫r2rml,(relation to rdf)
	表映射成类，列映射成属性，每行可以对应一个实体URL，外键映射成关联。
	有个软件ontop，可以帮助把数据库映射成rdf，实际上他叫virtual rdf，也就是依存关系，这样一个sparql查询，就会通过这个映射，直接映射成SQL。
	-------------------------    
	半结构化数据抽取，
	对于百科类，一般都会有一个infobox（信息框），然后可以直接和百科类定义好的实体概念进行自动匹配关联上，直接拿过来用。
	zhishi.org就是一个应用，他从百度百科、维基百科（中文）和互动百科上，抽取来的。
	------------------------
	纯网页的信息抽取，这个其实和爬虫中使用xpath来抽取，或者css选择器。
	这xpath也可以通过机器学习和标注数据，
	讲了一下webtable抽取，类似于数据库的抽取。

	时间抽取，有意思，看看有啥好的实现么？
	Schema.org 上有更多分类，700+，比一般的NER类别多多了。
	AllegroGraph，RDF4J等可以使用 - RDF数据库
	https://www.w3.org/wiki/LargeTripleStores

	实体消岐 一般用graph mining的算法 比如pagerank等 这里推荐一篇中科院韩先培老师论文 可以看一下 Collective Entity Linking in Web Text：A Graph-Based Method

	关于英文知识扩充中文知识 可以去看一下清华大学XLORE的工作http://www.xlore.org/

	http://www.doc88.com/p-3714999282595.html ;一种准确高效的领域知识图谱构建方法 杨玉基 之前答疑老师给的这篇文章感觉不错

	远程监督：


	JoyJedi钟敬德21:42:30
	上周看过一篇文章，就是结合GAN和远程监督做关系抽取，文章倒是说准确率蛮高的，还没时间复现试试

	ontop工具
	apache Tidy工具

第四课 知识抽取 2

	KBC，知识系统构建，
	从一句话，抽取出mention，然后到entity的对应过程叫做entity linking
	deepdive就是这样的一个KBC，构建工具，完成了很多牛逼的工作：文本预处理、统计推理和学习、特征抽取等等。
	ddlog文件是deepdive的主要文件，里面有一种类dblog的语言来表达，
	deepdive只关心关系的抽取，对于mention抽取，他依赖于斯坦福的nlp工具来做的实体的抽取，
	斯坦福的nlp工具可以帮助抽取，ORG，Person，Location等等9种。
	----------------------------------
	用deepdive来抽取，整个过程分几步：
	1. 先导入先验数据？为何呢？这个可是先验知识，就是已经明确了的关系啊，怎么用，下一步，留作问题？
	2.把文章导入，对他进行分词，词性POS，词法分析，实体识别NER，把它分析完后的导入到postsql中，得到的实际上是一堆字符串。
	3.抽取mention，mention的概念，我理解就是把实体更明确成mention的概念，就是对应的要分析的这个需求里明确的实体
	4.候选实体“对”生成，其实就是找到一句话里出现的两个公司，为下一步做准备
	5.下一步，就是抽关系了，输入就是刚才2-4中已经抽取的句子分析结果和实体对，输出就是特征
	    ddlib.span===》feature；用机器学习或者深度，来学出各种特征，比如前后的词的序列，这块其实没有完全理解，是找到哪个词是关系词么？是个位置确认的过程？
	（老师说，是靠Distant supervision：远监督。弱监督也称为远监督，数据集的标签是不可靠的(这里的不可靠可以是标记不正确，多种标记，标记不充分，局部标记等)，针对监督信息不完整或不明确对象的学习问题统称为弱监督学习。）
	6. 样本打标，就是用之前1中的正确的打标的数据，来训练，不过我理解是训练判断是否是关系，2分类问题，并给每个类一个置信度，大白话就是“看看俩实体是否有关系”，不过这玩意是可训练的么？其实，我理解是不关心关系到底是什么，而是关系，他们俩（实体）间是否有关系。
	就是确定/标注的数据+文章里的数据，一起训练，感觉远程监督就是这么一种训练。具体还是不明白。
	7.因子图构建，查了，是概率图的一种模型，用于推导是否存在这样是不是一个交易
	（哦，我理解错了，这个例子中，是判断是否有交易关系，也就是说，关系不需要确认是什么，已经确认了，就是“交易”）
	为什么有用到gibbs采样了，晕了，这块完全没听懂。
	------------------------
	deepdive的实验
	------------------------
	做实验过程中：
	* ddlog用的语言是datalog：http://blog.csdn.net/tao_sun/article/details/17610591
	* 脚本中装postgersql不靠谱，我下了安装包直接装到mac上
	    db.url加上用户名：postgresql://postgres:chuang@localhost:5432/transaction
	* sbt是一个scala的build工具，文档中的sbt/sbt其实是sbt目录下的sbt，就是这个工具
	* 下一步去抽取mention，其实很简单，就是上一步的NER结果：ner_tags，从中找那么类型是ORG实体对应的字符串：
	    mention_text = "".join(map(lambda i: tokens[i], xrange(begin_index, end_index + 1)))
	* 总是报“IOError: [Errno 2] No such file or directory: 'company_full_short.csv'”
	   怀疑是路径错误，不知道为何找不到，试了半天，最后没办法，直接放到他的运行目录里了解决的
	    CNdeepdive/transaction/run/process/ext_company_mention_by_map_company_mention/
	    后面才看到这句话“（PS：此处如果报路路径错误，请将transform.py中company_full_short.csv的相对路路径改为绝对路路径。）”，唉，坑啊，想哭。
	* “实体抽取及候选实体对⽣生成”，这步才是对应出一行里的实体对，一对，有了这对，再判断这对是否有交易关系，别忘了我们想做啥，我们想找哪些机构之间有交易关系（关系是确定的，要牢记，这个是领域抽取和开放IE抽取的区别，老师专门强调过）
	* 下一步是，抽象这些实体在文中的上下文feature，这个应该是比较复杂的，对我来说我完全是黑盒，大概是学出实体词前后左右的各种feature，是一个窗口的概念，这些feature可以为后续的判例做准备
	* 下一步是，开始学习了，学习啥啊，就是是不是两方有交易：我们有两部分数据，一部分是第一步就搞来的国泰安的数据，相当于已经给了标签的样例数据；还有一部分是我们上上步找出来的transcation_candidate数据，就是我们自己剥离出来的一个个的实体对，而且都是ORG，我们认为他们之间可能是有关系的了
	function supervise over函数是为了先根据一些明显标志打出一些样本来，我理解就是我们先过一圈，用规则的方法，筛出那些容易识别的正例。
	这样，我们的数据就变成了3份，1份是国泰安的正例数据，1份是我通过规则可以确认的数据，1份是我们完全无法判断关系的数据
	* 再往下，完全进入迷惑状态了，我！感觉是把这些数据变成一种变量，然后交给因子图去推测，因子图是一种概率图模型，我还是第一次听说这种算法，看这个例子，用因子图就可以完成关系推断了，faint
	终于做完试验了，总结一下：
	     - 几个核心步骤是：用斯坦福工具抽取实体，抽取实体对在文章的上下相关features，最终使用因子图模型学出关系
	    - 还是模棱两可在理解上，但是收获是知道了整个关系抽取过程，斯坦福的工具如何使用，deepdive的大概工作流程，以及ddlog语言有了感性认识
	    - 未来如果

	因子图，

	查询实体引用表，这个方法是

	--------------------------------------
	传统领域IE，关系是确定的，但是开放IE，关系都不确定，需要你去查找，在上下文中去确认这个关系。
	第一代OpenIE，textrunner，依赖句法，第二代，reverb、ollie，clauseie等，更细化从句、动词短语更细复杂颗粒度处理。
	---------------------------------------
	知识挖掘：


第七课

	RDFox现在还维护的不错，KNOA2基本上不维护了，但是都是同一个作者
	推荐这个，是个半商用的，还开源的

	ABox，关系抽取，都属于
	TBox，人工建立的，

	tbox的人工建立很难完备和可满足，所以是先根据领域知识借助推理机建立完备的Tbox，然后再用关系抽取的方法从大规模数据中抽取Abox，对吗
	>推理机无法构建，可以用来做tbox

	人工建立一个TBOx，基于这个Tbox来抽取，从上到下，
	还有一种，bottom-up方式，自下而上，来构建abox，然后通过挖掘，来提取tbox。

	如何保证tbox人工构建的质量？
	需要专家，是否能满足需求。一定是需求驱动的，tbox的构建。

	其实老师课件里的例子是零散简单的，那么对于实际工程，没有专家造一个好的Abox，光从大量数据中抽取那么大的Abox，那么这样利用率会很低吧
	>从数据库直接转，或者，从百科来导入

	Tbox一般不大，abox可能会很大，

	我理解tbox就是owl的概念层，比如openkg的CNSCHEMA，有公司用它做bot呢

	RDFOx老师再次推荐，

	前向推理，一步步地来的，推理完的结果，可以存到数据库里，然后可以查询了就，
	但是，这样推出的可能会很多条，另外，可能会有些变了abox，
	解决办法，就是“查询重写”，属于后向推理，数据是不变的，
	Ontop，就是干这个用的，

	产生式规则，是一种前向推理，
	working memory，就是abox的集合，
	产生式规则，又叫production memory,PM

	RDF4j，之前打算商用的额，但是后来做呲了


	我22:19:26
	感觉一个jena就够了，又有本体存储，又有推理
	xzxsungd045122:19:51
	这些推理方法 那种最有优势呢？
	我22:19:55
	打算不用别的了，就只用jena做我们的项目了，呵呵
	>老师说，没错，可以，但是大规模数据还差点意思，没事，我数据不大

	从百科的关系图谱中连接到新闻中的实体，再去做关系抽取，
	用百科的实体库，省去了实体识别了，来做关系抽取。
	天鹅pxf22:25:15
	那关系是从哪里来呢
	>关系是自己定义的！你自己标注，然后训练，或者用模板。

	规则是不隐式蕴含在Tbox中的，所以才显示指定，对吗，是不是说专家既要定义Tbox又要定义推理规则，然后推理机根据“”Tbox + 规则 +土里算法“”推出来Abox中没有显示定义的东西
	>OWL中的规则是schema层就定义出来了，他之间的关系其实就是规则了，
	>当然你还可以再增加额外的rule规则
	owl的规则推理是一套，和rete那种的规则引擎如drools的推理是不一样的，2种不太一样。
	商业场景，推荐rdffox，既带owl推理，又带rule推理。

	infobox还是能得到一些概念的。

	问答一般得让人可信，所以都有有schema，无schema的。


王昊奋老师的课的笔记（某人写的），很不错=>[传输门](http://pelhans.com/tags/#Knowledge%20Graph)

#### Jena实践中的坑


[看了一个jena和virtuoso的对比](https://db-engines.com/en/system/Jena%3BVirtuoso
https://github.com/memect/kg-beijing/wiki/%E7%AC%AC%E4%B8%80%E6%9C%9Fw3%EF%BC%9A%E7%9F%A5%E8%AF%86%E5%AD%98%E5%82%A8)
不推荐用Virtuoso， Sesame，Jena这些。都是上一代的老产品，复杂不好用。

妈蛋的，每次停止fuseki-server后，再启动就报错：
按照这个说的，删除了prefix，但是在web里访问，数据还是出不来啊！！！崩溃啊。
<https://zhuanlan.zhihu.com/p/33224431>
看了一些帖子，发现，不靠谱，果断放弃。没工夫在这上面耽误工夫。
<https://github.com/memect/kg-beijing/wiki/%E7%AC%AC%E4%B8%80%E6%9C%9Fw3%EF%BC%9A%E7%9F%A5%E8%AF%86%E5%AD%98%E5%82%A8>
这篇帖子里面提到，我个人最喜欢的是OrientDB，我认为完美达到我需要的知识图谱数据库的基本功能要求 
- 1）用类SQL查询语法，降低学习成本 
- 2）直接读写JSON，方便和Web API导入导出 
- 3）支持图的遍历和gremlin查询 
- 4） 支持blueprints标准 
- 5）部署简单 
- 6）还在积极维护

一个栗子：

	PREFIX fql:<http://www.yixin.com/fuqianla>
	SELECT ?mobile
	WHERE {
	    fql:张三 fql:拥有电话 ?mobile.
	}

	查通话大于20分钟的人
	PREFIX fql: <http://www.yixin.com/fuqianla#>
	SELECT ?target_person  ?call_length
	WHERE {
	    fql:张三 fql:拥有电话 ?mobile.
	      ?mobile fql:通话记录 ?call.
	      ?call fql:通话记录 ?target_mobile.  
	       ?target_person fql:拥有电话 ?target_mobile.   
	      ?call fql:通话时长 ?call_length.  
	  OPTIONAL{
	    Filter(?call_length > 10)
	  }
	}
	出不来，感觉是因为，       ?target_person fql:拥有电话 ?target_mobile.   这种被查询出来的字段在前面是不行的，
	除非是       ?target_person fql:拥有电话 ?target_mobile.   

	不对！
	用事实证明了我的猜想是错的：
	PREFIX fql: <http://www.yixin.com/fuqianla#>
	SELECT ?person  ?call_length
	WHERE {
	      ?person fql:拥有电话 ?mobile.
	      ?mobile fql:通话记录 ?call.
	      ?call fql:通话时长 ?call_length.  
	    Filter(?call_length > 10)
	}



#### Neo4j实践

请教个问题，电话A———通话——— 电话B，

电话A\B是实体，通话是关系，现在想表达通话时长，就是想在关系“通话”上加一个时长，这种怎么用owl表达呢？哪位有这方面经验，不吝赐教。
貌似可以通过n-ary关系表达，<https://www.w3.org/2001/sw/BestPractices/OEP/n-aryRelations-20040623/> ，不过总是觉得别扭，比如 电话（实体）-------拨打（关系）------通话记录（实体）--------拨打（关系）-------电话（实体），然后再建立 通话记录（实体）上的一个属性，通话时长。感觉有些冗余。有没有更好得思路？
类似于这个问题：<http://wenda.chinahadoop.cn/question/10400>

neo4j可以解决这个问题：
    -[role:acted_in {roles:["neo","hadoop"]}]-> 
    访问某一类关系下的某个属性的关系的数据 

小象问答中的：
研发人员说用neo4j建知识图谱时，在不同节点设置不同结构，就是本体层了，不用再单独建本体层，对么？
<http://chuansong.me/n/2450423751225>
blank node 简单来说就是没有 IRI 和 literal 的资源，或者说匿名资源。关于其作用，有兴趣的读者可以参考 W3C 的文档，这里不再赘述。我个人认为 blank node的存在有点多余，不仅会给对 RDF 的理解带来额外的困难，并且在处理的时候也会引入一些问题。通常我更愿意用带有 IRI 的 node 来充当 blank node，行使其功能，有点类似 freebase 中 CVT（compound value type）的概念。

昊奋老师讲过freebase的cvt，就是干这个的，第二课P141页，Freebase的特性

不过，我看了貌似在owl里，只能靠一个空节点，或者x-ary方式插入一个中间实体来解决，其实我理解，CVT就是一个空节点或者中间实体了

这个讲RDF关系的，比如自反，唯一，对称啥的，不错：<http://www.unconstraint.cn/blog/kg2>,<https://www.cnblogs.com/bigdata-stone/p/9613800.html>

我操，neo4j的关系是没有方向的：<https://www.jianshu.com/p/a25a1907b926>,在Neo4j中，遍历关系的任何一个方向所需的时间是相同的。进一步说，方向可以被完全忽略。因此，当单向的关系可以同时代表另一个方向的关系的时候，没有必要同时创建两个方向的关系。    

看了之前的医疗的知识图谱，<https://github.com/zhangziliang04/KGQA-Based-On-medicine>,没啥用，是neo4j的，反倒是王昊奋老师的那个小例子是基于本体数据库和rofe正则式的，


<https://www.bilibili.com/video/av12246870/>

	无模式，随时可以修改他的schema，
	要干啥：
	本体学习
	* 术语抽取
	* 同义关系抽取
	* 概念
	* 分类关系学习
	* 非分类关系学习
	* 公理和规则
	实体层学习
	* 实体学习
	* 实体数据填充
	* 实体对齐

	信息从哪里来？
	开放知识库、本题库，如KG.cn、wikidata
	结构化数据，如公司的数据库
	行业知识库，如一些公开的行业结构化数据
	在线百科，如各类百科
	公开网站，爬取非结构化数据

	具体怎么做：
	从百度百科中，有分类，可以直接拿来用
	实体，都有对应的实体，摘要，可以提取

	什么是对齐：
	就是把外部知识和知识库中的概念做映射，比如又叫，别名，同义等，就是本体是一个

	上下位关系学习？
	就是子类、实例，比如刘创是人，或者灵长目是哺乳动物。
	怎么学习？
	从开放知识库中直接抽取，百科中的关系图，从语言模式中（X是Y的一种，X如Y，Z），CRF学习

	概念的属性如何学习?

	行业知识图谱构建：
	通用是自下而上，行业往往是自上而下，啥意思呢？就是行业可以从高层次，抽象层次，整体性上构建，然后再细化，一个树形，从根往叶子。通用是反着，从一个个概念开始聚合，开放这么做也是没办法，世界太大了。
	D2R，
	行业数据源：结构化好的行业网站、外部数据库
	文本抽取

	我们的知识图谱构建：
	* 一个在线知识编辑工具
	* 思考好，需要构建哪些知识


太恶心了，neo4j是单个数据库的，你要是切换，得重启，只有一个数据库实例，类似于oracle。<https://www.youtube.com/watch?v=W9Bon8cWrSE>

KBQA的查询本体用的SparQL如何构建和映射？是根据意图映射成固定模板SparQL，还是类似于做语法解析，把Query的语法依存树编译成SparQL语句？
Sequicity



<https://blog.csdn.net/BBZZ2/article/details/72832486>

#### 贪心科技 - 知识图谱笔记

	知识图谱采用的场景：
	* 可视化需求
	* 比如公安、p2p、查看问题用户、嫌疑人关系
	* 深度搜索需求，比如2度、3度，维度增加是线性的
	* 实时性要求，在查询关系网络，多度查询的时候的性能要求
	* 知识推理目前在实际业务中应用还是初级、很少
	* 哪些数据源？如何获得？已经有哪些？缺哪些？
	一般来说，图谱中的超级节点都是没啥用的，啥叫超级节点，就是谁都和他链接到一起，比如电话通话记录图谱中的10086，就是个超级节点，这种节点就没啥意义；比如把性别“男”作为一个实体时候，他会成为超级节点（因为任何人都有性别），所以它也没有意义，所以应该仅仅把他当做人的一个属性对待就好了。
	没啥用的属性，尽量不要放到知识图谱的实体属性中，放到关系数据库里就好了嘛。
	知识图谱没啥用的信息，就尽量放到数据库里，保持知识图谱的整洁和高效。
	社区发现，标签传播算法， 
	 图相似度算法， 
	超级节点，影响性能，从设计中取出，价值不大，
	neo4j可以存储几亿以内的，再大就不合适了，而是是单节点的。如果要支持分布式，可以选择orientDB和JanusGraph。
	GraphX+Spark，来做更大规模的图数据分析，GraphX？

#### 数据炼金 - 知识图谱笔记

	不同的访问方式总结如下： 
	1.直接访问 
	https://www.wikidata.org/wiki/Specail:EntityData/Q23114.rdf 这种可以直接获得wikidata的rdf数据，后缀可以改成pdf，那么就是pdf文件了。
	2.php的web api访问 
	https://www.wikidata.org/w/api.php 直接api访问，但是没办法获取关联数据。
	3.通过SPARQL访问 
	https://query.wikidata.org/ 通过SPARQL来访问的web接口。
	4.使用python api访问 
	 pip install Wikipedia
	import wikipedia as w 
	  w.set_lang(“zh”) 
	  w.search(‘朝阳区’) 
	  不过得翻墙才能看到！
	5.访问谷歌的知识图谱 
	https://developers.google.com/knowledge-graph/  
	通过url访问api即可，需要翻墙： 
	https://kgsearch.googleapis.com/v1/entities:search?query=taylor+swift&key=AIzaSyAvlIZE-x58JmTa&limit=1&indent=True
	6. 
	CN-DBpedia查询 
	http://kw.fudan.edu.cn/apis/cndbpedia/  主页 
	一个例子：查询红楼梦：http://shuyantech.com/api/cndbpedia/ment2ent?q=%E7%BA%A2%E6%A5%BC%E6%A2%A6

	<https://edu.csdn.net/huiyiCourse/detail/833知识图谱发展>

	https://mp.weixin.qq.com/s?__biz=MzI1MDY1OTc0Ng==&mid=2247483925&idx=3&sn=b65331596cb9475fa5ee5212c17d085c

	首先我们要提取的第一个信息就是问题词
	第二个关键的信息，就是问题焦点
	第三个我们需要的信息，就是这个问题的主题词,我们可以通过命名实体识别NER来确定主题词
	第四个我们需要提取的特征，就是问题的中心动词

	通过对问题提取 问题词qword，问题焦点qfocus，问题主题词qtopic和问题中心动词qverb这四个问题特征，我们可以将该问题的依存树转化为问题图（Question Graph）

	从依存树到问题图的转换，实质是就是对问题进行信息抽取，提取出有利于寻找答案的问题特征，删减掉不重要的信息

	之所以有知识图谱，就是对推理的反动。在2001-2012年之间，语义网的研究特别强调推理。但是推理的成本很高，所以在工业界的实践中，逐渐就把推理废弃了。
	大部分的推理任务，是可以转化为图上的查询的。所以在实操中，不必要引入一套复杂的推理机机制。推理机是很强大，但是大多数工程师掌握不了。所以SPARQL rules或者neo4j的查询也就够用了。
	一阶逻辑系统在实战中也比较难以驾驭，通常会用描述逻辑或者逻辑编程logic programming。基于过程语义的规则系统比较实用，如 RIF PRD。

	如果是要解决问题，那就从问题出发，先不要考虑解决方案是不是知识图谱。大部分问题用搜索引擎和数据库就能解决了。即使用知识图谱，也只是在搜索引擎和数据库之上有一个增强。
	所以，先不要从方法出发。先从最成熟的传统技术出发来解决问题。
	不要为了构造知识图谱而构造知识图谱。
	如果不是面对具体问题，构造一个图谱是毫无意义的。

#### 其他

<https://www.zhihu.com/question/52368821/answer/138745422>

	知识图谱作为人工智能（AI）的一个分支，和AI的其他分支一样，它的成功运用，都是需要知道它的所长，更需要知道它的所短的。特别是AI各个学派林立，经验主义（机器学习）、连接主义（神经网络）、理性主义（知识工程）、行为主义（机器人）各个方法的优劣，倘若不能有纵览的理解，也难以做正确的技术选型，往往盲目相信或者排斥一种技术。AI是一个极端需要广阔视野的学科。
	知识图谱涉及知识提取、表达、存储、检索一系列技术，即使想有小成，也需要几年的功夫探索。如下所列，应该是每个知识图谱从业者都应该了解的一些基本功：
	知道Web的发展史，了解为什么互联和开放是知识结构形成最关键的一件事。（我把这个列第一条，是我的偏见——但我认为这是最重要的一个insights）
	知道RDF，OWL，SPARQL这些W3C技术堆栈，知道它们的长处和局限。会使用RDF数据库和推理机。
	了解一点描述逻辑基础，知道描述逻辑和一阶逻辑的关系。知道模型论，不然完全没法理解RDF和OWL。
	了解图灵机和基本的算法复杂性。知道什么是决策问题、可判定性、完备性和一致性、P、NP、NExpTime。
	最好再知道一点逻辑程序（Logic Programming），涉猎一点答集程序（Answer Set Programming），知道LP和ASP的一些小工具。这些东西是规则引擎的核心。如果不满足于正则表达式和if-then-else，最好学一点这些。
	哦，当然要精通正则表达式。熟悉regex的各种工具。
	从正则文法到自动机。不理解自动机很多高效的模式提取算法都理解不了。
	熟悉常见的知识库，不必事事重新造轮子，如Freebase, Wikidata, Yago, DBPedia。
	熟悉结构化数据建模的基本方法，如ER，面向对象，UML，脑图。
	学会使用一些本体编辑器，如Protege。（Palantir就是个价值120亿美元的本体编辑器）
	熟悉任何一种关系数据库。会使用存储过程写递归查询。明白什么叫物化视图、传递闭包、推理闭包。
	熟悉任何一种图数据库。明白图的局部索引和关系的全局索引的理论和实践性能差异。
	熟悉词法分析的基本工具，如分词、词性标注
	熟悉句法分析的基本工具，如成分分析、依存文法分析、深层文法分析
	熟悉TFIDF、主题模型和分布式表示的基本概念和工具。知道怎么计算两个词的相似度、词和句子的关联度。
	知道怎么做命名实体识别。知道一些常用的词表。知道怎么用规则做关系提取。
	为了上述的深化，要掌握一些机器学习的基本概念，识别、分类、聚类、预测、回归。掌握一些机器学习工具包的使用。
	谨慎地使用一些深度学习方法，最好在是了解了神经网络的局限之后，先玩玩BP。主要是用用LSTM。
	了解前人已经建好的各种Lexical数据库，如Wordnet, framenet, BabelNet, PropBank。熟悉一些常用的Corpus。
	知道信息检索的基本原理。知道各种结构的索引的代价。
	掌握Lucene或者Solr/Elasticsearch的使用。
	学会混合使用多种数据库，把结构化数据和非结构化数据放在一起使用。体会数据建模和查询的成本。
	学会一些概念原型工具，如Axure和Semantic Mediawiki。快速做MVP。

	http://blog.memect.cn/?p=393
	我们在传统的这种建模里面，为了表达三元组以上的东西，这个四元组、五元组的话，我们会用reification，这种奇技淫巧，这种东西会极大地降低我们的知识库的可维护性和可读性。


<https://zhuanlan.zhihu.com/knowledgegraph>

	=========
	笔记：
	=========
	数据类型属性（datatype properties）：类实例与RDF文字或XML Schema数据类型间的关系。
	对象属性（object properties）：两个类的实例间的关系。
	类应自然地对应于与某论域中的事物的出现集合
	属性是个体之间的二元关系
	函数属性(Functional Property)——通过这个属性只能连接一个个体
	对象属性(Object Property)——连接两个个体
	标注属性 (Annotation Property)——用来对类，属性，个体和本体添加信息(元数据)。
	概念（concept）这个词有时被用来代替类，实际上，类是概念的一个具体表现
	使用owl:disjointWith构造子可以表达一组类是不相交的。它保证了属于某一个类的个体不能同时又是另一个指定类的实例

	资源描述框架（Resource Description Framework, RDF）是一种描述有关 Web 资源的格式化语句集合的模型。
	Web Ontology Language (OWL)是一种 基于RDF的 应用程序，通常使用 RDF/XML 编码，它添加了一种丰富的词汇表，可以用来按照格式分类并分析 RDF 资源。 

	粗略地说，RDF局限于二元常谓词，RDFS局限于子类分层和属性分层(rdfs:subClassOf rdfs:subPropertyof),以及属性的定义域和值域限定(rdfs:domain rdfs:range). 
	owl本身是rdf的一个扩展，自然也满足rdf语法。
	Web本体语言(OWL)中描述3者区别提到一句：OWL-构建在 RDF 的顶端之上，描述属性与类别之间的关系。

	假如我们有两个语义网络A和B。在A中，熊是哺乳动物的一个实例。在B中，熊是哺乳动物的一个子类。前者是is-a关系，后者是subClassOf关系。这种情况常有发生，我们建模的角度不同，那么同一个事物的表示也可能不同。=====>有时候当做个体，有时候还是当做概念，确实是有这种情况。

	每条知识表示为一个SPO三元组(Subject-Predicate-Object)
	Subjet——（Predicate)——>Object
	RDF(Resource Description Framework)，即资源描述框架，是W3C制定的，用于描述实体/资源的标准数据模型。RDF图中一共有三种类型，International Resource Identifiers(IRIs)，blank nodes 和 literals。
	IRI我们可以看做是URI或者URL的泛化和推广，它在整个网络或者图中唯一定义了一个实体/资源，和我们的身份证号类似。
	literal是字面量，我们可以把它看做是带有数据类型的纯文本，比如我们在第一个部分中提到的罗纳尔多原名可以表示为"Ronaldo Luís Nazário de Lima"^^xsd:string。
	blank node简单来说就是没有IRI和literal的资源，或者说匿名资源。

	RDF的表达能力有限，无法区分类和对象，也无法定义和描述类的关系/属性。
	person:1 :nationality "巴西"^^string.

	RDFS，即“Resource Description Framework Schema”，是最基础的模式语言。轻量级的模式语言。
	我们这里只介绍RDFS几个比较重要，常用的词汇：
	1. rdfs:Class. 用于定义类。
	2. rdfs:domain. 用于表示该属性属于哪个类别。
	3. rdfs:range. 用于描述该属性的取值类型。
	4. rdfs:subClassOf. 用于描述该类的父类。比如，我们可以定义一个运动员类，声明该类是人的子类。
	5. rdfs:subProperty. 用于描述该属性的父属性。比如，我们可以定义一个名称属性，声明中文名称和全名是名称的子类。

	Data层是我们用RDF对罗纳尔多知识图的具体描述，Vocabulary是我们自己定义的一些词汇（类别，属性），RDF(S)则是预定义词汇。
	人们发现RDFS的表达能力还是相当有限，因此提出了OWL。我们也可以把OWL当做是RDFS的一个扩展，其添加了额外的预定义词汇。
	OWL，即“Web Ontology Language”，语义网技术栈的核心之一。OWL有两个主要的功能：
	1. 提供快速、灵活的数据建模能力。
	2. 高效的自动推理。

	schema层的描述语言换为OWL后

	描述属性特征的词汇
	1. owl:TransitiveProperty. 表示该属性具有传递性质。例如，我们定义“位于”是具有传递性的属性，若A位于B，B位于C，那么A肯定位于C。
	2. owl:SymmetricProperty. 表示该属性具有对称性。例如，我们定义“认识”是具有对称性的属性，若A认识B，那么B肯定认识A。
	3. owl:FunctionalProperty. 表示该属性取值的唯一性。 例如，我们定义“母亲”是具有唯一性的属性，若A的母亲是B，在其他地方我们得知A的母亲是C，那么B和C指的是同一个人。
	4. owl:inverseOf. 定义某个属性的相反关系。例如，定义“父母”的相反关系是“子女”，若A是B的父母，那么B肯定是A的子女。
	本体映射词汇（Ontology Mapping）
	1. owl:equivalentClass. 表示某个类和另一个类是相同的。
	2. owl:equivalentProperty. 表示某个属性和另一个属性是相同的。
	3. owl:sameAs. 表示两个实体是同一个实体。

	本体映射主要用在融合多个独立的Ontology（Schema）。举个例子，张三自己构建了一个本体结构，其中定义了Person这样一个类来表示人；李四则在自己构建的本体中定义Human这个类来表示人。当我们融合这两个本体的时候，就可以用到OWL的本体映射词汇。回想我们在第二篇文章中提到的Linked Open Data，如果没有OWL，我们将无法融合这些知识图谱。

	OWL在推理方面的能力。知识图谱的推理主要分为两类：基于本体的推理和基于规则的推理。

	一般的关系都靠"Object Properties"
	换到"Object Properties"页面，我们在此界面创建类之间的关系，即，对象属性。
	"domain"表示该属性是属于哪个类的，"range"表示该属性的取值范围。
	"hasActedIn"表示某人参演了某电影，属性的"domain"是人，4号框定义"range”是电影

	"Data properties"，我们在该界面创建类的属性，即，数据属性。其定义方法和对象属性类似，除了没有这么丰富的描述属性特性的词汇。数据属性相当于树的叶子节点，只有入度，而没有出度。其实区分数据属性和对象属性还有一个很直观的方法，我们观察其"range"，取值范围即可。对象属性的取值范围是类，而数据属性的取值范围则是字面量。
	我理解，DataProperties就是个文本、数字属性值，而类之间关系都用ObjectProperties，后者更常用。

	W3C的RDB2RDF工作小组制定的两个标准：

	第一个标准是direct mapping，即直接映射。
	1、数据库的表作为本体中的类（Class）。比如我们在mysql中保存的数据，一共有5张表。那么通过映射后，我们的本体就有5个类了，而不是我们自己定义的三个类。2. 表的列作为属性（Property）。3. 表的行作为实例/资源。。。
	在实际应用中我们很少用到这种方法，Direct mapping的缺点很明显，不能把数据库的数据映射到我们自己定义的本体上。

	第二个标准是RDB2RDF工作小组指定了另外一个标准——R2RML，可以让用户更灵活的编辑和设置映射规则。是个规范：W3C的文档(R2RML: RDB to RDF Mapping Language)。就是个工具，用的时候再查文档。其实就是一个映射文件，你映射好了，他就按照这个帮你从数据库生成本体数据。
	有个工具叫D2RQ，你提供类R2RML映射，然后他通过这个类R2RML mapping文件，把对RDF的查询等操作翻译成SQL语句，最终在RDB上实现对应操作。就是给你数据库套上一个RDF的壳子。
	D2RQ提供了自己的mapping language，其形式和R2RML类似。D2RQ发布了r2rml-kit以支持W3C制定的两个映射标准。D2RQ有一个比较方便的地方，可以根据你的数据库自动生成预定义的mapping文件，用户可以在这个文件上修改，把数据映射到自己的本体上。
	使用下面的命令将我们的数据转为RDF：
	.\dump-rdf.bat -o kg_demo_movie.nt .\kg_demo_movie_mapping.ttl
	这样，就可以把数据库的数据导出到RDF文件中了。

	在2008年，SPARQL 1.0；2013年发布了SPARQL 1.1；
	两个部分组成：协议和查询语言。
	1. 查询语言很好理解，就像SQL用于查询关系数据库中的数据，XQuery用于查询XML数据，SPARQL用于查询RDF数据。
	2. 协议是指我们可以通过HTTP协议在客户端和SPARQL服务器（SPARQL endpoint）之间传输查询和结果，这也是和其他查询语言最大的区别。
	一个SPARQL查询本质上是一个带有变量的RDF图。SPARQL查询是基于图匹配的思想。我们把上述的查询与RDF图进行匹配，找到符合该匹配模式的所有子图，最后得到变量的值。
	SPARQL查询分为三个步骤：
	1. 构建查询图模式，表现形式就是带有变量的RDF。
	2. 匹配，匹配到符合指定图模式的子图。
	3. 绑定，将结果绑定到查询图模式对应的变量上。
	SELECT * WHERE {
	  ?s ?p ?o
	}
	SPARQL的部分关键词：
	* SELECT， 指定我们要查询的变量。在这里我们查询所有的变量，用*代替。
	* WHERE，指定我们要查询的图模式。含义上和SQL的WHERE没有区别。
	* FROM，指定查询的RDF数据集。我们这里只有一个图，因此省去了FROM关键词。
	* PREFIX，用于IRI的缩写。
	SELECT ?n WHERE {
	  ?s rdf:type :Person.
	  ?s :personName '周星驰'.
	  ?s :hasActedIn ?o.
	  ?o :movieTitle ?n
	}
	关于知识图谱，有一个非常重要的概念，即开放世界假定（Open-world assumption，OWA）。这个假定的意思是当前没有陈述的事情是未知的，或者说知识图谱没有包含的信息是未知的。怎么理解？首先我们要承认知识图谱无法包含所有完整的信息。以我们这个电影数据的例子而言，很明显，它的数据十分残缺。即使我们拥有一个十分完整的电影知识图谱，包含了当下所有的电影、演员等信息，在现实世界中，信息也是动态变化和增长的。即，我们要承认知识图谱的信息本身就是残缺的。
	周星驰出演了上述查询结果中的电影。基于我们构建的电影知识图谱，提问：周星驰出演了《卧虎藏龙》吗？根据OWA，我们得到的答案是“不知道”，相反，如果是封闭世界假定（Closed-world assumption），我们得到的答案是“没有出演”。


<https://zhuanlan.zhihu.com/knowledgegraph>

	知识图谱学习笔记
	这个是学习知乎专栏：知识图谱-给AI装个大脑
	作者是SimmerChan，感谢！
	很凌乱，只保留干货，主要是自己看，看官如果觉得辣眼，见谅！
	数据类型属性（datatype properties）：类实例与RDF文字或XML Schema数据类型间的关系。 
	对象属性（object properties）：两个类的实例间的关系。 
	类应自然地对应于与某论域中的事物的出现集合 
	属性是个体之间的二元关系 
	函数属性(Functional Property)——通过这个属性只能连接一个个体 
	对象属性(Object Property)——连接两个个体 
	标注属性 (Annotation Property)——用来对类，属性，个体和本体添加信息(元数据)。 
	概念（concept）这个词有时被用来代替类，实际上，类是概念的一个具体表现 
	使用owl:disjointWith构造子可以表达一组类是不相交的。它保证了属于某一个类的个体不能同时又是另一个指定类的实例
	资源描述框架（Resource Description Framework, RDF）是一种描述有关 Web 资源的格式化语句集合的模型。 
	Web Ontology Language (OWL)是一种 基于RDF的 应用程序，通常使用 RDF/XML 编码，它添加了一种丰富的词汇表，可以用来按照格式分类并分析 RDF 资源。 
	粗略地说，RDF局限于二元常谓词，RDFS局限于子类分层和属性分层(rdfs:subClassOf rdfs:subPropertyof),以及属性的定义域和值域限定(rdfs:domain rdfs:range).  
	owl本身是rdf的一个扩展，自然也满足rdf语法。 
	Web本体语言(OWL)中描述3者区别提到一句：OWL-构建在 RDF 的顶端之上，描述属性与类别之间的关系。
	假如我们有两个语义网络A和B。在A中，熊是哺乳动物的一个实例。在B中，熊是哺乳动物的一个子类。前者是is-a关系，后者是subClassOf关系。这种情况常有发生，我们建模的角度不同，那么同一个事物的表示也可能不同。=——–>有时候当做个体，有时候还是当做概念，确实是有这种情况。
	每条知识表示为一个SPO三元组(Subject-Predicate-Object) 
	Subjet——（Predicate)——>Object 
	RDF(Resource Description Framework)，即资源描述框架，是W3C制定的，用于描述实体/资源的标准数据模型。RDF图中一共有三种类型，International Resource Identifiers(IRIs)，blank nodes 和 literals。 
	IRI我们可以看做是URI或者URL的泛化和推广，它在整个网络或者图中唯一定义了一个实体/资源，和我们的身份证号类似。 
	literal是字面量，我们可以把它看做是带有数据类型的纯文本，比如我们在第一个部分中提到的罗纳尔多原名可以表示为”Ronaldo Luís Nazário de Lima”^^xsd:string。 
	blank node简单来说就是没有IRI和literal的资源，或者说匿名资源。
	RDF的表达能力有限，无法区分类和对象，也无法定义和描述类的关系/属性。 
	person:1 :nationality “巴西”^^string.
	RDFS，即“Resource Description Framework Schema”，是最基础的模式语言。轻量级的模式语言。 
	我们这里只介绍RDFS几个比较重要，常用的词汇：
	1. rdfs:Class. 用于定义类。
	2. rdfs:domain. 用于表示该属性属于哪个类别。
	3. rdfs:range. 用于描述该属性的取值类型。
	4. rdfs:subClassOf. 用于描述该类的父类。比如，我们可以定义一个运动员类，声明该类是人的子类。
	5. rdfs:subProperty. 用于描述该属性的父属性。比如，我们可以定义一个名称属性，声明中文名称和全名是名称的子类。
	Data层是我们用RDF对罗纳尔多知识图的具体描述，Vocabulary是我们自己定义的一些词汇（类别，属性），RDF(S)则是预定义词汇。
	人们发现RDFS的表达能力还是相当有限，因此提出了OWL。我们也可以把OWL当做是RDFS的一个扩展，其添加了额外的预定义词汇。 
	OWL，即“Web Ontology Language”，语义网技术栈的核心之一。OWL有两个主要的功能：
	1. 提供快速、灵活的数据建模能力。
	2. 高效的自动推理。
	schema层的描述语言换为OWL后
	描述属性特征的词汇
	1. owl:TransitiveProperty. 表示该属性具有传递性质。例如，我们定义“位于”是具有传递性的属性，若A位于B，B位于C，那么A肯定位于C。
	2. owl:SymmetricProperty. 表示该属性具有对称性。例如，我们定义“认识”是具有对称性的属性，若A认识B，那么B肯定认识A。
	3. owl:FunctionalProperty. 表示该属性取值的唯一性。 例如，我们定义“母亲”是具有唯一性的属性，若A的母亲是B，在其他地方我们得知A的母亲是C，那么B和C指的是同一个人。
	4. owl:inverseOf. 定义某个属性的相反关系。例如，定义“父母”的相反关系是“子女”，若A是B的父母，那么B肯定是A的子女。 
	本体映射词汇（Ontology Mapping）
	5. owl:equivalentClass. 表示某个类和另一个类是相同的。
	6. owl:equivalentProperty. 表示某个属性和另一个属性是相同的。
	7. owl:sameAs. 表示两个实体是同一个实体。
	本体映射主要用在融合多个独立的Ontology（Schema）。举个例子，张三自己构建了一个本体结构，其中定义了Person这样一个类来表示人；李四则在自己构建的本体中定义Human这个类来表示人。当我们融合这两个本体的时候，就可以用到OWL的本体映射词汇。回想我们在第二篇文章中提到的Linked Open Data，如果没有OWL，我们将无法融合这些知识图谱。
	OWL在推理方面的能力。知识图谱的推理主要分为两类：基于本体的推理和基于规则的推理。
	一般的关系都靠”Object Properties” 
	换到”Object Properties”页面，我们在此界面创建类之间的关系，即，对象属性。 
	“domain”表示该属性是属于哪个类的，”range”表示该属性的取值范围。 
	“hasActedIn”表示某人参演了某电影，属性的”domain”是人，4号框定义”range”是电影
	“Data properties”，我们在该界面创建类的属性，即，数据属性。其定义方法和对象属性类似，除了没有这么丰富的描述属性特性的词汇。数据属性相当于树的叶子节点，只有入度，而没有出度。其实区分数据属性和对象属性还有一个很直观的方法，我们观察其”range”，取值范围即可。对象属性的取值范围是类，而数据属性的取值范围则是字面量。 
	我理解，DataProperties就是个文本、数字属性值，而类之间关系都用ObjectProperties，后者更常用。
	W3C的RDB2RDF工作小组制定的两个标准：
	第一个标准是direct mapping，即直接映射。 
	1、数据库的表作为本体中的类（Class）。比如我们在mysql中保存的数据，一共有5张表。那么通过映射后，我们的本体就有5个类了，而不是我们自己定义的三个类。2. 表的列作为属性（Property）。3. 表的行作为实例/资源。。。 
	在实际应用中我们很少用到这种方法，Direct mapping的缺点很明显，不能把数据库的数据映射到我们自己定义的本体上。
	第二个标准是RDB2RDF工作小组指定了另外一个标准——R2RML，可以让用户更灵活的编辑和设置映射规则。是个规范：W3C的文档(R2RML: RDB to RDF Mapping Language)。就是个工具，用的时候再查文档。其实就是一个映射文件，你映射好了，他就按照这个帮你从数据库生成本体数据。 
	有个工具叫D2RQ，你提供类R2RML映射，然后他通过这个类R2RML mapping文件，把对RDF的查询等操作翻译成SQL语句，最终在RDB上实现对应操作。就是给你数据库套上一个RDF的壳子。 
	D2RQ提供了自己的mapping language，其形式和R2RML类似。D2RQ发布了r2rml-kit以支持W3C制定的两个映射标准。D2RQ有一个比较方便的地方，可以根据你的数据库自动生成预定义的mapping文件，用户可以在这个文件上修改，把数据映射到自己的本体上。 
	使用下面的命令将我们的数据转为RDF： 
	.\dump-rdf.bat -o kg_demo_movie.nt .\kg_demo_movie_mapping.ttl 
	这样，就可以把数据库的数据导出到RDF文件中了。
	在2008年，SPARQL 1.0；2013年发布了SPARQL 1.1； 
	两个部分组成：协议和查询语言。
	1. 查询语言很好理解，就像SQL用于查询关系数据库中的数据，XQuery用于查询XML数据，SPARQL用于查询RDF数据。
	2. 协议是指我们可以通过HTTP协议在客户端和SPARQL服务器（SPARQL endpoint）之间传输查询和结果，这也是和其他查询语言最大的区别。 
	一个SPARQL查询本质上是一个带有变量的RDF图。SPARQL查询是基于图匹配的思想。我们把上述的查询与RDF图进行匹配，找到符合该匹配模式的所有子图，最后得到变量的值。 
	SPARQL查询分为三个步骤：
	3. 构建查询图模式，表现形式就是带有变量的RDF。
	4. 匹配，匹配到符合指定图模式的子图。
	5. 绑定，将结果绑定到查询图模式对应的变量上。 
	SELECT * WHERE { 
	?s ?p ?o 
	} 
	SPARQL的部分关键词： 
	    * SELECT， 指定我们要查询的变量。在这里我们查询所有的变量，用*代替。
	    * WHERE，指定我们要查询的图模式。含义上和SQL的WHERE没有区别。
	    * FROM，指定查询的RDF数据集。我们这里只有一个图，因此省去了FROM关键词。
	    * PREFIX，用于IRI的缩写。 
	SELECT ?n WHERE { 
	?s rdf:type :Person. 
	?s :personName ‘周星驰’. 
	?s :hasActedIn ?o. 
	?o :movieTitle ?n 
	} 
	关于知识图谱，有一个非常重要的概念，即开放世界假定（Open-world assumption，OWA）。这个假定的意思是当前没有陈述的事情是未知的，或者说知识图谱没有包含的信息是未知的。怎么理解？首先我们要承认知识图谱无法包含所有完整的信息。以我们这个电影数据的例子而言，很明显，它的数据十分残缺。即使我们拥有一个十分完整的电影知识图谱，包含了当下所有的电影、演员等信息，在现实世界中，信息也是动态变化和增长的。即，我们要承认知识图谱的信息本身就是残缺的。 
	周星驰出演了上述查询结果中的电影。基于我们构建的电影知识图谱，提问：周星驰出演了《卧虎藏龙》吗？根据OWA，我们得到的答案是“不知道”，相反，如果是封闭世界假定（Closed-world assumption），我们得到的答案是“没有出演”。
	{:class=”myimg”} 
	组件有：TDB、rule reasoner和Fuseki。
	1. TDB是Jena用于存储RDF的组件，是属于存储层面的技术。在单机情况下，它能够提供非常高的RDF存储性能。目前TDB的最新版本是TDB2，且与TDB1不兼容。
	2. Jena提供了RDFS、OWL和通用规则推理机。其实Jena的RDFS和OWL推理机也是通过Jena自身的通用规则推理机实现的。
	3. Fuseki是Jena提供的SPARQL服务器，也就是SPARQL endpoint。其提供了四种运行模式：单机运行、作为系统的一个服务运行、作为web应用运行或者作为一个嵌入式服务器运行。
	TDB提供元组保存；Jena自带推理机也支持OWL推理规则；Fuseki是个响应SPARQL的服务器；
	使用“tdbloader.bat”将之前我们的RDF数据以TDB的方式存储。命令如下： 
	.\tdbloader.bat --loc="D:\apache jena\tdb" "D:\d2rq\kg_demo_movie.nt" 
	“–loc”:指定tdb存储的位置 
	kg_demo_movie.nt：我们之前的从数据库里导出的本体文件。
	知识图谱课笔记

	用依存分析，可以找到远点距离上的词的关系，而不是依赖一个窗口。
	如果给utterance构造一个query， 
	要做一个entity linking， 
	S-MART:novel tree-based structured learning algorithms apllied to tweet entity linking in ACL 2015. 
	用Freebase或者dbPedia，来做实体的链接的对象。
	CVT: component value type，freebase中用来定义多元关系的机制。 
	比如吧一个四元组转换成三元组的时候用。
	？？？知识表示，用cvt，三元组
	远程监督？distant supervision
	一阶谓词逻辑，需要看一下概念
	reference table，distant supervsion，的概念 
	消歧，第四课
	什么叫做远程监督？它既不是单纯的传统意义上的监督语料，当然也不是无监督。它是一种用KB去对齐朴素文本的标注方法。

<https://blog.csdn.net/u011801161/article/details/78910988> 

这篇不错，讲protege建模的

<https://www.zhihu.com/question/26385031>

问答系统(KBQA)。除了图关系挖掘外，主要的通用的应用场景。方法精度上，Pattern >> Machine Learning。语义分析“美人鱼的导演是谁” ，得到句法树，生成检索语句（与对应的存储方式对应：SparQL-Neo4j / MySQL-SQL），检索知识库得到结果 “周星驰”。

<http://www.vccoo.com/v/8b3im1_6>

问：感谢分享，使用自然语言进行友好查询的优化方法同样适用于 neo4j 吗？

答：同样适用于 neo4j，但是 neo4j 的 cypher 查询语言没有 SPARQL 那么标准。对于自然语言转化出来的结构化信息到 cypher 的转换的方法需要重新设计。NLU 这块的工作是相同的。

问：明略采用 RDF 的 entity 和 edge 的数量级是多少？有一些问题：为什么不考虑类似 neo4j，OrientDB，Titan 这类的图库，而要采用 SparQL，是因为数据量很大？

答：为了更好的支持智能化应用，在明略关于 RDF 的存储管理是处于探索阶段。目前我们实际的 SCOPA 系统是采用了自研的蜂巢知识图谱数据库，并对外提供的是 native 的 API。

neo4j和jena的比较：

<https://db-engines.com/en/system/Jena;Neo4j>

<http://skyhigh233.com/blog/2016/10/31/qa-insurance/>

[知识图谱讲座：阿里飞天专场](https://yunqi.aliyun.com/2017/hangzhou/videos?spm=a21cy.10467250.880280.811.ypKZOF&wh_ttid=pc#/video/243)

[阿尔法胖哥的知识图谱实战开发案例剖析](http://study.163.com/course/introduction.htm?courseId=1004964005”)

**文本相似度**

[中文文本相似度计算工具集](https://zhuanlan.zhihu.com/p/35843798?group_id=970051171658919936)

[文本相似度](http://www.cnblogs.com/huilixieqi/p/6493089.html)

这篇讲的很棒，很系统，抽空要认真学习一下
