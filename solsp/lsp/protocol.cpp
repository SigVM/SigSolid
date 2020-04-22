#include <lsp/protocol.h>
#include <libsolutil/Visitor.h>
#include <array>
#include <variant>

using namespace std;

namespace lsp::protocol {

namespace {

Request makeInitializeReq(Json::Value const& params)
{
	InitializeRequest req{};

	if (params["processId"])
		req.processId = params["processId"].asInt();

	if (params["rootPath"])
		req.rootPath = params["rootPath"].asString();

	if (params["rootUri"])
		req.rootUri = params["rootUri"].asString();

	// TODO: initializationOptions
	if (params["trace"])
	{
		auto value = params["trace"].asString();
		if (value == "off")
			req.trace = Trace::Off;
		else if (value == "messages")
			req.trace = Trace::Messages;
		else if (value == "verbose")
			req.trace = Trace::Verbose;
	}
	if (auto const folders = params["workspaceFolders"]; folders)
	{
		for (Json::ArrayIndex i = 0; i < folders.size(); ++i)
		{
			req.workspaceFolders.emplace_back(
				WorkspaceFolder{
					folders[i]["uri"].asString(),
					folders[i]["name"].asString()
				}
			);
		}
	}
	return req;
}

} // end unnamed private namespace

RequestMessage fromJsonRpc(Json::Value const& _request)
{
	auto const id = _request["id"].asUInt64();
	auto const method = _request["method"].asString();
	auto const& params = _request["params"];

	auto static const methodHandlers = array{
		pair{"initialize", makeInitializeReq},
		// TODO: more requests
	};

	for (auto const& methodHandler: methodHandlers)
		if (method == methodHandler.first)
			return RequestMessage{id, method, methodHandler.second(params)};

	return RequestMessage{id, method, {}};
}

Json::Value toJsonRpc(Response const& _response, optional<Id> _requestId)
{
	Json::Value json;

	if (_requestId.has_value())
	{
		if (holds_alternative<string>(*_requestId))
			json["id"] = get<string>(*_requestId);
		else
			json["id"] = get<int>(*_requestId);
	}
	else
		json["id"] = Json::nullValue;

	json["jsonrpc"] = "2.0";

	if (holds_alternative<InitializeResult>(_response))
	{
		auto& jsonResult = json["result"];
		auto& jsonCaps = jsonResult["capabilities"];
		InitializeResult const& response = get<InitializeResult>(_response);

		if (response.capabilities.hoverProvider)
			jsonCaps["hoverProvider"] = true;

		visit(solidity::util::GenericVisitor{
			[](monostate) {},
			[&](int _arg) { jsonCaps["textDocumentSync"] = _arg; },
			[&](TextDocumentSyncOptions const& _ops) {
				jsonCaps["textDocumentSync"]["openClose"] = _ops.openClose;
				jsonCaps["textDocumentSync"]["change"] = _ops.change;
				jsonCaps["textDocumentSync"]["willSave"] = _ops.willSave;
				jsonCaps["textDocumentSync"]["willSaveWaitUntil"] = _ops.willSaveWaitUntil;
				if (_ops.save.has_value())
				{
					SaveOptions const& saveOptions = *_ops.save;
					jsonCaps["textDocumentSync"]["save"]["includeText"] = saveOptions.includeText;
				}
			}
		}, response.capabilities.textDocumentSync);
	}

	return json;
}

} // end namespace
