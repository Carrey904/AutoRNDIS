#!/bin/sh
function network() {
	#超时时间
	local timeout=30

	#目标网站
	local target=www.baidu.com

	#获取响应状态码
	local ret_code=$(curl -I -s --connect-timeout ${timeout} ${target} -w %{http_code} | tail -n1)

	if [ "x$ret_code" = "x200" ]; then
		#网络畅通
		return 1
	else
		#网络不畅通
		return 0
	fi

	return 0
}

id=$(adb devices | grep device$)
if [ -z "$id" ]; then
	d=$(date '+%F %T')
	echo "[$d]device not found"
	echo "[$d]device not found" >>/tmp/net_check.log
else
	d=$(date '+%F %T')
	network
	if [ $? -eq 0 ]; then
		echo "[$d]网络不通畅"
        # toggle airplane mode on
		adb shell "su -c 'settings put global airplane_mode_on 1'"
        adb shell "su -c 'am broadcast -a android.intent.action.AIRPLANE_MODE'"
        sleep 3
        # toggle airplane mode off
        adb shell "su -c 'settings put global airplane_mode_on 0'"
        adb shell "su -c 'am broadcast -a android.intent.action.AIRPLANE_MODE'"
    else
        echo "[$d]网络通畅"
	fi
fi
