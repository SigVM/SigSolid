#pragma once
#include <lsp/Server.h>
#include <lsp/protocol.h>
#include <json/value.h>

#include <functional>
#include <optional>
#include <ostream>
#include <unordered_map>
#include <variant>

namespace solidity {

/// Solidity Language Server, managing one LSP client.
class LanguageServer: public lsp::Server
{
public:
	LanguageServer(std::ostream& _client, std::ostream& _logger);

	// Client-to-Server messages
	void operator()(lsp::protocol::CancelRequest const&) override;
	void operator()(lsp::protocol::InitializeRequest const&) override;
	void operator()(lsp::protocol::InitializedNotification const&) override;
	void operator()(lsp::protocol::DidOpenTextDocumentParams const&) override;
	//void textDocument_didClose(Id _id, Json::Value const& _params) override;
	// more to come :-)
};

} // namespace solidity

