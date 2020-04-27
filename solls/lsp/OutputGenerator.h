#pragma once

#include <libsolutil/JSON.h>
#include <lsp/protocol.h>

namespace lsp {

class OutputGenerator {
public:
	Json::Value generate(protocol::Response const& _response);

	// bi-directional messages
	Json::Value operator()(protocol::CancelRequest const& _message);

	// response messages
	Json::Value operator()(protocol::InitializeResult const& _response);
};

} // end namespace
