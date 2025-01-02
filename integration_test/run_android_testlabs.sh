#!/bin/bash
##!/usr/bin/env bash
#set -euo pipefail

#This script is used to run the integration test on Firebase Test Lab
#this will use pixel 5 device with android 11
#If you want to find device model, version, using gcloud firebase test android models list
#add --device model=MODEL_NAME,version=OS_VERSION_IDS,locale=en,orientation=portrait
#   --device model=redfin,version=30,locale=en_US,orientation=portrait \
#   --device model=panther,version=33,locale=en_US,orientation=portrait \
gcloud firebase test android run \
    --type instrumentation \
    --app build/app/outputs/apk/appiumTest/debug/app-appiumTest-debug.apk \
    --test build/app/outputs/apk/androidTest/appiumTest/debug/app-appiumTest-debug-androidTest.apk \
    --device model=lynx,version=33,locale=en_US,orientation=portrait \
    --num-flaky-test-attempts=2 \
    --timeout 10m \
    --use-orchestrator \
    --environment-variables clearPackageData=true \
    --client-details matrixLabel="Running integration test" \




