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
  halt
