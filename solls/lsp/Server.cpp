#include <lsp/Server.h>
#include <lsp/OutputGenerator.h>
#include <lsp/Transport.h>
#include <libsolutil/Visitor.h>
#include <libsolutil/JSON.h>
#include <ostream>

#include "helper.h"

#include <iostream>

using namespace std;

namespace lsp {

Server::Server(Transport& _client):
	m_client{_client},
	m_inputHandler{_client.logger()},
	m_outputGenerator{}
{
}

int Server::run()
{
	constexpr unsigned maxConsecutiveFailures = 10;
	unsigned failureCount = 0;

	while (failureCount <= maxConsecutiveFailures)
	{
		optional<Json::Value> const jsonMessage = client().receive();
		if (jsonMessage.has_value())
		{
			optional<protocol::Request> const message = m_inputHandler.handleRequest(*jsonMessage);
			if (message.has_value())
			{
				visit(*this, message.value());
				failureCount = 0;
			}
			else
			{
				m_client.log("Could not analyze RPC request.");
				failureCount++;
			}
		}
		else
		{
			m_client.log("Could not read RPC request.");
			failureCount++;
		}
	}

	if (failureCount < maxConsecutiveFailures)
		return EXIT_SUCCESS;
	else
		return EXIT_FAILURE;
}

void Server::handleMessage(string const& _message)
{
	optional<protocol::Request> const message = m_inputHandler.handleRequest(_message);
	if (message.has_value())
		visit(*this, message.value());
	else
		m_client.log("Could not analyze RPC request.");
}

void Server::reply(lsp::protocol::Id const& _id, lsp::protocol::Response const& _message)
{
	auto const json = m_outputGenerator(_message);
	m_client.reply(_id, json);
}

void Server::notify(lsp::protocol::Notification const& _message)
{
	auto const [method, json] = m_outputGenerator(_message);
	m_client.notify(method, json);
}

void Server::log(std::string const& _message)
{
	m_client.log(_message);
}

} // end namespace
