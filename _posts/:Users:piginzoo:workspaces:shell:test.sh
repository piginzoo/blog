#!/bin/bash
#滚动覆盖，文件file0,file1,file2,
#文件格式如：2015-12-13.log

LOOP = 10

file_name = `date '+%Y-%m-%d'`.zip
echo file_name

files = `ll testdir|awk '{print $9}'`
for each_file in files
	echo each_file
done