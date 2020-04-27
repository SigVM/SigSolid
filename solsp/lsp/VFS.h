#pragma once

#include <lsp/Range.h>

#include <deque>
#include <map>
#include <string>
#include <vector>

namespace lsp::vfs {

using TextLines = std::deque<std::string>;

// TODO: Unit-test me fore sure!
class File
{
public:
	File(std::string _uri, std::string _languageId, int _version, TextLines _text):
		m_uri{ std::move(_uri) },
		m_languageId{ std::move(_languageId) },
		m_version{ _version },
		m_text{ std::move(_text) }
	{}

	File(std::string _uri, std::string _languageId, int _version, std::string const& _text);

	// readers
	std::string const& uri() const noexcept { return m_uri; }
	std::string const& languageId() const noexcept { return m_languageId; }
	constexpr int version() const noexcept { return m_version; }
	TextLines const& text() const noexcept { return m_text; }
	std::string str() const;

	// modifiers
	constexpr void setVersion(int _version) noexcept { m_version = _version; }
	void erase(Range const& _range);
	void modify(Range const& _range, std::string const& _replacementText);
	void replace(std::string const& _replacementText);

	static TextLines splitLines(std::string const& _text);

private:
	std::string m_uri;
	std::string m_languageId;
	int m_version;
	TextLines m_text;
};

class VFS
{
public:
	VFS() = default;

	File& insert(std::string _uri, std::string _languageId, int _version, TextLines _text);
	File& insert(std::string _uri, std::string _languageId, int _version, std::string _text);

	void remove(std::string const& _uri);

	/// Modifies given VFS file by deleting the @p _range and replace it with the @p _replacementText.
	void modify(std::string const& _uri, Range const& _range, std::string const& _replacementText);

	File const* find(std::string const& _uri) const noexcept;
	File* find(std::string const& _uri) noexcept;

private:
	std::map<std::string, File> m_files;
};


} // end namespace
