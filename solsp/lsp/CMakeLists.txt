add_library(lsp
	InputHandler.cpp InputHandler.h
	MessageParser.cpp MessageParser.h
	OutputGenerator.cpp OutputGenerator.h
	Server.cpp Server.h
	protocol.cpp protocol.h
)
target_link_libraries(lsp PUBLIC jsoncpp solutil)
target_include_directories(lsp PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/..)
