# Experiments in verilog

Experiments in verilog.

## Testing

```console
$ python3 -m venv ./venv
$ . ./venv/bin/activate
$ pip install -e .
$ make -C verilog test
```

To look at output, load `.vcd` files into GtkWave.

## Requirements

- Icarus verilog
