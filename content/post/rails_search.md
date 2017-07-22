+++
date = "2017-07-22T17:40:26+09:00"
keywords = []
description = "記錄一些學習rails 過程中碰到的疑難雜症與新學到的用法part4。此篇記錄如何實作簡易的搜尋功能（不使用gem），以及最新消息功能"

title = "[Ruby on Rails] 實作簡易的搜尋和最新消息功能"
categories = ["Learning", "Rails"]

+++

網站傳送門：  https://gentle-inlet-97986.herokuapp.com/

主題是一個書評網站，需要登入才能發表評論，可以自行上傳書的圖片，也可以搜尋現有的書籍資訊。

（基本架構是照著Rails 101的教學做出來的，自己另外再加了一些小功能）

------

此篇主要紀錄如何實作最新消息功能和簡易的搜尋功能，不使用任何gem。當然，有很多現成的gem可以達到非常強大的搜尋功能，若有需要也想找機會試試（可是功能越強大說明通常也就越難懂ＸＤ（哭）。

## 簡易搜尋功能

以搜尋書本為例：

想達到的功能是在書本列表當中可以搜尋想要的書（title和description都可以對應）

首先，找到想放置搜尋bar的頁面：`app/views/groups/index.html.erb` 

加入下面這一段code，做一個陽春的搜尋框

```html
<div>
	<%= form_tag groups_path, id: "search-form", :method => "get" do %>  
	<%= text_field_tag :search, params[:search], class: 'btn btn-default', placeholder: "Search Books" %>
	<%= submit_tag "Search", class: 'btn btn-default', name: nil %>
	<% end %>
</div>
```

再來找到controller：`app/controllers/groups_controller.rb` 

更改index的部分，這樣才會顯示搜尋結果。記得paginate的部分也要寫，不然搜尋結果的頁面會報錯

```ruby
def index
    if params[:search]
      @groups = Group.search(params[:search]).recent.paginate(:page => params[:page], :per_page => 10)
    else 
      @groups = Group.all.recent.paginate(:page => params[:page], :per_page => 10)
    end
end
```

最後是model的部分：`app/models/group.rb` 

定義搜尋的動作，這邊我想要可以同時搜尋書的title跟description

```ruby
def self.search(search)
  		if search
    		#where("title LIKE ?", "%#{search}%") 
  			where("title LIKE :search OR description LIKE :search", search: "%#{search}%")
  		else
    		all
    	end
    end
```

如果只想要搜尋一個欄位（例如title的話），就用註解掉的那行就可以了。

---

## 最新消息：只想要顯示n個結果

概念：最新消息＝按照時間排序後的前n筆資料。不得不說，是有點土法煉鋼，很陽春的方法ＸＤＤ

首先，在view當中，就和一般顯示清單一樣：

```html
<table class="table table-hover">
	<thead>
    	<tr>
          <td></td>
          <td><h4>Title</h4></td>
         </tr>
    </thead>
    <tbody>   
         <% @groups.each do |group|  %>
         <tr>
         <td></td>
         <td class="text-success"><%= group.title %></td>
         </tr>
         <% end %>
     </tbody>
</table>       
```

重點在於controller當中，記得要限制返回的數量：

```ruby
def index  	
  	@groups = Group.all.limit(5).recent
end
```

對的，清單和最新消息真的只是一線之隔啊ＸＤ