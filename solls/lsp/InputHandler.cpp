#include <lsp/InputHandler.h>
#include <libsolutil/JSON.h>

using namespace lsp::protocol;
using namespace std;

namespace lsp {

InputHandler::InputHandler(ostream& _logger):
	m_logger{_logger}
{
}

optional<Request> InputHandler::handleRequest(std::string const& _message)
{
	Json::Value jsonMessage;
	string errs;
	solidity::util::jsonParseStrict(_message, jsonMessage, &errs);
	if (!errs.empty())
	{
		m_logger << errs << endl;
		return nullopt; // JsonParseError
	}

	return handleRequest(jsonMessage);
}

optional<Request> InputHandler::handleRequest(Json::Value const& _jsonMessage)
{
	m_logger << "handle message:\n" << solidity::util::jsonPrettyPrint(_jsonMessage) << endl;

	string const methodName = _jsonMessage["method"].asString();

	Id const id = _jsonMessage["id"].isInt()
		? Id{_jsonMessage["id"].asInt()}
		: _jsonMessage["id"].isString()
			? Id{_jsonMessage["id"].asString()}
			: Id{};

	Json::Value const& jsonArgs = _jsonMessage["params"];

	if (methodName == "cancelRequest")
		return cancelRequest(jsonArgs);
	if (methodName == "initialize")
		return initializeRequest(id, jsonArgs);
	if (methodName == "initialized")
		return initialized(id, jsonArgs);
	if (methodName == "textDocument/didOpen")
		return textDocument_didOpen(id, jsonArgs);
	if (methodName == "textDocument/didChange")
		return textDocument_didChange(id, jsonArgs);
	// if (methodName == "textDocument/didClose") TODO
	// 	return textDocument_didClose(id, jsonArgs);

	m_logger << "Unsupported RPC: " << methodName << endl;
	return nullopt;
}

optional<CancelRequest> InputHandler::cancelRequest(Json::Value const& _message)
{
	if (Json::Value id = _message["id"]; id.isInt())
		return CancelRequest{id.asInt()};
	else if (id.isString())
		return CancelRequest{id.asString()};
	else
		return nullopt;
}

optional<InitializeRequest> InputHandler::initializeRequest(Id const& _id, Json::Value const& _args)
{
	lsp::protocol::InitializeRequest request{};
	request.requestId = _id;

	if (Json::Value pid = _args["processId"]; pid)
		request.processId = pid.asInt();

	if (Json::Value rootPath = _args["rootPath"]; rootPath)
		request.rootPath = rootPath.asString();

	if (Json::Value uri = _args["rootUri"]; uri)
		request.rootUri = uri.asString();

	if (Json::Value trace = _args["trace"]; trace)
	{
		string const name = trace.asString();
		if (name == "messages")
			request.trace = lsp::protocol::Trace::Messages;
		else if (name == "verbose")
			request.trace = lsp::protocol::Trace::Verbose;
		else if (name == "off")
			request.trace = lsp::protocol::Trace::Off;
	}

	if (Json::Value folders = _args["workspaceFolders"]; folders)
	{
		for (Json::Value folder : folders)
		{
			lsp::protocol::WorkspaceFolder wsFolder{};
			wsFolder.name = folder["name"].asString();
			wsFolder.uri = folder["uri"].asString();
			request.workspaceFolders.emplace_back(move(wsFolder));
		}
	}

	// TODO: initializationOptions
	// TODO: ClientCapabilities

	return request;
}

optional<protocol::InitializedNotification> InputHandler::initialized(Id const&, Json::Value const&)
{
	// TODO: error checking?
	return InitializedNotification{};
}

optional<DidOpenTextDocumentParams> InputHandler::textDocument_didOpen(Id const& _id, Json::Value const& _args)
{
	if (!_args["textDocument"])
		return nullopt;

	DidOpenTextDocumentParams args{};
	args.requestId = _id;
	args.textDocument.uri = _args["textDocument"]["uri"].asString();
	args.textDocument.languageId = _args["textDocument"]["languageId"].asString();
	args.textDocument.version = _args["textDocument"]["version"].asInt();
	args.textDocument.text = _args["textDocument"]["text"].asString();

	return args;
}

optional<protocol::DidChangeTextDocumentParams> InputHandler::textDocument_didChange(Id const& _id, Json::Value const& _json)
{
	DidChangeTextDocumentParams didChange{};
	didChange.requestId = _id;
	didChange.textDocument.version = _json["textDocument"]["version"].asInt();
	didChange.textDocument.uri = _json["textDocument"]["uri"].asString();

	for (Json::Value jsonContentChange : _json["contentChanges"])
	{
		if (jsonContentChange.isObject() && jsonContentChange["range"])
		{
			Json::Value jsonRange = jsonContentChange["range"];
			TextDocumentRangedContentChangeEvent rangedChange;
			rangedChange.text = jsonRange["text"].asString();
			rangedChange.range.start.line = jsonRange["start"]["line"].asInt();
			rangedChange.range.start.column = jsonRange["start"]["character"].asInt();
			rangedChange.range.end.line = jsonRange["end"]["line"].asInt();
			rangedChange.range.end.column = jsonRange["end"]["character"].asInt();
			didChange.contentChanges.emplace_back(move(rangedChange));
		}
		else
		{
			// TODO: TextDocumentFullContentChangeEvent fullChange;
			m_logger << "TODO! TextDocumentFullContentChangeEvent!\n";
		}
	}

	return didChange;
}

} // end namespace
