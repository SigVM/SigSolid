#include <lsp/Server.h>
#include <lsp/OutputGenerator.h>
#include <libsolutil/Visitor.h>
#include <libsolutil/JSON.h>
#include <ostream>

#include "helper.h"

#include <iostream>

using namespace std;

namespace lsp {

Server::Server(ostream& _client, ostream& _logger):
	m_client{_client},
	m_logger{_logger},
	m_inputHandler{_logger}
{
}

void Server::handleRequest(Json::Value _request)
{
	optional<protocol::Request> const request = m_inputHandler.handleRequest(_request);
	if (request.has_value())
		visit(*this, request.value());
	else
		logger() << "Could not analyze RPC request.\n";
}

void Server::sendReply(lsp::protocol::CancelRequest const& _message)
{
	sendReply(OutputGenerator{}(_message), _message.id);
}

void Server::sendReply(Json::Value const& _response, optional<Id> _requestId)
{
	Json::Value json;
	json["jsonrpc"] = "2.0";
	json["result"] = _response;
	visit(solidity::util::GenericVisitor{
		[&](int _id) { json["id"] = _id; },
		[&](string const& _id) { json["id"] = _id; },
		[&](monostate) {}
	}, *_requestId);

	string const jsonString = solidity::util::jsonCompactPrint(json);
	m_client << "Content-Length: " << jsonString.size() << "\r\n\r\n" << jsonString;

	// for logging only
	auto const prettyPrinted = solidity::util::jsonPrettyPrint(json);
	m_logger << "Reply: " << jsonString.size() << " bytes\n" << prettyPrinted << endl;
}

} // end namespace
