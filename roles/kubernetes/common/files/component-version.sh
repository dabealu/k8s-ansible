#!/bin/bash -e

case $1 in
  "kubernetes")
    hyperkube --version | cut -f 2 -d 'v'
    ;;
  "etcd")
    etcdctl --version | grep 'etcdctl' | sed 's/etcdctl version: \(.*\)/\1/'
    ;;
  "calicoctl")
    calicoctl version | grep 'Client Version:' | cut -f 2 -d 'v'
    ;; 
  "cfssl")
    cfssl version | grep 'Version:' | sed 's/Version: \([0-9]*\.[0-9]*\).*/\1/'
    ;;
  *)
    echo "error: first arg must be one of: kubernetes, etcd, calicoctl, cfssl"
    exit 1
    ;;
esac