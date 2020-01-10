#include <json/json.h>

#include <istream>
#include <string>
#include <variant>

namespace lsp {

enum class ErrorCode
{
	TransportProtocolError = 1,
	JsonParseError,
	// TODO: more to follow
};

/// Synchronously parses a single JSON-RPC message from input stream.
std::variant<Json::Value, ErrorCode> parseMessage(std::istream& _source);

} // namespace lsp
