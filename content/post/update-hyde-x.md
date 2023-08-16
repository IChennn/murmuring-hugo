+++
date = "2023-04-07T09:03:08+09:00"
title = "讓Hyde-x theme重新動起來"
description = "Hyde-x在2018年之後就再也沒有更新維護，2023年已無法直接render。不過藉由override修正一些小地方，就可以讓Hyde-x重新動起來了！"
keywords = []
categories = ["Learning","Hugo"]
+++

距離上一次更新文章，不知不覺已經過了四年。最近想要重新振作起來，整理自己的生活，一方面希望能繼續保持生活中有所output的習慣，另一方面也是希望能有條理地回顧自己過去四年當中究竟有哪些成長與改變。



然而，就在我興致勃勃地將hugo重新載了回來之後（是的，這四年當中經歷了太多，連電腦都換了，當然也沒記得要裝hugo），發現我使用的Hyde-x模板竟然......已經壞了（哭



原本也想過要不要乾脆換個模板，或是沿用Hyde，但是換成其他的fork版本。畢竟Hyde-X自從2018年起就沒有再更新維護了，以後應該只會越壞越多吧ＱＱ



不過最後峰迴路轉，實在是懶得再去調整CSS，也覺得Hyde-x有一些我滿喜歡的功能（像是label），最後決定還是自己來修吧！



其實仔細看render error，只需要修改幾個小地方，並沒有想像中的整組壞光光ＸＤ因此做個紀錄，也為之後重新寫文章做個熱身＝）



##### `layouts/partials/sidebar.html`

這裡的寫法是從另一個Hyde repo直接借過來用的

https://github.com/spf13/hyde/blob/master/layouts/partials/sidebar.html

```
-    <p><font size=2>Copyright &copy; {{ .Now.Format "2006" }} <a href="{{ "/LICENSE" | absURL }}">License</a><br/>

+    <p><font size=2>{{ with .Site.Params.copyright }}{{.}}{{ else }}&copy; {{ now.Format "2006"}}. All rights reserved. {{end}}<br/>
```

Note： 這一行後來在Hyde-x中被移動到`layouts/partials/sidebar/footer.html`中了。我也忘了當初是出於什麼理由，一直將他留在我的override的`sidebar.html`中



##### `layouts/index.html`

這裡是Home page裡呈現出來的全部文章列表。

原本的寫法已經deprecated，在Hyde-x的issue中也有提到。

https://github.com/zyro/hyde-x/issues/84

```
-    {{ $paginator := .Paginate (where .Data.Pages "Type" "post") }}

+    {{ $paginator := .Paginate (where .Site.RegularPages "Type" "post") }}   
```



##### `layouts/partials/head.html`

這裡是另一個已經deprecated的寫法，在Hugo的論壇裡也有相關的討論。

https://discourse.gohugo.io/t/rsslink-cant-evaluate-field-rsslink-in-type-hugolib-pagestate-after-version-upgrade-0-91-2-v0-94-0-extended-linux-amd64/37617


修正如下：

```
-    {{ with .RSSLink }}<link href="{{ . }}" rel="alternate" type="application/rss+xml" title="{{ $siteTitle }} &middot; {{ $authorName }}" />{{ end }}

+    {{ with .OutputFormats.Get "RSS" }}<link href="{{ . }}" rel="alternate" type="application/rss+xml" title="{{ $siteTitle }} &middot; {{ $authorName }}" />{{ end }}
```



---

以上三個檔案修改完成後，又能繼續使用Hyde-x啦！畢竟當初也是花了一些時間塗塗改改了一些細節，看了這麼多年，也用得很順手了，希望這次的修改能再戰十年啊～
