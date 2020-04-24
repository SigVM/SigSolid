#pragma once

// TODO: remove me way before merge :)

#if 1 // !defined(NDEBUG)

#include <iostream>
#include <string>

namespace solidity {
	struct CallTrace {
		std::ostream& logger;
		std::string functionName;
		CallTrace(std::ostream& _logger, std::string const& _name):
			logger{_logger},
			functionName{_name} {
			logger << functionName << " enter" << std::endl;
		}
		~CallTrace() {
			logger << functionName << " leave" << std::endl;
		}
	};
}

#define FNTRACE(logger, name) ::solidity::CallTrace _((logger), (name))
#else
#define FNTRACE(name) do {} while (0)

#endif
