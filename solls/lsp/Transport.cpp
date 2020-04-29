#include <lsp/Transport.h>
#include <lsp/MessageParser.h>

#include <libsolutil/Visitor.h>

#include <boost/algorithm/string.hpp>

#include <istream>
#include <ostream>

using namespace std;

namespace lsp {

JSONTransport::JSONTransport(std::istream& _in, std::ostream& _out, std::ostream* _log):
	m_input{ _in },
	m_output{ _out },
	m_logger{ _log }
{
}

optional<Json::Value> JSONTransport::receive()
{
	auto const headers = parseHeaders();
	if (!headers)
		return nullopt;

	if (!headers->count("content-length"))
		return nullopt;

	size_t const contentLength = stoi(headers->at("content-length"));
	string const data = readBytes(contentLength);

	Json::Value jsonMessage;
	string errs;
	solidity::util::jsonParseStrict(data, jsonMessage, &errs);
	if (!errs.empty())
	{
		log("Transport.receive: JSON parser error. " + errs);
		return nullopt; // JsonParseError
	}

	return {jsonMessage};
}

void JSONTransport::notify(std::string const& _method, Json::Value const& _message)
{
	Json::Value json;
	json["jsonrpc"] = "2.0";
	json["method"] = _method;
	json["result"] = _message;
	send(json);
}

void JSONTransport::reply(protocol::Id const& _id, Json::Value const& _message)
{
	Json::Value json;
	json["jsonrpc"] = "2.0";
	json["result"] = _message;
	visit(solidity::util::GenericVisitor{
		[&](int _id) { json["id"] = _id; },
		[&](string const& _id) { json["id"] = _id; },
		[&](monostate) {}
	}, _id);
	send(json);
}

void JSONTransport::error(protocol::Id const& _id, std::string const& _message)
{
	Json::Value json;
	json["jsonrpc"] = "2.0";
	json["error"] = _message;
	visit(solidity::util::GenericVisitor{
		[&](int _id) { json["id"] = _id; },
		[&](string const& _id) { json["id"] = _id; },
		[&](monostate) {}
	}, _id);
	send(json);
}

void JSONTransport::send(Json::Value const& _json)
{
	string const jsonString = solidity::util::jsonCompactPrint(_json);

	m_output << "Content-Length: " << jsonString.size() << "\r\n";
	m_output << "\r\n";
	m_output << jsonString;

	m_output.flush();

#if !defined(NDEBUG)
	log("Transport.send:\n" + solidity::util::jsonPrettyPrint(_json));
#endif
}

void JSONTransport::log(std::string const& _message)
{
	if (m_logger)
		*m_logger << _message << endl;
}

string JSONTransport::readLine()
{
	string line;

	getline(m_input, line);
	if (!line.empty() && line.back() == '\r')
		line.resize(line.size() - 1);

	return line;
}

optional<JSONTransport::HeaderMap> JSONTransport::parseHeaders()
{
	unordered_map<string, string> headers;

	for (string line = readLine(); !line.empty(); line = readLine())
	{
		auto const delimiterPos = line.find(':');
		if (delimiterPos == string::npos)
			return nullopt;

		auto const name = boost::to_lower_copy(line.substr(0, delimiterPos));
		auto const value = boost::trim_copy(line.substr(delimiterPos + 1));

		headers[name] = value;
	}
	return {headers};
}

string JSONTransport::readBytes(size_t _n)
{
	string data;
	data.resize(_n);
	m_input.read(data.data(), _n);
	return data;
}

} // end namespace
