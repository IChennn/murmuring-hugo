+++
date = "2017-07-22T16:52:00+09:00"
categories = ["Learning", "Rails"]
keywords = []
description = "記錄一些學習rails 過程中碰到的疑難雜症與新學到的用法part2。實作Rails 101教程當中的文章刪除修改功能、如何修改時區（時間顯示），以及如何換行"
title = "[Ruby on Rails] 文章刪除修改實作、修改時區和換行"

+++

網站傳送門：  https://gentle-inlet-97986.herokuapp.com/

主題是一個書評網站，需要登入才能發表評論，可以自行上傳書的圖片，也可以搜尋現有的書籍資訊。

（基本架構是照著Rails 101的教學做出來的，自己另外再加了一些小功能）

------

此篇主要紀錄如何實作Rails 101教程當中沒有提供答案的文章修改刪除功能。

## 文章刪除修改實作

在`app/controllers/posts_controller.rb` 下定義`edit` method

```ruby
def edit
	@group = Group.find(params[:group_id]) 
	@post = Post.find(params[:id])
end
```

要記得`@group` 跟 `@post` 都要定義！不然會出現 NoMethodError

無論是Edit, update, destroy都需要

另外，edit介面也要同時加上`@group`跟`@post`，用array 方式表示，系統才能判斷是哪一個group裡面的哪一個post

```html
<%= simple_form_for [@group, @post] do |f| %>
  .....
```

---

## Simple_format ＆日期顯示

換行用，只要將要換行的內容放入`simple_format()` 當中就可以了

```html
<% @posts.each do |post| %>
        <tr>
          <td><%= simple_format(post.content) %></td>
          <td><%= post.user.email %></td>
          <td><%= post.created_at.to_date %></td>
        </tr>
      <% end %>
```

關於日期的顯示方式，若是只使用最簡單的`post.created_at` 會以這樣的方式呈現：

![default_timestamp](/img/201707-default_timestamp.jpg)

若想要讓樣式看起來簡潔一些，可以加上`created_at.to_date` （或是 `created_at.strftime("%Y-%m-%d")` ）就會只顯示到日期，不會出現後面的UTC之類的

![strtime_timestamp](/img/201707-strtime_timestamp.jpg)

---

## 時區更改

想要改到自己地區的時區，到`config/application.rb` 改設定：

```Ruby
config.time_zone = 'Osaka'
config.active_record.default_timezone = :local
```

