# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "Expat"
version = v"2.4.8"

# Collection of sources required to build Expat
sources = [
    ArchiveSource("https://github.com/libexpat/libexpat/releases/download/R_$(version.major)_$(version.minor)_$(version.patch)/expat-$(version).tar.xz",
                  "f79b8f904b749e3e0d20afeadecf8249c55b2e32d4ebb089ae378df479dcaf25"),
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/expat-*/
./configure --prefix=${prefix} --build=${MACHTYPE} --host=${target} --disable-static
make -j${nproc}
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms()

# The products that we will ensure are always built
products = [
    LibraryProduct("libexpat", :libexpat),
    ExecutableProduct("xmlwf", :xmlwf)
]

# Dependencies that must be installed before this package can be built
dependencies = Dependency[
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; julia_compat="1.6")
