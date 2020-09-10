# Signal and Handler Compiler Modifications
This repository provides a parser as well as a slightly modified compiler to help compile smart contracts utilizing signals and handlers. Example contracts can be found in `.signalhandler/examples/`. The parser implementation can be found in `./signalhandler/parser/`. 

To build and install the compiler from source, enter the root directory and do the following.
```
sudo sh ./scripts/install_deps.sh 
mkdir -p build
cd build
cmake ..
make
```
Visit [solidity](https://solidity.readthedocs.io/en/latest/installing-solidity) for more information. Once compiled, the solc executable can be found in the `./build/solc/` directory. 

# Parsing and Compiling a Contract
To parse the script, install perl and run parse.pl.
```
parse.pl <contract to be parsed> <parsed contract>
```
To compile a contract, use the solc executable located at `./build/solc/solc`. From the root directory, run:
```
./build/solc/solc --overwrite -o <output dir> --asm --bin --abi <parsed contract>
```

# Signal and Handler Syntax
Signals and handlers are declared with the `signal` and `handler` keywords. Signals have a list of methods associated included with it which are: `create_signal`, `delete_signal`, `emit`, and `delay`. Handlers also have a list of methods which are: `create_handler`, `delete_handler`, `bind`, and `detach`. For examples on what each method is parsed into, check out the example solidity file found in `./signalhandler/parser/example_parsed.sol`.

... document syntax here ...

# Compiler Modifications
Not much was changed to the compiler. New opcodes are added to `./libevasm/instruction.h` and `./libevasm/instruction.cpp` so that a modified version of a EVM (Ethereum Virtual Machine) which can execute the new bytecodes. An implementation of a blockchain which supports signal and handler opcodes can be found [here](https://github.com/R-Song/conflux-rust). In this blockchain there is an implementation of an EVM capable of executing the new signal and handler opcodes.

# More Information
This project was forked off of the main solidity repository (obviously). Check out the original github repository [here](https://github.com/ethereum/solidity).