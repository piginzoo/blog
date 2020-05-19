---
layout: post
title: 迁移我的博客
category: tech
---

## 缘起

我的博客是基于[Jekyll](http://jekyllcn.com/)做的，支持Markdown和Latex，页面中的图像，是我通过我的Mac Automator脚本实现的自动截屏，然后Save到我的本地，再提交到Github去的（是的，我把Github当做了我的图床）。

当我每次使用类似于Sublime这种文本编辑器，编写完我的主页后，提交到Github后，Github的[Git Page](https://pages.github.com/)系统会自动帮助我，完成了把Markdown自动转化成HTML网站的过程，然后我就可以通过域名piginzoo.github.io就可以访问了。[Git Page](https://pages.github.com/)服务是一个Github提供的免费的个人博客系统，很帅！

最后，我还需要使用我的www.piginzoo.com 域名，在[DNSPod](https://www.dnspod.cn/)上，CNAME到 piginzoo.github.io 上，完成我的域名配置和跳转，从而最终完成了我的博客网站。

可惜，从国内访问Github总是很慢，CNAME的解析也时常掉链子，导致我的托管主页访问起来也很慢，经常在手机上半天也出刷不来，让人捉急。

所以，一直想把我的博客迁移到自己的服务器上来，我自己有台速度还可以的服务器，于是，终于决定不再犯懒了，搞起来！

## 动手

在我自己的服务器上部署的话，需要依次解决这些问题：

- [x] 安装Ruby（jekyll需要ruby环境）和Gem
- [x] 安装Jekyll
- [x] 和Nginx集成
- [x] 还要可以自动从Git中拉取最新的内容

由于我的Server是CentOS7，默认的Yum安装的Ruby版本是1.9，可是最新的版本的[Jekyll](http://jekyllcn.com/)需要至少Ruby版本是2.x，没办法，只有先装个[RVM](http://rvm.io/)，他是一个多版本Ruby管理的一个工具，装了他就可以很方便的安装和使用多个版本的Ruby了。

好，我们来安装RVM：

### 安装RVM

安装Ruby参考了[这篇](https://blog.csdn.net/hooyying/article/details/83119948)。

- 去[http://rvm.io/](http://rvm.io/)去装rvm

然后运行命令安装它：

```python
gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL [https://get.rvm.io](https://get.rvm.io/) | bash -s stable
```

安装完RVM后，需要使用它来安装Ruby了，我选用的是Ruby 2.5.1。

### 安装ruby2.5.1

使用命令安装Ruby：

```bash
rvm install 2.5.1
```

这个过程有些慢，耐心等待。

安装完成后，使用命令，便可以启动Ruby 2.5.1的环境了：

```bash
rvm use 2.5.1
```

**加入rc.local使其自动启动**

安装完Ruby后，为了可以每次在启动之后，自动都设置成Ruby 2.5.1的环境，需要把这句话`rvm use 2.5.1`加入到`/etc/rc.loca`中，保证服务器已启动就自动设置为Ruby 2.5.1的环境。

接下来，终于安装博客生成系统Jekyll了

### 安装Jekyll

安装jekyll，需要使用Ruby自带的Gem工具，Gem是一个Ruby包安装工具，用于安装Ruby编写的各种应用。在命令行中输入命令：

```bash
gem install jekyll
```

过程有些慢，请耐心等待。安装完毕后，你就可以来使用Jekyll生成的网站了。

这里暂停一下，先对Jekyll，以及我使用心得，做一个简单的介绍：

#### 用Jekyll写博客

Jekyll网站生成工具，博客作者，可以使用Markdown语法书写博客，然后Jekyll会自动帮你讲Markdown页面转化成HTML页面，同时还会帮你构建了一个网站的基础框架，比如首页、分类。它还支持显示模板，使用CSS定制化你的显示样式，我使用的就是他默认提供的一套Bootstrap的模板，很朴素简洁。如果你觉得太素了，你可以下载其他热心网友制作的更酷的模板，切换过去后瞬间网站就高大上了，哈哈。

*同样的网站生成器，还有更灵活帅气的[Hexo](https://hexo.io/)，还有Go语言的[Hugo](https://www.gohugo.org/)实在是没时间再去研究鼓捣了，看以后有机会再玩吧~*

我还安装了一系列的插件，帮助我丰富我的博客网站：

- [MathJax](https://www.mathjax.org/)，一个JS库，瞬间把我的Latex文字翻译成漂亮的数学公式。
- 我利用 MAC 自带的Automator，写了一个[Python脚本](/assets/clipboard.py)，可以自动把你的剪贴板图片转化成jpg，存入到指定的目录，并且把路径拷贝到剪贴板，你只要paste一下，就把图片插入到了博文中。

下面是一个生成的图片的例子：目录`20181220`和文件名`1545282900519.jpg`都是自动生成，防止重名：
```
![](/images/20181220/1545282900519.jpg)
```
- 使用了Jquery插件[TOC](https://projects.jga.me/toc/)，来自动生成目录（不过貌似Jekyll自己也带TOC，有时间再研究吧）
- 使用了[Valine](https://valine.js.org/)，一个国产小哥写的评论系统，他是基于[LeanCloud](https://leancloud.cn/)开发的，可惜由于TMD“某种原因”不更新了，你懂的，它比[来必力](http://livere.com/)好用。我最早是用的[友言](http://www.uyan.cc/)，但是也因为“不可抗拒原因”关闭，FUCK！没办法，我只好弃用它了。
- Valine还自动帮我完成了帖子的[计数器功能](https://valine.js.org/visitor.html)，每篇帖子标题下方的计数器就是用它实现的。
- 安装了百度统计，帮助我了解网站和每篇帖子的访问和SEO情况。
- 另外，还自己改了一些内容，如置顶、排序、日期格式化...，Jekyll就是一个给程序员准备的Toy，本身就是一套Ruby脚本，所以作为程序员的你，可以自己尽情发挥。


### 克隆的网站

前面乱入了Jekyll的使用和心得，让我们继续回来，继续我们的网站迁移。

我们安装好Jekyll之后，还需要去Github上去克隆我们的博客代码。

我在服务器上创建了一个目录，然后把我的网站克隆到这里，克隆地址就是你Github托管主要的网址。

它没有master分支，只有一个名为“gh-pages”的分支，为什么起这么一个怪怪的分支名字呢，这个是Github Page 要求的，可以参考[我之前的博客](http://www.piginzoo.com/tech/2015/02/20/rebuild-my-website)了解更多。

然后，cd到这个这个git目录中，输入命令：

```bash
jekyll server &
```

顺利的话，网站就会启动起来，你会看到他会先运行一段生成程序，把你的Markdown页面转化成HTML，然后再默认在4000端口开始监听。

### 部署Nginx

虽然使用Jekyll生成了网页并且启动了一个Web服务器，但是我还是想让我的网站是构建在Nginx之上，Nginx可以帮我根据域名自动导向到我这台服务器上的多种服务，Jekyll主页服务，只是其中之一。

于是我修改了Nginx配置，让Nginx可以serve我的域名www.piginzoo.com ，并且，将Nginx对外服务的网页目录指向到了Jekyll的生成目录：

Nginx配置的修改：
```
    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  _ www.piginzoo.com piginzoo.com;

        # 自动跳转到www
        if ($host = 'piginzoo.com') {
      		     rewrite ^/(.*)$ http://www.piginzoo.com/$1 permanent;
      	}

      	# 设置我的主页目录为jekyll生成的页面目录
		root         【jekyll的生成目录】;

		# 开启gzip
        gzip on;
        gzip_min_length 1k;
        gzip_comp_level 4;
        gzip_types text/plain application/javascript application/x-javascript text/css application/xml text/javascript ;
        gzip_vary on;
        gzip_buffers 2 4k;
        gzip_http_version 1.1;

        # 给所有的页面自动增加*.html后缀,jekyll生成的页面的后缀	
        location / {
    		if (!-e $request_filename){
		        rewrite ^(.*)$ /$1.html last;
	        	break;
   		 }
        }
```

需要注意以下几点：

- 通过server_name来支持多个域名的访问
- Jekyll是根据Markdown页面自动生成的HTML静态页面，所以Nginx要把root指向到这个生成目录
- 需要增加一个rewrite，让所有的访问页面最后都自动去访问\*.html文件，比如去访问`http://www.piginzoo.com/tech/2015/02/20/rebuild-my-website`，最终访问的是`http://www.piginzoo.com/tech/2015/02/20/rebuild-my-website.html`。

### 最后，加入Git自动拉取

因为我的页面都是在host在Github上，需要`git pull`才可以把我最新的博客页面拉取下来，所以还需要写一个自动化拉取脚本：

- 使用crontab，设置自动每分钟拉取Github一次

```python
*/1 * * * *  git --git-dir=/xxx/.git --work-tree=/xxx pull > /dev/null
```

需要使用git-dir指定你的本地git库目录，使用work-tree指定的工作目录。

- 加入脚本后台运行jekyll server

```python
nohup jekyll server -s /xxx-d /xxx/_site/>/dev/null 2>&1 &
```

创建一个后台服务，来保持jekyll server的常驻。

这样，每1分钟，就去我的Github博客repo中尝试拉取最新的页面，一旦拉取了最新的页面，Jekyll会自动将其生成为HTML网页，Nginx就可以实时响应给用户了。

恩，完美了！

### 创建帖子的脚本

为了方便自己，创建了一个快速创建帖子的脚本，帮助我快速创建页面：

```
TODAY=`date +%Y-%m-%d`
TITLE=$1

if [ "$1" == "" ]; then
	echo "格式错误！"
	echo "\t必须要有一个以中划线分割的主题（英文）"
	echo "\t 如： create map-reduce"
	exit
fi


BLOG_FILE_NAME="_posts/$TODAY-$1.md"
touch $BLOG_FILE_NAME

echo "已经创建新帖子：$BLOG_FILE_NAME"

cat >> $BLOG_FILE_NAME <<EOF
---
layout: post
title: <修改这里的标题>
category: <修改这里的分类，用英文>
---
EOF

```

只要你在命令行输入：`create test-123`，就会自动在_posts目录下创建一个新帖子，你打开编辑就好，很方便。

## 好啦，终于可以安静的写博客了

好啦，终于都完事了，我可以安静的写博客了：

1、打开iterm，使用我的`create`命令创建一个新帖子

2、启动Sublime，编辑这个新帖子，使用我的MAC Automator脚本自动将我截屏的图片保存到目录中。

3、我会在本地启动一个`jekyll server`来预览我的网站。

4、最后，我使用`git add .; git commit; git push`，将我的修改提交到Github上去。

5、安静的等待一分钟，刷新我的www.piginzoo.com , 哇，新的网页出现了。

写博客，变成了一件简单、开心的事情，从此喜欢上了摆弄文字。

