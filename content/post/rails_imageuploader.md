+++
date = "2017-07-22T17:54:35+09:00"
title = "[Ruby on Rails] Carrierwave實作圖片上傳功能"
categories = ["Learning", "Rails"]
keywords = []
description = "記錄一些學習rails 過程中碰到的疑難雜症與新學到的用法part5。此篇記錄如何實作上傳圖片功能"

+++

網站傳送門：  https://gentle-inlet-97986.herokuapp.com/

主題是一個書評網站，需要登入才能發表評論，可以自行上傳書的圖片，也可以搜尋現有的書籍資訊。

（基本架構是照著Rails 101的教學做出來的，自己另外再加了一些小功能）

------

此篇主要紀錄如何用Carrierwave這個gem實作圖片上傳功能。

## 上傳圖片功能

首先要安裝`carrierwave` 跟`rmagick` 這兩個gem

`Gemfile` :

```
gem 'carrierwave'
gem 'rmagick'
```

##### 小插曲

在安裝rmagick之前，要先用homebrew 安裝imagemagick

```Shell
$ brew install imagemagick
```

然後安裝`rmagick` 的時候，可能會出現這樣的錯誤訊息：

```
Building native extensions.  This could take a while...
ERROR:  Error installing rmagick-2.16.0.gem:
	ERROR: Failed to build gem native extension.

    /Users/Hung/.tokaido/Rubies/2.2.2-p95/bin/ruby -r ./siteconf20170629-2407-7s934e.rb extconf.rb
checking for clang... yes
checking for Magick-config... no
checking for pkg-config... no
Can't install RMagick 2.16.0. Can't find Magick-config or pkg-config in /Users/Hung/.tokaido/bin:/Users/Hung/.tokaido/Rubies/2.2.2-p95/bin:/Users/Hung/.tokaido/Gems/2.2.0/bin:/Users/Hung/anaconda2/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin

*** extconf.rb failed ***
Could not create Makefile due to some reason, probably lack of necessary
libraries and/or headers.  Check the mkmf.log file for more details.  You may
need configuration options.

Provided configuration options:
	--with-opt-dir
	--without-opt-dir
	--with-opt-include
	--without-opt-include=${opt-dir}/include
	--with-opt-lib
	--without-opt-lib=${opt-dir}/lib
	--with-make-prog
	--without-make-prog
	--srcdir=.
	--curdir
	--ruby=/Users/Hung/.tokaido/Rubies/2.2.2-p95/bin/$(RUBY_BASE_NAME)

extconf failed, exit code 1

Gem files will remain installed in /Users/Hung/.tokaido/Gems/2.2.0/gems/rmagick-2.16.0 for inspection.
Results logged to /Users/Hung/.tokaido/Gems/2.2.0/extensions/x86_64-darwin-12/2.2.0-static/rmagick-2.16.0/gem_make.out
```

讀了錯誤訊息之後，問題應該在`Can't install RMagick 2.16.0. Can't find Magick-config or pkg-config` 

所以我又安裝了`pkg-confg` 

```
brew install pkg-config
```

但是依然有錯誤訊息，只不過這次的訊息變成`Can't install RMagick 2.16.0. Can't find MagickWand.h.` 

解決辦法：照著這篇 https://stackoverflow.com/questions/39494672/rmagick-installation-cant-find-magickwand-h

```
brew unlink imagemagick
brew install imagemagick@6 && brew link imagemagick@6 --force
```

之後`gem install rmagick` 應該就會成功了

Ps. 不過後來網路上有消息指出RMagick有洩漏訊息的問題，因此後來就改用MiniMagick了 （我那麼辛苦debug究竟是...XD

--

1.**用carrierwave建立image uploader**

```shell
$ rails generate uploader image
```

.

2.**新增model的欄位**

如果此時要儲存圖片的model都還沒建置的話，只要在generate的時候新增一個欄位給圖片就可以了。

這邊的情況是，我之前已經有了一個名為`group` 的model，但裡面沒有存放圖片的欄位，因此要另外新增

```shell
$ rails generate uploader image
$ rails generate migration add_image_to_groups
```

＊注意group有沒有s，可以在`db/migrate` 的檔名裡面找到資料表名稱

到`db/migrate/` 中新增的migrate檔裡面添加column：

```Ruby
class AddImageToGroups < ActiveRecord::Migration
  def change
  	add_column :groups, :image, :string
  end
end
```

最後`rake db:migrate` 就完成更新欄位

.

3.**連結model和uploader**

來到`app/model/group.rb` 當中，加上：

```ruby
mount_uploader :image, ImageUploader
```

 `:image` 是剛剛在model當中添加的欄位名，`ImageUploader` 的Image是uploader的名稱

.

4.**在controller當中允許更新**

來到`app/controllers/groups_controller.rb` 當中，在private的部分加上`:image` ：

```ruby
private

 	def group_params
   		params.require(:group).permit(:title, :description, :image)
 	end
```

.

5.**更改views**

在需要上傳圖片的部分，加上

```html
<%= f.file_field :image %>
```

就會自動生成上傳的按鈕了：

![img_uploader_add](/img/201707-img_uploader_add.jpg)

在需要顯示圖片的地方，則加入：

```html
<%= image_tag group.image.thumb %>
```

thumb是限制圖片大小的，下一步會提到

.

6.**限制圖片大小**

如果沒有這一步，圖片就會以原始大小呈現在網頁上，有時候會很令人驚嚇（？

來到`app/uploaders/image_uploader.rb` 當中，大概第六行的地方

```ruby
# Include RMagick or MiniMagick support:
  #include CarrierWave::RMagick
  #include CarrierWave::MiniMagick
```

選一個解除註解

第九行：

```ruby
# Choose what kind of storage to use for this uploader:
  #storage :file
  #storage :fog
```

把`storage :file` 解除註解

第35行左右：

```ruby
# Create different versions of your uploaded files:
  version :thumb do
    process resize_to_fit: [400, 400]
  end
```

可以改成任何自己喜歡的大小，`:thumb` 也可以換成別的，上一步驟圖片顯示的地方也要跟著更動就好

這時試著上傳圖片，應該就會成功了！

![img_uploader_show](/img/201707-img_uploader_show.jpg)

上傳圖片的功能很大部分是參考這篇(http://motion-express.com/blog/20140708-ruby-gem-carrierwave)

___



## 上傳圖片＋Heroku

如果選擇Heroku做為部署工具就要注意了，因為....

**heroku不能儲存使用者自己上傳的圖片啊！！！！**（登愣

如何解決？傳送門： [[Ruby on Rails] 部署到Heroku囉！](https://ichennn.github.io/blog/2017/07/ruby-on-rails-部署到heroku囉/)