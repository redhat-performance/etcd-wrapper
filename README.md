Automation wrapper for etcd

Description:
      Etcd is a distributed reliable key-value store that is simple, secure,
      and fast. It's a central component in the Kubernetes architecture, 
      where it's used as Kubernetes' backing store for all cluster data.
      Etcd was initially developed by CoreOS, a company that provided a 
      container management platform. CoreOS was later acquired by Red Hat in 
      2018, and etcd is now a part of the Cloud Native Computing Foundation (CNCF),
      which is part of the Linux Foundation. Etcd is released under the 
      Apache License 2.0. 
  
Location of underlying workload: https://github.com/etcd-io/etcd

Packages required: python3,gcc,lksctp-tools-devel,bc

To run:
```
[root@hawkeye ~]# git clone https://github.com/redhat-performance/etcd-wrapper
[root@hawkeye ~]# etcd-wrapper/etcd/etcd_run
```

Options
/root/etcd-wrapper/etcd/etcd_run --usage
Usage /root/etcd-wrapper///etcd/etcd_run:
```
  
```