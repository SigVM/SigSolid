#include <solls/LanguageServer.h>
#include <lsp/OutputGenerator.h>
#include <libsolutil/Visitor.h>
#include <libsolutil/JSON.h>
#include <ostream>
#include "helper.h"

#include <iostream>
#include <string>

using namespace std;
using namespace std::placeholders;

namespace solidity {

LanguageServer::LanguageServer(lsp::Transport& _client):
	lsp::Server(_client),
	m_vfs()
{
}

void LanguageServer::operator()(lsp::protocol::CancelRequest const& _args)
{
	auto const id = visit(util::GenericVisitor{
		[](string const& _id) -> string { return _id; },
		[](int _id) -> string { return to_string(_id); }
	}, _args.id);

	log("LanguageServer: Request " + id + " cancelled.");
}

void LanguageServer::operator()(lsp::protocol::InitializeRequest const& _args)
{
#if !defined(NDEBUG)
	ostringstream logMessage;
	logMessage << "LanguageServer: Initializing, PID :" << _args.processId.value_or(-1) << endl;
	logMessage << "                rootUri           : " << _args.rootUri.value_or("NULL") << endl;
	logMessage << "                rootPath          : " << _args.rootPath.value_or("NULL") << endl;
	for (auto const& workspace: _args.workspaceFolders)
		logMessage << "                workspace folder: " << workspace.name << "; " << workspace.uri << endl;
	log(logMessage.str());
#endif

	lsp::protocol::InitializeResult result;
	result.capabilities.hoverProvider = true;
	result.capabilities.textDocumentSync.openClose = true;
	result.capabilities.textDocumentSync.change = lsp::protocol::TextDocumentSyncKind::Incremental;
	result.requestId = _args.requestId;

	//sendReply(lsp::OutputGenerator{}(result), _args.requestId);
	reply(_args.requestId, result);
}

void LanguageServer::operator()(lsp::protocol::InitializedNotification const&)
{
	// NB: this means the client has finished initializing. Now we could maybe start sending
	// events to the client.
	log("LanguageServer: Client initialized");
}

void LanguageServer::operator()(lsp::protocol::DidOpenTextDocumentParams const& _args)
{
	log("LanguageServer: Opening document: " + _args.textDocument.uri);

	auto& file = m_vfs.insert(
		_args.textDocument.uri,
		_args.textDocument.languageId,
		_args.textDocument.version,
		_args.textDocument.text
	);

	validate(file);
}

void LanguageServer::operator()(lsp::protocol::DidChangeTextDocumentParams const& _didChange)
{
	if (lsp::vfs::File* file = m_vfs.find(_didChange.textDocument.uri); file != nullptr)
	{
		if (_didChange.textDocument.version.has_value())
			file->setVersion(_didChange.textDocument.version.value());

		for (lsp::protocol::TextDocumentContentChangeEvent const& contentChange: _didChange.contentChanges)
		{
			visit(util::GenericVisitor{
				[&](lsp::protocol::TextDocumentRangedContentChangeEvent const& change) {
#if !defined(NDEBUG)
					ostringstream str;
					str << "did change: " << change.range << " for '" << change.text << "'";
					log(str.str());
#endif
					file->modify(change.range, change.text);
				},
				[&](lsp::protocol::TextDocumentFullContentChangeEvent const& change) {
					file->replace(change.text);
				}
			}, contentChange);
		}
	}
	else
		log("LanguageServer: File to be modified not opened \"" + _didChange.textDocument.uri + "\"");
}

void LanguageServer::operator()(lsp::protocol::DidCloseTextDocumentParams const& _didClose)
{
	log("LanguageServer: didClose: " + _didClose.textDocument.uri);
}

void LanguageServer::validateAll()
{
	for (reference_wrapper<lsp::vfs::File const> const& file: m_vfs.files())
		validate(file.get());
}

void LanguageServer::validate(lsp::vfs::File const& _file)
{
	PublishDiagnosticsList result;
	validate(_file, result);

	for (lsp::protocol::PublishDiagnosticsParams const& diag: result)
		notify(diag);
}

void LanguageServer::validate(lsp::vfs::File const& _file, PublishDiagnosticsList& _result)
{
	// TODO
	//
	// 0.) [ ] drop old intermediate data structures (such as AST)
	// 1.) [ ] fully recompile the sources (and collect errors)
	// 2.) [ ] reconstruct m_diagnostics
	// 3.) [ ] push diagnostics to the client

	lsp::protocol::PublishDiagnosticsParams params{};
	params.uri = _file.uri();

	// TODO
	lsp::protocol::Diagnostic diag{};
	diag.message = "Test message";
	diag.range.start = {0, 0};
	diag.range.end = {0, 5};
	diag.severity = lsp::protocol::DiagnosticSeverity::Error;
	diag.source = "solc";
	params.diagnostics.emplace_back(diag);

	_result.emplace_back(params);
}

} // namespace solidity
