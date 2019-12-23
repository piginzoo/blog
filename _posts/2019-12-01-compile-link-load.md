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

每天，无数的程序，他们被写出来，编译出来，部署上去，不停的跑着，他们干着千奇百怪的事情，可是，就想千奇百怪、光怪陆离的这个世界和社会一样，都是由每个人每个个体组成的，再剖析每个人，都是一样的结构，再深入，就是细胞、组织，最终是基因决定了他们。

同样，通过这个隐喻来认知计算机，我们可以知道，计算机的基因和本质就是冯诺依曼体系，啥是冯诺依曼体系呢，通俗的讲，就是定义了整个硬件体系（CPU、外存、输入输出），以及取指执行的运行流程等等。可是，到底一个程序，如何就和硬件亲密无间的运行起来了呢，应该是很多人不了解的，包括很多计算机专业的同学可能也不是很了解。

本质上，其实就是一个“从代码编译、然后不同目标文件链接，最终加载到内存中，被操作系统管理起来的一个进程，可能还会动态的再去链接其他的一些程序（如动态链接库）的过程”，但是，每个部分都隐藏着很多细节，好奇心很强的你，一定想知道，到底计算机怎么做到的。

我们这片帖子不打算讨论从硬件到进程、网络的这么庞大的体系，我们就聚焦在程序的$\color{red}{链接和加载}$，这两个主题，当然，就已经很大了。

来吧，我们来一起探索一下。

## 基础

虽然我们只聚焦在链接和加载，但是，还是需要把一些基础知识交代一下的，否则，是无法理解链接和加载的。

### 硬件基础

先说说硬件吧，

**首先就是CPU**：

![](/images/20191223/1577076381870.jpg){:class="myimg30"}

CPU由一大堆寄存器，还有算数逻辑单元（就是做运算的），还有控制器组成，每次，通过PC（程序计数器，存着指令地址）寄存器，去内存里去寻址可执行二进制代码，然后加载到指令寄存器里，然后涉及到地址的话，再去内存里去加载数据，计算完，再写回到内存里。

CPU主频据说到了4GHz就到头了，所以，就开始多核了，我看看我笔记本上，服务器上，都是2.5-3GHz的，现在卖的多核，其实就是处理器多个，内部缓存共享打包在一起。

**然后，是主板了**：

![](/images/20191220/1576808941442.jpg){:class="myimg"}

如图，我们看到了，我们经常听说的“北桥、南桥”，他们是啥？

北桥其实就是一个计算机结构，准确说的是一个芯片，它连接的设备都高速设备，通过PCI总线，把cpu、内存、显卡串在一起，他的亲戚都是高速设备；而南桥就要慢很多了，都是鼠标、键盘、硬盘等这些“穷慢”亲戚，他们之间用ISA总线串在一起。

**硬盘呢，**

硬盘硬件上是盘片、磁道、扇区这样的一个结构，太复杂了，所以，从头到尾，给这些扇区编个号，就是所谓的“LBA（Logical Block Address）”的一个逻辑扇区的概念，方便寻址。

为了隔离，每个进程有一个自己的虚拟地址空间，然后想办法给他映射到物理内存里，但是内存不够怎么办？就想到了再细分，就是分页，分成4k的一个小页，常用的在内存里，不常用的交换到磁盘上。这就要经常用到地址映射计算（从虚拟地址到物理地址），这个工作就是MMU（Memory Management Unit），这玩意为了快都集成到CPU里面了。

**最后，说说输入输出设备**

还有好多外设，他们负责输入输出，他们一旦被外界输入东西，或者要输出东西，就要得去告诉CPU，告诉他“我有东西了，来取吧”，“我要输出啦，来帮我输出吧”，这事就要靠一个叫“中断”的机制了，你可以理解中断就是一种消息机制，用于通知CPU，来帮我干活。当然，也不是人人都可以直接骚扰CPU的，他们都要通过中断控制器来集中骚扰CPU的。

这些外设，都有自己的buffer，这些buffer也得有地址吧，这个地址叫端口。

![](/images/20191223/1577075515858.jpg){:class="myimg20"}

还得给每个设备编个号，这样系统才能识别谁是谁，每次中断，CPU一看，噢，原来是05，05是键盘啊，06！06是鼠标啊。这个号，叫中断编号（IRQ）。

每次都要骚扰CPU，非要这样么？可以直接把数据从外设的buffer（端口）里，直接灌到内存里，不用CPU参与，多好啊。对，这个做法就是DMA。每个DMA设备也得编个号，这个编号就是DMA通道，这些号可不能冲突啊。

![](/images/20191223/1577075790526.jpg){:class="myimg20"}

### 汇编基础

#### 汇编语法

GUN GCC使用传统的AT＆T语法，它在Unix-like操作系统上使用，而不是dos和windows系统上通常使用的Intel语法。
最常见的AT＆T语法的指令：movl %esp, %ebp，movl是一个最常见的汇编指令的名称，百分号表示esp和ebp是寄存器，在AT＆T语法中，有两个参数的时候，始终先给出源(source)，然后再给出目标(destination)。

`<指令>  [源]  [目标]`

#### 寄存器

寄存器是干嘛的？就是放着各种给cpu计算用的地址啊、数据用的，可以认为是为CPU计算准备数据用的。一般，分为8类：

累加寄存器：| 存储执行运算的数据和运算后的数据。 | 就是放计算用的数，算之前，算完后的
标志寄存器：| 存储运算处理后的CPU的状态。      | 一般溢出啊，或者JMP的时候看条件用的 
程序计数器：| 存储下一条指令所在内存的地址。    | 存着指令的地址，读他才能找到代码在哪，代码寻址用的
基址寄存器：| 存储数据内存的起始地址。         | 读内存用的，不过只放起始地址，寻址用的 
变址寄存器：| 存储基址寄存器的相对地址。       | 读内存用的，不过只放偏移地址，寻址用的
通用寄存器：| 存储任意数据。                 | 这个是放任意数据用的，我怎么觉得累加寄存器有点鸡肋了，用它不就得了
指令寄存器：| 存储指令。CPU内部使用，程序员无法通过程序对该寄存器进行读写操作。| 存执行指令用的
栈寄存器：  | 存储栈区域的起始地址。          | 寻址用的，永远指着当前栈的栈顶地址（内存的）

**命名**

命名上，x86一般都是指32位；x86-64一般都是指64位。32位寄存器，一般都是e开头，64位寄存器约定上都是以r开头。

**32位寄存器**

32位CPU一共有8个寄存器

%eax | %ebx | %ecx | %edx | %esi | %edi | %ebp | %esp

**详细的介绍**

%eax | 累加器(Accumulator)，用累加器进行的操作可能需要更少时间。可用于乘、 除、输入/输出等操作，使用频率很高；
%ebx | EBX称为基地址寄存器(Base Register)。它可作为存储器指针来使用
%ecx | ECX称为计数寄存器(Count Register)。 在循环和字符串操作时，要用它来控制循环次数；在位操作中，当移多位时，要用CL来指明移位的位数；
%edx | EDX称为数据寄存器(Data Register)。在进行乘、除运算时，它可作为默认的操作数参与运算，也可用于存放I/O的端口地址。
%ebp | EBP为基指针(Base Pointer)寄存器，一般作为当前堆栈的最后单元，用它可直接存取堆栈中的数据；
%esp | ESP为堆栈指针(Stack Pointer)寄存器，用它只可访问栈顶。
%esi/%edi | ESI、EDI为变址寄存器(Index Register)，它们主要用于存放存储单元在段内的偏移量， 它们可作一般的存储器指针使用。

**64位寄存器有：32个寄存器**
 
 %rax |  %rbx |  %rcx |  %rdx |  %rsi |  %rdi |  %rbp |  %rsp |  %r8  |%r9  |%r10 |  %r11 |  %r12 |  %r13 |  %r14 |  %r15 


**两者的区别：**

> 1、64位有16个寄存器，32位只有8个。但是32位前8个都有不同的命名，分别是e _ ，而64位前8个使用了r代替e，也就是r 。e开头的寄存器命名依然可以直接运用于相应寄存器的低32位。而剩下的寄存器名则是从r8 - r15，其低位分别用d，w,b指定长度。
>
>2、32位使用栈帧来作为传递的参数的保存位置，而64位使用寄存器，分别用rdi,rsi,rdx,rcx,r8,r9作为第1-6个参数。rax作为返回值
>
>3、64位没有栈帧的指针，32位用ebp作为栈帧指针，64位取消了这个设定，rbp作为通用寄存器使用
>
>4、64位支持一些形式的以PC相关的寻址，而32位只有在jmp的时候才会用到这种寻址方式。

对了，寄存器可不是L1、L2 cache啊！Cache位于CPU与主内存间，分为一级Cache(L1 Cache)和二级Cache(L2 Cache)，L1 Cache集成在CPU内部，L2 Cache早期在主板上,现在也都集成在CPU内部了，常见的容量有256KB或512KB。寄存器很少的，拿64位的来说，也就是16个。64x16，算算，也就是1024，1K啊。

总结：大致来说数据是通过内存-Cache-寄存器，Cache缓存则是为了弥补CPU与内存之间运算速度的差异而设置的的部件。

#### 寻址方式

你常看到`movl,movw`,这个l、w如下：

前缀 | 全称    | Size
B | BYTE      | 1 byte (8 bits)
W | WORD      | 2 bytes (16 bits)
L | LONG      | 4 bytes (32 bits)
Q | QUADWORD  | 8 bytes (64 bits)

就是一次你搬运的数据数量。

另外一个是寻址模式：

比如`movl %rax %rbx`，这个涉及到寻址模式：

寻址模式 | 示例 | 说明
全局符号寻址（Global Symbol） | MOVQ x, %rax
直接寻址（Immediate）   | MOVQ $56, %rax | 直接把56这个数搬到rax寄存器
寄存器寻址（Register）   | MOVQ %rbx, %rax | 把rbx里面的值，搬到rax中
间接寻址（Indirect）    |MOVQ （%rsp）, %rax | rbx里是个地址，按照这个地址寻址后的数，搬到rax中
相对基址寻址（Base-Relative） | MOVQ -8（%rbp）, %rax | rbx里是个地址，按照这个地址寻址后，再回退8个位置，那个位置里的数，搬到rax中
相对基址偏移缩放寻址（Offset-Scaled-Base-Relative） | MOVQ -16(%rbx,%rcx,8), %rax | 妈呀，地址是：指地址-16 +％rbx +％rcx * 8，然后到里面找到值，搬到rax里

#### 常用的指令

操作码 | 操作数 | 功能
movl  | A,B   | 把A赋给B
and   | A,B   | A=A+B
push  | A     | 把A压栈
pop   | A     | 出栈结果赋值给A
call  | A     | 调用函数A
ret   | 无    | 将处理结果返回函数的调用源


**参考：** [x86-64汇编入门](https://nifengz.com/introduction_x64_assembly/)

### 一些工具和玩法

这篇文档还会涉及到一些工具，这里列一下，大家可以尽情玩耍一下他们~

#### gcc

#### gdb

https://wizardforcel.gitbooks.io/100-gdb-tips/index.html

#### readelf

#### objdump


### 其他

#### 地址编码
假如有个整形变量1234，16进制是0x000004d2，占4个字节，比如是起始地址是0x10000，那么终止地址是0x10003，那么在外界看来，是0x10000还是0x10003是他的地址呢？答案是，小地址是，即0x10000是他的地址。

那接着问题来了，这个4个字节里面，怎么放这个数？

大端方式，高位在低地址，如 IBM360/370,MIPS:
| 0x10000 | 0x10001 | 0x10002 | 0x10003 |
|   d2    |   04    | 00      | 00

小端方式，高位在高地址，如 Intel 80x86 
| 0x10000 | 0x10000 | 0x10000 | 0x10000 |
|   00    |    00   |    04   |    d2   |

就是这么变态，呵呵。


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

编译不是这篇帖子的重点，这里就不过多讨论了，那也是个一大坨的东西，有机会再开个帖子讨论编译原理吧!

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


### 静态链接库

我们自己写的程序，可以编译成目标代码，然后等着链接，但是，我们可能会用到别的库，他们也是一个个的xxx.o文件么？然后，我们链接的时候，需要挨个都把他们指定链接进来么？

我们可能会用到c语言的核心库、操作系统提供的各种api的库、以及很多第三方的库。比如c的核心库，比较有名的是glibc，原始的glibc源代码很多，可以完成各种功能，如输入输出、日期、文件等等，他们其实就是一个个的xxx.o，如fread.o，time.o，printf.o，恩，就是你想象的样子的。

可是，他们被压缩到来一个大的zip文件里，叫libc.a:`./usr/lib/x86_64-linux-gnu/libc.a`，就是个大zip包，把各种\*.o都压缩进去了，据说libc.a包含了1400多个目标文件呢:

```
      objdump -t ./usr/lib/x86_64-linux-gnu/libc.a|more
      In archive ./usr/lib/x86_64-linux-gnu/libc.a:

      init-first.o:     file format elf64-x86-64

      SYMBOL TABLE:
      0000000000000000 l    d  .text  0000000000000000 .text
      0000000000000000 l    d  .data  0000000000000000 .data
      0000000000000000 l    d  .bss 0000000000000000 .bss
      .......
```

我好奇的统计了一下，其实，不止1400，我的这台ubuntu18.04上，有1690个呢：

```
      objdump -t ./usr/lib/x86_64-linux-gnu/libc.a|grep 'file format'|wc -l
      1690
```

如果你以--verbose方式运行编译命令，你能看到整个细节过程：

`gcc -static --verbose -fno-builtin a.c b.c -o ab`

```
       ....
        /usr/lib/gcc/x86_64-linux-gnu/7/cc1 -quiet -v -imultiarch x86_64-linux-gnu b.c -quiet -dumpbase b.c -mtune=generic -march=x86-64 -auxbase b -version -fno-builtin -fstack-protector-strong -Wformat -Wformat-security -o /tmp/cciXoNcB.s
       ....
       as -v --64 -o /tmp/ccMLSHnt.o /tmp/cciXoNcB.s
       .....
        /usr/lib/gcc/x86_64-linux-gnu/7/collect2 -o ab /usr/lib/gcc/x86_64-linux-gnu/7/../../../x86_64-linux-gnu/crt1.o /usr/lib/gcc/x86_64-linux-gnu/7/../../../x86_64-linux-gnu/crti.o /usr/lib/gcc/x86_64-linux-gnu/7/crtbeginT.o ...
```

可以看到整个过程就是3步：
- cc1做编译：编译成临时的汇编程序`/tmp/cciXoNcB.s`
- as汇编器：生成目标二进制代码
- collect2：实际上是一个ld的包装器，完成最后的链接

还可以看到，会链接各类的静态库，其实他们都在libc.a这类静态库中。

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

我们切换到进程的视角，进程也是要有一个虚拟空间的，叫做“进程虚拟空间（**Process Virtual Space**）”注意，我们又提到了虚拟空间，前面提是在说，链接器需要，好给每段代码呀、数据呀，编个地址。现在，进程，也需要地址啊，这个地址又是一个虚拟地址，我的学习认知，觉得，她们俩不是一回事，但是差不多了多少，都应该是总线位数的编码出来的空间大小，各个内容存放的位置也不会有太大变换。

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

看，一个物理页（4k）上，不再是放一个segment，而是还放着别的，然后物理页和进程中的页，是1：2的映射关系，浪费就浪费了，没事，反正也是虚拟的。物理上就被“压缩”到了一起，过去需要5个才能放下的内容，现在只需要3个物理页了。

### 堆和栈

可执行文件加载到进程空间里面之后，进程空间还有两个特殊的VMA区域，分别是堆和栈。

![](/images/20191219/1576734365469.jpg){:class="myimg30"}
![](/images/20191220/1576811733747.jpg){:class="myimg30"}

你通过查看linux中的进程内存映射，也可以看到这个信息：`cat /proc/555/maps`

```   ...
      55bddb42d000-55bddb4f5000 rw-p 00000000 00:00 0                          [heap]
      ...
      7ffeb1c1a000-7ffeb1c3b000 rw-p 00000000 00:00 0                          [stack]
```

### 参考

[Anatomy of a Program in Memory](https://manybutfinite.com/post/anatomy-of-a-program-in-memory/)
[Gcc 编译的背后](https://tinylab.gitbooks.io/cbook/zh/chapters/02-chapter2.html)

## 动态链接

静态链接我们大致搞清楚，接下来，我们说说动态链接。动态链接的好处很多：
- 代码段可以不用重复静态连接到需要他的可执行文件里面去了，省了磁盘空间。
- 运行期，还可以共享动态链接库的代码段啊，运行期也省内存了

### 一个栗子
lib.c
```
#include "lib.h"
#include <stdio.h>

void foobar(int i) {
    printf("Printing from lib.so --> %d\n", i);
    sleep(-1);
}
```
lib.h
```
  #ifndef LIB_H_
  #define LIB_H_

  void foobar(int i);

  #endif // LIB_H_
```

编译这个动态链接库：`gcc -fPIC -shared -o lib.so lib.c`

然后，编译引用他的程序的program1.c: `gcc -o program1 program1.c ./lib.so`

这样就可以顺利的引用这个动态链接库了。

![](/images/20191219/1576735881582.jpg)

这背后，到底发生了什么？

编译program1.c的时候，他引用了函数foobar，可是这个函数在哪里呢？所以，要在编译的时候，也就是链接的时候，告诉这个program1程序，你需要的那个foobar在lib.so里面，也就是在编译参数中，需要加入./lib.so这个文件的路径。据说，链接器要拷贝so的符号表信息到可执行文件中。

可是，在过去静态链接的时候，我们要对program1中对函数foobar的引用进行重定位，也就是修改program1中对函数foobar引用的地址，可是，现在是动态链接了，就不需要做这件事了，因为链接的时候，根本就没有foobar这个函数的代码在代码段中。

那什么时候，再告诉program1，foobar的调用地址到底是多少呢？答案是运行的时候，也就是运行期，加载lib.so的时候，再告诉program1，你该去调用哪个地址上的lib.so中的函数。

我们可以通过查看/proc/$id/maps，可以查看运行期的program1的样子：

`cat /proc/690/maps`

```
      55d35c6f0000-55d35c6f1000 r-xp 00000000 08:01 3539248                    /root/link/chapter7/program1
      55d35c8f0000-55d35c8f1000 r--p 00000000 08:01 3539248                    /root/link/chapter7/program1
      55d35c8f1000-55d35c8f2000 rw-p 00001000 08:01 3539248                    /root/link/chapter7/program1
      55d35dc53000-55d35dc74000 rw-p 00000000 00:00 0                          [heap]
      7ff68e48e000-7ff68e675000 r-xp 00000000 08:01 3671326                    /lib/x86_64-linux-gnu/libc-2.27.so
      7ff68e675000-7ff68e875000 ---p 001e7000 08:01 3671326                    /lib/x86_64-linux-gnu/libc-2.27.so
      7ff68e875000-7ff68e879000 r--p 001e7000 08:01 3671326                    /lib/x86_64-linux-gnu/libc-2.27.so
      7ff68e879000-7ff68e87b000 rw-p 001eb000 08:01 3671326                    /lib/x86_64-linux-gnu/libc-2.27.so
      7ff68e87f000-7ff68e880000 r-xp 00000000 08:01 3539246                    /root/link/chapter7/lib.so
      7ff68ea81000-7ff68eaa8000 r-xp 00000000 08:01 3671308                    /lib/x86_64-linux-gnu/ld-2.27.so
      7ffc2a646000-7ffc2a667000 rw-p 00000000 00:00 0                          [stack]
      7ffc2a66c000-7ffc2a66e000 r--p 00000000 00:00 0                          [vvar]
      7ffc2a66e000-7ffc2a670000 r-xp 00000000 00:00 0                          [vdso]
      ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0                  [vsyscall]
```

可以看到一个叫ld-2.27.so，这个玩意，其实就是**动态连接器**，系统开始的时候，他先接管控制权，加载完lib.so后，再把控制权返还给program1。凡是有动态链接库的程序，都会把他动态链接到程序的进程中的，由他首先加载动态链接库的。

### GOT和PLT

![](/images/20191219/got_plt.gif){:class="myimg"}

>对动态链接库中的函数动态解析过程如下：
1. 从调用该函数的指令跳转到该函数对应的PLT处；
2. 该函数对应的PLT第一条指令执行它对应的.GOT.PLT里的指令。第一次调用时，该函数的.GOT.PLT里保存的是它对应的PLT里第二条指令的地址；
3. 继续执行PLT第二条、第三条指令，其中第三条指令作用是跳转到公共的PLT（.PLT[0]）;
4. 公共的PLT（.PLT[0]）执行.GOT.PLT[2]指向的代码，也就是执行动态链接器的代码；
5. 动态链接器里的_dl_runtime_resolve_avx函数修改被调函数对应的.GOT.PLT里保存的地址，使之指向链接后的动态链接库里该函数的实际地址；
6. 再次调用该函数对应的PLT第一条指令，跳转到它对应的.GOT.PLT里的指令（此时已经是该函数在动态链接库中的真正地址），从而实现该函数的调用。

### 参考

- [Linux动态链接库之GOT,PLT](http://www.landq.cn/2019/08/11/Linux%E5%8A%A8%E6%80%81%E9%93%BE%E6%8E%A5%E5%BA%93%E4%B9%8BGOT-PLT/)
- [深入了解GOT,PLT和动态链接
](https://www.cnblogs.com/pannengzhi/p/2018-04-09-about-got-plt.html)
- [可执行文件的PLT和GOT](https://luomuxiaoxiao.com/?p=578)
- [Linux中的GOT和PLT到底是个啥？](https://www.freebuf.com/articles/system/135685.html)
- [聊聊Linux动态链接中的PLT和GOT](https://blog.csdn.net/linyt/article/details/51635768)

### Linux的共享库组织

Linux为了管理动态链接库的各种版本管理，定义了一个so的版本共享方案：

`libname.so.x.y.z`

- x是主版本号：重大升级才会变，不向前兼容，之前的引用的程序都要重新编译
- y是次版本号：原有的东东不变，增加了一些东西而已，向前兼容
- z是发布版本号：任何接口都没变，只是修复了bug，改进了性能而已

**SO-NAME**

Linux有个命名机制，用来管理so们之间的关系，这个机制叫SO-NAME。

任何一个so，都对应一个SO-NAME，其实就是`libname.so.x`，对，去掉了y和z。

一般系统的so，不管他的次版本号和发布版本号是多少，都会给他建立一个SO-NAME的软连接，例如 libfoo.so.2.6.1，系统就会给他建立一个叫libfoo.so.2的软链。

为什么要这么干呢？

这个软连接会指向这个so的最新版本，比如我有2个libfoo，一个是libfoo.so.2.6.1，一个是libfoo.so.2.5.5，那么软连接默认就会指向版本最新的libfoo.so.2.6.1。

在编译的时候，我们往往需要引入依赖的链接库，这个时候，依赖的so，使用软链接的SO-NAME，而不使用详细的细版本号。

在编译的ELF可执行文件中，会存在.dynamic段，用来保存自己所依赖的so的SO-NAME。

在编译的时候，有个更简洁指定lib的方式，就是`gcc -lxxx`，xxx就是libname中的name，比如`gcc -lfoo`就是告诉，链接的时候，去链接一个叫libfoo.so的最新的库，当然，这个是动态链接。如果加上-static：`gcc -static -lfoo`就会去默认静态链接libfoo.a的静态链接库，规则是一样的，顺道提一句。

**ldconfig**

Linux提供了一个工具“ldconfig”，运行它，linux就会遍历所有的共享库目录，然后更新所有的so的软链，指向她们的最新版，所以一般安装了新的so，都会运行一遍ldconfig。

### 系统的共享库路径

在Linux下，是尊崇一个叫FHS（File Hierarchy Standard）的一个标准，来规定系统文件是如何存放的。

- /lib：存放最关键的基础共享库，比如动态链接器、C语言运行库、数学库，她们都是/bin,/sbin里面的系统程序用到的库
- /usr/lib: 一般都是一些开发用到的 devel库啥的
- /usr/local/lib：一般都是一些第三方库，GNU标准推荐第三方的库安装到这个目录下

另外说一句/usr目录不是user的意思，而是“unix system resources”的缩写，哈哈。

[详细了解/usr](https://www.cnblogs.com/sddai/p/10615387.html):
>/usr 是系统核心所在，包含了所有的共享文件。它是 unix 系统中最重要的目录之一，涵盖了二进制文件，各种文档，各种头文件，还有各种库文件；还有诸多程序，例如 ftp，telnet 等等。



# 后记

# 参考
- [南京大学-袁春风老师-计算机系统基础](https://www.bilibili.com/video/av69563153/?p=1)
- [深入浅出计算机组成原理-极客时间](https://www.yuanrenxue.com/geektime/computer-organization-course.html)
- [程序是怎样跑起来的](https://book.douban.com/subject/26365491/)
- [程序员的自我修养](https://book.douban.com/subject/3652388/)
- [深入理解计算机系统](https://book.douban.com/subject/1230413/)
- [readlf、nm、ld、objdump、ldconfig、gcc命令](https://man.linuxde.net/readelf)
- 三本小书：

![](/images/20191203/1575355245154.jpg){:class="myimg"}{:class="myimg20"}
![](/images/20191203/1575355308075.jpg){:class="myimg"}{:class="myimg20"}
![](/images/20191203/1575355334411.jpg){:class="myimg"}{:class="myimg20"}