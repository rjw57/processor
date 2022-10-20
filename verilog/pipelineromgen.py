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
    Bit4 = 1 << 4
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
    Bit16 = 1 << 16
    Bit17 = 1 << 17
    Bit18 = 1 << 18
    Bit19 = 1 << 19
    Bit20 = 1 << 20
    Bit21 = 1 << 21
    Bit22 = 1 << 22
    Bit23 = 1 << 23
    Bit24 = 1 << 24
    Bit25 = 1 << 25
    Bit26 = 1 << 26
    Bit27 = 1 << 27
    Bit28 = 1 << 28
    Bit29 = 1 << 29
    Bit30 = 1 << 30
    Bit31 = 1 << 31


def control_lines(flags, opcode):
    inc_pc_flag = Line.IncrementPCRA0

    # Default to increment PC
    out = inc_pc_flag

    if opcode == Opcode.HALT:
        # On halt, stop incrementing the PC.
        out &= ~inc_pc_flag
        out |= Line.Halt
    elif opcode == Opcode.MOV_REGA_IMM:
        # Prevent immediate from being dispatched
        out |= Line.InstrDispatchBar

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
