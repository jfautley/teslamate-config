#!/bin/bash

source $(dirname $0)/functions.sh

BACKUPDIR=$(realpath $(dirname $0))/backup
S3BUCKET=teslamate-backup

[ ! -d $BACKUPDIR ] && mkdir $BACKUPDIR

# Perform TeslaMate DB backup
docker-compose exec -T database pg_dump -U teslamate teslamate > $BACKUPDIR/teslamate.db.$(date +%Y%m%d) 2> /tmp/err.$$
errCheck pg_dump $? /tmp/err.$$

# Sync to S3
docker run --rm -ti -v ~/.aws:/root/.aws -v $BACKUPDIR:/backup amazon/aws-cli s3 sync --only-show-errors /backup/ s3://$S3BUCKET > /tmp/err.$$
errCheck s3sync $? /tmp/err.$$

# Cleanup old backup files
find $BACKUPDIR -mtime +7 -delete > /tmp/err.$$
errCheck cleanup $? /tmp/err.$$

rm /tmp/err.$$
