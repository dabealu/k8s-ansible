### Deploy kubernetes multimaster cluster

**Q:** Why this playbook exists, when there's already kubespray doing same thing ?  
**A:** It's simpler and faster than kubespray, it doesn't support variety of different operation systems distributions, cloud providers or CNI plugins.  
Primarily it's created for bare-metal deployment on ubuntu 16.04 with calico CNI, no cluster addons other than kube-dns are installed, no container runtimes other than docker supported (maybe CRI-O support later).  

Component versions and some other settings can be found in `variables/k8s-global.yml`, don't forget to change `etcd_initial_token` here to something more secure.  
To setup the cluster, edit `hosts` file and run:
```
ansible-playbook -i hosts -u root kubernetes.yml
```
It's recommended to keep quorum of etcd server nodes (k8s_masters inventory group), so 3 or 5 etcd nodes for production cluster.

**TBD:**
- component description, api-proxy, etcd-gateway, ports, etc.
- describe cluster operations like replacement of failed master node
- externalIPs bug, see: https://github.com/kubernetes/kubernetes/issues/51499  
  to fix this issue, after deleting kubernetes svc and restarting control plane:
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
