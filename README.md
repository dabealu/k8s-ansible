## Deploy kubernetes multimaster cluster

**Q:** Why this playbook exists, when there's already kubespray doing same thing ?  
**A:** It's a bit different, simpler and faster than kubespray, it doesn't support variety of different GNU/Linux distributions, cloud providers or CNI plugins.  
Primarily it's created for bare-metal deployment on ubuntu 16.04 (centos 7 support in progress) with calico CNI, no cluster addons other than kube-dns are installed, no container runtime other than docker supported (maybe CRI-O support later).  

Component versions and some other settings can be found in `variables/k8s-global.yml`, don't forget to change `etcd_initial_token` to something more secure.  
To setup the cluster, edit `hosts` file and run:
```
ansible-playbook -i hosts -u root kubernetes.yml
```
**Note:** during playbook execution, some tasks are performed exclusively on first node of `k8s_masters` group in inventory file, ensure that this node is available and works properly.  
**Note 2:** to keep cluster working it's required to have quorum of etcd server nodes (`k8s_masters` inventory group), so consider 3, 5 or even 7 etcd nodes for production cluster.  
In most cases 3 master nodes is enough - one node can fail and cluster still will be available.  


### Requirements
Tested on bare-metal and KVM hosts with Ubuntu 16.04, but in theory it can work on a later releases and other environments too.


### Removal of failed node
Suppose we have failed node `k1`, perform removal on any other master node.  
If `k1` was a master:  
```
# list etcd members, get failed node id 5f24c1596c19839f
etcdctl.sh member list
4aae64497d02b63f, started, k2, https://192.168.88.11:2380, https://192.168.88.11:2379
5f24c1596c19839f, started, k1, https://192.168.88.12:2380, https://192.168.88.12:2379
770755e2751982de, started, k3, https://192.168.88.13:2380, https://192.168.88.13:2379
# remove node by id
etcdctl.sh member remove 5f24c1596c19839f
# remove node from kubernetes
kubectl delete node k1
# then remove failed node from ansible inventory and run playbook
```

If `k1` was a worker:
```
# remove node from kubernetes
kubectl delete node k1
```
**Note:** always try to keep 3-5-7-... master nodes in production, this will allow to withstand 1-2-3-... master's failures.


### Joining new nodes to cluster
Simply add new node to the according groups in inventory file and rerun playbook.  
**Note:** do not add more than one node to the `k8s_masters` group at a time.  


### Kube-apiserver proxy
This is additional service which resides on each worker node, it's a simple nginx TCP proxy container, started and controlled by systemd `kube-api-proxy` service.  
It listens on `localhost:9090` (port can be changed in `variables/k8s-global.yml`) and load balances all requests from `kubelet` to all cluster `kube-apiserver`s.  


---
**Known k8s bug** when using externalIPs, see: https://github.com/kubernetes/kubernetes/issues/51499  
There's a workaround to fix this issue, cleanup iptables and restart `kube-proxy` on affected worker nodes:
```
systemctl stop kube-proxy.service
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X
systemctl start kube-proxy.service
```
