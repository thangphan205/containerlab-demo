#!/bin/sh
# start-slapd.sh — script vận hành slapd của team hạ tầng
# SLAPD_SERVICES bê nguyên từ máy cũ (hồi đó app chạy chung host, chỉ cần socket local)
SLAPD_SERVICES="ldapi:///"

slapd -f /etc/openldap/slapd.conf -h "$SLAPD_SERVICES"
