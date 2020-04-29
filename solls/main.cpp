#include <solls/LanguageServer.h>
#include <lsp/MessageParser.h>
#include <lsp/Transport.h>
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
	// Tiny facility for debug-printing to log file instead of stderr when attached to an IDE.
	auto ownedLogger = argc == 2 ? make_unique<ofstream>(argv[1], ios::trunc | ios::ate) : nullptr;
	auto logger = ownedLogger ? ownedLogger.get() : &cerr;
	auto transport = lsp::JSONTransport{cin, cout, logger};
	auto languageServer = solidity::LanguageServer{transport};

	return languageServer.run();
}
