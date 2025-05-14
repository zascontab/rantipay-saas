#!/bin/bash
export SERVICE_NAME="user"
cd /home/wsi/developer/projects/rantipay/wankarlab/rantipay-saas/kit/user/minimal
go run main.go $1
