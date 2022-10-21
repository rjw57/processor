.org 0
.export 0, 0x7fff

entry:
  mov a, 0x87
  mov b, 0x32
  mov c, 0x41
  mov d, 0x39
  add a, b // should == 0xb9
  add a, c // should == 0xfa
  add a, d // should == 0x33 with carry
  add b, a // should == 0x65
  add b, c // should == 0xa6
  add b, d // should == 0xdf
  add b, d // should == 0x18 with carry
  add c, a // should == 0x74
  add c, b // should == 0x8c
  add c, d // should == 0xc5
  add c, a // should == 0xf8
  add c, b // should == 0x10 with carry
  add d, c // should == 0x49
  add d, b // should == 0x61
  add d, a // should == 0x94
  add d, b // should == 0xac
  add d, a // should == 0xdf
  add d, a // should == 0x12 with carry

  // we now check the ALU ops are being set on the right cycles by changing ops
  sub d, a // should == 0xdf
  sub d, b // should == 0xc7
  add d, c // should == 0xd7

  // check add with carry to compute 0x10f8 + 0x2123 == 0x321b
  mov a, 0xf8
  mov b, 0x10
  mov c, 0x23
  mov d, 0x21
  add c, a
  addc d, b   // {d, c} should now be {0x32, 0x1b}

  // check add with carry to compute 0x3032 + 0x2123 == 0x5155
  mov a, 0x32
  mov b, 0x30
  mov c, 0x23
  mov d, 0x21
  add c, a
  addc d, b   // {d, c} should now be {0x51, 0x55}
  halt
