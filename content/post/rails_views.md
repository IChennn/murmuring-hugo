+++
date = "2017-07-22T15:43:37+09:00"
title = "[Ruby on Rails] 基本View構成——HTML&CSS"
categories = ["Learning", "Rails", "HTML&CSS"]
keywords = []
description = "記錄一些學習rails 過程中碰到的疑難雜症與新學到的用法part1。主要著重在View的構成"

+++

這是第一次用Ruby on Rails 做出一個完整的網站。

已經架在Heroku上了：  https://gentle-inlet-97986.herokuapp.com/

可能跑的有點慢，畢竟整個專案很肥ＸＤ

這次的主題是一個書評網站，需要登入才能發表評論，可以自行上傳書的圖片，也可以搜尋現有的書籍資訊。

（基本架構是照著Rails 101的教學做出來的，自己另外再加了一些小功能）

---

此篇主要紀錄一些和View構成有關的部分。

## HTML partial

顧名思義，就是把一份html檔拆成好多部分來組合

基本上，一個頁面可以拆成三個部分：navbar, footer, 中間的內容。這麼拆的好處是，可以將上下兩條bar設定成全域樣式，中間的內容無論怎麼跳轉，都不會影響到上下方的bar

網站上頭的bar：`View/common/_navbar.html.erb`

```html
<!-- Navigation -->
<nav class="navbar navbar-default navbar-fixed-top topnav" role="navigation">
  ....
</nav>
```

網站下方的footer：`View/commom/_footer.html.erb`

```html
<!-- Footer -->
<footer>
   ...
</footer>
```

然後修改

`View/layouts/application.html.erb` 

(html全域樣式，不管頁面怎麼跳轉都會在)

```Html
<!DOCTYPE html>
<html>
    <head>
        <title>Book Reviews</title>
        <%= csrf_meta_tags %>
        <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track': 'reload' %>
        <%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>
    </head>
    <body>
        <div class="container-fluid">
            <%= render "common/navbar" %>
            <%= yield %>
        </div>
        <%= render "common/footer" %>
    </body>
</html>
```

`<%= yield %>` 是其他程式碼輸出的地方，也就是網頁的主要內容，會一直跳轉。

另外值得一提的是，

1. 雖然檔名是`_navbar`  ，但路徑卻是`common/navbar` 
2. 把header變成partial後，開了`rails server` 後會發現無法全頁面延展。這時只要把`<div class="container-fluid">` 的 class拿掉就好了(也就是變成只有`<div>` )

---

## 如何置底

把bar置底或置頂

```html
<nav class="navbar navbar-default navbar-fixed-bottom" role="navigation">
  ...
</nav>
```

置頂：navbar-fixed-top

---

## External css

每次產生一個View以後，總是有一些想要微調的部分，此時的CSS code要寫在哪裡呢？

`rails generate controller groups` 後，在 app/assets/stylesheets/ 下會有自動產生的 groups.scss

把css寫在這，但因為最後都會套用進(?) application.css

因此在html中要指定個別的`<div id=" ">` ，不要直接用body下指令，不然會連帶改到其他的頁面。

---

## 移到頁面中的某一段

有點像是標籤的功能，直接在區塊中指定name

```html
<a name="latest"></a>
    <div class="content-section-a">
      ......
```

頁尾標籤：

```html
<ul class="list-inline">
  <li>
  <a href="#">Home</a>
  </li>
  <li class="footer-menu-divider">&sdot;</li>
  <li>
  <a href=#latest>What's news</a>  # 不用“ ”
  </li>
</ul>
```

---

## Link button

不像一般HTML用`<a href = > </a>` 來操作超連結和按鈕，在Rails當中可以用一套特別的寫法

`<%= link_to("Cancel", groups_path, class: "btn btn-md btn-default")%>` 

其中，`"Cancel"` 是出現在按鈕上的字，`groups_path` 是按鈕按下去之後會連結到的路徑，按鈕的class有很多種大小可以選：

btn-xs, btn-sm, btn-md, btn-lg

更詳細的設定可以參考bootstrap的網站 : https://getbootstrap.com/

---

## 查看目前的action

欸，那如果不知道要連過去的那個頁面的路徑怎麼辦？！

因為Rails通常會一下子自動產生好多個檔案，有時候頁面一多自己也頭昏腦脹搞不清楚。

不過還好有個指令可以幫大家列出所有目前存在的路徑：

```Shell
$ rake routes
                  Prefix Verb   URI Pattern                    Controller#Action
        new_user_session GET    /users/sign_in(.:format)       devise/sessions#new
            user_session POST   /users/sign_in(.:format)       devise/sessions#create
    destroy_user_session DELETE /users/sign_out(.:format)      devise/sessions#destroy
           user_password POST   /users/password(.:format)      devise/passwords#create
       new_user_password GET    /users/password/new(.:format)  devise/passwords#new
      edit_user_password GET    /users/password/edit(.:format) devise/passwords#edit
      .
      .
      .
```

路徑就是prefix那欄，假設要連到第一欄的`new_user_session` ，路徑就是`new_user_session_path` 

