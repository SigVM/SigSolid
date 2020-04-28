#pragma once

#include <lsp/Range.h>
#include <optional>
#include <ostream>
#include <string>
#include <utility>

namespace lsp
{

/// Manages a text buffer.
class TextBuffer
{
public:
	using value_type = std::string;
	using reference = value_type::reference;
	using const_reference = value_type::const_reference;

	explicit TextBuffer(std::string _contents = {}): m_buffer{std::move(_contents)} {}
	TextBuffer(TextBuffer&&) = default;
	TextBuffer(TextBuffer const&) = delete;
	TextBuffer& operator=(TextBuffer&&) = default;
	TextBuffer& operator=(TextBuffer const&) = delete;

	bool empty() const noexcept { return m_buffer.empty(); }
	size_t size() const noexcept { return m_buffer.size(); }
	std::string const& data() const noexcept { return m_buffer; }

	reference at(size_t i) { return m_buffer.at(i); }
	const_reference at(size_t i) const { return m_buffer.at(i); }

	Position possitionOf(size_t _offset) const noexcept;
	size_t offsetOf(Position const& _position) const noexcept;
	std::pair<size_t, size_t> offsetsOf(Range const& _range) const noexcept;

	void replace(Range const& _range, std::string const& _replacementText);
	void assign(std::string const& _text);

private:
	std::string m_buffer;
};

} // end namespace

namespace std
{
	inline ostream& operator<<(ostream& _os, lsp::TextBuffer const& _text)
	{
		_os << _text.data();
		return _os;
	}
}

namespace lsp
{
	inline size_t TextBuffer::offsetOf(Position const& _position) const noexcept
	{
		// TODO: take care of Unicode.
		size_t offset = 0;
		Position current = {};
		while (current != _position)
		{
			if (at(offset) != '\n')
			{
				current.column++;
			}
			else
			{
				current.line++;
				current.column = 0;
			}
			offset++;
		}
		return offset;
	}

	inline Position TextBuffer::possitionOf(size_t _offset) const noexcept
	{
		// TODO: take care of Unicode.
		Position position = {};
		for (size_t offset = 0; offset != _offset; ++offset)
		{
			if (at(offset) != '\n')
			{
				position.column++;
			}
			else
			{
				position.line++;
				position.column = 0;
			}
		}
		return position;
	}

	inline std::pair<size_t, size_t> TextBuffer::offsetsOf(Range const& _range) const noexcept
	{
		return std::pair{
			offsetOf(_range.start),
			offsetOf(_range.end)
		};
	}

	inline void TextBuffer::replace(Range const& _range, std::string const& _replacementText)
	{
		auto const [start, end] = offsetsOf(_range);
		m_buffer.replace(start, end - start, _replacementText);
	}

	inline void TextBuffer::assign(std::string const& _text)
	{
		m_buffer = _text;
	}
}
