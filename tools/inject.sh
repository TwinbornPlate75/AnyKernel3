check_tools() {
    if ! command -v readelf >/dev/null 2>&1 || ! command -v awk >/dev/null 2>&1 || \
       ! command -v grep >/dev/null 2>&1; then
        return 1
    fi
}

analyze_file_info() {
    local file="$1"

    TEXT_VADDR=$(readelf -S "$file" | grep "\.text" | awk '{print $4}')
    TEXT_OFFSET=$(readelf -S "$file" | grep "\.text" | awk '{print $5}')

    if [ -z "$TEXT_VADDR" ] || [ -z "$TEXT_OFFSET" ]; then
        return 1
    fi

    TEXT_VADDR_DEC=$(printf "%d" "0x$TEXT_VADDR")
    TEXT_OFFSET_DEC=$(printf "%d" "0x$TEXT_OFFSET")
    return 0
}

# Resolve the file offset of a single named symbol (its entry point) from the
# ELF symbol table via readelf. Surface::queueBuffer only needs the function
# entry, so no disassembly is required.
find_queuebuf_symbol() {
    local file="$1"
    local mangled="$2"
    local sym val_dec

    # readelf -Ws covers both .symtab and .dynsym; column 8 is the name.
    sym=$(readelf -Ws "$file" 2>/dev/null | \
        awk -v m="$mangled" '$4=="FUNC" && $7!="UND" && $8==m {print $2; exit}')
    [ -z "$sym" ] && return 1

    val_dec=$(printf "%d" "0x$sym")
    [ "$val_dec" -ge "$TEXT_VADDR_DEC" ] || return 1

    QUEUEBUF_OFFSET=$((val_dec - TEXT_VADDR_DEC + TEXT_OFFSET_DEC))
    return 0
}

# Surface::queueBuffer has two manglings across Android versions:
#   old: ...queueBuffer(ANativeWindowBuffer*, int)
#   new: ...queueBuffer(ANativeWindowBuffer*, int, SurfaceQueueBufferOutput*)
# Only one exists per lib, so try the old signature first then the new one and
# emit the single offset that resolves. The kernel receives one offset.
analyze_libgui() {
    if [ $# -ne 1 ]; then
        return 1
    fi

    local file="$1"

    if [ ! -f "$file" ]; then
        return 1
    fi

    check_tools || return 1
    analyze_file_info "$file" || return 1

    find_queuebuf_symbol "$file" \
        "_ZN7android7Surface11queueBufferEP19ANativeWindowBufferi" || \
    find_queuebuf_symbol "$file" \
        "_ZN7android7Surface11queueBufferEP19ANativeWindowBufferiPNS_24SurfaceQueueBufferOutputE" || \
        return 1

    printf "0x%x\n" "$QUEUEBUF_OFFSET"
    return 0
}
