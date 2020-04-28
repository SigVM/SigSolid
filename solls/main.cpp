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

	solidity::LanguageServer ls{cout, logger};

	while (cin.good())
	{
		visit(
			solidity::util::GenericVisitor{
				[&](string const& message) {
					ls.handleMessage(message);
				},
				[&](lsp::ErrorCode ec) {
					logger << "Transport error: " << int(ec) << endl;
				}
			},
			lsp::parseMessage(cin)
		);
	}

	return EXIT_SUCCESS;
}
