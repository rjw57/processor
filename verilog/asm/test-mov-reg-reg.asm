// Simple test of moving register values around
.org 0
.export 0, 0x7fff

entry:
  mov a, 0x12
  mov b, 0x34
  mov c, 0x45
  mov d, 0x67
  mov a, b
  mov a, c
  mov a, d
  mov a, 0x89
  mov b, a
  mov b, c
  mov b, d
  mov b, 0xab
  mov c, a
  mov c, b
  mov c, d
  mov c, 0xcd
  mov d, a
  mov d, b
  mov d, c
  halt
