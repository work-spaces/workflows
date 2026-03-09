#!/bin/bash


for i in {1..15}; do
  spaces --ci co spaces-dev "test-checkout-$i" &
done

wait
echo "All processes finished"

for i in {1..15}; do
  pushd "test-checkout-$i"
  if ! spaces inspect; then
    echo "❌ error in $dir"
    exit 1
  fi
  popd
done
