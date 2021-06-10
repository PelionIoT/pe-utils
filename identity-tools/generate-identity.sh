#!/bin/bash

# Copyright (c) 2018, Arm Limited and affiliates.
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

EDGE_CORE_PORT=${1:-9101}
IDENTITY_DIR=${2:-./}
edge_status=$3
CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function jsonValue() {
    KEY=$2
    IFS='{",}'
    read -ra ARR <<< "$1"
    for ((i = 0; i < ${#ARR[@]}; ++i)); do
        if [ "${ARR[$i]}" == "$KEY" ]; then
            position=$(( $i + 2 ))
            echo "${ARR[$position]}"
        fi
    done
}

getEdgeStatus() {
    [[ -z "$edge_status" ]] && edge_status=$(curl http://localhost:${EDGE_CORE_PORT}/status)
    OU=`echo $edge_status | jq -r '."account-id"'`
    internalid=`echo $edge_status | jq -r '."internal-id"'`
    lwm2mserveruri=`echo $edge_status | jq -r '."lwm2m-server-uri"' | cut -d':' -f 2 | sed 's/^\/\///'`
    status=`echo $edge_status | jq -r .status`
    endpointname=`echo $edge_status | jq -r '."endpoint-name"'`
}

readIdentity() {
    if [ -f "${IDENTITY_DIR}/identity.json" ]; then
        identity=$(cat ${IDENTITY_DIR}/identity.json)
        deviceID=`echo $identity | jq -r .deviceID`
    fi
}

execute () {
    if [ "x$status" = "xconnected" ]; then
        echo "Edge-core is connected..."
        readIdentity
        if [ ! -f ${IDENTITY_DIR}/identity.json -o  "x$internalid" != "x$deviceID"  ]; then
            echo "Creating developer identity."
            mkdir -p ${IDENTITY_DIR}
            if [ -f ${IDENTITY_DIR}/identity.json ] ; then
                cp ${IDENTITY_DIR}/identity.json ${IDENTITY_DIR}/identity_original.json
            fi
            [[ $lwm2mserveruri == *"lwm2m"* ]] && commonaddr=${lwm2mserveruri#"lwm2m"}
            [[ $lwm2mserveruri == *"lwm2m-udp"* ]] && commonaddr=${lwm2mserveruri#"lwm2m-udp"}
            [[ $lwm2mserveruri == *"lwm2m-tcp"* ]] && commonaddr=${lwm2mserveruri#"lwm2m-tcp"}
            [[ $lwm2mserveruri == *"lwm2m-os2"* ]] && commonaddr=${lwm2mserveruri#"lwm2m-os2"}
            [[ $lwm2mserveruri == *"lwm2m-integration-lab"* ]] && commonaddr=${lwm2mserveruri#"lwm2m-integration-lab"}
            [[ $lwm2mserveruri == *"udp-lwm2m"* ]] && commonaddr=${lwm2mserveruri#"udp-lwm2m"}
            [[ $lwm2mserveruri == *"tcp-lwm2m"* ]] && commonaddr=${lwm2mserveruri#"tcp-lwm2m"}
            echo "common part of the address - $commonaddr"
            $CURR_DIR/developer_identity/create-dev-identity.sh\
                -d \
                -m $commonaddr\
                -e $endpointname\
                -n $OU\
                -o ${IDENTITY_DIR}\
                -i $internalid
        else
            echo "Success: Generated identity is same as reported by edge-core."
        fi
    else
        echo "Error: edge-core is not connected yet. Its status is- $status. Exited with code $?."
        exit 1
    fi
}

getEdgeStatus
execute
