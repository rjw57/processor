#!/usr/bin/env python3

import enum

from processor.encoding import Opcode

ADDR_WIDTH = 15


class Flags(enum.IntFlag):
    Carry = 1 << 0
    Negative = 1 << 1


class Line(enum.IntFlag):
    # Stage 1
    LoadRegConst = 1 << 0
    AssertLHSBit0 = 1 << 1
    AssertLHSBit1 = 1 << 2
    AssertRHSBit0 = 1 << 3
    AssertRHSBit1 = 1 << 4
    ALUOpcodeBit0 = 1 << 5
    ALUOpcodeBit1 = 1 << 6
    ALUOpcodeBit2 = 1 << 7
    ALUOpcodeBit3 = 1 << 8
    Bit9 = 1 << 0
    Bit10 = 1 << 10
    Bit11 = 1 << 11
    Bit12 = 1 << 12
    Bit13 = 1 << 13
    Bit14 = 1 << 14
    InstrDispatchBar = 1 << 15 # Can this be merged with LoadRegConst?

    # Stage 2
    LoadMainBit0 = 1 << 16
    LoadMainBit1 = 1 << 17
    LoadMainBit2 = 1 << 18
    ALUCarryIn = 1 << 19
    AssertMainBit0 = 1 << 20
    AssertMainBit1 = 1 << 21
    AssertMainBit2 = 1 << 22
    Bit23 = 1 << 23
    Bit24 = 1 << 24
    Bit25 = 1 << 25
    Bit26 = 1 << 26
    Bit27 = 1 << 27
    Bit28 = 1 << 28
    Bit29 = 1 << 29
    Bit30 = 1 << 30
    Halt = 1 << 31

    # Convenience for LHS assert
    AssertLHSRegA = 0 << 1
    AssertLHSRegB = 1 << 1
    AssertLHSRegC = 2 << 1
    AssertLHSRegD = 3 << 1

    # Convenience for RHS assert
    AssertRHSRegA = 0 << 3
    AssertRHSRegB = 1 << 3
    AssertRHSRegC = 2 << 3
    AssertRHSRegD = 3 << 3

    # Convenience for ALU opcode
    ALUOpcodeZero = 0 << 5
    ALUOpcodeAdd = 1 << 5
    ALUOpcodeSub = 2 << 5
    ALUOpcodeBitAnd = 3 << 5
    ALUOpcodeBitOr = 4 << 5
    ALUOpcodeBitXor = 5 << 5
    ALUOpcodeNotRHS = 6 << 5
    ALUOpcodeLogicalShiftLeftLHS = 7 << 5
    ALUOpcodeLogicalShiftRightLHS = 8 << 5
    ALUOpcodeArithShiftRightLHS = 9 << 5
    ALUOpcodeRotateLeftLHS = 10 << 5
    ALUOpcodeRotateRightLHS = 11 << 5

    # Concenience for increment register index
    TickRegPC = 1 << 10

    # Convenience for main load
    LoadRegA = 1 << 16
    LoadRegB = 2 << 16
    LoadRegC = 3 << 16
    LoadRegD = 4 << 16

    # Convenience for main bus assert device selection
    AssertMainRegConst = 1 << 20
    AssertMainRegA = 2 << 20
    AssertMainRegB = 3 << 20
    AssertMainRegC = 4 << 20
    AssertMainRegD = 5 << 20
    AssertMainALUResult = 6 << 20
    AssertMainIndex7 = 7 << 20
    AssertMainIndex8 = 8 << 20
    AssertMainIndex9 = 9 << 20
    AssertMainIndex10 = 10 << 20
    AssertMainIndex11 = 11 << 20
    AssertMainIndex12 = 12 << 20
    AssertMainIndex13 = 13 << 20
    AssertMainIndex14 = 14 << 20
    AssertMainIndex15 = 15 << 20


def control_lines(flags, opcode):
    inc_pc_flag = Line.TickRegPC

    # Default to increment PC
    out = inc_pc_flag

    # is the carry flag set
    is_carry = (flags & Flags.Carry) != 0

    # how would we set the ALU's carry in to match the current carry flag?
    if is_carry:
        set_input_carry = Line.ALUCarryIn
    else:
        set_input_carry = 0

    if opcode == Opcode.NOP:
        # nothing
        pass
    elif opcode == Opcode.HALT:
        # FIXME: halt still increments PC. We need some sort
        # of pipeline stall support
        out |= Line.Halt
        out &= ~inc_pc_flag
    elif opcode == Opcode.MOV_REGA_IMM:
        out |= (
            Line.InstrDispatchBar
            | Line.LoadRegConst
            | Line.LoadRegA
            | Line.AssertMainRegConst
        )
    elif opcode == Opcode.MOV_REGB_IMM:
        out |= (
            Line.InstrDispatchBar
            | Line.LoadRegConst
            | Line.LoadRegB
            | Line.AssertMainRegConst
        )
    elif opcode == Opcode.MOV_REGC_IMM:
        out |= (
            Line.InstrDispatchBar
            | Line.LoadRegConst
            | Line.LoadRegC
            | Line.AssertMainRegConst
        )
    elif opcode == Opcode.MOV_REGD_IMM:
        out |= (
            Line.InstrDispatchBar
            | Line.LoadRegConst
            | Line.LoadRegD
            | Line.AssertMainRegConst
        )
    elif opcode == Opcode.MOV_REGA_REGB:
        out |= Line.LoadRegA | Line.AssertMainRegB
    elif opcode == Opcode.MOV_REGA_REGC:
        out |= Line.LoadRegA | Line.AssertMainRegC
    elif opcode == Opcode.MOV_REGA_REGD:
        out |= Line.LoadRegA | Line.AssertMainRegD
    elif opcode == Opcode.MOV_REGB_REGA:
        out |= Line.LoadRegB | Line.AssertMainRegA
    elif opcode == Opcode.MOV_REGB_REGC:
        out |= Line.LoadRegB | Line.AssertMainRegC
    elif opcode == Opcode.MOV_REGB_REGD:
        out |= Line.LoadRegB | Line.AssertMainRegD
    elif opcode == Opcode.MOV_REGC_REGA:
        out |= Line.LoadRegC | Line.AssertMainRegA
    elif opcode == Opcode.MOV_REGC_REGB:
        out |= Line.LoadRegC | Line.AssertMainRegB
    elif opcode == Opcode.MOV_REGC_REGD:
        out |= Line.LoadRegC | Line.AssertMainRegD
    elif opcode == Opcode.MOV_REGD_REGA:
        out |= Line.LoadRegD | Line.AssertMainRegA
    elif opcode == Opcode.MOV_REGD_REGB:
        out |= Line.LoadRegD | Line.AssertMainRegB
    elif opcode == Opcode.MOV_REGD_REGC:
        out |= Line.LoadRegD | Line.AssertMainRegC
    elif opcode == Opcode.ADD_REGA_REGB:
        out |= (
            Line.AssertLHSRegA | Line.AssertRHSRegB | Line.ALUOpcodeAdd |
            Line.LoadRegA | Line.AssertMainALUResult
        )
    elif opcode == Opcode.ADD_REGA_REGC:
        out |= (
            Line.AssertLHSRegA | Line.AssertRHSRegC | Line.ALUOpcodeAdd |
            Line.LoadRegA | Line.AssertMainALUResult
        )
    elif opcode == Opcode.ADD_REGA_REGD:
        out |= (
            Line.AssertLHSRegA | Line.AssertRHSRegD | Line.ALUOpcodeAdd |
            Line.LoadRegA | Line.AssertMainALUResult
        )
    elif opcode == Opcode.ADD_REGB_REGA:
        out |= (
            Line.AssertLHSRegB | Line.AssertRHSRegA | Line.ALUOpcodeAdd |
            Line.LoadRegB | Line.AssertMainALUResult
        )
    elif opcode == Opcode.ADD_REGB_REGC:
        out |= (
            Line.AssertLHSRegB | Line.AssertRHSRegC | Line.ALUOpcodeAdd |
            Line.LoadRegB | Line.AssertMainALUResult
        )
    elif opcode == Opcode.ADD_REGB_REGD:
        out |= (
            Line.AssertLHSRegB | Line.AssertRHSRegD | Line.ALUOpcodeAdd |
            Line.LoadRegB | Line.AssertMainALUResult
        )
    elif opcode == Opcode.ADD_REGC_REGA:
        out |= (
            Line.AssertLHSRegC | Line.AssertRHSRegA | Line.ALUOpcodeAdd |
            Line.LoadRegC | Line.AssertMainALUResult
        )
    elif opcode == Opcode.ADD_REGC_REGB:
        out |= (
            Line.AssertLHSRegC | Line.AssertRHSRegB | Line.ALUOpcodeAdd |
            Line.LoadRegC | Line.AssertMainALUResult
        )
    elif opcode == Opcode.ADD_REGC_REGD:
        out |= (
            Line.AssertLHSRegC | Line.AssertRHSRegD | Line.ALUOpcodeAdd |
            Line.LoadRegC | Line.AssertMainALUResult
        )
    elif opcode == Opcode.ADD_REGD_REGA:
        out |= (
            Line.AssertLHSRegD | Line.AssertRHSRegA | Line.ALUOpcodeAdd |
            Line.LoadRegD | Line.AssertMainALUResult
        )
    elif opcode == Opcode.ADD_REGD_REGB:
        out |= (
            Line.AssertLHSRegD | Line.AssertRHSRegB | Line.ALUOpcodeAdd |
            Line.LoadRegD | Line.AssertMainALUResult
        )
    elif opcode == Opcode.ADD_REGD_REGC:
        out |= (
            Line.AssertLHSRegD | Line.AssertRHSRegC | Line.ALUOpcodeAdd |
            Line.LoadRegD | Line.AssertMainALUResult
        )
    elif opcode == Opcode.SUB_REGA_REGB:
        out |= (
            Line.AssertLHSRegA | Line.AssertRHSRegB | Line.ALUOpcodeSub | Line.ALUCarryIn |
            Line.LoadRegA | Line.AssertMainALUResult
        )
    elif opcode == Opcode.SUB_REGA_REGC:
        out |= (
            Line.AssertLHSRegA | Line.AssertRHSRegC | Line.ALUOpcodeSub | Line.ALUCarryIn |
            Line.LoadRegA | Line.AssertMainALUResult
        )
    elif opcode == Opcode.SUB_REGA_REGD:
        out |= (
            Line.AssertLHSRegA | Line.AssertRHSRegD | Line.ALUOpcodeSub | Line.ALUCarryIn |
            Line.LoadRegA | Line.AssertMainALUResult
        )
    elif opcode == Opcode.SUB_REGB_REGA:
        out |= (
            Line.AssertLHSRegB | Line.AssertRHSRegA | Line.ALUOpcodeSub | Line.ALUCarryIn |
            Line.LoadRegB | Line.AssertMainALUResult
        )
    elif opcode == Opcode.SUB_REGB_REGC:
        out |= (
            Line.AssertLHSRegB | Line.AssertRHSRegC | Line.ALUOpcodeSub | Line.ALUCarryIn |
            Line.LoadRegB | Line.AssertMainALUResult
        )
    elif opcode == Opcode.SUB_REGB_REGD:
        out |= (
            Line.AssertLHSRegB | Line.AssertRHSRegD | Line.ALUOpcodeSub | Line.ALUCarryIn |
            Line.LoadRegB | Line.AssertMainALUResult
        )
    elif opcode == Opcode.SUB_REGC_REGA:
        out |= (
            Line.AssertLHSRegC | Line.AssertRHSRegA | Line.ALUOpcodeSub | Line.ALUCarryIn |
            Line.LoadRegC | Line.AssertMainALUResult
        )
    elif opcode == Opcode.SUB_REGC_REGB:
        out |= (
            Line.AssertLHSRegC | Line.AssertRHSRegB | Line.ALUOpcodeSub | Line.ALUCarryIn |
            Line.LoadRegC | Line.AssertMainALUResult
        )
    elif opcode == Opcode.SUB_REGC_REGD:
        out |= (
            Line.AssertLHSRegC | Line.AssertRHSRegD | Line.ALUOpcodeSub | Line.ALUCarryIn |
            Line.LoadRegC | Line.AssertMainALUResult
        )
    elif opcode == Opcode.SUB_REGD_REGA:
        out |= (
            Line.AssertLHSRegD | Line.AssertRHSRegA | Line.ALUOpcodeSub | Line.ALUCarryIn |
            Line.LoadRegD | Line.AssertMainALUResult
        )
    elif opcode == Opcode.SUB_REGD_REGB:
        out |= (
            Line.AssertLHSRegD | Line.AssertRHSRegB | Line.ALUOpcodeSub | Line.ALUCarryIn |
            Line.LoadRegD | Line.AssertMainALUResult
        )
    elif opcode == Opcode.SUB_REGD_REGC:
        out |= (
            Line.AssertLHSRegD | Line.AssertRHSRegC | Line.ALUOpcodeSub | Line.ALUCarryIn |
            Line.LoadRegD | Line.AssertMainALUResult
        )
    elif opcode == Opcode.ADDC_REGA_REGB:
        out |= (
            Line.AssertLHSRegA | Line.AssertRHSRegB | Line.ALUOpcodeAdd | set_input_carry |
            Line.LoadRegA | Line.AssertMainALUResult
        )
    elif opcode == Opcode.ADDC_REGA_REGC:
        out |= (
            Line.AssertLHSRegA | Line.AssertRHSRegC | Line.ALUOpcodeAdd | set_input_carry |
            Line.LoadRegA | Line.AssertMainALUResult
        )
    elif opcode == Opcode.ADDC_REGA_REGD:
        out |= (
            Line.AssertLHSRegA | Line.AssertRHSRegD | Line.ALUOpcodeAdd | set_input_carry |
            Line.LoadRegA | Line.AssertMainALUResult
        )
    elif opcode == Opcode.ADDC_REGB_REGA:
        out |= (
            Line.AssertLHSRegB | Line.AssertRHSRegA | Line.ALUOpcodeAdd | set_input_carry |
            Line.LoadRegB | Line.AssertMainALUResult
        )
    elif opcode == Opcode.ADDC_REGB_REGC:
        out |= (
            Line.AssertLHSRegB | Line.AssertRHSRegC | Line.ALUOpcodeAdd | set_input_carry |
            Line.LoadRegB | Line.AssertMainALUResult
        )
    elif opcode == Opcode.ADDC_REGB_REGD:
        out |= (
            Line.AssertLHSRegB | Line.AssertRHSRegD | Line.ALUOpcodeAdd | set_input_carry |
            Line.LoadRegB | Line.AssertMainALUResult
        )
    elif opcode == Opcode.ADDC_REGC_REGA:
        out |= (
            Line.AssertLHSRegC | Line.AssertRHSRegA | Line.ALUOpcodeAdd | set_input_carry |
            Line.LoadRegC | Line.AssertMainALUResult
        )
    elif opcode == Opcode.ADDC_REGC_REGB:
        out |= (
            Line.AssertLHSRegC | Line.AssertRHSRegB | Line.ALUOpcodeAdd | set_input_carry |
            Line.LoadRegC | Line.AssertMainALUResult
        )
    elif opcode == Opcode.ADDC_REGC_REGD:
        out |= (
            Line.AssertLHSRegC | Line.AssertRHSRegD | Line.ALUOpcodeAdd | set_input_carry |
            Line.LoadRegC | Line.AssertMainALUResult
        )
    elif opcode == Opcode.ADDC_REGD_REGA:
        out |= (
            Line.AssertLHSRegD | Line.AssertRHSRegA | Line.ALUOpcodeAdd | set_input_carry |
            Line.LoadRegD | Line.AssertMainALUResult
        )
    elif opcode == Opcode.ADDC_REGD_REGB:
        out |= (
            Line.AssertLHSRegD | Line.AssertRHSRegB | Line.ALUOpcodeAdd | set_input_carry |
            Line.LoadRegD | Line.AssertMainALUResult
        )
    elif opcode == Opcode.ADDC_REGD_REGC:
        out |= (
            Line.AssertLHSRegD | Line.AssertRHSRegC | Line.ALUOpcodeAdd | set_input_carry |
            Line.LoadRegD | Line.AssertMainALUResult
        )

    return out


def main():
    roms = {"1a": [], "1b": [], "2a": [], "2b": []}
    for addr in range(2 ** ADDR_WIDTH):
        lines = control_lines(addr >> 8, addr & 0xFF)
        roms["1a"].append(lines & 0xFF)
        roms["1b"].append((lines >> 8) & 0xFF)
        roms["2a"].append((lines >> 16) & 0xFF)
        roms["2b"].append((lines >> 24) & 0xFF)

    for suffix, values in roms.items():
        with open(f"pipeline-{suffix}.mem", "w") as output:
            for value in values:
                output.write(f"{value:02x}\n")


if __name__ == "__main__":
    main()
