import enum


class Encoding(enum.Enum):
    NOP                 = [0x00]
    HALT                = [0x01]
    MOV_REGA_REGB       = [0x41]
    MOV_REGA_IMM        = [0x51, '#0']
    MOV_REGA_IREGSI     = [0x61]


# Generate an IntEnum of opcode values from the first value in the instruction
# encoding.
Opcode = enum.IntEnum('Opcodes', (
    (encoding.name, encoding.value[0])
    for encoding in Encoding
))
