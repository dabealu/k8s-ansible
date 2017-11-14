#!/bin/bash -e

if [[ "$1" == "kubectl" ]]; then
  kubectl version 2>/dev/null | grep 'Client Version' | sed 's/.*GitVersion:"v\([0-9]*\.[0-9]*\.[0-9]*\)".*/\1/'

elif [[ "$1" == "etcd" ]]; then
  etcdctl --version | grep 'etcdctl' | sed 's/etcdctl version: \(.*\)/\1/'

elif [[ "$1" =~ kube-apiserver|kube-scheduler|kube-controller-manager|kubelet|kube-proxy ]]; then
  $1 --version 2>/dev/null | cut -f 2 -d 'v'

else
  echo 'error: first arg must be the name of k8s component, i.e. kube-apiserver'
  exit 1
fi
