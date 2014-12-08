#!/bin/sh

# ElasticBeanstalk helpers script to sync all uploads in a Wordpress VCCW deployed environment

EC2_USER=ec2-user
AWS_KEY=~/.ssh/VOC-us-east-1-aws-eb
UPLOADS_DIR=wp-content/uploads
INSTANCE_DIR=/var/www/html/$UPLOADS_DIR/
LOCAL_DIR=www/wordpress/$UPLOADS_DIR/

if [ ! -d "$LOCAL_DIR" ]; then
    if [ ! -d "$UPLOADS_DIR" ]; then
        echo "$LOCAL_DIR local directory not found, cannot sync";
        exit 1;
    else
        LOCAL_DIR=$UPLOADS_DIR
    fi
fi

function syncDirectory(){
    echo "Syncing $EC2_INSTANCE_URL:$INSTANCE_DIR"
    #scp -i $AWS_KEY -r "$EC2_USER@$EC2_INSTANCE_URL:$INSTANCE_DIR"/* "$LOCAL_DIR"
    rsync -avz -e "ssh -i $AWS_KEY" "$EC2_USER@$EC2_INSTANCE_URL:$INSTANCE_DIR" "$LOCAL_DIR"
}

function syncAllInstancesDirectories(){
    for instance in `eb status --verbose|grep InService|awk '{print $1}'`; do
        instance=${instance//:/};
        EC2_INSTANCE_URL=`ec2-describe-instances $instance|grep -i 'privateipaddress'|awk '{print $4}'`;
        syncDirectory
    done
}

if [ "$1" != "" ]; then
    EC2_INSTANCE_URL="$1"
    syncDirectory
else
    syncAllInstancesDirectories
fi
