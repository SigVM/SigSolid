#pragma once

#include <json/value.h>

#include <any>
#include <array>
#include <optional>
#include <map>
#include <string>
#include <variant>
#include <vector>

// NOTE: https://microsoft.github.io/language-server-protocol/specifications/specification-3-14/

namespace lsp::protocol {

using DocumentUri = std::string; // such as "file:///path/to"

enum class Trace { Off, Messages, Verbose };

/// Known error codes for an `InitializeError`
struct InitializeError {
	enum Code {
		/**
		 * If the protocol version provided by the client can't be handled by the server.
		 * @deprecated This initialize error got replaced by client capabilities. There is
		 * no version handshake in version 3.0x
		 */
		UnknownProtocolVersion = 1,
	};
	Code code;
	bool retry;
};

/// Many tools support more than one root folder per workspace.
/// Examples for this are VS Code’s multi-root support, Atom’s project folder support or Sublime’s project support.
/// If a client workspace consists of multiple roots then a server typically needs to know about this.
/// The protocol up to now assumes one root folder which is announced to the server by the rootUri property
/// of the InitializeParams. If the client supports workspace folders and announces them via the corresponding
/// workspaceFolders client capability, the InitializeParams contain an additional property workspaceFolders
/// with the configured workspace folders when the server starts.
struct WorkspaceFolder {
	/**
	 * The associated URI for this workspace folder.
	 */
	DocumentUri uri;

	/**
	 * The name of the workspace folder. Used to refer to this
	 * workspace folder in the user interface.
	 */
	std::string name;
};

/// The initialize request is sent as the first request from the client to the server.
struct InitializeRequest {
	std::optional<int> processId;
	std::optional<std::string> rootPath;
	std::optional<DocumentUri> rootUri;

	/**
	 * User provided initialization options.
	 */
	std::optional<std::any> initializationOptions;

	/**
	 * The capabilities provided by the client (editor or tool)
	 */
	//TODO: ClientCapabilities capabilities;

	/**
	 * The initial trace setting. If omitted trace is disabled ('off').
	 */
	Trace trace = Trace::Off;

	/**
	 * The workspace folders configured in the client when the server starts.
	 * This property is only available if the client supports workspace folders.
	 * It can be `null` if the client supports workspace folders but none are
	 * configured.
	 *
	 * Since 3.6.0
	 */
	std::vector<WorkspaceFolder> workspaceFolders;
};

/**
 * Save options.
 */
struct SaveOptions {
	/**
	 * The client is supposed to include the content on save.
	 */
	bool includeText;
};

struct TextDocumentSyncOptions {
	/**
	 * Open and close notifications are sent to the server. If omitted open close notification should not
	 * be sent.
	 */
	bool openClose;

	/**
	 * Change notifications are sent to the server. See TextDocumentSyncKind.None, TextDocumentSyncKind.Full
	 * and TextDocumentSyncKind.Incremental. If omitted it defaults to TextDocumentSyncKind.None.
	 */
	int change;

	/**
	 * If present will save notifications are sent to the server. If omitted the notification should not be
	 * sent.
	 */

	bool willSave;

	/**
	 * If present will save wait until requests are sent to the server. If omitted the request should not be
	 * sent.
	 */
	bool willSaveWaitUntil;

	/**
	 * If present save notifications are sent to the server. If omitted the notification should not be
	 * sent.
	 */
	std::optional<SaveOptions> save;
};

struct ServerCapabilities {
	/**
	 * Defines how text documents are synced. Is either a detailed structure defining each notification or
	 * for backwards compatibility the TextDocumentSyncKind number. If omitted it defaults to `TextDocumentSyncKind.None`.
	 */
	std::variant<int, TextDocumentSyncOptions, std::monostate> textDocumentSync;

	bool hoverProvider = false;
	// TODO
};

struct InitializeResult {
	ServerCapabilities capabilities;
};

/**
 * Position in a text document expressed as zero-based line and zero-based
 * character offset. A position is between two characters like an ‘insert’ cursor
 * in a editor. Special values like for example -1 to denote the end of a line
 * are not supported.
 */
struct Position {
	/**
	 * Line position in a document (zero-based).
	 */
	int line;

	/**
	 * Character offset on a line in a document (zero-based). Assuming that the line is
	 * represented as a string, the `character` value represents the gap between the
	 * `character` and `character + 1`.
	 *
	 * If the character value is greater than the line length it defaults back to the
	 * line length.
	 */
	int character;
};

/**
 * A range in a text document expressed as (zero-based) start and end positions.
 * A range is comparable to a selection in an editor. Therefore the end position is exclusive.
 * If you want to specify a range that contains a line including the line ending character(s)
 * then use an end position denoting the start of the next line. For example:
 *
 * {
 *   start: { line: 5, character: 23 },
 *   end : { line 6, character : 0 }
 * }
 */
struct Range {
	/**
	 * The range's start position.
	 */
	Position start;

	/**
	 * The range's end position.
	 */
	Position end;
};

/**
 * Represents a location inside a resource, such as a line inside a text file.
 */
struct Location {
	DocumentUri uri;
	Range range;
};

/**
 * Represents a link between a source and a target location.
 */
struct LocationLink {
	/**
	 * Span of the origin of this link.
	 *
	 * Used as the underlined span for mouse interaction. Defaults to the word range at
	 * the mouse position.
	 */
	std::optional<Range> originSelectionRange;

	/**
	 * The target resource identifier of this link.
	 */
	DocumentUri targetUri;

	/**
	 * The full target range of this link. If the target for example is a symbol then target range is the
	 * range enclosing this symbol not including leading/trailing whitespace but everything else
	 * like comments. This information is typically used to highlight the range in the editor.
	 */
	Range targetRange;

	/**
	 * The range that should be selected and revealed when this link is being followed, e.g the name of a function.
	 * Must be contained by the the `targetRange`. See also `DocumentSymbol#range`
	 */
	Range targetSelectionRange;
};

enum class DiagnosticSeverity {
	/**
	 * Reports an error.
	 */
	Error = 1,
	/**
	 * Reports a warning.
	 */
	Warning = 2,
	/**
	 * Reports an information.
	 */
	Information = 3,
	/**
	 * Reports a hint.
	 */
	Hint = 4,
};

/**
 * Represents a related message and source code location for a diagnostic. This should be
 * used to point to code locations that cause or related to a diagnostics, e.g when duplicating
 * a symbol in a scope.
 */
struct DiagnosticRelatedInformation {
	/**
	 * The location of this related diagnostic information.
	 */
	Location location;

	/**
	 * The message of this related diagnostic information.
	 */
	std::string message;
};

/**
 * Represents a diagnostic, such as a compiler error or warning.
 * Diagnostic objects are only valid in the scope of a resource.
 */
struct Diagnostic {
	/**
	 * The range at which the message applies.
	 */
	Range range;

	/**
	 * The diagnostic's severity. Can be omitted. If omitted it is up to the
	 * client to interpret diagnostics as error, warning, info or hint.
	 */
	std::optional<DiagnosticSeverity> severity;

	/**
	 * The diagnostic's code, which might appear in the user interface.
	 */
	std::variant<int, std::string, std::monostate> code;

	/**
	 * A human-readable string describing the source of this
	 * diagnostic, e.g. 'typescript' or 'super lint'.
	 */
	std::optional<std::string> source;

	/**
	 * The diagnostic's message.
	 */
	std::string message;

	/**
	 * An array of related diagnostic information, e.g. when symbol-names within
	 * a scope collide all definitions can be marked via this property.
	 */
	std::vector<DiagnosticRelatedInformation> relatedInformation;
};

/**
 * Represents a reference to a command.
 * Provides a title which will be used to represent a command in the UI.
 * Commands are identified by a string identifier.
 * The recommended way to handle commands is to implement their execution on the server side
 * if the client and server provides the corresponding capabilities.
 * Alternatively the tool extension code could handle the command.
 * The protocol currently doesn’t specify a set of well-known commands.
 */
struct Command {
	/**
	 * Title of the command, like `save`.
	 */
	std::string title;

	/**
	 * The identifier of the actual command handler.
	 */
	std::string command;

	/**
	 * Arguments that the command handler should be
	 * invoked with.
	 */
	std::optional<std::vector<std::any>> arguments;
};

/**
 * A textual edit applicable to a text document.
 */
struct TextEdit {
	/**
	 * The range of the text document to be manipulated. To insert
	 * text into a document create a range where start === end.
	 */
	Range range;

	/**
	 * The string to be inserted. For delete operations use an
	 * empty string.
	 */
	std::string newText;
};

/**
 * Text documents are identified using a URI. On the protocol level, URIs are passed as strings.
 * The corresponding JSON structure looks like this:
 */
struct TextDocumentIdentifier {
	/**
	 * The text document's URI.
	 */
	DocumentUri uri;
};

struct VersionedTextDocumentIdentifier : public TextDocumentIdentifier {
	/**
	 * The version number of this document. If a versioned text document identifier
	 * is sent from the server to the client and the file is not open in the editor
	 * (the server has not received an open notification before) the server can send
	 * `null` to indicate that the version is known and the content on disk is the
	 * truth (as speced with document content ownership).
	 *
	 * The version number of a document will increase after each change, including
	 * undo/redo. The number doesn't need to be consecutive.
	 */
	std::variant<int, std::monostate> version;
};

/**
 * Describes textual changes on a single text document.
 * The text document is referred to as a VersionedTextDocumentIdentifier to allow clients
 * to check the text document version before an edit is applied. A TextDocumentEdit describes
 * all changes on a version Si and after they are applied move the document to version Si+1.
 * So the creator of a TextDocumentEdit doesn’t need to sort the array or do any kind of ordering.
 * However the edits must be non overlapping.
 */
struct TextDocumentEdit {
	/**
	 * The text document to change.
	 */
	VersionedTextDocumentIdentifier textDocument;

	/**
	 * The edits to be applied.
	 */
	std::vector<TextEdit> edits;
};

// -----------------------------------------------------------------------------------------------
// File Reosurce Changes
// ---------------------
// New in 3.13

/**
 * Options to create a file.
 */
struct CreateFileOptions {
	/**
	 * Overwrite existing file. Overwrite wins over `ignoreIfExists`
	 */
	std::optional<bool> overwrite;

	/**
	 * Ignore if exists.
	 */
	std::optional<bool> ignoreIfExists;
};

/**
 * Create file operation
 */
struct CreateFile {
	/**
	 * The resource to create.
	 */
	DocumentUri uri;

	/**
	 * Additional options
	 */
	std::optional<CreateFileOptions> options;
};

/**
 * Rename file options
 */
struct RenameFileOptions {
	/**
	 * Overwrite target if existing. Overwrite wins over `ignoreIfExists`
	 */
	std::optional<bool> overwrite;

	/**
	 * Ignores if target exists.
	 */
	std::optional<bool> ignoreIfExists;
};

/**
 * Rename file operation
 */
struct RenameFile {
	/**
	 * The old (existing) location.
	 */
	DocumentUri oldUri;

	/**
	 * The new location.
	 */
	DocumentUri newUri;

	/**
	 * Rename options.
	 */
	std::optional<RenameFileOptions> options;
};

/**
 * Delete file options
 */
struct DeleteFileOptions {
	/**
	 * Delete the content recursively if a folder is denoted.
	 */
	std::optional<bool> recursive;

	/**
	 * Ignore the operation if the file doesn't exist.
	 */
	std::optional<bool> ignoreIfNotExists;
};

/**
 * Delete file operation
 */
struct DeleteFile {
	/**
	 * The file to delete.
	 */
	DocumentUri uri;

	/**
	 * Delete options.
	 */
	std::optional<DeleteFileOptions> options;
};

// -----------------------------------------------------------------------------------------------

/**
 * A workspace edit represents changes to many resources managed in the workspace.
 * The edit should either provide `changes` or `documentChanges`.
 * If the client can handle versioned document edits and if `documentChanges` are present,
 * the latter are preferred over `changes`.
 */
struct WorkspaceEdit {
	struct Changes {
		DocumentUri uri;
		std::vector<TextEdit> edits;
	};
	/**
	 * Holds changes to existing resources.
	 */
	//changes?: { [uri: DocumentUri]: TextEdit[]; };
	std::optional<std::map<DocumentUri, std::vector<TextEdit>>> changes;

	/**
	 * Depending on the client capability `workspace.workspaceEdit.resourceOperations` document changes
	 * are either an array of `TextDocumentEdit`s to express changes to n different text documents
	 * where each text document edit addresses a specific version of a text document. Or it can contain
	 * above `TextDocumentEdit`s mixed with create, rename and delete file / folder operations.
	 *
	 * Whether a client supports versioned document edits is expressed via
	 * `workspace.workspaceEdit.documentChanges` client capability.
	 *
	 * If a client neither supports `documentChanges` nor `workspace.workspaceEdit.resourceOperations` then
	 * only plain `TextEdit`s using the `changes` property are supported.
	 */
	//documentChanges?: (TextDocumentEdit[] | (TextDocumentEdit | CreateFile | RenameFile | DeleteFile)[]);
	std::optional<std::variant<
		std::vector<TextDocumentEdit>,
		std::vector<std::variant<
			TextDocumentEdit,
			CreateFile,
			RenameFile,
			DeleteFile
		>>
	>> documentChanges;
};


/**
 * An item to transfer a text document from the client to the server.
 */
struct TextDocumentItem {
	/**
	 * The text document's URI.
	 */
	DocumentUri uri;

	/**
	 * The text document's language identifier.
	 */
	std::string languageId;

	/**
	 * The version number of this document (it will increase after each
	 * change, including undo/redo).
	 */
	int version;

	/**
	 * The content of the opened text document.
	 */
	std::string text;
};

/**
 * A parameter literal used in requests to pass a text document and a position inside that document.
 */
struct TextDocumentPositionParams {
	/**
	 * The text document.
	 */
	TextDocumentIdentifier textDocument;

	/**
	 * The position inside the text document.
	 */
	Position position;
};

/// A document filter denotes a document through properties like language, scheme or pattern.
/// An example is a filter that applies to TypeScript files on disk.
/// Another example is a filter the applies to JSON files with name package.json:
///   { language: 'typescript', scheme: 'file' }
///   { language: 'json', pattern: '**/package.json' }
struct DocumentFilter {
	/**
	 * A language id, like `typescript`.
	 */
	std::optional<std::string> language;

	/**
	 * A Uri [scheme](#Uri.scheme), like `file` or `untitled`.
	 */
	std::optional<std::string> scheme;

	// A glob pattern, like `*.{ts,js}`.
	//
	// Glob patterns can have the following syntax:
	// - `*` to match one or more characters in a path segment
	// - `?` to match on one character in a path segment
	// - `**` to match any number of path segments, including none
	// - `{}` to group conditions (e.g. `**/*.{ts,js}` matches all TypeScript and JavaScript files)
	// - `[]` to declare a range of characters to match in a path segment (e.g., `example.[0-9]` to match on `example.0`, `example.1`, …)
	// - `[!...]` to negate a range of characters to match in a path segment (e.g., `example.[!0-9]` to match on `example.a`, `example.b`, but not `example.0`)
	std::optional<std::string> pattern;
};

/// A document selector is the combination of one or more document filters.
using DocumentSelector = std::vector<DocumentFilter>;


/**
 * Describes the content type that a client supports in various
 * result literals like `Hover`, `ParameterInfo` or `CompletionItem`.
 *
 * Please note that `MarkupKinds` must not start with a `$`. This kinds
 * are reserved for internal usage.
 */
enum class MarkupKind {
	/**
	 * Plain text is supported as a content format
	 */
	PlainText,

	/**
	 * Markdown is supported as a content format
	 */
	Markdown
};

/**
 * A `MarkupContent` literal represents a string value which content is interpreted base on its
 * kind flag. Currently the protocol supports `plaintext` and `markdown` as markup kinds.
 *
 * If the kind is `markdown` then the value can contain fenced code blocks like in GitHub issues.
 * See https://help.github.com/articles/creating-and-highlighting-code-blocks/#syntax-highlighting
 *
 * *Please Note* that clients might sanitize the return markdown. A client could decide to
 * remove HTML from the markdown to avoid script execution.
 */
struct MarkupContent {
	/**
	 * The type of the Markup
	 */
	MarkupKind kind;

	/**
	 * The content itself
	 */
	std::string value;
};

// -----------------------------------------------------------------------------------------------

using Request = std::variant<
	InitializeRequest
>;

using Response = std::variant<
	InitializeResult
>;

using Id = std::variant<int, std::string>;

struct RequestMessage {
	std::optional<Id> id;
	std::string method;
	std::optional<Request> params;
};

// -----------------------------------------------------------------------------------------------

/// Transforms an LSP request message from JSON-RPC to C++ highlevel struct.
RequestMessage fromJsonRpc(Json::Value const& _request);

/// Transforms a LSP response message into a JSON-RPC response message.
Json::Value toJsonRpc(Response const& _response, std::optional<Id> _requestId = std::nullopt);

} // end namespace
