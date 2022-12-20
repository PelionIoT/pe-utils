#!/usr/bin/env bash
#
# Copyright (c) 2022 Izuma Networks
#
# Arguments: $1 - default branch name (master or main typically)
#            $1 - PR branch name
set -e
echo "default branch = $1 and PR branch = $2"
# scripts-internal was already cloned by the pr-checker.yml
# No point in the checking the scripts-internal, let's stop that.
echo "." >scripts-internal/.nopyshcheck
# This is what we SHOULD do, but can't due to too many findings.
#status=$(./scripts-internal/pysh-check/pysh-check.sh --workdir .)

# Get all branches, default clone is shallow
git fetch --all

# Get reference count of pysh-check issues
git checkout "$1"
ref_count=$(./scripts-internal/pysh-check/pysh-check.sh --workdir . | wc -l)

# Checkout the pr branch again, get it's count
git checkout "$2"
count=$(./scripts-internal/pysh-check/pysh-check.sh --workdir . | wc -l)
echo "Finding(s) count before = $ref_count, finding(s) count now = $count"
# Do we have more findings that in master?
if ((count>ref_count));then
    # Return with error code
    echo "Oh no, we cannot make matters worse."
    exit 1
fi
decrease=$((ref_count-count))
if ((decrease>0));then
    echo "Excellent, $decrease findings less than earlier!"
else
    echo "Good, you did not make matters worse."
fi
exit 0