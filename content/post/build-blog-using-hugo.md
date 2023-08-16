+++
date = "2017-03-20T20:28:57+08:00"
description = "其實寫部落格真的是一件很麻煩的事，但好不容易下定決心要為生活留下一點痕跡，就來記錄一下生出現在的部落格的過程吧。"
title = "如何用Hugo架出乾淨簡潔的部落格"
categories = ["Learning","Hugo" ]
keywords = []

+++

從小時候就一直覺得寫自己的部落格是一件很潮很厲害的事，當然也經營過好幾個，從最一開始的yahoo部落格、無名小站到天空部落，前前後後也寫了好幾年，可是最後都虎頭蛇尾收場ＸＤ還是別提了

但是從很早之前，我就一直對這些部落格平台有一些小小的不滿（？

1. 首先，樣板很固定，用過的幾個當中，大概只有天空算比較自由，其他就......xd
2. 很多時候只是想寫一些自己的碎碎念，並不想要知道有多少人看過，也不想要有人對此發表評論。
3. 有廣告有廣告有廣告啊啊啊

直到最近開始學著用github之後，意外發現可以利用github pages存放靜態頁面。於是又重新燃起了我寫部落格的熊熊大火啊

---

## Hugo是什麼？

簡單來說就是一個靜態網頁生成器，簡單快速好用。

可以放在任何可host網站的空間，如github或FTP。
用Go語言寫成，據說比Jekyll穩定且快（當然也比較簡單ＸＤ



## 這個網站怎麼生出來的？

有多簡單好用呢？用Hugo架一個部落格，大概需要以下幾個步驟，根據官網的[Quick start](http://gohugo.io/overview/quickstart/)這個過程大概只要2分鐘：

1. 下載hugo
2. `hugo new site <sitename>`，然後`cd`進`themes`，網路上隨便找個順眼的主題，把它`git clone`下來（ps. 如果想放github上的話，這邊請用submodule）
3. `hugo new post/<title>.md` ，寫點什麼東西進去
4. `hugo server` 就可以在本地看到熱騰騰的網站了

好了，結束收工（欸

不是啦，其實還是有很多細節可以設定，在`config.toml` 當中可以客製化一些細節，也可自己寫一個css覆蓋原本的主題做微調。真的要鑽研也是研究不完，像是short code我到現在還是沒弄懂 囧

[Hugo官網](http://gohugo.io/)裡面有很多好玩的設定，留著日後慢慢看ＸＤ



## Hosting on Github

然後呢？總不能這麼簡單漂亮的網站只有我自己看得到吧？

我當初為了研究怎麼把它放上github，搞了一天一夜快要瘋掉，[官網上的教學](http://gohugo.io/tutorials/github-pages-blog/)一個很複雜不想看懂（欸），一個怎麼試都失敗搞得我很火大ry

順帶一提github pages有分成user page跟project page兩種，托hugo的福，我之前一直不知道原來有分別，詳細差別參見[官方](https://help.github.com/articles/user-organization-and-project-pages/)。

最後在各種英文日文網站的教學拼拼湊湊下，終於成功使用user page放上去惹～（也就是網址是github.io結尾）：



##### Step1: 準備兩個repository

一個命名為`<username>.github.io`，用來放產生的靜態頁面；另一個隨意，用來放Hugo site的source code。



##### Step2: 利用hugo架網站囉

```bash
$ hugo new site <sitename>
$ cd <sitename>
$ hugo new post/<title>.md  #文章會放在content/post裡
$ git init
$ git remote add origin <隨意>.git. #對應到另一個隨意命名的repo
$ git submodule add <theme url> theme/<theme name>
```

submodule大概就是git裡的超連結，可以連到另一個獨立的repository裏，這樣原作者有什麼更新的話，就不用再手動更新了。

不過直接`git clone`下來也是可以的，只要本地有檔案還是可以產生靜態頁面。真要說有什麼不方便的話，大概就是某天想要換電腦寫文章的時候，要再額外到theme作者的頁面git clone一次而已。



##### Step3:  生成網頁

先填寫好`config.toml`內的設定，準備好要發表的文章，`hugo`後會產生一個存放靜態頁面的資料夾，預設是叫public

```bash
$ hugo
$ git submodule add <username>.github.io.git public
```

將public對應到`<username>.github.io`，這樣之後就可以直接將public中的靜態頁面push上去了



##### Step4:  準備放上GitHub

```bash
$ cd public #很重要！！
$ git add .
$ git commit -m "message"
$ git push origin master
```

為什麼說很重要呢？因為不`cd`進public，裡面的東西是不會被連帶push上去的啊！！

之後要新增文章，只要寫好之後執行`hugo`，再把public資料夾裡的東西push上去就可以更新了💕



