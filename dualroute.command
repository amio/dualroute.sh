#!/bin/bash
# 携程双网络脚本。内网走Ethernet，外网走Wi-Fi

VER='v0.1'

echo -e '\n携程双网络工具 / '$VER'\n\n   (登录这台电脑的密码 u_u)\n            ↓↓↓↓↓↓'

NETWORKS=\"Ethernet\"`networksetup -listallnetworkservices | sed -E '/^An asterisk\ .*|^Ethernet$/d' | sed 's/.*/ \"&\"/' | tr -d "\n"`
COMMAND="sudo networksetup -ordernetworkservices "$NETWORKS
echo $COMMAND | bash

# GW0:Wi-Fi, GW1:Ethernet
GW0=`networksetup -getinfo wi-fi | awk '{if($1 == "Router:") print $2}'`
GW1=`networksetup -getinfo ethernet | awk '{if($1 == "Router:") print $2}'`

echo 'Gateway Wi-Fi:       '$GW0
echo 'Gateway Ethernet:    '$GW1

if ( `test -z $GW0`) then
  echo 'Did you forgot active Wi-Fi?'
elif (`test -z "$GW1"`) then
  echo 'Something wrong with your Ethernet.'
else
  sudo route -n flush
  echo -e '\n\n'
  sudo route -n add 0.0.0.0 $GW0
  sudo route -n add -net 192.168.0.0/16 $GW1
  sudo route -n add -net 172.16.128.0/17 $GW1
  sudo route -n add -net 10.0.0.0/8 $GW1
  # wxd.ctrip.com
  sudo route -n add -net 210.13.73.60 $GW1
  
  echo -e "\n$(tput setaf 1)DONE!"
  osascript -e 'tell application "Terminal" to quit'
fi
