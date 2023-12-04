#!/usr/bin/env bash

readonly TARGET_DIR="/tmp/cce-log-exporter"
readonly OPENSTACK_METADATA="http://169.254.169.254/openstack/2015-10-15/meta_data.json" 
readonly LOG_DIR="/var/log"

PACKAGES=(
  sar
  curl
)

# in /var/log
COMMON_LOGS=(
  dmesg
  cce-agent-install.log
  cloud-init.log
  kern.log
)

#in /var/log/cce
CCE_LOGS=(
  containerd/containerd.log
  everest-csi-driver/everest-csi-controller.log
  everest-csi-driver/everest-csi-driver.log
  kubernetes/kube-proxy.log
  kubernetes/kubelet.log
  yangtse/yangtse-agent.log
  yangtse/yangtse-cni.log
  canal/canal-agent.log
)

help() {
  echo "usage..."
  exit 0
}

info() {
  >&2 echo -e "\e[32m[INFO]\e[0m $*" 
}

warn() {
  >&2 echo -e "\e[33m[WARN]\e[0m $*"
}

err() {
  >&2 echo -e "\e[31m[ERROR]\e[0m $*"
  exit 1
}

check_root() {
  if [[ "$(id -u)" -ne 0 ]]; then
     err "Script must be running as root!" 
  fi
}

create_script_dir() {
  info "Creating target directory."
  mkdir -p ${TARGET_DIR}/logs/cce
}

get_openstack_metadata() {
  info "Quering openstack metadata."
  >&2 curl --connect-timeout 2 ${OPENSTACK_METADATA} > ${TARGET_DIR}/meta_data.json 2>/dev/null \
    && info "Openstack metadata saved." || warn "Cannot obtain openstack metadata"
}

get_kernel_info() {
  info "Getting kernel version."
  uname -a > ${TARGET_DIR}/kernel_version.txt
}

get_mounts() {
  info "Getting mount info"
  mount > ${TARGET_DIR}/mount.txt
}

get_load() {
  info "Getting historical load values."
  sar -q > ${TAGET_DIR}/load_values.txt \
    && info "Getting load values success." || warn "Cannot get historycal load values."
}

get_iptables() {
  info "Getting iptables tables."
  iptables-save > ${TARGET_DIR}/iptables.txt
}

check_disk() {
  info "Checking available disk space on root."
  local free_disk
  threshold=2000000
  result=$(df / | grep -v "Filesystem" | awk '{ print $4 }')
  if [[ "${result}" -le "${threshold}" ]]; then
    err "You need at least 2GB free space on root to run the script!"
  fi
}

check_packages() {
  for package in ${PACKAGES[*]}; do
    if which $package | grep -q $package ; then
      info "Package $package is installed."
    else
      warn "Package $package is not installed."
      warn "To get all the export features, please install $package."
    fi
  done
}

get_common_logs() {
  local syslog_lines="100000"
  info "Collecting common logs."
  if [[ -e /var/log/messages ]]; then 
    info "Processing messages."
    tail -n ${syslog_lines} ${LOG_DIR}/messages > ${TARGET_DIR}/logs/messages
  fi
  if [[ -e /var/log/syslog ]]; then
    info "Processing syslog."
    tail -n ${syslog_lines} ${LOG_DIR}/syslog > ${TARGET_DIR}/logs/syslog
  fi
  for log_file in ${COMMON_LOGS[*]}; do
    info "Processing ${log_file}."
    if [[ -e "${LOG_DIR}/${log_file}" ]]; then
      cp -f ${LOG_DIR}/${log_file}* ${TARGET_DIR}/logs/ 2>/dev/null
    else
      warn "Cannot find ${log_file}."
    fi
  done
  info "Common logs collected."
}

get_cce_logs() {
  info "Collecting CCE logs."
  for log_file in ${CCE_LOGS[*]}; do
    info "Processing ${log_file}."
    if [[ -e "${LOG_DIR}/cce/${log_file}" ]]; then
      cp -f ${LOG_DIR}/cce/${log_file} ${TARGET_DIR}/logs/cce/ 2>/dev/null
      continue
    else
      warn "Cannot find ${log_file}."
    fi
  done
  info "CCE logs collected."
}

pack() {
  tar --gzip -cvf /tmp/cce-export-${HOSTNAME}.tar.gz --directory ${TARGET_DIR} . >/dev/null 2>&1 \
    && info "Pacaking complete. Please see the file at: /tmp/cce-export-${HOSTNAME}.tar.gz" || err "Cannot package directory." 
}

init() {
  check_root
  check_disk
  check_packages
}

run() {
  create_script_dir
  get_kernel_info
  get_openstack_metadata
  get_load
  get_iptables
  get_common_logs
  get_cce_logs
  pack
}

init
run
