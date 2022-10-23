.org 0
.export 0, 0x7fff

entry:
  mov a, 0xdf
  mov tx, $label
  jmp tx
  halt
.org 0x0105
label:
  mov c, 0x45
  mov tx, 0x1234
  mov si, tx
  halt
