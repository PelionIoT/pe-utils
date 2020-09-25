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
    edge_status=$(curl http://localhost:${EDGE_CORE_PORT}/status)
    OU=$(jsonValue $edge_status account-id)
    internalid=$(jsonValue $edge_status internal-id)
    lwm2mserveruri=$(jsonValue $edge_status lwm2m-server-uri)
    status=$(jsonValue $edge_status status)
}

readIdentity() {
    if [ -f "${IDENTITY_DIR}/identity.json" ]; then
        identity=$(cat ${IDENTITY_DIR}/identity.json)
        deviceID=$(jsonValue "$identity" deviceID)
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
            IFS='.' read -ra ADDR <<< "$lwm2mserveruri"
            $CURR_DIR/developer_identity/create-dev-identity.sh\
                -d \
                -z ${ADDR[${#ADDR[@]} - 3]}\
                -m ${ADDR[${#ADDR[@]} - 2]}\
                -p DEV0\
                -n $OU\
                -o ${IDENTITY_DIR}\
                -i $internalid
        fi
    else
        echo "Error: edge-core is not connected yet. Its status is- $status. Exited with code $?."
        exit 1
    fi
}

getEdgeStatus
execute
