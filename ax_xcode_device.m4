AC_DEFUN([AX_XCODE_DEVICE],
    [
        DEVELOPER_PATH=$(xcode-select --print-path)
        DEFAULT_DEVICE='iPhoneSimulator'
        SDK_PATH=
        DEVICE=
        SIMULATOR=
        MINVERSION=
        AC_ARG_WITH(
            [xcode-device],
            [AC_HELP_STRING(
                [--with-xcode-device],
                [This can be one of the following: iPhoneOS, iPhoneSimulator, AppleTVOS, AppleTVSimulator, WatchOS, WatchSimulator, MacOSX.]
            )],
            [
                DEVICE=${withval}
                SDK_PATH=${DEVELOPER_PATH}/Platforms/${DEVICE}.platform/Developer/SDKs
                ISYSROOT=${SDK_PATH}/${DEVICE}.sdk
                FOUNDATION=${ISYSROOT}/System/Library/Frameworks/Foundation.framework/Headers/Foundation.h
                AC_CHECK_FILE(
                    [${FOUNDATION}],
                    [
                        if test "x${DEVICE:(${#DEVICE}-2):2}" = "xOS"; then
                            SIMULATOR="no"
                        else
                            SIMULATOR="yes"
                        fi
                        VSORT=sort
                        if ! echo 'a b c' | $VSORT -V >& /dev/null; then
                            VSORT=gsort
                        fi
                        for dir in $(ls $SDK_PATH | $VSORT -V)
                        do
                            if ! test "x$dir" = "x$DEVICE.sdk"; then
                                MINVERSION=${dir:${#DEVICE}:${#dir} - ${#DEVICE} - 4}
                                break
                            fi
                        done
                        if test "x$SIMULATOR" = "xyes"; then
                            if test "$(echo -e "$MINVERSION\n11.0" | $VSORT -V | tail -n 1)" = "11.0"; then
                                CFLAGS="${CFLAGS} -arch i386"
                                OBJCFLAGS="${OBJCFLAGS} -arch i386"
                            fi
                            CFLAGS="${CFLAGS} -arch x86_64"
                            CFLAGS="${CFLAGS} -mios-simulator-version-min=${MINVERSION}"

                            OBJCFLAGS="${OBJCFLAGS} -arch x86_64"
                            OBJCFLAGS="${OBJCFLAGS} -mios-simulator-version-min=${MINVERSION}"
                        else
                            if test "$(echo -e "$MINVERSION\n11.0" | $VSORT -V | tail -n 1)" = "11.0"; then
                                CFLAGS="${CFLAGS} -arch armv7"
                                OBJCFLAGS="${OBJCFLAGS} -arch armv7"
                            fi
                            CFLAGS="${CFLAGS} -arch arm64"
                            CFLAGS="${CFLAGS} -mios-version-min=${MINVERSION}"

                            OBJCFLAGS="${OBJCFLAGS} -arch arm64"
                            OBJCFLAGS="${OBJCFLAGS} -mios-version-min=${MINVERSION}"
                        fi
                        CFLAGS="${CFLAGS} -isysroot ${ISYSROOT}"
                        OBJCFLAGS="${OBJCFLAGS} -isysroot ${ISYSROOT}"
                    ],
                    [AC_MSG_ERROR([specified ${DEVICE} is not valid])]
                )
            ],
            [AC_MSG_NOTICE([no xcode device configured])]
        )
    ]
)
