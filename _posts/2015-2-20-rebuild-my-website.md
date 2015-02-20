---
layout: post
title: 重建博客
category: 技术
---
自从我的**piginzoo.com**域名和在国外的虚拟主机相继过期后，我就等着国际域名管理组织回收它，经过了长大九九八十一天+的等待，终于被回收了。我终于回到了被*阉割*的祖国，没办法，要备案！备案结束后，就迫不及待的重建它，终于这几天有时间了，赶紧摆弄起来。研究了一番后，决定还是用github的pages系统，使用jeklly方式，回头试试简书吧也，anyway，先折腾一番再说！  



搭建自己的blog，[参考](http://www.cnblogs.com/purediy/archive/2013/03/07/2948892.html) 明白了jekyll只是github上用的后台编译blog的模板系统，可以下载到本地用ruby去跑，但是只是用来预览，要按照他的格式提交到github上用他的pages系统才能真正生成，也就是说生成过程实在服务器端完成的。网上的文章上来就讲jekyll，生怕别人不明白这个高大上的东西，但是实际上在笔记本上不装jekyll就完全可以直接提及到github上靠github pages来在服务器生成。而在笔记本上装jekyll也只是为了预览或者本地生成html用。  

另外，为了让github帮你生成html，必须要用给一个诡异的gh-pages分支来存kekyll的markdown的模板，是个约定，自己在笔记本上得一堆git命令才能搞定，简单的办法有么？有，就是直接在某个repository用auto page generator自动生成这个repository用的pages系统，然后你克隆下来，在此基础上改造成自己的博客。  

我的做法是，先用这东西创建gh-pages分之，然后用jeklly-bootstrap直接生成我的网站博客框架，再改之，不过我还是装了jeklly，用于本地调试博客。  

最后，吐槽一下，妈蛋，搞个博客还是得费点劲的，怪不得那么多程序员都用github pages来搞呢，用来装逼确实有范，但是，我只是想搞个自己的博客，唉，从了。最后，还是绑个cname，才能访问。我去！

```
git clone https://github.com/plusjade/jekyll-bootstrap.git piginzoo.github.com
```  
然后mv到我的blog目录下，嚯嚯

参考：  
[http://www.ruanyifeng.com/blog/2012/08/blogging_with_jekyll.html]()  
[http://site.douban.com/196781/widget/notes/12161495/note/264946576/]()