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

int main([[maybe_unused]] int argc, [[maybe_unused]] char* argv[])
{
	auto transport = lsp::JSONTransport{cin, cout};
	auto languageServer = solidity::LanguageServer{transport};

	return languageServer.run();
}
