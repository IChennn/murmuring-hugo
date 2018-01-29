+++
date = "2017-07-22T17:54:54+09:00"
keywords = []
description = "記錄一些學習rails 過程中碰到的疑難雜症與新學到的用法part6。主要紀錄一些和上傳到Heroku上有關的設定和技巧，包含如何利用AWS S3實現在Heroku上傳圖片的功能"
title = "[Ruby on Rails] 部署到Heroku囉！"
categories = ["Learning", "Rails"]

+++

網站傳送門：  https://gentle-inlet-97986.herokuapp.com/

主題是一個書評網站，需要登入才能發表評論，可以自行上傳書的圖片，也可以搜尋現有的書籍資訊。

（基本架構是照著Rails 101的教學做出來的，自己另外再加了一些小功能）

------

此篇主要紀錄如何解決上傳到Heroku時可能碰到的一些亂七八糟的小毛病。以及如何在Heroku上實現使用者上傳圖片的功能。

##第一次部署到Heroku

首先，安裝Heroku的 gem。再來，註冊一個Heroku帳號。

接下來照著這篇：https://www.railstutorial.org/book/beginning 的1.5章將Rails的設定都弄好就行了！

網路上有一些聲音認為Heroku實在是太囉唆麻煩，一大堆設定，搞不好又會上傳失敗，作為一個server實在是讓人惱火。

嘛，確實ＸＤ不過以一個新手的觀點來說，因為是免費的（當然，需要更大的空間的話就要付費的），而且玩過Heroku的人多，就算碰到什麼問題也總是能估狗到答案的，就這兩點來說還是滿不錯的啦。

---

## heroku update

在一般情況下，要將專案push到Heroku上，是這樣下指令的：

`git push heroku master`

但在進行Rails專案時，可能會開好幾個branch，假設今天要把branch h03 push到heroku 上面的話也很簡單，只要：

 `git push heroku h03:master` 

然後 `heroku run rake db:migrate` 

就可以用 `heroku open` 打開熱騰騰的網站了！

-

另外，經過實測，有幾點問題值得紀錄：

- heroku上無法顯示flashes (解決方式未知，因為覺得flash很醜，乾脆就不用了ＸＤ)
- 在`app/assets/stylesheets/application.scss` 當中加入

```scss
@import "bootstrap-sprockets";
@import "bootstrap";
```

會使heroku無法push (原因未知)

這兩點因為沒什麼必須性，因此為了省麻煩我就都直接刪掉了ＸＤ

---

## 解決在heroku上圖片無法顯示的問題

好不容易上傳成功，結果一打開——哇，所有的圖片都不見惹～～～的這種惱火感真的很讓人難忘啊...

不過解決方法也不複雜，把設定改一下就行了。只要到`Config/environments/production.rb` 當中，將

```
config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?
```

改成

```
config.serve_static_assets = true
```

---

## 上傳圖片＋Heroku

好的，終於辛辛苦苦把上傳圖片的功能做好了，想要傳到heroku上面自己看著爽一下，殊不知......

**heroku不能儲存使用者自己上傳的圖片啊！！！！**

（抱頭痛哭

好的，哭完了還是要來想想辦法

-

1.**AWS S3**

先說結論，利用AWS S3儲存圖片就可以解決這個問題了

步驟參照這篇：http://blog.qinfeng.io/posts/1383092

建立一個AWS帳號，然後新增一組IAM user，拿到credentials.csv

最後建立一個S3 bucket來裝圖片

2.**安裝gem**

在`Gemfile` 當中增加兩個gem

```
gem "figaro" 
gem "fog"
```

然後

```
bunle install
figaro install
```

此時會產生`config/application.yml` 這份文件

3.**S3 Acccess key**

在`application.yml` 當中輸入剛剛從下載的csv檔當中得到的key id跟secret key

```yml
production:
  aws_access_key_id: "key id"
  aws_secret_access_key: " secret key"
  aws_bucket_name: "bucket name"

development:
  aws_access_key_id: "key id"
  aws_secret_access_key: " secret key"
  aws_bucket_name: "bucket name"
```

接下來在`config/initializers` 當中新增 `carrierwave.rb`  :

```shell
$ touch config/initializers/carrierwave.rb
```

加上：

```ruby
CarrierWave.configure do |config|
    config.storage :fog                       
    config.fog_credentials = {
      provider:              'AWS',                        
      aws_access_key_id:     ENV["aws_access_key_id"],                 


      aws_secret_access_key: ENV["aws_secret_access_key"],    


      region:                'ap-northeast-1'    


    }
    config.fog_directory  = ENV["aws_bucket_name"] 
    config.cache_dir = "#{Rails.root}/tmp/uploads"
end
```

`ap-northeast-1` 是日本時區，其他地區要再去查

要注意`ENV[ ]`  當中的名稱必須要跟在`application.yml` 取的別名一樣，不然會錯誤

4.**更改uploader的設定**

最後到`app/uploaders/image_uploader.rb` 中第九行：

```ruby
# Choose what kind of storage to use for this uploader:
  storage :file
  #storage :fog
```

把`storage :file` 改成`storage :fog`  

5.**更改Heroku設定**

進入Heroku中的application當中，在setting當中點選Reveal Config Vars

把剛剛設定的

```
aws_access_key_id: "key id"
aws_secret_access_key: " secret key"
aws_bucket_name: "bucket name"
```

 這三項加進去

最後就可以`git push heroku master` 試試看了！



