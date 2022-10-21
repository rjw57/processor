// Simple test of moving an immediate value into registers.
.org 0
.export 0, 0x7fff

entry:
  mov a, 0xa5
  mov b, 0x12
  mov c, 0x34
  mov d, 0x45
  mov d, 0x6a
  mov c, 0x7b
  mov b, 0x8c
  mov a, 0x9d
  halt
