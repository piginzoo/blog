---
layout: post
title: 谷歌Vocikit
category: fun
---
# 玩转Voice Kit

之前看过voicekit的神奇，很是羡慕，一直想找个时机，搞起来。家里的树莓派也落土一层了，必须动手利用起来，于是，某天，淘宝上果断下手，买之。

说明一下，voicekit是谷歌给爱玩的技术爱好者，开发的一个小板子，这个voicekit板子必须配合树莓派3B或者3B+，另外，现在voicekit最新固件是2.0，但是淘宝上卖的都是1.0的板子。

[VoiceKit主页](https://aiyprojects.withgoogle.com/voice/)在此，很详细，照着弄就可以了。

## 步骤

1.安装，硬件安装起来很简单，照着手册弄就可以了，把两个板子扣在一起，不用焊接，全都是直接插上。

2.刷固件！需要从voicekit主页上下载固件，然后用一个叫Etcher的软件将固件烧制到tf卡上。

3.开机，然后测试声音，麦克风啥的，顺利的话，都ok

4.然后就是去[谷歌云](https://console.cloud.google.com) 去创建一个应用，这步也是主页教程的一部分，教程很赞，照着弄就可以，主要是为了生成appid啥的几个从你树莓派链接谷歌云应用所需要的那几个appkey,screte啥的.

5.然后，教程就没有，中国特色的，需要翻墙，安装shadowsocks+privoxy，把树莓派设置成可以翻墙连接到谷歌云上去.

6.都完事后，运行固件中带的demo程序，绿灯亮起，齐活.

## 硬件准备

需要买一个树莓派，一个voicekit，淘宝上都有，如果犯懒，在一家买就可以。不过，tf卡卖的比较贵，建议在京东上购买，可以便宜很多。另外，树莓派配套的电源别忘了买一个。

## 各种坑
1. 我的板子是3B，不是3B+
2. 我买的voicekit不是2.0，是1.0，上面写着2017，而不是2018
3. 所以我只能用这个文档：https://aiyprojects.withgoogle.com/voice-v1/#users-guide-turn-on-the-google-assistant-api
4. 照着来就可以，第一步是刷固件，要装一个单独的固件，下载，然后用Etcher烧制到tf卡上就可以
5. 启动后，试试喇嘛和麦克，都ok
6. 然后照着弄auth2的认证，生成一个key
7. 然后去测试代码src/examples/voice/assistant_library_demo.py，发现不同，要翻墙
8. 于是安装shdowsocks，启动之，结果发现是sock5，不行，还是在装个privoxy，把sock5转成proxy
9. 修改配置的时候，把sock5写成了sock5t(照着网上写的，坑)，结果死活不行，搞半天
10.最终通了，curl -x 127.0.0.1:8118 google.com
11.再运行assistant_library_demo.py，提示我访问一个地址，得到一个授权码，然后再把这个授权码拷贝到term里，终于启动起来了
12.最后为了让其自启动，把sslocal，privoxy，proxy甚至都放到自启动里

## 参考

[Etcher主页](https://etcher.io/)

[VoiceKit v1.0](https://aiyprojects.withgoogle.com/voice-v1/#users-guide-turn-on-the-google-assistant-api)

[树莓派折腾之：树莓派和ShadowSocks](http://www.wuliaole.com/post/raspberry_pi_and_shadowsocks/)

[解决openssl升级到1.1.0后shadowsocks服务报错问题](https://blog.lyz810.com/article/2016/09/shadowsocks-with-openssl-greater-than-110/)

[AIY Voice Kit 初体验](https://harttle.land/2018/01/29/aiy-voice-kit.html)

## 其他
之前遇到个ssl版本的问题，undefined symbol: EVP_CIPHER_CTX_cleanup，得给源码成cleanup->reset，具体看帖子
google.auth.exceptions.TransportError: ("bad handshake: SysCallError(104, 'ECONNRESET')",) 这个往往是代理有问题