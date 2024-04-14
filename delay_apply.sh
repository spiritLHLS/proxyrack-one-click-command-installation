#!/bin/bash
# FROM https://github.com/spiritLHLS/proxyrack-one-click-command-installation
# 2024.04.14

PRTOKEN="$1"
uuid=$(cat /usr/local/bin/proxyrack_uuid)
dname=$(cat /usr/local/bin/proxyrack_dname)

# 等待5分钟
sleep 5m

# 第一次请求
curl -s \
  -X POST https://peer.proxyrack.com/api/device/add \
  -H "Api-Key: $PRTOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"device_id\":\"$uuid\",\"device_name\":\"$dname\"}"

# 等待5分钟
sleep 5m

# 第二次请求
curl -s \
  -X POST https://peer.proxyrack.com/api/device/add \
  -H "Api-Key: $PRTOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"device_id\":\"$uuid\",\"device_name\":\"$dname\"}"

# 等待5分钟
sleep 5m

# 第二次请求
curl -s \
  -X POST https://peer.proxyrack.com/api/device/add \
  -H "Api-Key: $PRTOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"device_id\":\"$uuid\",\"device_name\":\"$dname\"}"

rm -rf nohup.out delay_apply.sh