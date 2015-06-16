#!/bin/bash
/usr/local/sbin/logrotate.sh
/opt/ec2/s3-upload-log.sh
/sbin/poweroff -p