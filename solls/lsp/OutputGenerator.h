#pragma once

#include <libsolutil/JSON.h>
#include <lsp/protocol.h>

#include <tuple>

namespace lsp {

struct OutputGenerator
{
	// notifications
	struct NotificationInfo { std::string method; Json::Value params; };
	NotificationInfo operator()(protocol::CancelRequest const&);
	NotificationInfo operator()(protocol::Notification const&);
	NotificationInfo operator()(protocol::PublishDiagnosticsParams const&);

	// replies
	Json::Value operator()(protocol::InitializeResult const&);
	Json::Value operator()(protocol::Response const&);

	// helpers
	Json::Value toJson(Range const& _range);

	// TODO: Obviousely, here's more to come...
};

} // end namespace
