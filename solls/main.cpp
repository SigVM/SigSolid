#include <solls/LanguageServer.h>
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

	while (cin.good())
	{
		visit(
			solidity::util::GenericVisitor{
				[&](Json::Value const& json) {
					lsp.handleRequest(json);
				},
				[&](lsp::ErrorCode ec) {
					logger << "Message Error:\n" << int(ec) << endl;
				}
			},
			lsp::parseMessage(cin, &logger)
		);
	}

	return EXIT_SUCCESS;
}
