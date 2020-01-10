add_library(lsp
	MessageParser.cpp MessageParser.h
	protocol.cpp protocol.h
)
target_link_libraries(lsp PUBLIC jsoncpp devcore)
target_include_directories(lsp PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/..)

