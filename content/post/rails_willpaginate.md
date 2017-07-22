+++
date = "2017-07-22T17:10:16+09:00"
categories = ["Learning", "Rails", "Gem"]
keywords = []
description = "記錄一些學習rails 過程中碰到的疑難雜症與新學到的用法part3。此篇主要紀錄will paginate及simple_form_for這兩個好用的gem"

title = "[Ruby on Rails] 好用的will_paginate及simpl_ form_for"

+++

網站傳送門：  https://gentle-inlet-97986.herokuapp.com/

主題是一個書評網站，需要登入才能發表評論，可以自行上傳書的圖片，也可以搜尋現有的書籍資訊。

（基本架構是照著Rails 101的教學做出來的，自己另外再加了一些小功能）

------

此篇主要紀錄如何使用will paginate 及 simple form for這兩個方便又好用的gem來使網站變得更美觀。

## use simple_form_for

Simple_form_for 是一個好用的gem，可以自動調整格式

如果還沒安裝的話，記得先在gemfile裡面新增`gem "simple_form"` ，然後 `bundle install` 

下一步：

`rails generate simple_form:install --bootstrap` 執行boostrap的設定

就可以使用simple_form_for了！

使用方法也很簡單，只要將原本是`form_for` 的部分都替換成`simple_form_for` 並照著規定的格式更改內容就行了。

```html
<%= simple_form_for @group do |f| %>
	<%= f.input :description, input_html: { class: "form-horizontal", :rows => 4} %>
<% end %>
```

`:rows`  可以用來調輸入框的高度

這是使用simple_form_for的效果：

![simple_form_for_before](/img/201707-simple_form_for_before.jpg)

Simple_form_for會自動偵測不可空白的欄位，並給出警告：

![simple_form_for_adjustment](/img/201707-simple_form_for_adjustment.jpg)

- Reference  : use `form_for` 

  ```html
  <%= form_for @group do |f| %>
      <%= f.label "description", :class => "string optional control-label" %>
      <%= f.text_area :description, :class => "string optional form-control" %>
   <% end %>   
  ```

這段和上面的simple_form_for能達到的效果幾乎是一模一樣的，但明顯就囉唆了點ＸＤ

---

## will paginate

不管是什麼網站，紀錄一多，就會落落長讓人眼花撩亂，這時候有個好看簡單的分頁功能就顯得格外重要了！

安裝完will_paginate後，也要記得在寫進`Gemfile` 裡面 

首先，在`App/controllers/groups_controller.rb`  當中加入

```ruby
@posts = @group.posts.recent.paginate(:page => params[:page], :per_page => 10)
```

此時若是直接`rails server` 的話會一直出現undefined method "recent"

這是因為系統當中並沒有名為recent的方法，要自己去`app/models/post.rb` 中加入

```ruby
scope :recent, -> {order("created_at DESC")}
```

此時應該就可以順利看到分頁了！

![paginate](/img/201707-paginate.jpg)