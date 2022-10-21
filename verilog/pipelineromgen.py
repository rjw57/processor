#!/usr/bin/env python3
import enum

from processor.encoding import Opcode

ADDR_WIDTH = 15

class Line(enum.IntFlag):
    # Stage 1
    IncrementPCRA0 = 1 << 0
    IncrementPCRA1 = 1 << 1
    Halt = 1 << 2
    InstrDispatchBar = 1 << 3
    LoadRegConst = 1 << 4
    Bit5 = 1 << 5
    Bit6 = 1 << 6
    Bit7 = 1 << 7
    Bit8 = 1 << 8
    Bit9 = 1 << 9
    Bit10 = 1 << 10
    Bit11 = 1 << 11
    Bit12 = 1 << 12
    Bit13 = 1 << 13
    Bit14 = 1 << 14
    Bit15 = 1 << 15

    # Stage 2
    LoadRegA = 1 << 16
    LoadRegB = 1 << 17
    LoadRegC = 1 << 18
    LoadRegD = 1 << 19
    AssertMainDeviceBit0 = 1 << 20
    AssertMainDeviceBit1 = 1 << 21
    AssertMainDeviceBit2 = 1 << 22
    Bit23 = 1 << 23
    Bit24 = 1 << 24
    Bit25 = 1 << 25
    Bit26 = 1 << 26
    Bit27 = 1 << 27
    Bit28 = 1 << 28
    Bit29 = 1 << 29
    Bit30 = 1 << 30
    Bit31 = 1 << 31

    # Convenience for main bus assert device selection
    AssertMainRegConst = 1 << 20
    AssertMainRegA = 2 << 20
    AssertMainRegB = 3 << 20
    AssertMainRegC = 4 << 20
    AssertMainRegD = 5 << 20
    AssertMainDeviceIndex6 = 6 << 20
    AssertMainDeviceIndex7 = 7 << 20


def control_lines(flags, opcode):
    inc_pc_flag = Line.IncrementPCRA0

    # Default to increment PC
    out = inc_pc_flag

    if opcode == Opcode.HALT:
        # On halt, stop incrementing the PC.
        out &= ~inc_pc_flag
        out |= Line.Halt
    elif opcode == Opcode.MOV_REGA_IMM:
        out |= Line.InstrDispatchBar | Line.LoadRegConst | Line.LoadRegA | Line.AssertMainRegConst
    elif opcode == Opcode.MOV_REGB_IMM:
        out |= Line.InstrDispatchBar | Line.LoadRegConst | Line.LoadRegB | Line.AssertMainRegConst
    elif opcode == Opcode.MOV_REGC_IMM:
        out |= Line.InstrDispatchBar | Line.LoadRegConst | Line.LoadRegC | Line.AssertMainRegConst
    elif opcode == Opcode.MOV_REGD_IMM:
        out |= Line.InstrDispatchBar | Line.LoadRegConst | Line.LoadRegD | Line.AssertMainRegConst
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

    return out


def main():
    roms = {'1a': [], '1b': [], '2a': [], '2b': []}
    for addr in range(2**ADDR_WIDTH):
        lines = control_lines(addr >> 8, addr & 0xff)
        roms['1a'].append(lines & 0xff)
        roms['1b'].append((lines >> 8) & 0xff)
        roms['2a'].append((lines >> 16) & 0xff)
        roms['2b'].append((lines >> 24) & 0xff)

    for suffix, values in roms.items():
        with open(f'pipeline-{suffix}.mem', 'w') as output:
            for value in values:
                output.write(f'{value:02x}\n')


if __name__ == '__main__':
      main()
