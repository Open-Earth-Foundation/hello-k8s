#!/bin/sh

# command line arguments

export HOSTNAME=$1
export ADDRESS=$2

# constants for our servers

export ZONEID=Z0994301DA3Y3RNT8BQA
export DOMAIN=openearth.dev

export CHANGEBATCH=$(cat << EOF
{
    "Changes": [
        {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "${HOSTNAME}.${DOMAIN}",
                "Type": "A",
                "TTL": 300,
                "ResourceRecords": [
                    {
                        "Value": "${ADDRESS}"
                    }
                ]
            }
        }
    ]
}
EOF
)

aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONEID \
    --change-batch "$CHANGEBATCH"
