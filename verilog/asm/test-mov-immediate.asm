// Simple test of moving an immediate value into registers.
.org 0
.export 0, 0x7fff

entry:
  mov a, 12
  halt
