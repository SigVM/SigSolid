#include "LanguageServer.h"
#include <libsolutil/Visitor.h>
#include <libsolutil/JSON.h>
#include <ostream>

using namespace std;

namespace solidity {

LanguageServer::LanguageServer(ostream& _client, ostream& _logger):
	m_client{_client},
	m_logger{_logger}
{
}

void LanguageServer::handleRequest(Id _requestId, std::string const& _method, Json::Value const& _args)
{
	if (_method == "initialize")
		initialize(_args);
	else if (_method == "initialized")
		initialized();
	else if (_method == "textDocument/didOpen")
		textDocument_didOpen(_requestId, _args);
	else if (_method == "textDocument/didClose")
		textDocument_didClose(_requestId, _args);
	else
		m_logger << "Could not parse RPC? " << solidity::util::jsonCompactPrint(_args) << endl;
}

void LanguageServer::sendReply(Json::Value const& _response, optional<Id> _requestId)
{
	Json::Value json;
	json["jsonrpc"] = "2.0";
	json["result"] = _response;
	visit(util::GenericVisitor{
		[&](int _id) { json["id"] = _id; },
		[&](string const& _id) { json["id"] = _id; },
		[&](monostate) {}
	}, *_requestId);

	string const jsonString = util::jsonCompactPrint(json);
	m_client << "Content-Length: " << jsonString.size() << "\r\n\r\n" << jsonString;

	// for logging only
	m_logger << "Logging: Response\r\n";
	m_logger << "Content-Length: " << jsonString.size() << "\r\n\r\n" << jsonString;
}

void LanguageServer::initialize(Json::Value const& _args)
{
	(void) _args;

	m_logger << "Initializing, PID=" << _args["processId"].asInt() << endl;
	for (auto const& workspace: _args["workspaceFolders"])
		m_logger << "workspace folder: " << workspace["name"].asString() << "; " << workspace["uri"].asString() << endl;

	// Respond with a InitializeResult{}
	Json::Value reply;
	reply["capabilities"]["hoverProvider"] = true;
	reply["capabilities"]["textDocumentSync"] = true;
	sendReply(reply);
}

void LanguageServer::initialized()
{
}

void LanguageServer::textDocument_didOpen(Id _id, Json::Value const& _args)
{
	(void) _id;
	(void) _args;
}

void LanguageServer::textDocument_didClose(Id _id, Json::Value const& _args)
{
	(void) _id;
	(void) _args;
}

} // namespace solidity
