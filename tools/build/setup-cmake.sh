#!/bin/bash

echo "Setting up CMake in prefix '$prefix'."
mkdir -p $PREFIX/src && pushd $PREFIX/src
wget --no-check-certificate https://cmake.org/files/v3.6/cmake-3.6.2.tar.gz
tar xzf cmake*
cd cmake*
./bootstrap --prefix=$PREFIX && make -j && make install
