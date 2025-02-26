# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "SQLite"
version = v"3.39.2"

# Collection of sources required to complete build
sources = [
    ArchiveSource("https://www.sqlite.org/2022/sqlite-autoconf-3390200.tar.gz",
                  "852be8a6183a17ba47cee0bbff7400b7aa5affd283bf3beefc34fcd088a239de"),
    FileSource("https://git.archlinux.org/svntogit/packages.git/plain/trunk/license.txt?h=packages/sqlite&id=33cad63ddb1ba86b7c5a47430c98083ce2b4d86b",
               "4e57d9ac979f1c9872e69799c2597eeef4c6ce7224f3ede0bf9dc8d217b1e65d"; filename="LICENSE"),
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/sqlite-autoconf-*/

# Use same flags as
# https://github.com/archlinux/svntogit-packages/blob/packages/sqlite/trunk/PKGBUILD
export CPPFLAGS="-DSQLITE_ENABLE_COLUMN_METADATA=1 \
                 -DSQLITE_ENABLE_UNLOCK_NOTIFY \
                 -DSQLITE_ENABLE_DBSTAT_VTAB=1 \
                 -DSQLITE_ENABLE_FTS3_TOKENIZER=1 \
                 -DSQLITE_SECURE_DELETE \
                 -DSQLITE_ENABLE_STMTVTAB \
                 -DSQLITE_MAX_VARIABLE_NUMBER=250000 \
                 -DSQLITE_MAX_EXPR_DEPTH=10000 \
                 -DSQLITE_ENABLE_MATH_FUNCTIONS"

./configure --prefix=${prefix} \
    --build=${MACHTYPE} \
    --host=$target \
    --disable-static \
    --enable-fts3 \
    --enable-fts4 \
    --enable-fts5 \
    --enable-rtree
make -j${nproc}
make install
install_license "${WORKSPACE}/srcdir/LICENSE"
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms(; experimental=true)

# The products that we will ensure are always built
products = [
    LibraryProduct("libsqlite3", :libsqlite),
    ExecutableProduct("sqlite3", :sqlite3),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency("Zlib_jll"),
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; julia_compat="1.6")
