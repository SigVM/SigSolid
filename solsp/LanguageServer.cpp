#include "LanguageServer.h"
#include <lsp/protocol.h>
#include <libsolutil/JSON.h>
#include <ostream>

using namespace std;
using namespace lsp::protocol;

namespace solidity {

LanguageServer::LanguageServer(ostream& _client, ostream& _logger):
	m_client{_client},
	m_logger{_logger}
{
}

void LanguageServer::reply(Response const& _response, optional<Id> _requestId)
{
	Json::Value json = lsp::protocol::toJsonRpc(_response, _requestId);
	string jsonString = util::jsonCompactPrint(json);
	m_client << "Content-Length: " << jsonString.size() << "\r\n\r\n" << jsonString;

	// for logging only
	m_logger << "Logging: Response\r\n";
	m_logger << "Content-Length: " << jsonString.size() << "\r\n\r\n" << jsonString;
}

void LanguageServer::operator()(InitializeRequest const& _initialize, Id _requestId)
{
	m_logger << "Initializing, PID=" << _initialize.processId.value_or(-1) << endl;
	for (auto const& workspace: _initialize.workspaceFolders)
		m_logger << "workspace folder: " << workspace.name << "; " << workspace.uri << endl;

	// Respond with a InitializeResult{}
	InitializeResult result;
	result.capabilities.hoverProvider = true;
	result.capabilities.textDocumentSync = true;
	reply(result, _requestId);
}

} // namespace solidity
