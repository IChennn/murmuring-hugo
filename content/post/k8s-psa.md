+++
title = "Kubernetes Pod Security Admission (PSA) 筆記與實測"
date = 2025-04-17T12:08:34+09:00
description = "記錄如何利用簡單的labeling來確保pod符合安全性要求。從概念到實測的一些筆記"
keywords = []
categories = ["Learning","Kubernetes"]

+++

自從換了新公司之後，因為業界的性質，安全性一直是在實務上一個非常大的考量。可以不做新功能，可以不上新版本，但一定要嚴格要求安全性。



## 什麼是Pod Security Admission (PSA)？



先來說說什麼是[Pod Security Standards（PSS）](https://kubernetes.io/docs/concepts/security/pod-security-standards/)。

PSS簡單來說是一系列的predefined的security policy，根據某些安全基準要求必須在manifest當中定義某項設定，而該項設定又有嚴格的Allow值，除了允許的設定內容外都被視為不合格（包含未定義該項設定）。

而PSS根據嚴格程度從輕到重分成三種等級（LEVEL）：**Privileged**、**Baseline**、**Restricted**

詳細的說明及規範的內容都在官方的文檔裡有詳細介紹，在此就割愛不贅述了。



簡單介紹了PSS後，再回頭來說PSA。[Pod Security Admission (PSA)](https://kubernetes.io/docs/concepts/security/pod-security-admission/)是一個從kubernetes 1.25開始的功能，是一個build-in的controller，以簡單的labeling方式去實踐PSS。一般來說是以namespace為單位去apply，也可以對整個cluster去apply。

而根據pod被判定為non-compliant時的動作，可以分為三種模式（MODE）：**enforce**、**audit**、**warn**

在最嚴格的enforce模式下，若pod被判定不合規，會直接被rejected。



## 實際作法



說穿了其實超級單純，就是在目標ns或是cluster加上一個label `pod-security.kubernetes.io/<MODE>: <LEVEL>` 

若只想限制特定namespace內的pod：

`kubectl label ns xxxx pod-security.kubernetes.io/enforce=restricted`

上述的缺點就是若後來創建了新namespace，很有可能就成為漏網之魚了。

若想一勞永逸對全體cluster都加上限制的話（目前公司使用Azure因此是aks的command）：

`az aks update --resource-group xxx --name xxx --security-profile workload-policy=restricted`

rollback的方式也很直觀，就是把label拿掉就行了

`kubectl label ns test pod-security.kubernetes.io/enforce-`

`az aks update --resource-group xxx --name xxx --security-profile workload-policy=none`



## 一些筆記



不知道該幫這個段落取什麼名字，哈哈哈

總之在嘗試的過程中，發現一些值得留意的點，在實務上可能會造成誤會及困擾，因此覺得該記錄一下以供日後參考。

#### non-compliant pod不會立刻被reject

當label被加上之後，若有violation的話會出現warning，詳細指出哪些設定不符規則，但現存的pod (running狀態下)並不會立刻受到影響。

pod依然可以正常運作，但是當下一次pod被update或是restart時則會被reject。因此PSA帶來的限制效果可能是有一定的時間延遲的。

也就是說PSA並不會溯及既往，只會影響發生在限制加上後的pod operation。

#### Validation

kubernetes 1.30+後，有一種新的resource可以作為validation的方法，像個守門員？一樣替你檢查新做成的pod合不合規定。

因為檢查的條件可以自己定義，因此不局限於PSA的內容，任何關於pod的設定，例如最少要幾個replica之類的規則也都沒問題。

由於這次沒有實驗這個功能，就只留下document作為一個筆記了。

https://kubernetes.io/docs/reference/access-authn-authz/validating-admission-policy/



## 實作

首先，在任何一個namespace裡隨便起一個pod，確認pod順利變成running status。

```bash
> k get all -n test
NAME                       READY   STATUS    RESTARTS   AGE
pod/test-94569c955-7k8qg   1/1     Running   0          5s

NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/test   1/1     1            1           8m36s

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/test-94569c955    1         1         1       6s

```

然後為這個ns加上最嚴格的PSA設定。由於是enforce mode，在此規範加上後，新建或更新時若不合乎規範的pod將無法啟動。

加上PSA時，系統也會很貼心地給出warning指出哪些地方不合規範，給使用者一個修改的方向。

這些內容是什麼意思，以及該如何修改才能通過PSA則在官方的文檔裡都能找到答案：

https://kubernetes.io/docs/concepts/security/pod-security-standards/

```
> k label ns test pod-security.kubernetes.io/enforce=restricted
Warning: existing pods in namespace "test" violate the new PodSecuity enforce level "restricted:latest"
Warning: test-7ddbbd8d79-877zz: allowPrivilegeEscalation != false, unrestricted capabilities, runAsNonRoot != true, seccompProfile
namespace/test labeled
```

label加上後再次檢查pod，會發現並無任何變化（已經在running狀態的既存pod不受影響）

```
> k get all -n test
NAME                       READY   STATUS    RESTARTS   AGE
pod/test-94569c955-7k8qg   1/1     Running   0          15s

NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/test   1/1     1            1           8m56s

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/test-94569c955    1         1         1       16s
```

這時若重啟pod，PSA會再次跳出warning。

```
> k rollout restart deploy test -n test
Warning: would violate PodSecurity "restricted:latest": allowPrivilegeEscalation != false (container "network-debugger" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "network-debugger" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (pod or container "network-debugger" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "network-debugger" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
deployment.apps/test restarted
```

再次確認pod狀態，會發現restart的操作確實被實行了，因此出現了一個新的replicaset，但是pod卻是原本舊的那個，並沒有被替換成新的pod。

pod的更新失敗了，新pod無法啟動

```
> k get all -n test
NAME                       READY   STATUS    RESTARTS   AGE
pod/test-94569c955-7k8qg   1/1     Running   0          4m18s

NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/test   1/1     0            1           12m

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/test-5f6b588c6    1         0         0       8s
replicaset.apps/test-94569c955    1         1         1       4m19s
```

這時我們把PSA的label拿掉。

```
> k label ns test pod-security.kubernetes.io/enforce-
namespace/test unlabeled
```

再次確認pod狀態，會發現剛才restart後更新的pod成功啟動並變成running狀態。

```
> k get all -n test
NAME                       READY   STATUS    RESTARTS   AGE
pod/test-5f6b588c6-qjrd8   1/1     Running   0          4s

NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/test   1/1     1            1           13m

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/test-5f6b588c6    1         1         1       45s
replicaset.apps/test-94569c955    0         0         0       4m56s
```



## reference

[Only one label to improve your Kubernetes security posture, with the Pod Security Admission (PSA) — just do it! | by Mathieu Benoit | Google Cloud - Community | Medium](https://medium.com/google-cloud/improve-your-kubernetes-security-posture-with-the-pod-security-admission-psa-6bb59cc6923f)

