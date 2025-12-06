check_tools() {
    if ! command -v file >/dev/null 2>&1 || ! command -v readelf >/dev/null 2>&1 || \
       ! command -v strings >/dev/null 2>&1 || ! command -v grep >/dev/null 2>&1 || \
       ! command -v xxd >/dev/null 2>&1; then
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

find_target_function() {
    local file="$1"
    
    STRING_BYTE_OFFSET=$(grep -abo "nSyncAndDrawFrame" "$file" | head -1 | cut -d: -f1)
    
    if [ -z "$STRING_BYTE_OFFSET" ]; then
        return 1
    fi
    
    STRING_BYTE_OFFSET_HEX=$(printf "%016x" "$STRING_BYTE_OFFSET")
    STRING_HEX_REVERSED=$(echo "$STRING_BYTE_OFFSET_HEX" | sed 's/\(..\)/\1 /g' | awk '{for(i=NF;i>0;i--)printf "%s",$i}' | tr -d ' ')
    FUNC_PTR_OFFSET=$(xxd -p "$file" | tr -d '\n' | grep -b -o "$STRING_HEX_REVERSED" | head -1 | cut -d: -f1)
    
    if [ -z "$FUNC_PTR_OFFSET" ]; then
        return 1
    fi
    
    FUNC_PTR_OFFSET=$((FUNC_PTR_OFFSET / 2))
    FUNC_PTR_READ_OFFSET=$((FUNC_PTR_OFFSET + 16))
    FUNC_PTR_BYTES=$(dd if="$file" bs=1 skip="$FUNC_PTR_READ_OFFSET" count=8 2>/dev/null | xxd -p -c 8 | tr -d '\n')
    FUNC_PTR_HEX=$(echo "$FUNC_PTR_BYTES" | tr -d ' ' | sed 's/\(..\)/\1 /g' | awk '{for(i=NF;i>0;i--)printf "%s",$i}' | tr -d ' ')
    FUNC_PTR="0x$FUNC_PTR_HEX"
    
    if [ -z "$FUNC_PTR" ]; then
        return 1
    fi
    
    FUNC_PTR_DEC=$(printf "%d" "$FUNC_PTR")
    if [ "$FUNC_PTR_DEC" -ge "$TEXT_VADDR_DEC" ]; then
        FUNC_FILE_OFFSET=$((FUNC_PTR_DEC - TEXT_VADDR_DEC + TEXT_OFFSET_DEC))
        return 0
    else
        return 1
    fi
}

analyze_function() {
    local file="$1"
    
    FUNC_HEX=$(dd if="$file" bs=1 skip="$FUNC_FILE_OFFSET" count=200 2>/dev/null | xxd -p -c 200 | tr -d '\n')
    
    if [ -z "$FUNC_HEX" ]; then
        return 1
    fi
    
    DISASM_OUTPUT=$(cstool aarch64 "$FUNC_HEX" 2>/dev/null)
    
    if [ -z "$DISASM_OUTPUT" ]; then
        return 1
    fi
    
    X4_ASSIGN_LINE=$(echo "$DISASM_OUTPUT" | grep -E "mov.*x4,|add.*x4,|ldr.*x4," | head -1)
    
    if [ -z "$X4_ASSIGN_LINE" ]; then
        return 1
    fi
    
    X4_ASSIGN_REL_ADDR=$(echo "$X4_ASSIGN_LINE" | awk '{print $1}')
    X4_ASSIGN_REL_OFFSET_DEC=$(printf "%d" "0x$X4_ASSIGN_REL_ADDR")
    INJECT1_OFFSET=$((FUNC_FILE_OFFSET + X4_ASSIGN_REL_OFFSET_DEC + 4))
    
    BLR_LINE=$(echo "$DISASM_OUTPUT" | grep -E "blr" | head -1)
    
    if [ -z "$BLR_LINE" ]; then
        return 1
    fi
    
    BLR_REL_ADDR=$(echo "$BLR_LINE" | awk '{print $1}')
    BLR_REL_OFFSET_DEC=$(printf "%d" "0x$BLR_REL_ADDR")
    INJECT2_OFFSET=$((FUNC_FILE_OFFSET + BLR_REL_OFFSET_DEC + 4))
    return 0
}

analyze_libhwui() {
    if [ $# -ne 1 ]; then
        return 1
    fi
    
    local file="$1"
    
    if [ ! -f "$file" ]; then
        return 1
    fi
    
    check_tools || return 1
    analyze_file_info "$file" || return 1
    find_target_function "$file" || return 1
    analyze_function "$file" || return 1
    
    printf "0x%x 0x%x\n" "$INJECT1_OFFSET" "$INJECT2_OFFSET"
    return 0
}
