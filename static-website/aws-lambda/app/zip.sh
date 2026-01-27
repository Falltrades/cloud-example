#!/bin/bash

set -euo pipefail

rm -rf build lambda.zip
mkdir build

cp app.py build/

# Build dependencies for Lambda using Docker
docker run --rm \
    -v "$(pwd)/build":/var/task \
    -v "$(pwd)/requirements.txt":/var/requirements.txt \
    --entrypoint "" \
    public.ecr.aws/lambda/python:3.11 \
    python3.11 -m pip install -r /var/requirements.txt -t /var/task

cd build
zip -r ../lambda.zip .
cd ..
