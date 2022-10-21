.org 0
.export 0, 0x7fff

entry:
  mov a, 0x87
  mov b, 0x32
  mov c, 0x41
  mov d, 0x39
  sub a, b // should == 0x55
  sub a, c // should == 0x14
  sub a, d // should == 0xdb
  sub b, a // should == 0x57
  sub b, c // should == 0x16
  sub b, d // should == 0xdd
  sub c, a // should == 0x66
  sub c, b // should == 0x89
  sub c, d // should == 0x50
  sub c, a // should == 0x75
  sub c, b // should == 0x98
  sub d, c // should == 0xa1
  sub d, b // should == 0xc4
  sub d, a // should == 0xe9
  sub d, b // should == 0x0c
  sub d, a // should == 0x31

  halt
