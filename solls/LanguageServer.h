#pragma once

#include <lsp/Server.h>
#include <lsp/protocol.h>
#include <lsp/VFS.h>
#include <lsp/protocol.h>

#include <libsolidity/interface/CompilerStack.h>

#include <json/value.h>

#include <functional>
#include <optional>
#include <ostream>
#include <unordered_map>
#include <variant>

namespace solidity {

/// Solidity Language Server, managing one LSP client.
class LanguageServer final: public lsp::Server
{
public:
	using PublishDiagnosticsList = std::vector<lsp::protocol::PublishDiagnosticsParams>;

	explicit LanguageServer(lsp::Transport& _client);

	int exec();

	// Client-to-Server messages
	void operator()(lsp::protocol::CancelRequest const&) override;
	void operator()(lsp::protocol::InitializeRequest const&) override;
	void operator()(lsp::protocol::InitializedNotification const&) override;
	void operator()(lsp::protocol::DidOpenTextDocumentParams const&) override;
	void operator()(lsp::protocol::DidChangeTextDocumentParams const&) override;
	void operator()(lsp::protocol::DidCloseTextDocumentParams const&) override;
	// TODO more to come :-)

	/// performs a validation run.
	///
	/// update diagnostics and also pushes any updates to the client.
	void validateAll();
	void validate(lsp::vfs::File const& _file, PublishDiagnosticsList& _result);
	void validate(lsp::vfs::File const& _file);

private:
	/// In-memory filesystem for each opened file.
	///
	/// Closed files will not be removed as they may be needed for compiling.
	lsp::vfs::VFS m_vfs;

	/// Mapping between VFS file and its diagnostics.
	std::map<std::string /*URI*/, PublishDiagnosticsList> m_diagnostics;
};

} // namespace solidity

