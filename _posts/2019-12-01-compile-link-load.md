---
layout: post
title: 程序的编译、转载与链接
category: tech
---

## 前言

作为计算机专业的人，我最遗憾的就是上编译原理的时候被别的老师拉取干活了，没上成。而对一个程序怎么就从源代码变成了一个在内存里活灵活现的进程，一直也很心怀好奇。这种好奇，一直驱使我，要找个机会深入了解一下，所以，就开此贴，来督促自己深入研究下。

主要就参考三本书，在后面[参考](#参考)中列出了，其中的很多基础知识和细节我不再赘述，主要会写一写我对很多关键知识的理解和说明。

三本书里，最主要还是《程序员的自我修养 - 链接、装载与库》，里面的代码我放到了[我的github](https://github.com/piginzoo/link-load-library-code)上，并且配有shell脚本和说明，运行后可以实操理解到更多内容。

另外，为了方便自己的实验，制作了一个ubuntu的环境，并且内置了代码，方便实验：
(阿里docker镜像)[registry.cn-hangzhou.aliyuncs.com/piginzoo/learn]

`docker pull registry.cn-hangzhou.aliyuncs.com/piginzoo/learn:1.0`

## 概述

计算机本质还是脱离不了冯诺依曼体系，硬件体系，取指执行等等。可是，到底一个程序，如何就和硬件亲密无间的运行起来了呢，应该是很多人不了解的，包括很多计算机专业的同学可能也不是很了解。

本质上，其实就是一个“从代码编译、然后不同目标文件链接，最终加载到内存中，被操作系统管理起来的一个进程，可能还会动态的再去链接其他的一些程序（如动态链接库）的过程”，但是，到底每个部分都隐藏着哪些细节和知识呢？我们来一起探索一下。



## 编译

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

## 链接

### 目标文件

目标代码是还没有链接的代码，但是已经和这台电脑和操作系统相关了，比如寄存器、数据长度，但是，对应的变量的地址没有确定。目标文件里面就是这些数据和指令代码，还有符号表和一些调试信息。

目标代码总是有个结构的，这结构其实是有规范的，就是[**COFF**](https://en.wikipedia.org/wiki/COFF)（Common File Format），其实，windows和linux的可执行文件（PE和ELF）也是这种格式，恩，是的，大家都是用的COFF格式。甚至动态链接库也是。linux下的file命令可以让你窥视一个文件的这些信息，可以试试。

>通过file命令可以参看目标文件、elf可执行文件，甚至shell文件：

```
      file /lib/x86_64-linux-gnu/libc-2.27.so
      /lib/x86_64-linux-gnu/libc-2.27.so: ELF 64-bit LSB shared object, x86-64, version 1 (GNU/Linux), dynamically linked, interpreter /lib64/l, BuildID[sha1]=b417c0ba7cc5cf06d1d1bed6652cedb9253c60d0, for GNU/Linux 3.2.0, stripped

      file run.sh
      run.sh: Bourne-Again shell script, UTF-8 Unicode text executable

      file a.o
      a.o: ELF 64-bit LSB relocatable, x86-64, version 1 (SYSV), not stripped

      file ab
      ab: ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), statically linked, not stripped
```

### 目标文件的结构

目标文件（或可执行文件），都有一个完整的机构:

ELF头部   | 
.text   |
.data   |
.bss  |
其他段 |
段表    |
符号表 |

#### 文件头（ELF Header）

会有个文件头部分，里面有是否可执行、目标硬件、操作系统等，还包含一个重要的东东，“段表”，就是用来记录段的信息。

```
      ELF Header:
        Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00
        Class:                             ELF64
        Data:                              2's complement, little endian
        Version:                           1 (current)
        OS/ABI:                            UNIX - System V
        ABI Version:                       0
        Type:                              REL (Relocatable file)
        Machine:                           Advanced Micro Devices X86-64
        Version:                           0x1
        Entry point address:               0x0
        Start of program headers:          0 (bytes into file)
        Start of section headers:          816 (bytes into file)
        Flags:                             0x0
        Size of this header:               64 (bytes)
        Size of program headers:           0 (bytes)
        Number of program headers:         0
        Size of section headers:           64 (bytes)
        Number of section headers:         12
        Section header string table index: 11
```
- "7f 45 4c 46"是**ELF魔法数**，其实就是DEL字符加上“ELF”3个字母，表明他是一个elf目标或者可执行文件
关于elf文件头格式。

关于更详细的elf文件头的内容，可以参考：
- [ELF 格式解析](https://paper.seebug.org/papers/Archive/refs/elf/Understanding_ELF.pdf)
- [ELF文件格式解析](https://blog.csdn.net/feglass/article/details/51469511)
- [ELF文件格式分析](http://gnaixx.cc/2016/09/30/20160930_elf-file/)

#### 段表

除了elf文件头，就属段表重要了，各个段的信息都在这里呢，先看个例子：
 
`readelf -S ab`

```
      There are 9 section headers, starting at offset 0x1208:

      Section Headers:
        [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
        [ 0]                   NULL            00000000 000000 000000 00      0   0  0
        [ 1] .text             PROGBITS        08048094 000094 000091 00  AX  0   0  1
        [ 2] .eh_frame         PROGBITS        08048128 000128 000080 00   A  0   0  4
        [ 3] .got.plt          PROGBITS        0804a000 001000 00000c 04  WA  0   0  4
        [ 4] .data             PROGBITS        0804a00c 00100c 000008 00  WA  0   0  4
        [ 5] .comment          PROGBITS        00000000 001014 00002b 01  MS  0   0  1
        [ 6] .symtab           SYMTAB          00000000 001040 000120 10      7  10  4
        [ 7] .strtab           STRTAB          00000000 001160 000063 00      0   0  1
        [ 8] .shstrtab         STRTAB          00000000 0011c3 000043 00      0   0  1
      Key to Flags:
        W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
        L (link order), O (extra OS processing required), G (group), T (TLS),
        C (compressed), x (unknown), o (OS specific), E (exclude),
        p (processor specific)
```
这个可执行文件里面有9个段。

常见的3个段：代码段、数据段、bss段:
- 代码段：.code或者叫.text
- 数据段：.data，放全局变量和局部静态变量
- BSS段：.bss，为未初始化的全局变量和局部静态变量预留位置，不占空间（？？？bss的意义？）

还有其他一堆的段：
- .strtab : String Table 字符串表，用于存储 ELF 文件中用到的各种字符串。
- .symtab : Symbol Table 符号表，从这里可以所以文件中的各个符号。
- .shstrtab : 是各个段的名称表，实际上是由各个段的名字组成的一个字符串数组。
- .hash : 符号哈希表。
- .line : 调试时的行号表，即源代码行号与编译后指令的对应表。
- .dynamic : 动态链接信息。
- .debug : 调试信息。
- .comment : 存放编译器版本信息，比如 "GCC:(GNU)4.2.0"。
- .plt 和 .got : 动态链接的跳转表和全局入口表。
- .init 和 .fini : 程序初始化和终结代码段。
- .rodata1 : Read Only Data，只读数据段，存放字符串常量，全局 const 变量，该段和 .rodata 一样。

段表里面，记着每个段的开始的位置和位移（offset）、长度，毕竟这些段，都是紧密的放在二进制文件中，需要段表的描述信息，才能把他们每个段分割开。

#### 重定位表

**.rel.xxx**

干嘛用的？

链接用的！因为你需要把某个目标中出现的函数啊、变量啊，这些东东的地址，要换成其他目标文件中的位置，也就是地址，这样才能正确的引用到这些变量，调用到这些函数啊。至于链接细节，后面惊天链接的时候再说。

长什么样？

就叫.rel.xxx，其中xxx就是text、data。

- .rel.text：代码段重定位表，就是描述代码段中出现的函数、变量的引用地址信息的描述的
- .rel.data: 数据段重定位表

#### 字符串表

**.strtab、.shstrtab**

ELF中很多字符串呢，比如函数名字啊，变量名字啊，都需要有个地方放吧，恩，他们都放到一个叫“字符串”表的段中。

#### 符号表

注意哈，字符串表只是字符串，符号表跟他不一样，符号表更重要，是表示了各个函数、变量的名字对应的代码或者内存地址啦。这玩意，在链接的时候，非常有用。因为链接，就是要找个各个变量和函数的位置啊，这样才可以更新编译阶段**空出来**的函数、变量的引用地址啊。

每个目标文件里面都有这么一个符号表，用nm和readelf都可以查看：

**a.o目标文件的符号表**

`nm a.o`

```
                 U _GLOBAL_OFFSET_TABLE_
                 U __stack_chk_fail
0000000000000000 T main
                 U shared
                 U swap
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


** 可执行文件ab的符号表 **

`nm ab`
```
      0804a000 d _GLOBAL_OFFSET_TABLE_
      0804a014 D __bss_start
      080480d7 T __x86.get_pc_thunk.ax
      0804a014 D _edata
      0804a014 D _end
      080480db T main
      0804a00c D shared
      08048094 T swap
      0804a010 D test
```

`readelf -s ab`

```
      Symbol table '.symtab' contains 18 entries:
         Num:    Value  Size Type    Bind   Vis      Ndx Name
           0: 00000000     0 NOTYPE  LOCAL  DEFAULT  UND
           1: 08048094     0 SECTION LOCAL  DEFAULT    1
           2: 08048128     0 SECTION LOCAL  DEFAULT    2
           3: 0804a000     0 SECTION LOCAL  DEFAULT    3
           4: 0804a00c     0 SECTION LOCAL  DEFAULT    4
           5: 00000000     0 SECTION LOCAL  DEFAULT    5
           6: 00000000     0 FILE    LOCAL  DEFAULT  ABS b.c
           7: 00000000     0 FILE    LOCAL  DEFAULT  ABS a.c
           8: 00000000     0 FILE    LOCAL  DEFAULT  ABS
           9: 0804a000     0 OBJECT  LOCAL  DEFAULT    3 _GLOBAL_OFFSET_TABLE_
          10: 08048094    67 FUNC    GLOBAL DEFAULT    1 swap
          11: 080480d7     0 FUNC    GLOBAL HIDDEN     1 __x86.get_pc_thunk.ax
          12: 0804a010     4 OBJECT  GLOBAL DEFAULT    4 test
          13: 0804a00c     4 OBJECT  GLOBAL DEFAULT    4 shared
          14: 0804a014     0 NOTYPE  GLOBAL DEFAULT    4 __bss_start
          15: 080480db    74 FUNC    GLOBAL DEFAULT    1 main
          16: 0804a014     0 NOTYPE  GLOBAL DEFAULT    4 _edata
          17: 0804a014     0 NOTYPE  GLOBAL DEFAULT    4 _end
```

Ndx是关键一列，说明他是干嘛的，如果是数字，就是段的编号，参考下面的段的编号片段（前面的实验中的）

如：1就是.text代码段，4就是.data数据段。

```
    上面曾经显示过的段的编号
      。。。。
        [ 1] .text             PROGBITS        08048094 000094 000091 00  AX  0   0  1
        [ 2] .eh_frame         PROGBITS        08048128 000128 000080 00   A  0   0  4
        [ 3] .got.plt          PROGBITS        0804a000 001000 00000c 04  WA  0   0  4
        [ 4] .data             PROGBITS        0804a00c 00100c 000008 00  WA  0   0  4
        [ 5] .comment          PROGBITS        00000000 001014 00002b 01  MS  0   0  1
      。。。
```

第二列Type也挺有用的：Object就表示是数据的符号；而Func就是函数符号；

## 静态链接

前面有了目标文件了，链接过程，就是要把几个目标文件“凑”到一起，那么，就需要把各个段合并到一起，

![](/images/20191203/1575370638734.jpg){:class="myimg30"}

合并没啥，读每个目标文件的文件头，就可以获得各个段的信息：
- 读每个目标文件，收集各个段的信息，然后合并到一起，其实我理解就是压缩到一起，你的代码段挨着我的代码段，我们合并成一个新的，因为每个ELF目标文件都是有文件头的，这些信息都有，所以，是可以很严格合并到一起的
- 符号重定位，说白了，就是把之前调用某个函数的地址，给重新调整一下，或者某个变量的在data段中的地址重新调整一下，为毛？因为合并的时候变了啊。这步是链接最核心的东东！

`ld a.o b.o ab`

我们来细看一下a.o+b.o=> ab的变化，特别是虚拟地址的变化：

```
a.o的段属性(objdump -h a.o)
------------------------------------------------------------------------
      Idx Name          Size      VMA               LMA               File off  Algn
        0 .text         00000051  0000000000000000  0000000000000000  00000040  2**0
                        CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
        1 .data         00000000  0000000000000000  0000000000000000  00000091  2**0
                        CONTENTS, ALLOC, LOAD, DATA
        2 .bss          00000000  0000000000000000  0000000000000000  00000091  2**0
                        ALLOC

b.o的段属性(objdump -h b.o)
------------------------------------------------------------------------
      Idx Name          Size      VMA               LMA               File off  Algn
        0 .text         0000004b  0000000000000000  0000000000000000  00000040  2**0
                        CONTENTS, ALLOC, LOAD, READONLY, CODE
        1 .data         00000008  0000000000000000  0000000000000000  0000008c  2**2
                        CONTENTS, ALLOC, LOAD, DATA
        2 .bss          00000000  0000000000000000  0000000000000000  00000094  2**0
                        ALLOC

ab的段属性(objdump -h ab)
------------------------------------------------------------------------
      Idx Name          Size      VMA       LMA       File off  Algn
        0 .text         00000091  08048094  08048094  00000094  2**0
                        CONTENTS, ALLOC, LOAD, READONLY, CODE
        1 .eh_frame     00000080  08048128  08048128  00000128  2**2
                        CONTENTS, ALLOC, LOAD, READONLY, DATA
        2 .got.plt      0000000c  0804a000  0804a000  00001000  2**2
                        CONTENTS, ALLOC, LOAD, DATA
        3 .data         00000008  0804a00c  0804a00c  0000100c  2**2
                        CONTENTS, ALLOC, LOAD, DATA
```

### 合体的ELF可执行文件

我们先不管目标文件a.o，b.o，我们直接来看合体，也就是链接他俩后，得到的可执行ELF文件吧。

先说一下VMA：我们可以看到一个概念叫**VMA**,实际上就是一个文件中虚拟地址。这个地址在目标文件中，是从0开始的；但是在可执行文件中，是0x8048000开始的；为何是这么个数？这个是因为操作系统进程虚拟地址的开始地址就是这个傻数。

这么一来，你看ab的代码段.text，就是从0x8048094开始的，长度是0x91，也就是145个字节长度的代码段。

好！段的开头地址确定了，接下来就好找，段里面的符号对应的地址了（也就是.text段中的函数，和.data段中的变量）

我们回过头来，去看几个符号：swap函数、main函数、test变量、shared变量：

```
        Num:    Value     Size Type    Bind   Vis      Ndx Name
          10:   08048094    67 FUNC    GLOBAL DEFAULT    1 swap
          12:   0804a010     4 OBJECT  GLOBAL DEFAULT    4 test
          13:   0804a00c     4 OBJECT  GLOBAL DEFAULT    4 shared
          15:   080480db    74 FUNC    GLOBAL DEFAULT    1 main
```
- main函数：地址是080480db，Ndx=1，Type=FUNC，也就是说，main这个符号，对应的是一个函数，在代码段.text,起始地址是080480db。
- test变量：地址是0804a010，Ndx=4，Type=OBJECT，也就是说，test这个符号，对应的是一个变量，在数据段，起始地址是0804a010。

那问题来了，这些地址，都是如何确定的呢？要知道a.o,b.o里面的地址还都是0作为基地址的，到了他俩合体后的可执行文件ab，怎么就填充了这些东西呢？

### 符号重定位

既然链接是把大家的代码段、数据段，都合并到一起，那么就需要修改对应的调用的地址，比如a.o要调用b.o中的函数，那合并到一起成为ab的时候，就需要修改之前a.o中的调用的地址为一个新的ab中的地址，也就是之前b.o中的那个函数swap的地址。 

那链接器是怎么做的呢？是通过“**重定位**和符号解析”完成的。

最开始啊，编译完的目标文件，其实里面的变量地址、函数地址，基准地址，都是0，也就是啥都是0地址开始的。

可是，一旦你链接，你就不能从0开始了，你要从操作系统规定的应用进程的规定虚拟起始地址开始作为基准地址了，这个规定是多少？`0x08048094`。别问我为何是这么个怪地址，真心不知。

另外，你还合并了好几个目标文件的各个段，这样的话，里面最开始基于0地址的变量啊、函数啊，都要开始调整一通了吧。对吧？这个可以理解吧。

之前每个函数、变量的地址，都是相对于0的，也就是，你是知道他们的offset的，这样的话，你只需要告诉他们新的基地址的调整值，他们就可以加上之前的offset，算出新的地址啦。把所有涉及到他们被调用的地方，都改一下，就完成了这个重定位的过程啊。

具体怎么干呢？

是通过重定位表来完成：

### 重定位表

就是一个表，记着之前每个object目标文件中，哪些函数呀、变量呀，需要被重定位，恩，这个是一个单独的段，命名还有规律呢！就是.rel.xxx，比如.rel.data、.rel.text。

看个栗子：
```
      RELOCATION RECORDS FOR [.text]:
      OFFSET           TYPE              VALUE
      0000000000000025 R_X86_64_PC32     shared-0x0000000000000004
      0000000000000032 R_X86_64_PLT32    swap-0x0000000000000004
```
看到了吧，shared变量，和swap函数，都在a.o的重定位表中被记录下来，说明，他们的地址后期会被调整。

而其中的offset中的25，就是shared变量对于数据段的起始位置的位移offset是25个字节；同样，swap函数相对于代码段开始的offset是32个字节。

另外，VALUE这列的“shared、swap”，会对应到符号表里面的饿shared、swap符号。重定位表只记录那些符号需要重定位，而关于这个函数啊、变量啊，更详细的信息，都在符号表中。

接下来，精彩的事情发生了，也就是链接中最关键的一步，也就是要修改链接完成的文件中，调用函数和变量引用的地址了：

### 指令修改

修改有很多种方法，这涉及到各个平台的寻址指令差异，比如R_X86_64_PC32，就是
```
      ---------
      a
      ---------
      a的调用swap的汇编：
        33: e8 fc ff ff ff        call   34 <main+0x34>

      a的重定位表（'.rel.text'）：
        00000034  00000e04 R_386_PLT32       00000000   swap

      a的代码段：
        [ 2] .text             PROGBITS        00000000 00003c 00004a 00  AX  0   0  1

      a的符号表：
          14: 00000000     0 NOTYPE  GLOBAL DEFAULT  UND swap

      ---------
      b
      ---------

      b的符号表：
          12: 00000000    67 FUNC    GLOBAL DEFAULT    2 swap

      ---------
      ab
      ---------
      符号表：
          10: 08048094    67 FUNC    GLOBAL DEFAULT    1 swap

      段信息（代码段）：
        [ 1] .text             PROGBITS        08048094 000094 000091 00  AX  0   0  1 

      ab的汇编（调用swap）：
       804810e: e8 81 ff ff ff        call   8048094 <swap>
```

对于32位的程序来说，一共有10种重定位的类型，想尽情了解，可以阅读[这篇博客](https://bbs.pediy.com/thread-246373.htm)，获得更多。

### 看个例子

好吧，来个糖炒栗子，俩文件a.c,b.c，然后链接成ab，那他们的目标文件和最最后的可执行文件（ELF）长啥样啊？

>
常用的查看elf的工具：readelf, dumobj, 
- 安装: apt-get install binutils
- readelf:readelf则并不借助BFD，而是直接读取ELF格式文件的信息，得到的信息也略细致一些。
- objdump:以一种可阅读的格式让你更多地了解二进制文件带有的信息的工具,objdump借助BFD，更加通用一些, 可以应付不同文件格式，它提供反汇编的功能。
还有2个有用的工具: hexdump,od
- apt-get install -y bsdmainutils  util-linux

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

**a.c的汇编文件**

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


链接ba

`ld -static -m elf_i386 -e main b.o a.o -o ab`

`objdump -d ab`:显示一下ab的代码

**链接后的 ab ELF可执行文件**

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

## 装载

### 虚拟地址空间
这段可以去大厚书上看看，

进程虚拟地址空间，在我看来是一个非常重要的概念，他的意义在于，让每个程序，甚至后面的进程概念，都变得独立起来，每个人玩自己的，不考虑啥物理啊，硬盘，在文件中的绝对位置啊，他关心的，就是只是自己在一个虚拟空间的地址位置了。这样链接器就好安排每个代码、数据的位置了，将来，装载器，也好安排指令和数据，甚至栈啊、堆啊她们的位置了，恩，与硬件无关了。

这个地址编码也很简单，就是你总线多大，我就能编码多大，比如8位总线，地址也就256个，但是到了32为，地址就可以是4G大小了，到了64为，妈呀，就算不清楚了，就很大了，对，这个地址的空间大小，都给一个程序和进程用啦，哈哈，好大好大啊，可是，真实内存可能就16G，32G，还有那么多进程兄弟们，怎么办？怎么装载进来，映射进来，恩，别急，后面我们会讲，不过，你已经自己给出了答案，就是要映射。

### 如何载入内存

前面说了，你一个可执行文件，地址空间硕大无比，那你怎么把自己这头大象，装入只有16G空间大小的“冰箱”----内存？！

答案是映射。

![](/images/20191219/1576724995161.jpg){:class="myimg50"}

这样，你就把可执行文件中的一块一块的装进内存里面了，前提是进程需要的块，比如正在或者马上要执行的代码，数据啥的，但是剩下的怎么办？还有如果内存满了怎么办？这些不用担心，操作系统负责调度，会判断你是否用到了，就给他加载；如果满了，就按照LRU算法替换旧的，诸如此类的做法。

### 进程视角

我们切换到进程的视角，进程也是要有一个虚拟空间的，注意，我们又提到了虚拟空间，前面提是在说，链接器需要，好给每段代码呀、数据呀，编个地址。现在，进程，也需要地址啊，这个地址又是一个虚拟地址，我的学习认知，觉得，她们俩不是一回事，但是差不多了多少，都应该是总线位数的编码出来的空间大小，各个内容存放的位置也不会有太大变换。

但是，毕竟是不一样的呀，所以啊，她们俩之间，也需要映射。有了这个映射，进程发现自己所需要的可执行代码缺了，才能知道到可执行文件中的第几行到第几行加载啊。对！这个映射关系叫VMA（虚拟内存区域），就是个映射表。

这个概念需要细化一下。

你说，你直接可执行文件长啥样，就原封不动的映射到进程空间，多好啊啊，这样映射多简单啊。

不是这样的。

为了空间布局上的效率，链接器，会把很多段合并，规整成可执行的段、可读写的段、只读段等，合并了后，空间利用率就高了，否则，很小的很小的一段，未来物理内存页浪费太大（物理内存页分配一般都是整数倍一块给你，比如4k），所以，链接器，趁着链接，就把小块们都合并了，这个合并信息就在VMA信息里，这个VMA信息就在可执行文件头里，通过:

`readelf -l ab` 可以查看，

```
      Elf file type is EXEC (Executable file)
      Entry point 0x80480db
      There are 3 program headers, starting at offset 52

      Program Headers:
        Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
        LOAD           0x000000 0x08048000 0x08048000 0x001a8 0x001a8 R E 0x1000
        LOAD           0x001000 0x0804a000 0x0804a000 0x00014 0x00014 RW  0x1000
        GNU_STACK      0x000000 0x00000000 0x00000000 0x00000 0x00000 RW  0x10

       Section to Segment mapping:
        Segment Sections...
         00     .text .eh_frame
         01     .got.plt .data
```
你看，Segment Sections，就告诉你了，如何合并的。

注意哈！有个词出来了：**segement**，上面我们说的VMA的段，就说的是他了，而之前，目标文件里面，可执行文件里面也有段，那个段是“sections”，我去，晕啊。

可执行文件里有俩段了哈：section和segment。

你看上面的例子，他有3个段（Segment），其中2个type是LOAD的Segment，一个是可执行的Segment，一个是只读的Segment；那第一个Segment，可执行那个，到底合并哪些Section呢? 答案是：`00     .text .eh_frame`。

这个信息，是存在可执行文件的一个叫“程序头表（Program Header Table - PHT）”里面的，就是你用readelf -f看到的内容。告诉你sections如何合并成segments。

好吧，再总结一下！

- 目标文件是有自己的sections的，so，可执行文件也一样
- 只不过，可执行文件又创造了一个概念，segment，就是把sections做了一个合并
- 但是，这事没完，真正装载的时候，放到内存里面的时候，还要

### 段（Segment）地址对齐

内存啊，都是一个一个4k的小页，便于分配，这个就不多说了，涉及到内存管理。

所以呢，操作系统一个给你，就给你一摞4k小页，那问题了了，即使你压缩了sections们成了segment，你也不正好就4k大小啊，又多又少，就算你多一丢丢4k的整数倍，操作系统都得额外再给你分配一页，多浪费啊。

办法来了，就是段地址对齐。

![](/images/20191219/1576726917641.jpg){:class="myimg"}

### 对和栈


## 动态链接


### Linux的共享库组织

Linux为了管理动态链接库的各种版本管理，定义了一个so的版本共享方案：

`libname.so.x.y.z`



# 后记

# 参考

- [深入浅出计算机组成原理-极客时间](https://www.yuanrenxue.com/geektime/computer-organization-course.html)
- [程序是怎样跑起来的](https://book.douban.com/subject/26365491/)
- [程序员的自我修养](https://book.douban.com/subject/3652388/)
- [深入理解计算机系统](https://book.douban.com/subject/1230413/)
- [readlf、nm、ld、objdump、ldconfig、gcc命令](https://man.linuxde.net/readelf)
- 三本小书：

![](/images/20191203/1575355245154.jpg){:class="myimg"}{:class="myimg20"}
![](/images/20191203/1575355308075.jpg){:class="myimg"}{:class="myimg20"}
![](/images/20191203/1575355334411.jpg){:class="myimg"}{:class="myimg20"}