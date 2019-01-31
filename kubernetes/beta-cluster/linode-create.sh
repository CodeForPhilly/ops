#!/bin/bash

linode-cli k8s-alpha create codeforphilly \
    --region us-east \
    --master-type g6-standard-2 \
    --node-type g6-standard-2 \
    --nodes 2
