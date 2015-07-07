set -e
package=fftw
version=3.3.4
libdir=/shared/ucl/apps/rsd/$package
moddir=/shared/ucl/apps/rsd/modulefiles
builddir=/tmp
compilers=(intel/13.0/028_cxx11 gnu/4.9.2)
standard_args="--enable-threads"

function download_source {
  cd $builddir
  downsource=http://www.fftw.org/fftw-$version.tar.gz
  [[ -e fftw-$version.tar.gz ]] || wget $downsource
  tar -xvf fftw-$version.tar.gz
}

function build_one {
  compiler=$1
  precision=$2
  shortname=$(dirname $compiler)

  module swap compilers compilers/$compiler
  cd $source_dir
  [[ -d build/$compiler/$precision ]] || mkdir -p build/$compiler/$precision
  cd build/$compiler/$precision

  args="$standard_args"
  if [[ "$precision" == "float" ]] ; then
     args="$args --enable-float"
  elif [[ "$precision" == "long" ]] ; then
     args="$args --enable-long-double"
  fi
  if [[ "$precision" != "long" ]] && [[ "$shortname" != "gnu" ]] ; then
     args="$args --enable-avx"
  elif [[ "$precision" != "long" ]] ; then
     args="$args --enable-sse2"
  fi
  
  CFLAGS=-O2 $source_dir/configure $args --prefix=$libdir/$version/$compiler
  make -j8
  make install -j8
}

function install_build {
  source_dir=$builddir/fftw-$version
  for compiler in ${compilers[@]}; do
    for precision in float double long; do
      build_one $compiler $precision

      CFLAGS=-O2 $source_dir/configure $args --prefix=$libdir/$version/$compiler
      make -j8
      make install -j8
    done
  done
}

function module_file {
  filename=$moddir/$package-rsdt/$version
  [[ -d $(dirname $filename) ]] || mkdir -p $(dirname $filename)
  cat > $filename <<EOF
#%Module
#
# $package library
#

proc ModulesHelp { } {
    puts stderr "Adds the $package $version library."
    puts stderr ""
}

module-whatis "Adds the $package $version library."

# Check we have some compiler loaded and deduce path
EOF

  ifcmd="if"
  for compiler in ${compilers[@]}; do
    cat >> $filename <<EOF
$ifcmd { [ is-loaded compilers/$compiler ] } {
  set compiler $compiler
EOF
  ifcmd="} elseif"
  done
  cat >> $filename <<EOF
} else {
  error "require one of the following compilers: ${compilers[@]}"
}
EOF

  cat >> $filename <<EOF
prereq compilers/\$compiler
set root $libdir/$version/\$compiler
setenv FFTW3_INCLUDE_DIR  \$root/include
setenv FFTW3_LIBRARY_DIR  \$root/lib
append-path  PATH \$root/bin
append-path  LD_RUN_PATH \$root/lib
append-path  LD_LIBRAR_PATH \$root/lib
append-path  CMAKE_PREFIX_PATH \$root
append-path  PKG_CONFIG_PATH \$root/lib/pkgconfig
append-path  MANPATH \$root/share/man
append-path  INFOPATH \$root/share/man
EOF
}


# download_source
# install_build
module_file
