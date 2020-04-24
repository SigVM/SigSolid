#include <lsp/protocol.h>
#include <libsolutil/Visitor.h>
#include <array>
#include <variant>

using namespace std;

namespace lsp::protocol {

namespace {

// Request makeInitializeReq(Json::Value const& params)
// {
// 	InitializeRequest req{};
//
// 	if (params["processId"])
// 		req.processId = params["processId"].asInt();
//
// 	if (params["rootPath"])
// 		req.rootPath = params["rootPath"].asString();
//
// 	if (params["rootUri"])
// 		req.rootUri = params["rootUri"].asString();
//
// 	// TODO: initializationOptions
// 	if (params["trace"])
// 	{
// 		auto value = params["trace"].asString();
// 		if (value == "off")
// 			req.trace = Trace::Off;
// 		else if (value == "messages")
// 			req.trace = Trace::Messages;
// 		else if (value == "verbose")
// 			req.trace = Trace::Verbose;
// 	}
// 	if (auto const folders = params["workspaceFolders"]; folders)
// 	{
// 		for (Json::ArrayIndex i = 0; i < folders.size(); ++i)
// 		{
// 			req.workspaceFolders.emplace_back(
// 				WorkspaceFolder{
// 					folders[i]["uri"].asString(),
// 					folders[i]["name"].asString()
// 				}
// 			);
// 		}
// 	}
// 	return req;
// }

} // end unnamed private namespace

} // end namespace
