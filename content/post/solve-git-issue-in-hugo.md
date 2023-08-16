+++
categories = ["Learning","Hugo"]
keywords = []
description = "記錄一下在Hugo裡塗塗改改後，卻push不上去的困境以及如何被估狗拯救。"
title = "在Hugo寫完文章，卻push不上github怎麼辦？"
date = "2017-03-21T00:33:37+08:00"

+++

今天突然心血來潮想說自己來改改看hugo theme的樣式，CSS門外漢的我，就每個檔案都給它打開來研究研究，然後手賤的塗塗改改，想說反正`hugo server` 上面看爽的就好，改壞了大不了重新`git clone`下來就好惹～～

結果，門外漢的我還是手賤，push了一些也不知道自己在改啥的東西上去後......就發現放hugo souce的repo裡的submodule好像不同步......？

…...我真的不知道我剛剛做了什麼（崩潰

為什麼public裡面的靜態網頁push不上去ＱＱＱ救命哦

想當然，就算喊破喉嚨應該也是沒人能救我  囧

自己的手賤自己救，拜過估狗大神後還是把它弄好了（雙手合十

---



### **<u>所以我到底對他做了什麼呢</u>？**



…….我真的不知道啦（哭

##### →可能原因： <font color="red">**push順序錯誤：**<font>

<font color="black">因為submodule的內容不會被連帶更新，所以要先push submodule再push上一層（如果有需要的話），不然從上一層repo連結過去會是前一次push的內容。<font>

只要連過去後發現，在顯示`branch:master`的地方會顯示`tree:<上一次的commit>`，應該就是不小心忘了先push submodule的目錄。

此時在submodule裡面嘗試push的話，就會顯示：

```
Everything up-to-date
```

一開始看到我真的是滿頭問號orz明明最新的內容都push不上去你還騙我說什麼up-to-date....



### **<u>解決方法</u>**

參照[這篇](http://stackoverflow.com/questions/4445738/unable-to-push-commits-from-a-git-submodule) [註一]，總結來說就是：

```Bash
$ cd <submodule directory>
$ git checkout master
$ git merge HEAD@{1}
$ git push origin master
```

因為現在其實有兩個branch。

```Bash
$ git branch
* (HEAD detached from <上一次的commit>)
  master
```

除了`master`以外，另一個就是我們現在所處的branch 。所以解決方法就是要把這兩個莫名其妙被我搞出來的東西merge在一起。當輸入merge指令之後，會看到：

```Bash
$ git merge HEAD@{1}
Updating 300cd65..08987fb
Fast-forward
 blog/.DS_Store                              | Bin 6148 -> 6148 bytes
 blog/{year-month-day => 2017}/.DS_Store     | Bin 6148 -> 6148 bytes
 blog/year-month-day/day_1/index.html        |  96 ----------------
 blog/year-month-day/day_2/index.html        |  96 ----------------
 .
 .
 #下接一串要update的檔案
```

耶，然後就正常了！我以後還是乖乖寫東西更新就好了，不要再亂動裡面的檔案orz

---



### `git add`的時候碰到奇怪的錯誤訊息：



如果第一步要`add`就不幸發生錯誤了

```bash
$ git add .
fatal: Unable to create '/Users/.../.git/index.lock': File exists.

Another git process seems to be running in this repository, e.g.
an editor opened by 'git commit'. Please make sure all processes
are terminated then try again. If it still fails, a git process
may have crashed in this repository earlier:
remove the file manually to continue.
```

 就直接把`index.lock`刪除即可。

```Bash
$ rm -f ./.git/index.lock
```



若無法`git add`的是submodule的話，訊息應該是這樣的：

```Bash
$ git add .
Assertion failed: (item->nowildcard_len <= item->len && item->prefix <= item->len), function prefix_pathspec, file pathspec.c, line 308.
Abort trap: 6
```

此時解決方法就不太一樣，要回到上一層處理：

```bash
$ git submodule init
$ git submodule update
```



因為自己真的很常手賤，又腦袋不太清楚就亂push東西......這些問題從一開始很慌張地去估狗，甚至考慮把整個repo砍掉重練，到現在已經見怪不怪了～～（好像沒什麼好得意XD）

------



[註一] 在stackoverflow的連結裡的狀況是headless-branch，跟我碰到的似乎有點不太一樣，不過提供的方法一樣有效就是了。



