# Solidity: Language Server

## Motivations

The following features could be implemented (incomplete list of ideas):

- realtime compilation validation (error, warning, formal verification)
- auto completion
- go to definition
- find all references
- auto correction on typical programming issues
- semantic highlying of symbols
- symbol rename
- automatic adding of imports whenever a symbol is referenced that is not yet imported in the current unit.
- signature and natspec documentation information upon symbol hover
  - show generated EVM code for hovered scope
  - show estimated gas cost for hovered expression
- get realtime suggestions to improve code quality, or other reasons
- the solidity upgrade tool could potentially be integrated into the language server
- also support Yul
- Questions:
  - what clients would you guys like us to support? Remix, VS, VIM, ...?
  - could this be wanted by by Remix?
  - what would be most/least important to you to have in general (and in the initial release)
  - how do clients want to push their build configuration to the server?
    - C++ LS uses a `compile_commands.json` for the flags
  - LSIF: is there interest in "Language Server Index Format"?
	- pronounced "else-if"
    - Ref: https://code.visualstudio.com/blogs/2019/02/19/lsif
    - this is an indexing file format that the LS can produce for offline usage
	- example use: platforms (such as GitHub!) could provide goto definition (etc) features


## What an initial release could look like

### Features:

- [ ] basic compilation checking with reporting errors to the client
- [ ] goto definition
- [ ] semantic highlighting of the currently selected word
- [ ] hover support (showing signature, maybe natspec docs already?)
- [ ] auto completion upon writing `.` or `(` or `,`

### Internal Requirements

- [x] detail: basic functioning JSON-RPC
- [x] detail: (WIP) translation from/to JSON-RPC <-> higher level structs
- [x] detail: buffer management ("text synchronization")
- [ ] (WIP) unit tests for all LSP core functionalities
- [ ] validation runs (look for compilation errors/warnings)
- [ ] Publish Notifications to the clients
- [ ] Completion Requests
- [ ] hover-information (signature + natspec documentation)
- [ ] perform validation not after every change but
  - either if there was no text change notification for a given timeout, or
  - if a bigger timeout has been exceeded and no revalidation has been taken place since that period of time yet.

