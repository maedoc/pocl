# all the metadata
project(pocl-build)
cmake_minimum_required(VERSION 3.6)

# all the versions
set(LLVM_VER "3.8.1")
set(POCL_VER "0.13")
MESSAGE("Using LLVM verion ${LLVM_VER} and PoCL version ${POCL_VER}.")

# all the cores
include(ProcessorCount)
ProcessorCount(J)
MESSAGE("Will build with -j${J}.")

# all the projects
include(ExternalProject)

ExternalProject_Add(pkgconfig
	PREFIX "pkgconfig"
	URL "https://pkg-config.freedesktop.org/releases/pkg-config-0.29.tar.gz"
	CONFIGURE_COMMAND ../pkgconfig/configure --prefix=$ENV{PREFIX} --with-internal-glib
	BUILD_COMMAND make -j${J} install
)

ExternalProject_Add(hwloc
	DEPENDS pkgconfig
	PREFIX "hwloc"
	URL "https://www.open-mpi.org/software/hwloc/v1.11/downloads/hwloc-1.11.4.tar.gz"
	CONFIGURE_COMMAND ../hwloc/configure --prefix=$ENV{PREFIX}
	BUILD_COMMAND make -j${J} install
)

ExternalProject_Add(libtool
	DEPENDS pkgconfig
	PREFIX "libtool"
	URL "http://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.gz"
	CONFIGURE_COMMAND ../libtool/configure --prefix=$ENV{PREFIX}
	BUILD_COMMAND make -j${J} install
)

ExternalProject_Add(llvm
	DEPENDS pkgconfig
	PREFIX "llvm"
	URL "http://llvm.org/releases/${LLVM_VER}/llvm-${LLVM_VER}.src.tar.xz"
	INSTALL_DIR "$ENV{PREFIX}"
	CMAKE_CACHE_ARGS
		-DBUILD_SHARED_LIBS:BOOL=OFF
		-DLLVM_ENABLE_RTTI:BOOL=ON
		-DLLVM_TARGETS_TO_BUILD:STRING=X86
		-DCMAKE_INSTALL_PREFIX:STRING=${CMAKE_INSTALL_PREFIX}
		-DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
		-DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
		-DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}
)

ExternalProject_Add(cfe
	DEPENDS llvm pkgconfig
	PREFIX "cfe"
	URL "http://llvm.org/releases/${LLVM_VER}/cfe-${LLVM_VER}.src.tar.xz"
	INSTALL_DIR "$ENV{PREFIX}"
	CMAKE_CACHE_ARGS
		-DCLANG_TOOL_LIBCLANG_BUILD:BOOL=ON
		-DLIBCLANG_BUILD_STATIC:BOOL=ON
		-DLLVM_ENABLE_RTTI:BOOL=ON
		-DCMAKE_INSTALL_PREFIX:STRING=${CMAKE_INSTALL_PREFIX}
		-DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
		-DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
		-DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}
)

ExternalProject_Add(pocl
	DEPENDS llvm cfe libtool hwloc pkgconfig
	PREFIX "pocl"
	URL "http://portablecl.org/downloads/pocl-${POCL_VER}.tar.gz"
	INSTALL_DIR "$ENV{PREFIX}"
	CMAKE_CACHE_ARGS
		-DBUILD_SHARED_LIBS:BOOL=ON
		-DENABLE_ICD:BOOL=OFF
		-DDIRECT_LINKAGE:BOOL=ON
		-DINSTALL_OPENCL_HEADERS:BOOL=ON
		-DPOCL_DEBUG_MESSAGES:BOOL=ON
		-DSTATIC_LLVM:BOOL=OFF
		-DKERNELLIB_HOST_CPU_VARIANTS:STRING=distro
		-DCMAKE_INSTALL_PREFIX:STRING=${CMAKE_INSTALL_PREFIX}
		-DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
		-DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
		-DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}
)

ExternalProject_Add(pyopencl
	DEPENDS pocl
	PREFIX "pyopencl"
	GIT_REPOSITORY "http://git.tiker.net/trees/pyopencl.git"
	CONFIGURE_COMMAND python configure.py --cl-pretend-version=1.1 --cl-inc-dir=$ENV{PREFIX}/include --cl-lib-dir=$ENV{PREFIX}/lib
	BUILD_IN_SOURCE 1
	BUILD_COMMAND python setup.py build
	INSTALL_COMMAND ls build/
)
