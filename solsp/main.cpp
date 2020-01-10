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

int main(int argc, char* argv[])
{
	// Tiny facility for debug-printing to log file instead of stderr when attached to IDE
	unique_ptr<ostream> ownedLogger = argc == 2 ? make_unique<ofstream>(argv[1], ios::trunc | ios::ate) : nullptr;
	ostream& logger = ownedLogger ? *ownedLogger : cerr;

	solidity::LanguageServer lsp{cout, logger};
	using Id = solidity::LanguageServer::Id;

	while (cin.good())
	{
		auto const message = lsp::parseMessage(cin);
		if (holds_alternative<Json::Value>(message))
		{
			auto const& json = get<Json::Value>(message);

			string const methodName = json["method"].asString();
			Id const id = json["id"].isInt()
				? Id{json["id"].asInt()}
				: json["id"].isString()
					? Id{json["id"].asString()}
					: Id{};
			Json::Value const& args = json["params"];

			lsp.handleRequest(id, methodName, args);
		}
		else
			logger << "Message Error:\n" << (int)get<lsp::ErrorCode>(message) << endl;
	}

	return EXIT_SUCCESS;
}
