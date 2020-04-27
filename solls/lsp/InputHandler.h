#pragma once

#include <lsp/protocol.h>
#include <libsolutil/JSON.h>
#include <ostream>

namespace lsp {

// Handles pure JSON input values by transforming them into LSP objects
class InputHandler
{
public:
	using Id = protocol::Id; // TODO: move me to lsp namespace instead?

	explicit InputHandler(std::ostream& _logger);

	/// Transforms JSON RPC request message into a higher level LSP request message.
	/// It will return std::nullopt in case of protocol errors.
	std::optional<protocol::Request> handleRequest(Json::Value const& _request);

	// <->
	std::optional<protocol::CancelRequest> cancelRequest(Json::Value const& _message);

	// client to server
	std::optional<protocol::InitializeRequest> initializeRequest(Id const& _id, Json::Value const& _args);
	std::optional<protocol::InitializedNotification> initialized(Id const& _id, Json::Value const&);
	std::optional<protocol::DidOpenTextDocumentParams> textDocument_didOpen(Id const& _id, Json::Value const& _args);
	std::optional<protocol::DidChangeTextDocumentParams> textDocument_didChange(Id const& _id, Json::Value const&);

private:
	std::ostream& m_logger;
};

}
