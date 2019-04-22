+++
keywords = []
date = "2017-07-22T14:54:32+09:00"
description = "紀錄一下如何調製（？出一個賞心悅目的terminal畫面"
title = "許我一個美麗的Terminal"
categories = ["Learning", "Terminal"]

+++

每天都去辦公室的話，自然就會想要把座位妝點的溫馨舒適：每天都開電腦，也自然就會想著要換個賞心悅目的漂亮桌面。

同理可證，每天都開terminal，怎麼捨得讓他黑壓壓一片字又小不拉機的還不去處理呢！

其實稍微爬一下國外的網站，就有很多如何客製化終端機的教學，但為了不要讓自己每次改過就忘，在此做個紀錄。

---

首先，叫出`.bash_profile.` 這個檔案

```shell
$ subl ~/.bash_profile
```

加上這兩段：

```Shell
#enable color
export CLICOLOR='true'
export LSCOLORS="gxfxcxdxcxegedabagacad"

#change hostname color shown in terminal
export PS1="\[\e[0;33m\]\u\[\033[m\]@\[\033[2;93m\]\h:\[\033[0;32m\]\w\[\033[m\]\$ "
```

其中

* `\u` 是user name
* `\h` 是host name
* `\w` 是working directory
* $ 和 ＠ 看個人喜好，也可以換成其他喜歡的符號

字母後面的是顏色的色碼，一樣可以在網路上查到各式各樣的顏色 （關鍵字：terminal color code）

最後別忘了 `source ~/.bash_profile`

按照上面的設定，最後的成果長這樣：

![terminal color](/img/201707-terminal-color.jpg)

