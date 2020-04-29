#pragma once

#include <lsp/protocol.h>
#include <lsp/InputHandler.h>
#include <lsp/OutputGenerator.h>

#include <json/value.h>

#include <iosfwd>
#include <optional>
#include <string>

namespace lsp {

/// Transport layer API
///
/// The transport layer API is abstracted so it users become more testable as well as
/// this way it could be possible to support other transports (HTTP for example) easily.
class Transport
{
public:
	virtual ~Transport() = default;

	/// Reveives a message
	virtual std::optional<Json::Value> receive() = 0;

	/// Sends a notification message to the other end (client).
	virtual void notify(std::string const& _method, Json::Value const& _message) = 0;

	/// Sends a reply message, optionally with a given ID to corelate this message to another from the other end.
	virtual void reply(protocol::Id const& _id, Json::Value const& _message) = 0;

	/// Sends an error reply with regards to the given request ID.
	virtual void error(protocol::Id const& _id, std::string const& _message) = 0;

	/// Logs given message to the transport related logging sink.
	virtual void log(std::string const& _message) = 0;

	using Logger = std::function<void(std::string const)>;

	Logger logger() { return [this](std::string const& _message) { log(_message); }; }
};

/// Standard stdio style JSON-RPC stream transport.
class JSONTransport: public Transport
{
public:
	/// Constructs a standard stream transport layer.
	///
	/// @param _in for example std::cin (stdin)
	/// @param _out for example std::cout (stdout)
	/// @param _log for example std::cerr (stderr) or a regular file.
	JSONTransport(std::istream& _in, std::ostream& _out, std::ostream* _log);

	std::optional<Json::Value> receive() override;
	void notify(std::string const& _method, Json::Value const& _message) override;
	void reply(protocol::Id const& _id, Json::Value const& _message) override;
	void error(protocol::Id const& _id, std::string const& _message) override;
	void log(std::string const& _message) override;

private:
	using HeaderMap = std::unordered_map<std::string, std::string>;

	void send(Json::Value const& _message);

	/// Parses a single text line ending with CRLF (or just LF).
	std::string readLine();

	/// Parses header section including message-delimiting empty line.
	std::optional<HeaderMap> parseHeaders();

	/// Reads given number of bytes from input stream.
	std::string readBytes(size_t _n);

private:
	std::istream& m_input;
	std::ostream& m_output;
	std::ostream* m_logger;
};

} // end namespace


