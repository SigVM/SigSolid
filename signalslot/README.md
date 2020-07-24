# SignalSlot Parser
The compiler modifications and parsing script in this repository are part of an end to end implementation of signals and slots on the Conflux chain. In order to support higher level language features in solidity related to signal and slots, a parser is used to rewrite signal and slot solidity syntax as a combination of functions and inline assembly. Amongst the inline assembly are five new opcodes which are supported on a modified version of the conflux chain. These five opcodes are CREATESIG, CREATESLOT, BINDSLOT, DETACHSLOT, and EMITSIG. 
## Parsing
To parse the script, install perl and run parse.pl.
```
parse.pl <contract to be parsed> <parsed contract>
```
## Compilation
To build and install compiler from source, enter the root directory and do the following. For more information visit https://solidity.readthedocs.io/en/latest/installing-solidity.html#building-from-source. Once compiled, the solc executable can be found in the ./build/solc/ directory. 
```
sudo sh ./scripts/install_deps.sh 
mkdir -p build
cd build
cmake ..
make
```
To compile a parsed contract from the root of this repository, run the following.
```
./build/solc/solc --overwrite -o <output dir> --asm --bin --abi <parsed contract>
```
The binary files and abi JSON file will be generated in the specified output directory.
## Tests
A few test contracts are held in the tests folder. These example contracts demonstrate the signal and slot solidity syntax that is supported by the parsing script. The output binaries are also included. The js_tests folder contains some information for testing on the conflux chain.
To run all builtin tests
```
cd <root dir>/signalslot/tests
python test_for_all.py
```
Then check the error and info in stdout. More individual tests can be added in test_for_all.py.