#include <lsp/protocol.h>
#include <optional>
#include <ostream>

namespace solidity {

class LanguageServer
{
public:
	LanguageServer(std::ostream& _client, std::ostream& _logger);

	void operator()(lsp::protocol::InitializeRequest const& _request, lsp::protocol::Id _requestId);
	// more to come :-)

private:
	void reply(lsp::protocol::Response const& _response, std::optional<lsp::protocol::Id> _requestId);

private:
	std::ostream& m_client;
	std::ostream& m_logger;
};

} // namespace solidity

