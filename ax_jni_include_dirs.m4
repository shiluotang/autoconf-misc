# ===========================================================================
#    http://www.gnu.org/software/autoconf-archive/ax_jni_include_dir.html
# ===========================================================================
#

AC_DEFUN([AX_JNI_INCLUDE_DIRS],[

JNI_INCLUDE_DIRS=""

if test "x$JAVA_HOME" != x; then
	_JTOPDIR="$JAVA_HOME"
else
	if test "x$JAVAC" = x; then
		JAVAC=javac
	fi
	AC_PATH_PROG([_ACJNI_JAVAC], [$JAVAC], [no])
	if test "x$_ACJNI_JAVAC" = xno; then
		AC_MSG_ERROR([cannot find JDK; try setting \$JAVAC or \$JAVA_HOME])
	fi
	_ACJNI_FOLLOW_SYMLINKS("$_ACJNI_JAVAC")
	_JTOPDIR=`echo "$_ACJNI_FOLLOWED" | sed -e 's://*:/:g' -e 's:/[[^/]]*$::'`
fi

case "$host_os" in
        darwin*)        # Apple JDK is at /System location and has headers symlinked elsewhere
                        case "$_JTOPDIR" in
                        /System/Library/Frameworks/JavaVM.framework/*)
				_JTOPDIR=`echo "$_JTOPDIR" | sed -e 's:/[[^/]]*$::'`
				_JINC="$_JTOPDIR/Headers";;
			*)      _JINC="$_JTOPDIR/include";;
                        esac;;
        *)              _JINC="$_JTOPDIR/include";;
esac
_AS_ECHO_LOG([_JTOPDIR=$_JTOPDIR])
_AS_ECHO_LOG([_JINC=$_JINC])

# On Mac OS X 10.6.4, jni.h is a symlink:
# /System/Library/Frameworks/JavaVM.framework/Versions/Current/Headers/jni.h
# -> ../../CurrentJDK/Headers/jni.h.
AC_CHECK_FILE([$_JINC/jni.h],
	[JNI_INCLUDE_DIRS="$JNI_INCLUDE_DIRS|$_JINC"],
	[_JTOPDIR=`echo "$_JTOPDIR" | sed -e 's:/[[^/]]*$::'`
	 AC_CHECK_FILE([$_JTOPDIR/include/jni.h],
		[JNI_INCLUDE_DIRS="$JNI_INCLUDE_DIRS|$_JTOPDIR/include"],
                AC_MSG_ERROR([cannot find JDK header files]))
	])

# get the likely subdirectories for system specific java includes
case "$host_os" in
bsdi*)          _JNI_INC_SUBDIRS="bsdos";;
freebsd*)       _JNI_INC_SUBDIRS="freebsd";;
darwin*)        _JNI_INC_SUBDIRS="darwin";;
linux*)         _JNI_INC_SUBDIRS="linux genunix";;
osf*)           _JNI_INC_SUBDIRS="alpha";;
solaris*)       _JNI_INC_SUBDIRS="solaris";;
mingw*)		_JNI_INC_SUBDIRS="win32";;
cygwin*)	_JNI_INC_SUBDIRS="win32";;
*)              _JNI_INC_SUBDIRS="genunix";;
esac

# add any subdirectories that are present
for JINCSUBDIR in $_JNI_INC_SUBDIRS
do
    if test -d "$_JTOPDIR/include/$JINCSUBDIR"; then
         JNI_INCLUDE_DIRS="$JNI_INCLUDE_DIRS|$_JTOPDIR/include/$JINCSUBDIR"
    fi
done
OLD_IFS=${IFS}
IFS="|"
INCLUDE_DIR=
for JNI_INCLUDE_DIR in $JNI_INCLUDE_DIRS
do
    INCLUDE_DIR=$(echo "${JNI_INCLUDE_DIR}" | sed -e 's/ /\\ /')
    if [ test ! -z "${INCLUDE_DIR}" ]; then
        CPPFLAGS="$CPPFLAGS -I${INCLUDE_DIR}"
    fi
done
INCLUDE_DIR=
IFS=${OLD_IFS}
])

# _ACJNI_FOLLOW_SYMLINKS <path>
# Follows symbolic links on <path>,
# finally setting variable _ACJNI_FOLLOWED
# ----------------------------------------
AC_DEFUN([_ACJNI_FOLLOW_SYMLINKS],[
# find the include directory relative to the javac executable
_cur="$1"
while ls -ld "$_cur" 2>/dev/null | grep " -> " >/dev/null; do
        AC_MSG_CHECKING([symlink for $_cur])
        _slink=`ls -ld "$_cur" | sed 's/.* -> //'`
        case "$_slink" in
        /*) _cur="$_slink";;
        # 'X' avoids triggering unwanted echo options.
        *) _cur=`echo "X$_cur" | sed -e 's/^X//' -e 's:[[^/]]*$::'`"$_slink";;
        esac
        AC_MSG_RESULT([$_cur])
done
_ACJNI_FOLLOWED="$_cur"
])# _ACJNI
