# SignalSlot Parser Instruction
## Parse
Use parse.pl located at signalslot\_parse\_script to parse the contract to be run
```
parse.pl <contract to be parsed> <parsed contract>
```
## Solidity compiler
In root dir, do as following
```
mkdir -p build
cd build
make
./solc/solc --overwrite -o <output dir> --asm --bin --abi <parsed contract>
```
In \<output dir\>, the binary file and abi json file will be used.
