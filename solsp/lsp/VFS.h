#pragma once

#include <deque>
#include <map>
#include <string>
#include <vector>

namespace lsp::vfs {

struct Position
{
	unsigned line;
	unsigned column;
};

struct Range
{
	Position from;
	Position to;

	struct LineNumIterator {
		unsigned current;
		unsigned lastLine;

		/// Determines whether or not this is an inner line or a boundary line (first/last).
		bool inner = false;

		constexpr unsigned operator*() const noexcept { return current; }

		constexpr LineNumIterator& operator++() noexcept
		{
			++current;
			if (current + 1 < lastLine)
				inner = true;
			return *this;
		}

		constexpr LineNumIterator& operator++(int) noexcept
		{
			return ++*this;
		}

		constexpr bool operator==(LineNumIterator const& _rhs) const noexcept
		{
			return current == _rhs.current;
		}

		constexpr bool operator!=(LineNumIterator const& _rhs) const noexcept
		{
			return !(*this == _rhs);
		}
	};

	/// Returns an iterator for iterating through the line numbers of this range.
	constexpr LineNumIterator lineNumbers() const noexcept
	{
		return LineNumIterator{from.line, to.line + 1};
	}
};

// TODO: Unit-test me fore sure!
class File
{
public:
	using TextLines = std::deque<std::string>;

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

	// modifiers
	void erase(Range const& _range);
	void modify(Range const& _range, std::string const& _replacementText);

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

	File& insert(std::string _uri, File _contents);
	void remove(std::string const& _uri);

	/// Modifies given VFS file by deleting the @p _range and replace it with the @p _replacementText.
	void modify(std::string const& _uri, Range const& _range, std::string const& _replacementText);

	File const* find(std::string const& _uri) const;

private:
	std::map<std::string, File> m_files;
};


} // end namespace
