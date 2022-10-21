import enum


class Encoding(enum.Enum):
    NOP                 = [0x00]
    HALT                = [0x01]
    MOV_REGA_REGB       = [0x41]
    MOV_REGA_REGC       = [0x42]
    MOV_REGA_REGD       = [0x43]
    MOV_REGB_REGA       = [0x44]
    MOV_REGB_REGC       = [0x45]
    MOV_REGB_REGD       = [0x46]
    MOV_REGC_REGA       = [0x47]
    MOV_REGC_REGB       = [0x48]
    MOV_REGC_REGD       = [0x49]
    MOV_REGD_REGA       = [0x4a]
    MOV_REGD_REGB       = [0x4b]
    MOV_REGD_REGC       = [0x4c]
    MOV_REGA_IMM        = [0x51, '#0']
    MOV_REGB_IMM        = [0x52, '#0']
    MOV_REGC_IMM        = [0x53, '#0']
    MOV_REGD_IMM        = [0x54, '#0']
    MOV_REGA_IREGSI     = [0x61]


# Generate an IntEnum of opcode values from the first value in the instruction
# encoding.
Opcode = enum.IntEnum('Opcodes', (
    (encoding.name, encoding.value[0])
    for encoding in Encoding
))
