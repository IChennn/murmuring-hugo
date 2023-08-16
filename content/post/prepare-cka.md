+++
title = "CKA備考＆常用指令筆記"
date = 2023-08-12T17:29:03+09:00
description = "叨叨念念要考CKA（Certified Kubernetes Administrator）已經過了一年，終於在2023年趁著準備轉職的契機，一鼓作氣地把線上課看完，緊鑼密鼓的準備了約一個月，最後有驚無險地通過啦！過程中整理了一些考試時常用，實務中也有用的指令，趁著記憶猶新的時候整理記錄以供日後參考。"
keywords = []
categories = ["Learning","Kubernetes"]

+++



最初因為工作需要而開始接觸Kubernetes，組內的前輩們花了一段時間建立了一個cluster，有好幾個worker node，上面也已經deployed了各種app。

身為一個剛被配屬的小菜鳥，也從來沒有接觸過k8s，前輩們於是決定幫我開一個ナレッジ共有会，從pod的基本概念講起，淘淘不絕分享了兩小時（其實仔細想想，線上課都要20幾小時，兩小時要是我就聽懂了也是滿神的），但是只換來我呆滯的眼神跟停止思考的腦袋......

總而言之，就是一知半解，但工作還是要做，日子還是要過。我就這樣半推半就（？）進入了kubernetes的世界，竟也跌跌撞撞但有驚無險的摸懂了基本操作，甚至還主導了幾次cluster upgrade跟cluster migration。幾句話的輕描淡寫，背後也是花了好幾年的時間，期間一直在想，我應該要找個線上課老老實實地從頭開始打基本功，能順便考個CKA就好了。

但行動力像條蟲的我，拖延病一發作就是一兩年，直到今年，各種層面上想要好好整頓一下自己的生活，也包括未來的職涯。也因此好好把CKA拿到手，就又回到我的待辦事項中，趁著4月新生活打折的時機，以30%off的價格買了CKA考試。

## 線上課程

跟網路上大部分人一樣，都是找了udemy上Mumshad Mannambeth的`Certified Kubernetes Adminidtrator(CKA) with Practice Tests`來看。

不得不說，真的清楚易懂，而且每個小單元都有練習題，最後還有三個模擬試題可以練習，雖然環境和真正考試環境並不是100%相同，但也相去不遠了。課程影片和hands on lab雖然是相輔相成的，但畢竟考試的形式不是選擇題，而是上機實際操作，hands on lab其實才是決定能不能順利通過考試的關鍵！！

說實在，若有無限的時間慢慢google的話其實都不是難事（畢竟是開書考ＸＤ），但難就難在必須在有限的時間內（2小時）完成17道題目，而且要敲的指令也不算少，做完題目也得檢查一下比較保險，因此把簡單的指令記下來，並知道要怎麼在doc中搜尋出複雜的指令就成了考試對策中一個重要的環節。（大概就跟考多益一樣，到最後也不見得是在考英文能力，而是耐心跟讀題速度ＸＤ）

## kubectl常用指令

雖然說是為了考試而寫的筆記，但在自己過去的實務經驗上，好用實用的指令還是很多的，準備CKA也不只是為了那張證書，在自己的技術提升上也是受益良多了。

#### 參考Document url

- CKA開書考可參考範圍
  - https://kubernetes.io/docs/home/
- k8s cheat sheet
  - https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- 指令
  - `kubectl help`
  - https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands

#### 前置設定

- 生成yaml

  ```bash
  export do="--dry-run=client -o yaml"
  ```

#### create各種

- Pod

  - 雖然被歸類在create，但生成pod是唯一不能使用kubectl create的

    ```bash
    kubectl run <pod-name>
    ```

  - 生成1個以上container的pod
    - 先create一個container，再手動修改yaml

- Deployment, Daemonset

  - Deployment

    ```bash
    kubectl create deployment <name> --image=xxx --replicas=3 (-r 3)
    ```

  - Daemonset
    - 先create deployment，再手動將`Kind: Deployment`改成`Kind: Daemonset`

- Secret

  - `docker-registry`

    ```
    kubectl create secret docker-registry xxx --docker-server=xxx:5000 --docker-username=user --docker-password=pass
    ```

  - `generic`

    ```
    kubectl create secret generic xxx --from-literal=app=web --from-literal=pass=123
    ```

- Service

  - Expose pod(or other resource)

    - `port`: port on service
    - `target port`: port on pod(or other target)

    ```
    kubectl expose pod <pod-name> --port=6379 --target-port=8080 --type=ClusterIP --name=<svc-name>
    ```

  - 也可使用create

    ```
    kubectl create service <name>
    ```

- PV, PVC
  - 沒有指令可以創建
  - Search document by : `pv hostpath pod` 
    - https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/

#### 修改、刪除等基本操作

- Update: Edit, Replace

  - 若是pod，有可能無法直接修改，需要先存成yaml修改後再replace

    ```
    kubectl get pod xxx -o yaml > test.yaml
    kubectl replace -f test.yaml 
    ```

  - Kubectl edit

    ```
    kubectl edit <resource> <name> -n <ns>
    kubectl edit deployment test-deploy -n staging
    ```

- Delete

  - 刪除帶有同一label的resource

    ```
    kubectl delete pod -l tier=front
    ```

  - 強制刪除（等待時間可能較短）

    ```
    kubectl delete pod <name> --force --grace-period=0
    ```

- Scale out 

  - Deployment, Replicaset

    ```
    kubectl scale replicaset <replicaset-name> --replicas=5
    ```

- Check log

  ```
  kubectl logs <pod-name>
  ```

  - check log in multiple container pod

    ```
    kubectl logs <pod-name> -c <container-name> 
    ```

- Set command in container (when creating resource)

  - 生成yaml至指定path

    - `--command` 必須在一連串flag的最後

    ```
    kubectl run --image=busybox static-busybox --dry-run=client -o yaml --command -- sleep 1000 > /etc/kubernetes/manifests/static-busybox.yaml
    ```

  - 在container中執行bash script

    ```
    kubectl run myshell --image=busybox --command -- sh -c "tail xxx.log"
    ```

    - 若需要在bash中執行，卻沒有寫`sh -c`時會報錯：

      ```
      unable to start container process: exec: "tail xxx.log"
      ```

- 在既有pod中執行指令

  - 將結果存到操作VM中

    ```
    kubectl exec -it hr -- nslookup mysql.payroll > /root/CKA/nslookup.out
    ```

  - Get shell of pod

    - `-it`:  `--stdin --tty`

    ```
    kubectl exec -it shell-demo -- /bin/bash
    ```

#### select, operate on resource

- Taint node

  - Add taint

    ```
    kubectl taint node node01 <key>=<value>:NoSchedule
    ```

  - Remove taint

    ```
    kubectl taint node node01 <key>=<value>:NoSchedule-
    ```

- Rollout 

  - `deployment`, `daemonset`, `statefulsets`

  - Check version

    ```
    kubectl rollout history deployment xxx
    ```

  - rollback

    ```
    kubectl rollout undo deployment xxx --to-revision=80
    ```

- Label

  - Show label

    ```
    kubectl get node --show-labels
    ```

  - Select by label  (`-l`: `--selector`)

    ```
    kubectl get pod -l enc=dev  
    ```

  - Add label

    ```
    kubectl label node node01 <key>=<value>
    ```

- Filter namespaced resource only

  ```
  kubectl api-resources --namespaced=true/false
  ```

- Check service endpoint (point to pod)

  ```
  kubectl get ep
  ```

- Find static pod

  - Find those pod name with node name instead of hash. ex. etcd-master01

    ```
    kubectl get pod
    ```

  - Default manifest path for static pod
    - `/etc/kubernetes/manifest`

#### 一些yaml修改寫法

- 指定`scheduler`

  ```yaml
  spec: 
  	schedulerName: my-sceduler
  ```

- 指定`node`

  ```yaml
  spec: 
  	nodeName: Node-01
  ```

- 設置`env`

  - 直接指定

    - https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/#using-environment-variables-inside-of-your-config

    ```yaml
    spec:
      containers:
      - name: env-print-demo
        env:
        - name: GREETING
          value: "Warm greetings to"
        - name: HONORIFIC
          value: "The Most Honorable"
    ```

    

  - 使用Configmap的key-value pair

    - https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#define-container-environment-variables-using-configmap-data

    ```yaml
    spec:
      containers:
        - name: test-container
          env:
          - name: SPECIAL_LEVEL_KEY
            valueFrom:
              configMapKeyRef:
                name: special-config
                key: special.how
    ```

    ```yaml
    spec:
      containers:
        - name: test-container
          envFrom:
          - configMapRef:
              name: special-config
    ```

    

  - 使用Secret的key-value pair

    - Search document by: `environment variable secret/ env configmap`
    - https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/#define-container-environment-variables-using-secret-data

    ```yaml
    spec:
      containers:
      - name: envars-test-container
        env:
        - name: SECRET_USERNAME
          valueFrom:
            secretKeyRef:
              name: backend-user
              key: backend-username
    ```

    ```yaml
    spec:
      containers:
      - name: envars-test-container
        envFrom:
        - secretRef:
            name: test-secret
    ```

  - 將pod matadata設為env

    - Search document by: `env container expose`
    - https://kubernetes.io/docs/tasks/inject-data-application/environment-variable-expose-pod-information/

    ```yaml
    spec:
      containers:
        - name: test-container
          env:
            - name: MY_NODE_NAME
              valueFrom:
                fieldRef:
                  fieldPath: spec.nodeName
            - name: MY_POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: MY_POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            - name: MY_POD_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP
    ```

#### Install, Upgrade cluster

- Upgrade cluster

  - Search document by: `upgrade kubeadm`
    - https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/

- Install cluster

  - Search document by: `kubeadm install`

    - https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

  - Do the install, and do not forget to:

    ```
    kubeadm init  --apiserver-advertise-address=<k8s endpoint>
    ```

    - Endpoint can be seen by `kubectl describe svc kubernetes`

  - Manifest url of some CNI plugin

    - flannel: https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
    - weave: https://github.com/weaveworks/weave/releases/latest/download/weave-daemonset-k8s.yaml

- Join a node in existing cluster

  - need to get kubeadm join command first

    - search document by: `kubeadm token`
      - https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-token/

    ```
    kubeadm token create --print-join-command
    ```

  - If kubeadm join command not working, try `kubeadm reset`

#### etcd backup

- Search document by: `backup etcd`

  - https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#backing-up-an-etcd-cluster

- Restore 

  ```
  ETCDCTL_API=3 etcdctl snapshot restore --data-dir <where-to-store-the-recover-file> <snapshot-path>
  ```

  - For stacked cluster: edit `etcd.yaml` for  volumes part to point to new path
  - For external cluster: edit etcd data dir in `/etc/systemd/system/etcd.service`

#### Context

```
kubectl config view
kubectl config current-context
kubectl config get-clusters
kubectl config use-context cluster1
```

#### CSR

- Search document by: `csr`
  - https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#normal-user

```
kubectl certificate approve/deny xxx
```

- create user  -> create .crt (which CN is defined)  ->  create csr to request approve

- csr name is not username, username is defined in certificate!

- Check k8s certifivate content

  - search `openssl ca` , see `8. View the certificate`
  - https://kubernetes.io/docs/tasks/administer-cluster/certificates/#openssl

  ```
  openssl x509 -in /etc/kubernetes/pki/ca.crt -text -noout 
  ```

#### Securitycontext

- Search document by: `security context`
  - https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
- Decide which user to run in container
  - `root` if runasuser not defined 
  - Can be set on pod level or container level

- Have to delete and recreate pod to change securitycontext. cannot do it with `kubectl edit`

#### Networking

- CNI
  - Node connection network
    - by default, cni plugin are in `/opt/cni/bin`
    - by default, cni config are in `/etc/cni/`
  - pod network
    - `eth0`
  - service ip range
    - check kubeapiserver setting (`service-cluster-ip`) in manifest

- DNS
  - DNS IP
    - cluster ip of dns svc
  - Name resolve
    - 參考
      - https://page.codespaper.com/2019/k8s-dns-resolve/
    - root domain (`cluster.local`) should be used together. 
      - OK:   `web.default.svc.cluster.local` or just `web.default.svc`
      - NG:  `web.default.svc.cluster`
- Ingress
  - ingress(kind:ingress) vs ingress controller(kind:deployment)
    - 只有ingress，沒有controller也是可以的
  - svc in different ns can use same ingress controller(deployment)
    - Don't forget add rewrite annotation
  - Set same ingress setting in different ns will cause 503 error

#### jsonpath

```
kubectl get pv -A -o=jsonpath='{.items[*].spec.capacity.storage}'
  (same as: kubectl get pv  -o=jsonpath={.items..spec.capacity.storage})
kubectl get pv --sort-by=.spec.capacity.storage | sort -r
kubectl get pv --sort-by=.spec.capacity.storage -o=custom-columns=NAME:.metadata.name,CAPACITY:.spec.capacity.storage
kubectl get pod --no-header
kubectl config view --kubeconfig=my-kube-config -o jsonpath="{.contexts[?(@.context.user=='aws-user')].name}" > /opt/outputs/aws-context-name
kubectl get pv -o jsonpath='{.items[?(@.metadata.name=="pv-log-1")].metadata.name}'
```

- if `""` is used in jsonpath, have to specify `''` to `jsonpath='{}'`
- when using `-o=jsonpath` need to include `.item[*]` but `--sort-by` no need to
  - https://kodekloud.com/community/t/answer-is-kubectl-get-pv-sort-by-spec-capacity-storage-gt-opt-outputs-sto/227175/2

#### TroubleShooting

- Application failure
  - Check service name, port, label/selector, user

- Pod pending
  - Check kube-scheduler
- Scale problem
  - Check kube-control-manager, check mount path, command, cert file name
- Node not ready
  - Check kubelet is running or not, journalctl to see log, cert file path, restart kubelet after edit
- Pod containercreating, svc not working
  - Check if cni installed

- File not exist 
  - Check filename, file name in configmap, mountpath
- pvc not bound
  - Check if require more than pv capacity, access mode

## Linux指令

#### Grep

- `-i` :  ignore case distinction

  ```
  grep -i <keyword> xxx.yaml
  ```

- Show more result before and after the match

  - `-B 2`:  show 2 lines before the match

  - `-A 2`:  show 2 lines after the match
  - `-C 2`:  show 2 lines beafore and after the match

#### Get encryted public key

```
cat akshay.csr | base64 | tr -d "\n"
```

#### Count lines

```
kubectl get xxxxx | wc -l
```

#### Check listining port

```
netstat -nplt (numeric-ip program listen tcp)
netstat -anp | grep etcd | grep 2379 (list all program with etcd on port 2379)
```

#### Print specific column

```
kubectl top pods | awk {'print $1'}
```



