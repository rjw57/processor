#!/usr/bin/env python3

import enum

from processor.encoding import Opcode

ADDR_WIDTH = 15


class Flags(enum.IntFlag):
    Carry = 1 << 0
    Negative = 1 << 1


class Line(enum.IntFlag):
    # Stage 1
    IncrementPCRA0 = 1 << 0
    IncrementPCRA1 = 1 << 1
    InstrDispatchBar = 1 << 2
    LoadRegConst = 1 << 3
    AssertLHSDeviceBit0 = 1 << 4
    AssertLHSDeviceBit1 = 1 << 5
    AssertRHSDeviceBit0 = 1 << 6
    AssertRHSDeviceBit1 = 1 << 7
    ALUOpcodeBit0 = 1 << 8
    ALUOpcodeBit1 = 1 << 9
    ALUOpcodeBit2 = 1 << 10
    ALUOpcodeBit3 = 1 << 11
    Bit12 = 1 << 12
    Bit13 = 1 << 13
    Bit14 = 1 << 14
    Halt = 1 << 15

    # Stage 2
    LoadMainDeviceBit0 = 1 << 16
    LoadMainDeviceBit1 = 1 << 17
    LoadMainDeviceBit2 = 1 << 18
    ALUCarryIn = 1 << 19
    AssertMainDeviceBit0 = 1 << 20
    AssertMainDeviceBit1 = 1 << 21
    AssertMainDeviceBit2 = 1 << 22
    LoadRegFlags = 1 << 23
    Bit24 = 1 << 24
    Bit25 = 1 << 25
    Bit26 = 1 << 26
    Bit27 = 1 << 27
    Bit28 = 1 << 28
    Bit29 = 1 << 29
    Bit30 = 1 << 30
    Bit31 = 1 << 31

    # Convenience for LHS assert
    AssertLHSRegA = 0 << 4
    AssertLHSRegB = 1 << 4
    AssertLHSRegC = 2 << 4
    AssertLHSRegD = 3 << 4

    # Convenience for RHS assert
    AssertRHSRegA = 0 << 6
    AssertRHSRegB = 1 << 6
    AssertRHSRegC = 2 << 6
    AssertRHSRegD = 3 << 6

    # Convenience for ALU opcode
    ALUOpcodeAdd = 0 << 8
    ALUOpcodeSub = 1 << 8
    ALUOpcodeBitAnd = 2 << 8
    ALUOpcodeBitOr = 3 << 8
    ALUOpcodeBitXor = 4 << 8
    ALUOpcodeNotRHS = 5 << 8
    ALUOpcodeLogicalShiftLeftLHS = 6 << 8
    ALUOpcodeLogicalShiftRightLHS = 7 << 8
    ALUOpcodeArithShiftRightLHS = 8 << 8
    ALUOpcodeRotateLeftLHS = 9 << 8
    ALUOpcodeRotateRightLHS = 10 << 8
    ALUOpcodeZero = 11 << 8

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
    AssertMainDeviceIndex7 = 7 << 20
    AssertMainDeviceIndex8 = 8 << 20
    AssertMainDeviceIndex9 = 9 << 20
    AssertMainDeviceIndex10 = 10 << 20
    AssertMainDeviceIndex11 = 11 << 20
    AssertMainDeviceIndex12 = 12 << 20
    AssertMainDeviceIndex13 = 13 << 20
    AssertMainDeviceIndex14 = 14 << 20
    AssertMainDeviceIndex15 = 15 << 20


def control_lines(flags, opcode):
    inc_pc_flag = Line.IncrementPCRA0

    # Default to increment PC
    out = inc_pc_flag

    if opcode == Opcode.NOP:
        return out
    elif opcode == Opcode.HALT:
        # FIXME: halt still increments PC. Do we want halt to be in pipeline 1
        # or 2?
        out |= Line.Halt
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
            Line.LoadRegA | Line.AssertMainALUResult | Line.LoadRegFlags
        )
    elif opcode == Opcode.ADD_REGA_REGC:
        out |= (
            Line.AssertLHSRegA | Line.AssertRHSRegC | Line.ALUOpcodeAdd |
            Line.LoadRegA | Line.AssertMainALUResult | Line.LoadRegFlags
        )
    elif opcode == Opcode.ADD_REGA_REGD:
        out |= (
            Line.AssertLHSRegA | Line.AssertRHSRegD | Line.ALUOpcodeAdd |
            Line.LoadRegA | Line.AssertMainALUResult | Line.LoadRegFlags
        )
    elif opcode == Opcode.ADD_REGB_REGA:
        out |= (
            Line.AssertLHSRegB | Line.AssertRHSRegA | Line.ALUOpcodeAdd |
            Line.LoadRegB | Line.AssertMainALUResult | Line.LoadRegFlags
        )
    elif opcode == Opcode.ADD_REGB_REGC:
        out |= (
            Line.AssertLHSRegB | Line.AssertRHSRegC | Line.ALUOpcodeAdd |
            Line.LoadRegB | Line.AssertMainALUResult | Line.LoadRegFlags
        )
    elif opcode == Opcode.ADD_REGB_REGD:
        out |= (
            Line.AssertLHSRegB | Line.AssertRHSRegD | Line.ALUOpcodeAdd |
            Line.LoadRegB | Line.AssertMainALUResult | Line.LoadRegFlags
        )
    elif opcode == Opcode.ADD_REGC_REGA:
        out |= (
            Line.AssertLHSRegC | Line.AssertRHSRegA | Line.ALUOpcodeAdd |
            Line.LoadRegC | Line.AssertMainALUResult | Line.LoadRegFlags
        )
    elif opcode == Opcode.ADD_REGC_REGB:
        out |= (
            Line.AssertLHSRegC | Line.AssertRHSRegB | Line.ALUOpcodeAdd |
            Line.LoadRegC | Line.AssertMainALUResult | Line.LoadRegFlags
        )
    elif opcode == Opcode.ADD_REGC_REGD:
        out |= (
            Line.AssertLHSRegC | Line.AssertRHSRegD | Line.ALUOpcodeAdd |
            Line.LoadRegC | Line.AssertMainALUResult | Line.LoadRegFlags
        )
    elif opcode == Opcode.ADD_REGD_REGA:
        out |= (
            Line.AssertLHSRegD | Line.AssertRHSRegA | Line.ALUOpcodeAdd |
            Line.LoadRegD | Line.AssertMainALUResult | Line.LoadRegFlags
        )
    elif opcode == Opcode.ADD_REGD_REGB:
        out |= (
            Line.AssertLHSRegD | Line.AssertRHSRegB | Line.ALUOpcodeAdd |
            Line.LoadRegD | Line.AssertMainALUResult | Line.LoadRegFlags
        )
    elif opcode == Opcode.ADD_REGD_REGC:
        out |= (
            Line.AssertLHSRegD | Line.AssertRHSRegC | Line.ALUOpcodeAdd |
            Line.LoadRegD | Line.AssertMainALUResult | Line.LoadRegFlags
        )
    elif opcode == Opcode.SUB_REGA_REGB:
        out |= (
            Line.AssertLHSRegA | Line.AssertRHSRegB | Line.ALUOpcodeSub | Line.ALUCarryIn |
            Line.LoadRegA | Line.AssertMainALUResult | Line.LoadRegFlags
        )
    elif opcode == Opcode.SUB_REGA_REGC:
        out |= (
            Line.AssertLHSRegA | Line.AssertRHSRegC | Line.ALUOpcodeSub | Line.ALUCarryIn |
            Line.LoadRegA | Line.AssertMainALUResult | Line.LoadRegFlags
        )
    elif opcode == Opcode.SUB_REGA_REGD:
        out |= (
            Line.AssertLHSRegA | Line.AssertRHSRegD | Line.ALUOpcodeSub | Line.ALUCarryIn |
            Line.LoadRegA | Line.AssertMainALUResult | Line.LoadRegFlags
        )
    elif opcode == Opcode.SUB_REGB_REGA:
        out |= (
            Line.AssertLHSRegB | Line.AssertRHSRegA | Line.ALUOpcodeSub | Line.ALUCarryIn |
            Line.LoadRegB | Line.AssertMainALUResult | Line.LoadRegFlags
        )
    elif opcode == Opcode.SUB_REGB_REGC:
        out |= (
            Line.AssertLHSRegB | Line.AssertRHSRegC | Line.ALUOpcodeSub | Line.ALUCarryIn |
            Line.LoadRegB | Line.AssertMainALUResult | Line.LoadRegFlags
        )
    elif opcode == Opcode.SUB_REGB_REGD:
        out |= (
            Line.AssertLHSRegB | Line.AssertRHSRegD | Line.ALUOpcodeSub | Line.ALUCarryIn |
            Line.LoadRegB | Line.AssertMainALUResult | Line.LoadRegFlags
        )
    elif opcode == Opcode.SUB_REGC_REGA:
        out |= (
            Line.AssertLHSRegC | Line.AssertRHSRegA | Line.ALUOpcodeSub | Line.ALUCarryIn |
            Line.LoadRegC | Line.AssertMainALUResult | Line.LoadRegFlags
        )
    elif opcode == Opcode.SUB_REGC_REGB:
        out |= (
            Line.AssertLHSRegC | Line.AssertRHSRegB | Line.ALUOpcodeSub | Line.ALUCarryIn |
            Line.LoadRegC | Line.AssertMainALUResult | Line.LoadRegFlags
        )
    elif opcode == Opcode.SUB_REGC_REGD:
        out |= (
            Line.AssertLHSRegC | Line.AssertRHSRegD | Line.ALUOpcodeSub | Line.ALUCarryIn |
            Line.LoadRegC | Line.AssertMainALUResult | Line.LoadRegFlags
        )
    elif opcode == Opcode.SUB_REGD_REGA:
        out |= (
            Line.AssertLHSRegD | Line.AssertRHSRegA | Line.ALUOpcodeSub | Line.ALUCarryIn |
            Line.LoadRegD | Line.AssertMainALUResult | Line.LoadRegFlags
        )
    elif opcode == Opcode.SUB_REGD_REGB:
        out |= (
            Line.AssertLHSRegD | Line.AssertRHSRegB | Line.ALUOpcodeSub | Line.ALUCarryIn |
            Line.LoadRegD | Line.AssertMainALUResult | Line.LoadRegFlags
        )
    elif opcode == Opcode.SUB_REGD_REGC:
        out |= (
            Line.AssertLHSRegD | Line.AssertRHSRegC | Line.ALUOpcodeSub | Line.ALUCarryIn |
            Line.LoadRegD | Line.AssertMainALUResult | Line.LoadRegFlags
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
