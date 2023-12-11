+++
title = "Kubernetes cluster migration（verelo篇)"
date = 2023-12-12T01:04:16+09:00
description = "記錄如何將k8s上的worload和pv由舊的clustet轉移到新建的cluster。此篇參考網路上的教學文章，主要使用verelo指令來完成任務。也會記錄一些使用verelo的限制與條件。"
keywords = []
categories = ["Learning","Kubernetes"]

+++

上篇：

https://ichennn.github.io/blog/2023/11/kubernetes-cluster-migrationkubectl%E7%AF%87/



雖然上一篇使用kubectl移植workload跟pv沒有什麼問題，但就是步驟略多略複雜，又是全部手動操作，移植的對象一多，難免曠日廢時忙中有錯ＸＤ



恩～有沒有更好更快的方法呢？



突然靈光一閃，之前我不是抱著嚐鮮的心態安裝了velero在cluster裡嗎！一直以來沒什麼實際應用的機會略感可惜，這不，天上掉下來一個大好的機會，正好可以試試看velero好不好用。



## 安裝velero



其實安裝沒碰到太多的困難，只要準備好存放備份的object storage，接下來照著公式上的步驟deploy到cluster上就行了。



https://velero.io/docs/v1.12/



velero雖然看似單純的一個小工具，其實用途很多，像是disaster recovery、cluster migration、或是日常的測試時用來回復備份等等，沒有不會怎樣，但有了之後突然感覺很方便的概念。



由於不是本篇的重點，公式網站的文章也有非常詳細的說明，因此就不贅述了。



##  使用velero來備份



```
# velero backup create --from-schedule stg-k8s-backup     
INFO[0000] No Schedule.template.metadata.labels set - using Schedule.labels for backup object
backup=velero/stg-k8s-backup-20230210160910 labels="map[]"
Creating backup from schedule, all other filters are ignored.
Backup request "stg-k8s-backup-20230210160910" submitted successfully.
Run `velero backup describe stg-k8s-backup-20230210160910` or `velero backup logs stg-k8s-backup-20230210160910` for more details.

# velero backup get | grep stg-jpe12-k8s-backup-20230210
stg-k8s-backup-20230210160910          Completed★        0       1        2023-02-10 16:09:11 +0900 JST  6d       default         <none>
```



## [舊cluster]將deployment replica=0



這邊和上一篇是一樣的，主要是想要保險一點，在replica=0的狀態下移植到新的環境，避免ip衝突，或是其他有可能的紕漏。



```
# kubectl scale deployment -n test-dev jenkins-deployment --replicas=0
deployment.apps/jenkins-deployment scaled
```



```
# kubectl get all -n test-dev 
NAME                      TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)                        AGE
service/jenkins-service   LoadBalancer   10.109.1xx.xxx   172.xx.xx.xx   80:30194/TCP,50000:31910/TCP   2d

NAME                                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/jenkins-deployment             0/0     0            0           2d

NAME                                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/jenkins-deployment-9b9bbcb8c              0         0         0       2d
```



## [新cluster]使用velero來恢復備份



沒錯，就是這麼迅速簡單，已經來到了restore的步驟了ＸＤ



```
# velero restore create --from-backup stg-k8s-backup-20230210160910 --include-namespaces test-dev 
Restore request "stg-k8s-backup-20230210160910-20230210161603" submitted successfully.
Run `velero restore describe stg-k8s-backup-20230210160910-20230210161603` or `velero restore logs stg-k8s-backup-20230210160910-20230210161603` for more details.
```



這時可以發現原本在舊cluster的workload已經被原封不動的搬移到新cluster了。replicaset和pv的hash也和舊cluster一模一樣。



```
# kubectl get all -n test-dev
NAME                                                READY   STATUS    RESTARTS   AGE
pod/jenkins-deployment-9b9bbcb8c-wdfrk              1/1     Running   0          109s

NAME                      TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)                        AGE
service/jenkins-service   LoadBalancer   192.172.48.40    172.xx.xx.xx   80:30009/TCP,50000:31100/TCP   109s

NAME                                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/jenkins-deployment             1/1     1            1           109s

NAME                                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/jenkins-deployment-9b9bbcb8c              1         1         1       109s
```

 

此時進入jenkins畫面，會發現和上一集手動migration的結果一樣，舊cluster上創建的內容都出現在新cluster上了。

雖然兩者都可以達到一樣的效果，不過使用velero確實更直接、更快速可以將workload移植到新cluster囉！



## 使用velero的一些注意點與個人筆記



### velero的label

使用velero備份還原後，會發現原本的resource被velero加上了一些備份關聯的label。雖說只是幾個label也無傷大雅，不過label內容實在有夠長，看多了就覺得有夠阿雜ＸＤ

這時可以直接使用kubectl edit去刪除修正這些被另外加上的label就行。


### storageclass名稱改變時

這次的migration除了升級k8s以外，也順便整理了前輩們留下來的各種resource，其中就包括了為storageclass更名。

上一篇有提到，jenkins使用的pv其實是經由storageclass來provision的，因此理論上使用velero恢復備份時，也會經由storageclass重新provision一個pv來用。

然而若是storageclass的名稱改變了，就造成一個有點尷尬的局面——明明（對身為人類的我們來說）是同一個storageclass，但對k8s來說就是不存在的，因此沒辦法恢復原本是由舊名稱所provision的pv，也就是說，若是storageclass名更改了，就無法使用velero來進行migration或restore。

當初也是過先restore，然後kubectl edit嘗試直接修改storageclass名，可惜結果是一旦宣告使用舊storageclass來provision pv和pvc後，無論成不成功，都無法途中更改storageclass名或是nfs ip了，必須重新來過才行。

也正是因為這一點，成了這次migration最終沒有採用velero，而是土法煉鋼使用kubectl來操作的最大理由。（使用kubectl的話需要先將舊cluster的pv和pvc保存成yaml，也就可以趁還沒deploy到新cluster之前先修改storageclass了）


### 同樣的resource已經存在只是namespace改變時

這個狀況或許不太有機會發生，不過當初因為事先在新stg cluster隨便命名了一個ns來測試pypi，後來隨著migration的方針越來越清晰，最後要將原本測試用的ns給遷移到另一個命名的namespace裡。

因此狀況是這樣的：

- 有個namespace叫做test-dev，上面有一開始測試用的pypi resource包含pv
- 目標是，將test-dev的pypi移植到同一個cluster另一個叫做staging的namespace上，並使用原本就有的pv

此時可以使用velero的mapping指令來達成：

```
velero restore create --from-backup ns-test-dev-20230310 --namespace-mappings test-dev:staging --selector app.kubernetes.io/name=pypi
```

若是從別的cluster移植過來，只是需要將namespace更名的話，直接執行這個command就行。不過由於這次是同一個cluster內的移動，因此需要在pv上多下一點功夫。

- 首先，要先將舊namespace裡的東西刪除（當然，要先backup啦）（deployment、pvc之類的這時都被刪掉了）

  ```
  kubectl delete ns test-dev
  ```

  

- 再來是將pv裡面殘存的和pvc相連的reference刪除。刪掉之後pv就會被釋放出來，也才能夠被之後restore的新pvc所使用

  ```
  kubectl edit pv <pv-name>
  刪掉 claimRef: 的部分
  ```

  
