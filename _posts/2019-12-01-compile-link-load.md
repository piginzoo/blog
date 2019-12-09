---
layout: post
title: 程序的编译、转载与链接
category: tech
---

# 前言

作为计算机专业的人，我最遗憾的就是上编译原理的时候被别的老师拉取干活了，没上成。而对一个程序怎么就从源代码变成了一个在内存里活灵活现的进程，一直也很心怀好奇。这种好奇，一直驱使我，要找个机会深入了解一下，所以，就开此贴，来督促自己深入研究下。

主要就参考三本书，在后面[参考](#参考)中列出了，其中的很多基础知识和细节我不再赘述，主要会写一写我对很多关键知识的理解和说明。

三本书里，最主要还是《程序员的自我修养 - 链接、装载与库》，里面的代码我放到了[我的github](https://github.com/piginzoo/link-load-library-code)上，并且配有shell脚本和说明，运行后可以实操理解到更多内容。

# 概述

计算机本质还是脱离不了冯诺依曼体系，硬件体系，取指执行等等。可是，到底一个程序，如何就和硬件亲密无间的运行起来了呢，应该是很多人不了解的，包括很多计算机专业的同学可能也不是很了解。

本质上，其实就是一个“从代码编译、然后不同目标文件链接，最终加载到内存中，被操作系统管理起来的一个进程，可能还会动态的再去链接其他的一些程序（如动态链接库）的过程”，但是，到底每个部分都隐藏着哪些细节和知识呢？我们来一起探索一下。

# 编译

先说说编译吧，由于我没学过编译，其实我对词法分析、语法分析也不甚了解，找机会再深入吧，这里只是把大致知识梳理一下。

`词法分析->语法分析->语义分析->中间代码生成->目标代码生成`

- 首先是$\color{red}{词法分析}$，通过FSM（有限状态机）模型，说白了，就是按照语法定义好的样子，挨个扫描源代码，把其中的每个单词和符号，都给他做个归类，比如你是关键字、你是标识符、你是字符串还是数字的值等，然后把大家都分门别类的放到各个表中（符号表、文字表）。如果你不符合语法规则，那么对不起，词法分析过程中，就会给出各类警告，咱们编译过程中看到的很多语法错误，就是它干的。有个开源的lex的程序，可以搞来玩玩，体会一下这个过程。

- 词法分析后，就是$\color{red}{语法分析}$了，由词法分析的符号表，要形成一个抽象语法树，方法是“上下文无关语法（CFG）”。这过程，就是把程序表示成一棵树，一般来收，叶子节点就是符合和数字，而之上组合成语句，也就是表达式，层层递归，形成整个程序的语法树。同上面的词法分析一样，也有个开源项目，可以帮你做这个树的构建，就是yacc（Yet Another Compiler Compiler）。

- 接下来是$\color{red}{语义分析}$，这个我理解要比语法分析工作量小一些，主要就是干一些类型匹配、类型转换的工作，然后把这些信息更新到语法树上。

- 再往下是$\color{red}{中间语言生成}$，干嘛呢？就是把抽象语法树，转成成一个**顺序**的中间代码，这种中间代码，往往采用一种叫**三地址码**或者**P-Code**的格式，形如`x = y op z`,长成这个样子：
```
t1 = 2 + 6
array[index] = t1
```
不过这些代码，是不和硬件相关的寄存器呀、变量地址啥的相关的，还是“抽象”代码。

- 最后终于到了$\color{red}{目标代码生成}$了，就是把中间代码，转换成**目标机器**代码，这就需要和真正的硬件和操作系统打交道了，要按照目标系统，把中间代码翻译成目标操作系统的汇编指令，而且，还要给变量们分配寄存器、规定长度啥的了，最后得到了一堆汇编指令。
对于整形、浮点、字符串，都可以翻译成，把几个bytes的数据初始化到某某寄存器中，但是对于数组啊，其他的大的数据结构，就要涉及到为它们分配空间了，这样，才可以确定数组中某个index的地址啊，不过，这事儿，编译不做，留给链接去做。

# 链接

## 目标文件

目标代码是还没有链接的代码，但是已经和这台电脑和操作系统相关了，比如寄存器、数据长度，但是，对应的变量的地址没有确定。目标文件里面就是这些数据和指令代码，还有符号表和一些调试信息。

目标代码总是有个结构的，这结构其实是有规范的，就是[COFF](https://en.wikipedia.org/wiki/COFF)（Common File Format），其实，windows和linux的可执行文件（PE和ELF）也是这种格式，恩，是的，大家都是用的COFF格式。甚至动态链接库也是。linux下的file命令可以让你窥视一个文件的这些信息，可以试试。

一般目标文件（或可执行文件）会有个文件头部分，里面有是否可执行、目标硬件、操作系统等，还包含一个重要的东东，“段表”，就是用来记录段的信息。

是的，目标文件里面是按照“**段**”（Segment）来划片的，存着下面的东东：
- 代码段：.code或者叫.text
- 数据段：.data，放全局变量和局部静态变量
- BSS段：.bss，为未初始化的全局变量和局部静态变量预留位置，不占空间（？？？bss的意义？）
 
ELF头部 	| 
.text  	|
.data 	|
.bss 	|
其他段	|
段表		|
符号表	|

## 静态链接

前面有了目标文件了，链接过程，就是要把几个目标文件“凑”到一起，那么，就需要把各个段合并到一起，

![](/images/20191203/1575370638734.jpg){:class="myimg30"}

合并没啥，读每个目标文件的文件头，就可以获得各个段的信息：
- 读每个目标文件，收集各个段的信息，然后合并到一起，其实我理解就是压缩到一起，你的代码段挨着我的代码段，我们合并成一个新的，因为每个ELF目标文件都是有文件头的，这些信息都有，所以，是可以很严格合并到一起的
- 符号重定位，说白了，就是把之前调用某个函数的地址，给重新调整一下，或者某个变量的在data段中的地址重新调整一下，为毛？因为合并的时候变了啊。这步是链接最核心的东东！

```
a.o的段属性
Idx Name          Size      Address          Type
  0 __text        0000002e 0000000000000000 TEXT
  1 __compact_unwind 00000020 0000000000000030 DATA
  2 __eh_frame    00000040 0000000000000050 DATA
------------------------------------------------------------------------
b.o的段属性
Idx Name          Size      Address          Type
  0 __text        0000002c 0000000000000000 TEXT
  1 __data        00000008 000000000000002c DATA
  2 __compact_unwind 00000020 0000000000000038 DATA
  3 __eh_frame    00000040 0000000000000058 DATA
------------------------------------------------------------------------
ab.o的段属性
Idx Name          Size      Address          Type
  0 __text        0000005c 0000000000001f70 TEXT
  1 __eh_frame    00000030 0000000000001fd0 DATA
  2 __data        00000008 0000000000002000 DATA
```


## 符号重定位

“**重定位**和符号解析”非常重要，是链接核心，都干了啥？

最开始啊，编译完的目标文件，其实里面的变量地址、函数地址，基准地址，都是0，也就是啥都是0地址开始的。

可是，一旦你链接，你就不能从0开始了，你要从操作系统规定的应用进程的规定虚拟起始地址开始作为基准地址了，这个规定是多少？`0x08048094`。别问我为何是这么个怪地址，真心不知。

另外，你还合并了好几个目标文件的各个段，这样的话，里面最开始基于0地址的变量啊、函数啊，都要开始调整一通了吧。对吧？这个可以理解吧。

好，那么问题来了，怎么搞？

看个例子：
**a.c**
```
extern int shared;

int main()
{
    int a = 0;
    swap(&a, &shared);
}
```
**b.c**
```
int shared = 1;
int test = 3;

void swap(int* a, int* b) {
    *a ^= *b ^= *a ^= *b;
}
```

`gcc -c -m32 a.o b.o`得到目标文件，然后，

`objdump -d a.o`可以看到目标文件a.o的汇编：

```
00000000 <main>:
   0: 8d 4c 24 04           lea    0x4(%esp),%ecx
   4: 83 e4 f0              and    $0xfffffff0,%esp
   7: ff 71 fc              pushl  -0x4(%ecx)
   a: 55                    push   %ebp
   b: 89 e5                 mov    %esp,%ebp
   d: 51                    push   %ecx
   e: 83 ec 14              sub    $0x14,%esp
  11: 65 a1 14 00 00 00     mov    %gs:0x14,%eax
  17: 89 45 f4              mov    %eax,-0xc(%ebp)
  1a: 31 c0                 xor    %eax,%eax
  1c: c7 45 f0 00 00 00 00  movl   $0x0,-0x10(%ebp) <---- 这就是把share变量的值放到ESP(栈指针寄存器)
  23: 83 ec 08              sub    $0x8,%esp
  26: 68 00 00 00 00        push   $0x0
  2b: 8d 45 f0              lea    -0x10(%ebp),%eax
  2e: 50                    push   %eax
  2f: e8 fc ff ff ff        call   30 <main+0x30> <---- 恩，这句就是调用函数，
  34: 83 c4 10              add    $0x10,%esp
  37: b8 00 00 00 00        mov    $0x0,%eax
  3c: 8b 55 f4              mov    -0xc(%ebp),%edx
  3f: 65 33 15 14 00 00 00  xor    %gs:0x14,%edx
  46: 74 05                 je     4d <main+0x4d>
  48: e8 fc ff ff ff        call   49 <main+0x49>
  4d: 8b 4d fc              mov    -0x4(%ebp),%ecx
  50: c9                    leave
  51: 8d 61 fc              lea    -0x4(%ecx),%esp
  54: c3                    ret
```


`readelf -s a.o` , 来，看看目标文件的符号表长啥样：

```
Symbol table '.symtab' contains 12 entries:
   Num:    Value  Size Type    Bind   Vis      Ndx Name
     0: 00000000     0 NOTYPE  LOCAL  DEFAULT  UND
     1: 00000000     0 FILE    LOCAL  DEFAULT  ABS a.c
     2: 00000000     0 SECTION LOCAL  DEFAULT    1
     3: 00000000     0 SECTION LOCAL  DEFAULT    3
     4: 00000000     0 SECTION LOCAL  DEFAULT    4
     5: 00000000     0 SECTION LOCAL  DEFAULT    6
     6: 00000000     0 SECTION LOCAL  DEFAULT    7
     7: 00000000     0 SECTION LOCAL  DEFAULT    5
     8: 00000000    85 FUNC    GLOBAL DEFAULT    1 main
     9: 00000000     0 NOTYPE  GLOBAL DEFAULT  UND shared
    10: 00000000     0 NOTYPE  GLOBAL DEFAULT  UND swap
    11: 00000000     0 NOTYPE  GLOBAL DEFAULT  UND __stack_chk_fail
```

链接ba

`ld -static -m elf_i386 -e main b.o a.o -o ab`

`objdump -d ab`:显示一下ab的代码

```
08048094 <swap>:
 8048094: 55                    push   %ebp
 8048095: 89 e5                 mov    %esp,%ebp
 8048097: 8b 45 08              mov    0x8(%ebp),%eax
 804809a: 8b 10                 mov    (%eax),%edx
 804809c: 8b 45 0c              mov    0xc(%ebp),%eax
 804809f: 8b 00                 mov    (%eax),%eax
 80480a1: 31 c2                 xor    %eax,%edx
 80480a3: 8b 45 08              mov    0x8(%ebp),%eax
 80480a6: 89 10                 mov    %edx,(%eax)
 80480a8: 8b 45 08              mov    0x8(%ebp),%eax
 80480ab: 8b 10                 mov    (%eax),%edx
 80480ad: 8b 45 0c              mov    0xc(%ebp),%eax
 80480b0: 8b 00                 mov    (%eax),%eax
 80480b2: 31 c2                 xor    %eax,%edx
 80480b4: 8b 45 0c              mov    0xc(%ebp),%eax
 80480b7: 89 10                 mov    %edx,(%eax)
 80480b9: 8b 45 0c              mov    0xc(%ebp),%eax
 80480bc: 8b 10                 mov    (%eax),%edx
 80480be: 8b 45 08              mov    0x8(%ebp),%eax
 80480c1: 8b 00                 mov    (%eax),%eax
 80480c3: 31 c2                 xor    %eax,%edx
 80480c5: 8b 45 08              mov    0x8(%ebp),%eax
 80480c8: 89 10                 mov    %edx,(%eax)
 80480ca: 90                    nop
 80480cb: 5d                    pop    %ebp
 80480cc: c3                    ret

080480cd <main>:
 80480cd: 8d 4c 24 04           lea    0x4(%esp),%ecx
 80480d1: 83 e4 f0              and    $0xfffffff0,%esp
 80480d4: ff 71 fc              pushl  -0x4(%ecx)
 80480d7: 55                    push   %ebp
 80480d8: 89 e5                 mov    %esp,%ebp
 80480da: 51                    push   %ecx
 80480db: 83 ec 14              sub    $0x14,%esp
 80480de: c7 45 f4 00 00 00 00  movl   $0x0,-0xc(%ebp) <---- c7(movl),45 f4(ebp)，给ebp赋值为0
 80480e5: 83 ec 08              sub    $0x8,%esp
 80480e8: 68 6c 91 04 08        push   $0x804916c
 80480ed: 8d 45 f4              lea    -0xc(%ebp),%eax
 80480f0: 50                    push   %eax
 80480f1: e8 9e ff ff ff        call   8048094 <swap> <---- 调用函数swap: e8(call) 9e ff ff ff()
 80480f6: 83 c4 10              add    $0x10,%esp
 80480f9: b8 00 00 00 00        mov    $0x0,%eax
 80480fe: 8b 4d fc              mov    -0x4(%ebp),%ecx
 8048101: c9                    leave
 8048102: 8d 61 fc              lea    -0x4(%ecx),%esp
 8048105: c3                    ret
```

操作码 | 操作数 | 功能
movl  | A,B   | 把A赋给B
and   | A,B   | A=A+B
push  | A     | 把A压栈
pop   | A     | 出栈结果赋值给A
call  | A     | 调用函数A
ret   | 无    | 将处理结果返回函数的调用源

# 装载

# 后记

# 参考

- [深入浅出计算机组成原理-极客时间](https://www.yuanrenxue.com/geektime/computer-organization-course.html)
- [程序是怎样跑起来的](https://book.douban.com/subject/26365491/)
- [程序员的自我修养](https://book.douban.com/subject/3652388/)
- [深入理解计算机系统](https://book.douban.com/subject/1230413/)

![](/images/20191203/1575355245154.jpg){:class="myimg"}{:class="myimg20"}
![](/images/20191203/1575355308075.jpg){:class="myimg"}{:class="myimg20"}
![](/images/20191203/1575355334411.jpg){:class="myimg"}{:class="myimg20"}