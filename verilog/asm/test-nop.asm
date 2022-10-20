// Test of nop instructions
.org 0
.export 0, 0x7fff

entry:
  nop
  nop
  nop
  nop
  nop
  nop
  halt
