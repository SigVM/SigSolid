# LSP / SolidityLSP / YulSLP Small TODO list

# Milestone-1:

## Features:

- [ ] basic compilation checking
- [ ] goto definition
- [ ] semantic highlighting of the currently selected word
- [ ] hover support (showing signature, maybe natspec docs already?)
- [ ] auto completion upon writing `.` or `(` or `,`

## Internal Requirements

- [x] (WIP) basic functioning JSON-RPC
- [x] (WIP) translation from/to JSON-RPC <-> higher level structs
- [ ] buffer management ("text synchronization")
- [ ] unit tests for all LSP core functionalities

# Future-work

- hover request should also respond with Natspec documentation
- symbol rename
- automatic adding of imports whenever a symbol is referenced that is not yet imported in the current unit.
