#include "LanguageServer.h"
#include <lsp/MessageParser.h>
#include <lsp/protocol.h>

#include <json/json.h>
#include <libsolutil/JSON.h>
#include <libsolutil/Visitor.h>

#include <cstdlib>
#include <fstream>
#include <iostream>
#include <memory>
#include <string>
#include <variant>

using namespace std;

void handleRequest(lsp::protocol::RequestMessage const& _request, ostream& _logger)
{
	solidity::LanguageServer lsp{cout, _logger};

	visit(solidity::util::GenericVisitor{
		[&](lsp::protocol::InitializeRequest const& _initialize) { lsp(_initialize, *_request.id); },
		// TODO: more request methods implemented here ...
	}, *_request.params);
}

int main(int argc, char* argv[])
{
	// Tiny facility for debug-printing to log file instead of stderr when attached to IDE
	unique_ptr<ostream> ownedLogger = argc == 2 ? make_unique<ofstream>(argv[1], ios::trunc | ios::ate) : nullptr;
	ostream& logger = ownedLogger ? *ownedLogger : cerr;

	while (cin.good())
	{
		auto const message = lsp::parseMessage(cin);
		if (holds_alternative<Json::Value>(message))
		{
			auto const& json = get<Json::Value>(message);
			if (auto const requestMessage = lsp::protocol::fromJsonRpc(json); requestMessage.params.has_value())
				handleRequest(requestMessage, logger);
			else
				logger << "Could not parse RPC?" << solidity::util::jsonCompactPrint(json) << endl;
		}
		else
			logger << "Message Error:\n" << (int)get<lsp::ErrorCode>(message) << endl;
	}

	return EXIT_SUCCESS;
}
