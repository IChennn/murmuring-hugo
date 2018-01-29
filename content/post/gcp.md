+++
date = "2018-01-29T14:49:08+09:00"
categories = ["Learning","Tech", "google cloud platform"]
keywords = []
description = "為了要跑研究上一筆有點大的資料，開始研究怎麼用google cloud platform。此篇介紹如何在gcp的虛擬機器上面跑Jupiter notebook"
title = "用google cloud platform 開jupyter notebook!"

+++



參照這篇，做個紀錄以免我以後又忘了（真的很金魚腦 該怎麼辦

https://towardsdatascience.com/running-jupyter-notebook-in-google-cloud-platform-in-15-min-61e16da34d52



### 創建google cloud platform 帳號

直接用自己的google帳號就可以惹，一年有300美試用額度，對一般人而言真的是綽綽有餘了



### 建立vm instance :

compute> compute engine



### 安裝google cloud sdk:

可以使用本地terminal利用SSH連線登入google cloud platform的server，不一定要使用，也可以直接網頁上點一下SSH開啟console

不過用gcloud指令的話傳檔案比較快ＸＤ

解壓縮之後，執行install.sh

我自己就莫名其妙一直有奇怪的錯誤訊息（不過好像還是有安裝成功...吧），接著要認證帳戶

輸入`gcloud auth login` ，瀏覽器會自動跳出google帳號的頁面讓你點選登入的帳號

接下來就可以使用gcloud了

到google cloud platform的vm那邊，點選SSH連線旁邊小三角形後再選查看gcloud指令

![](/img/201801-gcp.jpg)

會出現類似`gcloud compute --project "<project-id>" ssh --zone "<your-zone>" "<instance-name>"` 的指令，在terminal輸入後就可以用SSH連線到google cloud platform



### 安裝anaconda3

```shell
wget http://repo.continuum.io/archive/Anaconda3-4.3.0-Linux-x86_64.sh
bash Anaconda3-4.0.0-Linux-x86_64.sh
source ~/.bashrc
```



### 設定網路

Network > VPC network

External IP address :先將網路改成static

Firewall rule: 建立一個新的rule允許port `tcp:5000` (or 任何一個想要指定開啟notebook 的port)



### 設定jupyter notebok

`jupyter notebook --generate-config` 建立config檔（若沒有的話）

在configurable configuration 輸入

```
c = get_config()
c.NotebookApp.ip = '*'
c.NotebookApp.open_browser = False
c.NotebookApp.port = <上一步允許的Port >  （ex. 5000）
```

打開Jupiter notebook 囉！

```shell
jupyter-notebook --no-browser --port=<PORT-NUMBER>
```

只要輸入一次，之後就跟一般一樣輸入`jupyter notebook`  就好了！



### 傳檔案

傳檔案進去google could platform的server

```shell
gcloud compute scp [LOCAL_FILE_PATH] [INSTANCE_NAME]:~＃
# example: bin/gcloud compute scp "/Users/Hung/cosine_sim_ver2.py" "my02":~/ 
```

從server傳檔案出來

```shell
gcloud compute scp [INSTANCE_NAME]:[REMOTE_FILE_PATH] [LOCAL_FILE_PATH]
```

.

.

ps.  題外話，要如何在terminal中讓python script print出有顏色的訊息呢

```python
from termcolor import colored
print(colored('hello', 'red'))
```

