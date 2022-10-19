"""
Assemble files for the processor

Usage:
    pasm (-h | --help)
    pasm [--output=FILE] <source>

Options:
    -h, --help      Print brief usage summary
"""

import ast
import dataclasses
import logging
import os
import typing
import itertools

import docopt
import lark

from .encoding import Encoding

logging.basicConfig(level=logging.INFO)

LOG = logging.getLogger(__name__)

# Assembler grammar
GRAMMAR = """
    // Tokens
    %import common.NEWLINE
    %import common.CNAME
    %import common (DIGIT, HEXDIGIT, ESCAPED_STRING)

    BINARY_LITERAL: "0b" ("0".."1")+
    DECIMAL_LITERAL: DIGIT+
    HEX_LITERAL: "0x" HEXDIGIT+

    DIRECTIVE_NAME: "." CNAME
    LABEL: CNAME ":"
    VARIABLE_REF: "$" CNAME

    ADDOP: "+" | "-"
    MULOP: "*" | "/"
    SHIFTOP: "<<" | ">>"
    UNARYOP: "+" | "-" | "~" | "<" | ">"

    // Rules
    start: (_item? NEWLINE)* _item?

    _item: directive
         | label+ instruction?
         | instruction

    // Assembler directive
    directive: DIRECTIVE_NAME [_directiveparams]
    _directiveparams: (_directiveparam ",")* _directiveparam
    _directiveparam: literal_integer
                   | literal_string

    // Labels and instructions
    label: LABEL
    instruction: CNAME [_operands]
    _operands: (expression ",")* expression

    // Literals
    literal_integer: DECIMAL_LITERAL
                   | HEX_LITERAL
                   | BINARY_LITERAL
    literal_string: ESCAPED_STRING

    // Registers
    registerref: CNAME

    // Expressions - precedence mirrors C
    ?expression: registerref | indirectregref | bitorexpr
    ?bitorexpr: (bitxorexpr "|")* bitxorexpr
    ?bitxorexpr: (bitandexpr "^")* bitandexpr
    ?bitandexpr: (shiftexpr "&")* shiftexpr
    ?shiftexpr: (addexpr SHIFTOP)* addexpr
    ?addexpr: (mulexpr ADDOP)* mulexpr
    ?mulexpr: (unaryexpr MULOP)* unaryexpr
    ?unaryexpr: UNARYOP* atomexpr
    ?atomexpr: "(" expression ")"
             | constintexpr
             | variablerefexpr
    constintexpr: literal_integer
    variablerefexpr: VARIABLE_REF
    indirectregref: "[" registerref "]"

    // Ignore comments and whitespace
    %import common (CPP_COMMENT, C_COMMENT, WS_INLINE)
    %ignore CPP_COMMENT
    %ignore C_COMMENT
    %ignore WS_INLINE
"""


class Expression:
    def evaluate(
        self, *, symbol_table: typing.Optional[dict[str, int]] = None
    ) -> typing.Union[int, "Expression"]:
        """Evaluate expressions with or without a symbol table"""
        _ = (symbol_table,)  # stop linters moaning about unused variable
        return self


@dataclasses.dataclass
class ConstantInt(Expression):
    value: int

    def evaluate(self, **_):
        return self.value


@dataclasses.dataclass
class VariableRef(Expression):
    variable: str

    def evaluate(self, *, symbol_table=None):
        if symbol_table is None:
            return self
        v = symbol_table.get(self.variable)
        if v is None:
            return self
        return v


@dataclasses.dataclass
class BinaryOp(Expression):
    op: str
    left: Expression
    right: Expression

    def evaluate(self, *, symbol_table=None):
        lhs = self.left.evaluate(symbol_table=symbol_table)
        rhs = self.right.evaluate(symbol_table=symbol_table)
        if not isinstance(lhs, int) or not isinstance(rhs, int):
            if isinstance(lhs, int):
                lhs = ConstantInt(value=lhs)
            if isinstance(rhs, int):
                rhs = ConstantInt(value=rhs)
            return BinaryOp(op=self.op, left=lhs, right=rhs)

        if self.op == "+":
            return lhs + rhs
        elif self.op == "-":
            return lhs - rhs
        elif self.op == "*":
            return lhs * rhs
        elif self.op == "/":
            return lhs // rhs
        elif self.op == "<<":
            return lhs << rhs
        elif self.op == ">>":
            return lhs >> rhs
        elif self.op == "&":
            return lhs & rhs
        elif self.op == "|":
            return lhs | rhs
        elif self.op == "^":
            return lhs ^ rhs
        else:
            return self


@dataclasses.dataclass
class UnaryOp(Expression):
    op: str
    right: Expression

    def evaluate(self, *, symbol_table=None):
        rhs = self.right.evaluate(symbol_table=symbol_table)
        if not isinstance(rhs, int):
            return UnaryOp(op=self.op, right=rhs)

        if self.op == "+":
            return rhs
        elif self.op == "-":
            return -rhs
        elif self.op == "<":
            return rhs & 0xFF
        elif self.op == ">":
            return (rhs >> 8) & 0xFF
        elif self.op == "~":
            return ~rhs
        else:
            return self


@dataclasses.dataclass
class LabelDefinition:
    label: str


@dataclasses.dataclass
class RegisterRef:
    register: str


@dataclasses.dataclass
class IndirectRegisterRef:
    register: str


@dataclasses.dataclass
class Directive:
    name: str
    parameters: list[typing.Union[int, str]]


@dataclasses.dataclass
class Instruction:
    encoding: list[typing.Union[int, Expression]]


class AssemblerTransformer(lark.Transformer):
    _assembly: dict[int, typing.Union[int, Expression]]
    _instr_ptr: int
    _symbol_table: dict[str, int]
    _export_range: tuple[int, int]

    def __init__(self):
        self._export_range = (0, 255)
        self._instr_ptr = 0
        self._assembly = {}
        self._symbol_table = {}

    def start(self, children):
        for child in children:
            if isinstance(child, Directive):
                self._process_directive(child)
            elif isinstance(child, Instruction):
                self._process_instruction(child)
            elif isinstance(child, LabelDefinition):
                self._symbol_table[child.label] = self._instr_ptr

    def link(self) -> bytes:
        for k, v in self._assembly.items():
            if isinstance(v, Expression):
                sv = v.evaluate(symbol_table=self._symbol_table)
                if not isinstance(sv, int):
                    raise RuntimeError(f"could not evaluate: {v!r}")
                self._assembly[k] = sv & 0xFF

        output = [
            0,
        ] * (1 + self._export_range[1] - self._export_range[0])
        for k, v in self._assembly.items():
            if k < self._export_range[0] or k > self._export_range[1]:
                continue
            assert isinstance(v, int)
            output[k - self._export_range[0]] = v

        return bytes(output)

    def _insert_bytes(self, bytes_: typing.Sequence[typing.Union[int, Expression]]):
        for b in bytes_:
            self._assembly[self._instr_ptr] = b
            self._instr_ptr += 1

    def _process_directive(self, directive: Directive):
        if directive.name == "org":
            assert len(directive.parameters) == 1
            assert isinstance(directive.parameters[0], int)
            self._instr_ptr = directive.parameters[0]
        elif directive.name == "export":
            assert len(directive.parameters) == 2
            s, e = directive.parameters[:2]
            assert isinstance(s, int)
            assert isinstance(e, int)
            assert e >= e
            self._export_range = (s, e)
        elif directive.name == "db":
            for p in directive.parameters:
                if isinstance(p, int):
                    self._insert_bytes([p])
                elif isinstance(p, str):
                    self._insert_bytes(p.encode("ascii"))
                else:
                    assert False, f"should not be reached: {p!r}"
        else:
            raise RuntimeError(f"unknown directive: {directive!r}")

    def _process_instruction(self, instruction: Instruction):
        self._insert_bytes(instruction.encoding)

    def label(self, children):
        return LabelDefinition(label=children[0].value[:-1])

    def directive(self, children):
        return Directive(name=children[0].value[1:], parameters=children[1:])

    def instruction(self, children):
        opcode = children[0].value.upper()
        encoding_components = [opcode]
        immediates = []
        for child in children[1:]:
            if isinstance(child, RegisterRef):
                encoding_components.append(f"REG{child.register}")
            elif isinstance(child, IndirectRegisterRef):
                encoding_components.append(f"IREG{child.register}")
            elif isinstance(child, Expression):
                encoding_components.append("IMM")
                immediates.append(child.evaluate() & 0xff)
            else:
                assert False, f"should not be reached with child: {child!r}"

        encoding = getattr(Encoding, "_".join(encoding_components), None)
        if encoding is None:
            print(f"No encoding for: {encoding_components!r}. Using NOP.")
            encoding = Encoding.NOP

        encoding_bytes = []
        for e in encoding.value:
            if isinstance(e, int):
                encoding_bytes.append(e)
            elif isinstance(e, str) and e.startswith("#"):
                encoding_bytes.append(immediates[int(e[1:])])
            else:
                assert False, f"unknown encoding: {e!r}"

        return Instruction(encoding=encoding_bytes)

    def variablerefexpr(self, children):
        return VariableRef(variable=children[0][1:])

    def unaryexpr(self, children):
        value = children[-1]
        for op in children[-2::-1]:
            value = UnaryOp(op=op.value, right=value)
        return value

    def _binaryexpr(self, children):
        value = children[-1]
        for idx in range(len(children) - 3, -1, -2):
            left = children[idx]
            op = children[idx + 1].value
            value = BinaryOp(left=left, op=op, right=value)
        return value

    def mulexpr(self, children):
        return self._binaryexpr(children)

    def addexpr(self, children):
        return self._binaryexpr(children)

    def shiftexpr(self, children):
        return self._binaryexpr(children)

    def bitandexpr(self, children):
        return self._binaryexpr(children)

    def bitxorexpr(self, children):
        return self._binaryexpr(children)

    def bitorexpr(self, children):
        return self._binaryexpr(children)

    def constintexpr(self, children):
        return ConstantInt(value=children[0])

    def registerref(self, children):
        return RegisterRef(register=children[0].value.upper())

    def indirectregref(self, children):
        return IndirectRegisterRef(register=children[0].register)

    def literal_integer(self, children):
        token = children[0]
        base = AssemblerTransformer.INTEGER_TOKEN_BASES[token.type]
        return int(token.value, base=base)

    def literal_string(self, children):
        token = children[0]
        assert token.type == "ESCAPED_STRING"
        value = ast.literal_eval(token.value)
        assert isinstance(value, str)
        return value

    INTEGER_TOKEN_BASES = {
        "DECIMAL_LITERAL": 10,
        "HEX_LITERAL": 16,
        "BINARY_LITERAL": 2,
    }


def main():
    opts = docopt.docopt(f"{__doc__}")

    source_path = opts["<source>"]
    if opts["--output"] is not None:
        output_path = opts["--output"]
    else:
        output_path = f"{os.path.splitext(source_path)[0]}.mem"

    LOG.info('Reading input from "%s"', source_path)
    LOG.info('Writing output to "%s"', output_path)

    transformer = AssemblerTransformer()
    parser = lark.Lark(GRAMMAR, parser="lalr", propagate_positions=True)
    with open(source_path) as fobj:
        tree = parser.parse(fobj.read())

    transformer.transform(tree)
    output = transformer.link()
    with open(output_path, "w") as fobj:
        for addr, line_bytes in itertools.groupby(
            enumerate(output), key=lambda v: v[0] >> 4
        ):
            line_bytes = bytes(v for _, v in line_bytes)
            data_s = " ".join(f"{v:02x}" for v in line_bytes)
            fobj.write(data_s)
            fobj.write(" " * (50 - len(data_s)))
            fobj.write(f"// {addr << 4:04x} : |")
            for v in line_bytes:
                if v < 0x20 or v >= 0x7F:
                    fobj.write(".")
                else:
                    fobj.write(chr(v))
            fobj.write("|\n")
