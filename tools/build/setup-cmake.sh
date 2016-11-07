#!/bin/bash

# if we don't even have CMake, set that up
if [ -z "$(which cmake)" ]
then
	echo "Setting up CMake in prefix '$prefix'."
	mkdir -p $PREFIX/src && pushd $PREFIX/src
	wget --no-check-certificate https://cmake.org/files/v3.6/cmake-3.6.2.tar.gz
	tar xzf cmake*
	cd cmake*
	./bootstrap --prefix=$PREFIX && make -j && make install
else
	echo "CMake found at '$(which cmake)'."
fi

# make running CMake scripts easier
if [ -z "$(which cmake-p)" ]
then
	cat > $PREFIX/bin/cmake-p <<EOF
#!/bin/bash
cmake -P "\$@"
EOF
	chmod +x $PREFIX/bin/cmake-p 
fi
