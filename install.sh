#!/bin/bash

config_dir=/etc/socat-forwarder
bin_dir=/usr/local/sbin

[ ! -d "${config_dir}" ] && mkdir -- "${config_dir}"
[ ! -e "${bin_dir}/socat-forwarder.sh" ] && ln -s "${PWD}/socat-forwarder.sh" "${bin_dir}/"

echo "Copy example.conf to ${config_dir} and adjust to your needs."
