#include "LanguageServer.h"
#include <lsp/OutputGenerator.h>
#include <libsolutil/Visitor.h>
#include <libsolutil/JSON.h>
#include <ostream>
#include "helper.h"

#include <iostream>

using namespace std;

namespace solidity {

LanguageServer::LanguageServer(ostream& _client, ostream& _logger):
	lsp::Server(_client, _logger)
{
}

void LanguageServer::operator()(lsp::protocol::CancelRequest const& _args)
{
	(void) _args; // TODO
}

void LanguageServer::operator()(lsp::protocol::InitializeRequest const& _args)
{
	using namespace lsp::protocol;

	logger() << "Initializing, PID :" << _args.processId.value_or(-1) << endl;
	logger() << "rootUri           : " << _args.rootUri.value_or("NULL") << endl;
	logger() << "rootPath          : " << _args.rootPath.value_or("NULL") << endl;
	for (auto const& workspace: _args.workspaceFolders)
		logger() << "workspace folder: " << workspace.name << "; " << workspace.uri << endl;

	InitializeResult result;
	result.capabilities.hoverProvider = true;
	result.capabilities.textDocumentSync.openClose = true;
	result.capabilities.textDocumentSync.change = TextDocumentSyncKind::Incremental;

	sendReply(lsp::OutputGenerator{}(result), _args.requestId);
}

void LanguageServer::operator()(lsp::protocol::InitializedNotification const&)
{
	// NB: this means the client has finished initializing. Now we could maybe start sending
	// events to the client.
}

void LanguageServer::operator()(lsp::protocol::DidOpenTextDocumentParams const& _args)
{
	(void) _args;
	// TODO
}

// void LanguageServer::textDocument_didClose(Id _id, Json::Value const& _args)
// {
// 	(void) _id;
// 	(void) _args;
// }

} // namespace solidity
