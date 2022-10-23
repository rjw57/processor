import enum


class Encoding(enum.Enum):
    NOP                 = [0x00]
    HALT                = [0x01]

    JMP_IMM             = [0x10, '<0', '>0']

    MOV_REGA_REGB       = [0x40]
    MOV_REGA_REGC       = [0x41]
    MOV_REGA_REGD       = [0x42]
    MOV_REGB_REGA       = [0x43]
    MOV_REGB_REGC       = [0x44]
    MOV_REGB_REGD       = [0x45]
    MOV_REGC_REGA       = [0x46]
    MOV_REGC_REGB       = [0x47]
    MOV_REGC_REGD       = [0x48]
    MOV_REGD_REGA       = [0x49]
    MOV_REGD_REGB       = [0x4a]
    MOV_REGD_REGC       = [0x4b]

    MOV_REGA_IMM        = [0x50, '<0']
    MOV_REGB_IMM        = [0x51, '<0']
    MOV_REGC_IMM        = [0x52, '<0']
    MOV_REGD_IMM        = [0x53, '<0']

    MOV_REGSI_REGAB     = [0x54]
    MOV_REGSI_REGCD     = [0x55]

    MOV_REGA_IREGSI     = [0x6a]

    ADD_REGA_REGB       = [0x70]
    ADD_REGA_REGC       = [0x71]
    ADD_REGA_REGD       = [0x72]
    ADD_REGB_REGA       = [0x73]
    ADD_REGB_REGC       = [0x74]
    ADD_REGB_REGD       = [0x75]
    ADD_REGC_REGA       = [0x76]
    ADD_REGC_REGB       = [0x77]
    ADD_REGC_REGD       = [0x78]
    ADD_REGD_REGA       = [0x79]
    ADD_REGD_REGB       = [0x7a]
    ADD_REGD_REGC       = [0x7b]

    SUB_REGA_REGB       = [0x80]
    SUB_REGA_REGC       = [0x81]
    SUB_REGA_REGD       = [0x82]
    SUB_REGB_REGA       = [0x83]
    SUB_REGB_REGC       = [0x84]
    SUB_REGB_REGD       = [0x85]
    SUB_REGC_REGA       = [0x86]
    SUB_REGC_REGB       = [0x87]
    SUB_REGC_REGD       = [0x88]
    SUB_REGD_REGA       = [0x89]
    SUB_REGD_REGB       = [0x8a]
    SUB_REGD_REGC       = [0x8b]

    ADDC_REGA_REGB       = [0x90]
    ADDC_REGA_REGC       = [0x91]
    ADDC_REGA_REGD       = [0x92]
    ADDC_REGB_REGA       = [0x93]
    ADDC_REGB_REGC       = [0x94]
    ADDC_REGB_REGD       = [0x95]
    ADDC_REGC_REGA       = [0x96]
    ADDC_REGC_REGB       = [0x97]
    ADDC_REGC_REGD       = [0x98]
    ADDC_REGD_REGA       = [0x99]
    ADDC_REGD_REGB       = [0x9a]
    ADDC_REGD_REGC       = [0x9b]


# Generate an IntEnum of opcode values from the first value in the instruction
# encoding.
Opcode = enum.IntEnum('Opcodes', (
    (encoding.name, encoding.value[0])
    for encoding in Encoding
))
