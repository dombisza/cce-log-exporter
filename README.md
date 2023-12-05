# CCE node info and logs exporter

This is a simple script which will export all required information and logs for asking troubleshooting help from OTC support in regard of CCE node problems.

# Usage

### Clone repository 
Run from the workernode
```bash
git clone https://github.com/dombisza/cce-log-exporter.git
```

### Run the script as root 
Run from the workernode
```bash
sudo ./cce-log-export.sh
```

Output
```bash
[INFO] Checking available disk space on root.
[INFO] Package sar is installed.
[INFO] Package curl is installed.
[INFO] Creating target directory.
[INFO] Getting kernel version.
[INFO] Quering openstack metadata.
[INFO] Openstack metadata saved.
[INFO] Getting historical load values.
[INFO] Getting load values success.
[INFO] Getting mount info
[INFO] Getting iptables tables.
[INFO] Collecting common logs.
[INFO] Processing syslog.
[INFO] Processing dmesg.
[INFO] Processing cce-agent-install.log.
[INFO] Processing cloud-init.log.
[INFO] Processing kern.log.
[INFO] Common logs collected.
[INFO] Collecting CCE logs.
[INFO] Processing containerd/containerd.log.
[WARN] Cannot find containerd/containerd.log.
[INFO] Processing everest-csi-driver/everest-csi-controller.log.
[INFO] Processing everest-csi-driver/everest-csi-driver.log.
[INFO] Processing kubernetes/kube-proxy.log.
[INFO] Processing kubernetes/kubelet.log.
[INFO] Processing yangtse/yangtse-agent.log.
[INFO] Processing yangtse/yangtse-cni.log.
[INFO] Processing canal/canal-agent.log.
[WARN] Cannot find canal/canal-agent.log.
[INFO] CCE logs collected.
[INFO] Collecting config files.
[INFO] Processing /opt/cloud/cce/kubernetes/kube-proxy/kube-proxy.
[INFO] Processing /opt/cloud/cce/kubernetes/kubelet/kubelet_config.yaml.
[INFO] Processing /opt/cloud/cce/kubernetes/kubelet/kubelet.
[INFO] Processing /opt/cloud/cce/kubernetes/cce-agent/agentConfig.
[INFO] Processing /etc/containerd/config.toml.
[INFO] Processing /etc/docker/daemon.json.
[INFO] Configs collected
[INFO] Packaging complete. Please see the file at: /tmp/cce-export-sdombi-dev-cluster-69514.tar.gz
```

Collection
```bash
├── config
│   ├── agentConfig
│   ├── config.toml
│   ├── daemon.json
│   ├── kube-proxy
│   ├── kubelet
│   └── kubelet_config.yaml
├── iptables.txt
├── kernel_version.txt
├── logs
│   ├── cce
│   │   ├── everest-csi-controller.log
│   │   ├── everest-csi-driver.log
│   │   ├── kube-proxy.log
│   │   ├── kubelet.log
│   │   ├── yangtse-agent.log
│   │   └── yangtse-cni.log
│   ├── cce-agent-install.log
│   ├── cloud-init.log
│   ├── dmesg
│   ├── dmesg.0
│   ├── dmesg.1.gz
│   ├── dmesg.2.gz
│   ├── kern.log
│   ├── kern.log.1
│   └── syslog
├── meta_data.json
└── mount.txt
```

### Download the file 
Run from your local client
```bash
scp <CCE_NODE>:/tmp/cce-export-<CCE_NODE_HOSTNAME>.tar.gz .
```
