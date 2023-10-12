#!/bin/bash
#
# Copyright (c) 2023, Izuma Networks
#
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

edgeinfover=$(head -n 32 "edge-info/edge-info" | tail -n 1)
# Use grep with a regular expression to extract the version
if [[ $edgeinfover =~ version=\"([^\"]+)\" ]]; then
  extracted_ver="${BASH_REMATCH[1]}"
else
  echo "Version not found from line 32 in edge-info/edge-info -file ($edgeinfover)."
  exit 1
fi
devidver=$(head -n 1 "identity-tools/developer_identity/VERSION")
chgver=$(head -n 1 "CHANGELOG.md" | awk '{ for (i=1; i<=NF; i++) if ($i ~ /^[0-9]+\.[0-9]+\.[0-9]+$/) { print $i; exit } }')
echo "ChangeLog version: $chgver"
echo "edge-info version: $extracted_ver"
echo "Identity tool version: $devidver"
if [ "$extracted_ver" != "$devidver" ] || \
   [ "$extracted_ver" != "$chgver" ]; then
  echo "Versions do not match! @extracted_ver vs. $devidver vs. $chgver"
  echo "Fix required."
  exit 1
else
  echo "Versions match."
fi
