#include <lsp/protocol.h>
#include <json/value.h>

#include <functional>
#include <optional>
#include <ostream>
#include <unordered_map>
#include <variant>

namespace solidity {

/// Solidity Language Server, managing one LSP client.
class LanguageServer
{
public:
	LanguageServer(std::ostream& _client, std::ostream& _logger);
	virtual ~LanguageServer() = default;

	using Id = std::variant<std::monostate, int, std::string>;

	void handleRequest(Id _requestId, std::string const& _method, Json::Value const& _params);

	// Client-to-Server messages
	virtual void initialize(Json::Value const& _params);
	virtual void initialized();
	virtual void textDocument_didOpen(Id _id, Json::Value const& _params);
	virtual void textDocument_didClose(Id _id, Json::Value const& _params);
	// more to come :-)

protected:
	void sendReply(Json::Value const& _response, std::optional<Id> _requestId = std::nullopt);

private:
	using Handler = std::function<void(std::optional<Id>, Json::Value const&)>;

	std::unordered_map<std::string, Handler> m_handler;
	std::ostream& m_client;
	std::ostream& m_logger;
};

} // namespace solidity

