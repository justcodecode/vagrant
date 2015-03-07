#!/bin/bash
/etc/cron.hourly/10-logrotate.sh
/etc/cron.hourly/20-logrotate-upload-to-s3.sh
/sbin/poweroff -p