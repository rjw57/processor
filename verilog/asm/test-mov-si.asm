.org 0
.export 0, 0x7fff

entry:
  mov a, 0x12
  mov b, 0x34
  mov tx, 0xabcd
  mov si, tx
  // Test that subsequent instructions are not lost
  mov c, a
  mov d, b
  mov tx, 0x9876
  mov si, tx
  // Test that constant loads work immediately after the address bus has been
  // used.
  mov c, 0xfe
  mov d, 0xdc
  halt
