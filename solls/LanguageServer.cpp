#include <solls/LanguageServer.h>
#include <lsp/OutputGenerator.h>
#include <libsolutil/Visitor.h>
#include <libsolutil/JSON.h>
#include <ostream>
#include "helper.h"

#include <iostream>
#include <string>

using namespace std;

namespace solidity {

LanguageServer::LanguageServer(ostream& _client, ostream& _logger):
	lsp::Server(_client, _logger),
	m_vfs(&_logger)
{
}

void LanguageServer::operator()(lsp::protocol::CancelRequest const& _args)
{
	auto const id = visit(util::GenericVisitor{
		[](string const& _id) -> string { return _id; },
		[](int _id) -> string { return to_string(_id); }
	}, _args.id);

	logger() << "LanguageServer: Request " << id << " cancelled." << endl;
}

void LanguageServer::operator()(lsp::protocol::InitializeRequest const& _args)
{
	logger() << "LanguageServer: Initializing, PID :" << _args.processId.value_or(-1) << endl;
	logger() << "                rootUri           : " << _args.rootUri.value_or("NULL") << endl;
	logger() << "                rootPath          : " << _args.rootPath.value_or("NULL") << endl;
	for (auto const& workspace: _args.workspaceFolders)
		logger() << "                workspace folder: " << workspace.name << "; " << workspace.uri << endl;

	lsp::protocol::InitializeResult result;
	result.capabilities.hoverProvider = true;
	result.capabilities.textDocumentSync.openClose = true;
	result.capabilities.textDocumentSync.change = lsp::protocol::TextDocumentSyncKind::Incremental;

	sendReply(lsp::OutputGenerator{}(result), _args.requestId);
}

void LanguageServer::operator()(lsp::protocol::InitializedNotification const&)
{
	// NB: this means the client has finished initializing. Now we could maybe start sending
	// events to the client.
	logger() << "LanguageServer: Client initialized" << endl;
}

void LanguageServer::operator()(lsp::protocol::DidOpenTextDocumentParams const& _args)
{
	logger() << "LanguageServer: " << "Opening document: " << _args.textDocument.uri << endl;
	m_vfs.insert(
		_args.textDocument.uri,
		_args.textDocument.languageId,
		_args.textDocument.version,
		_args.textDocument.text
	);
}

void LanguageServer::operator()(lsp::protocol::DidChangeTextDocumentParams const& _didChange)
{
	logger() << "LanguageServer: DidChangeTextDocumentParams!" << endl;
	if (lsp::vfs::File* file = m_vfs.find(_didChange.textDocument.uri); file != nullptr)
	{
		if (_didChange.textDocument.version.has_value())
			file->setVersion(_didChange.textDocument.version.value());

		logger() << "  didChange: " << _didChange.textDocument.uri << endl;
		for (lsp::protocol::TextDocumentContentChangeEvent const& contentChange: _didChange.contentChanges)
		{
			visit(util::GenericVisitor{
				[&](lsp::protocol::TextDocumentRangedContentChangeEvent const& change) {
					logger() << "    range: " << change.range << " text: \"" << change.text << '"' << endl;
					file->modify(change.range, change.text);
				},
				[&](lsp::protocol::TextDocumentFullContentChangeEvent const& change) {
					file->replace(change.text);
				}
			}, contentChange);
		}
	}
	else
		logger() << "LanguageServer: File to be modified not opened \"" << _didChange.textDocument.uri << "\"" << endl;
}

void LanguageServer::operator()(lsp::protocol::DidCloseTextDocumentParams const& _didClose)
{
	logger() << "LanguageServer: didClose: " << _didClose.textDocument.uri << endl;
}

} // namespace solidity
