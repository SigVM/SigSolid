#include <lsp/VFS.h>
#include <libsolutil/StringUtils.h>
#include <deque>
#include <algorithm>

using namespace std;
using namespace solidity::util;

namespace lsp::vfs {

File::File(string _uri, string _languageId, int _version, string const& _text):
	File(_uri, _languageId, _version, splitLines<deque>(_text))
{
}

void File::erase(Range const& _range)
{
	auto firstLine = next(begin(m_text), _range.from.line);
	auto lastLine = next(begin(m_text), _range.to.line);

	m_version++;

	if (firstLine == lastLine)
	{
		firstLine->erase(
			_range.from.column,
			_range.to.column - _range.from.column
		);
	}
	else
	{
		// erase first line fragment
		bool const firstLineFullyReplaced = _range.from.column == 0;
		if (!firstLineFullyReplaced)
			firstLine->erase(_range.from.column);
		else
			firstLine = m_text.erase(firstLine);

		// erase last line fragment
		bool const lastLineFullyReplaced = lastLine->size() == _range.to.column + 1;
		if (!lastLineFullyReplaced)
			lastLine->erase(0, _range.to.column);
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
	if (_range.from.line == _range.to.line)
	{
		auto firstLine = next(begin(m_text), _range.from.line);
		firstLine->replace(
			_range.from.column,
			_range.to.column - _range.from.column,
			_replacementText
		);
		m_version++;
	}
	else
	{
		erase(_range);

		auto firstLine = next(begin(m_text), _range.from.line);
		deque<string> lines = splitLines<deque>(_replacementText);

		// Insert first line
		firstLine->append(move(lines.front()));
		lines.pop_front();

		m_text.insert(next(firstLine), begin(lines), end(lines));
	}
}

File& VFS::insert(std::string _uri, File _contents)
{
	auto [iter, inserted] = m_files.emplace(pair{_uri, move(_contents)});
	if (!inserted)
		iter->second = move(_contents);

	return iter->second;
}

void VFS::remove(std::string const& _uri)
{
	if (auto i = m_files.find(_uri); i != end(m_files))
		m_files.erase(i);
}

} // end namespace
