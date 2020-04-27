#include <lsp/VFS.h>
#include <libsolutil/StringUtils.h>
#include <deque>
#include <algorithm>
#include <sstream>

using namespace std;
using namespace solidity::util;

namespace lsp::vfs {

File::File(string _uri, string _languageId, int _version, string const& _text):
	File(_uri, _languageId, _version, splitLines(_text))
{
}

TextLines File::splitLines(string const& _text)
{
	TextLines lines;
	solidity::util::splitLines(_text, lines);
	return lines;
}

string File::str() const
{
	ostringstream sstr;

	for (string const& line: m_text)
		sstr << line << '\n';

	return sstr.str();
}

void File::erase(Range const& _range)
{
	auto firstLine = next(begin(m_text), _range.start.line);
	auto lastLine = next(begin(m_text), _range.end.line);

	m_version++;

	if (firstLine == lastLine)
	{
		firstLine->erase(
			_range.start.column,
			_range.end.column - _range.start.column
		);
	}
	else
	{
		// erase first line fragment
		bool const firstLineFullyReplaced = _range.start.column == 0;
		if (!firstLineFullyReplaced)
			firstLine->erase(_range.start.column);
		else
			firstLine = m_text.erase(firstLine);

		// erase last line fragment
		bool const lastLineFullyReplaced = lastLine->size() == _range.end.column + 1;
		if (!lastLineFullyReplaced)
			lastLine->erase(0, _range.end.column);
		else
			lastLine = m_text.erase(lastLine);

		// erase inner lines
		m_text.erase(++firstLine, lastLine);

		// maybe merge first/last lines
		if (!firstLineFullyReplaced && !lastLineFullyReplaced)
		{
			firstLine->append(*lastLine);
			m_text.erase(lastLine);
		}
	}
}

void File::modify(Range const& _range, std::string const& _replacementText)
{
	if (_range.start.line == _range.end.line)
	{
		if (_replacementText.find('\n') == string::npos)
		{
			// single line to single line
			auto firstLine = next(begin(m_text), _range.start.line);
			firstLine->replace(
				_range.start.column,
				_range.end.column - _range.start.column,
				_replacementText
			);
		}
		else
		{
			// single line edit to multi line

			TextLines const replacementText = File::splitLines(_replacementText);
			auto targetLine = next(begin(m_text), _range.start.line);
			auto sourceLine = begin(replacementText);

			// erase the fragemnt that is going to be replaced
			targetLine->erase(_range.start.column, _range.end.column - _range.start.column);

			// split line (because we replace with multi-line content)
			m_text.insert(targetLine, targetLine->substr(0, _range.start.column) + *sourceLine);
			targetLine->erase(0, _range.start.column);
			sourceLine++;

			// insert middle replacement lines
			while (sourceLine != prev(end(replacementText)))
				m_text.insert(targetLine, *sourceLine++);

			// Merge last replacementText line with next line iff former was NOT empty.
			if (!sourceLine->empty())
				targetLine->insert(0, *sourceLine);
		}
	}
	else
	{
		// multi line
		erase(_range);

		auto firstLine = next(begin(m_text), _range.start.line);
		TextLines lines = splitLines(_replacementText);

		// Insert first line
		firstLine->append(move(lines.front()));
		lines.pop_front();

		m_text.insert(next(firstLine), begin(lines), end(lines));
	}
}

void File::replace(std::string const& _replacementText)
{
	m_text = splitLines(_replacementText);
}

File& VFS::insert(std::string _uri, std::string _languageId, int _version, TextLines _text)
{
	if (auto i = m_files.find(_uri); i != end(m_files))
	{
		i->second = vfs::File(move(_uri), move(_languageId), _version, move(_text));
		return i->second;
	}
	else
	{
		File file{_uri, move(_languageId), _version, move(_text)};
		return m_files.emplace( pair{_uri, move(file)}).first->second;
	}
}

File& VFS::insert(std::string _uri, std::string _languageId, int _version, string _text)
{
	return insert(move(_uri), move(_languageId), _version, File::splitLines(_text));
}

File const* VFS::find(std::string const& _uri) const noexcept
{
	if (auto i = m_files.find(_uri); i != end(m_files))
		return &i->second;
	else
		return nullptr;
}

File* VFS::find(std::string const& _uri) noexcept
{
	if (auto i = m_files.find(_uri); i != end(m_files))
		return &i->second;
	else
		return nullptr;
}

void VFS::remove(std::string const& _uri)
{
	if (auto i = m_files.find(_uri); i != end(m_files))
		m_files.erase(i);
}

} // end namespace
