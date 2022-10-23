.org 0
.export 0, 0x7fff

entry:
  mov a, 0xab
  mov b, 0xcd
  mov si, ab
  // Test that subsequent instructions are not lost
  mov c, a
  mov d, b
  mov a, 0x12
  mov b, 0x34
  mov si, ab
  // Test that constant loads work immediately after the address bus has been
  // used.
  mov c, 0xfe
  mov d, 0xdc
  mov si, cd
  halt
  mov a, b // should not be executed
