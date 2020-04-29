#pragma once

#include <lsp/protocol.h>

#include <libsolutil/JSON.h>

#include <functional>
#include <ostream>
#include <string>
#include <unordered_map>

namespace lsp {

// Handles pure JSON input values by transforming them into LSP objects
class InputHandler
{
public:
	using Id = protocol::Id; // TODO: move me to lsp namespace instead?

	explicit InputHandler(std::function<void(std::string const&)> _logger);

	/// Transforms JSON RPC request message into a higher level LSP request message.
	/// It will return std::nullopt in case of protocol errors.
	std::optional<protocol::Request> handleRequest(std::string const& _message);
	std::optional<protocol::Request> handleRequest(Json::Value const& _message);

	// <->
	std::optional<protocol::CancelRequest> cancelRequest(Id const&, Json::Value const&);

	// client to server
	std::optional<protocol::InitializeRequest> initializeRequest(Id const&, Json::Value const&);
	std::optional<protocol::InitializedNotification> initialized(Id const&, Json::Value const&);
	std::optional<protocol::DidOpenTextDocumentParams> textDocument_didOpen(Id const&, Json::Value const&);
	std::optional<protocol::DidChangeTextDocumentParams> textDocument_didChange(Id const&, Json::Value const&);
	std::optional<protocol::DidCloseTextDocumentParams> textDocument_didClose(Id const&, Json::Value const&);

private:
	using Handler = std::function<std::optional<protocol::Request>(Id const&, Json::Value const&)>;
	using HandlerMap = std::unordered_map<std::string, Handler>;

	std::function<void(std::string const&)> m_logger;
	HandlerMap m_handlers;
};

}
