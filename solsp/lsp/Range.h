#pragma once

namespace lsp {

/**
 * Position in a text document expressed as zero-based line and zero-based
 * character offset. A position is between two characters like an ‘insert’ cursor
 * in a editor. Special values like for example -1 to denote the end of a line
 * are not supported.
 */
struct Position
{
	unsigned line;    // zero-based index to the line
	unsigned column;  // zero-based index to the column
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
struct Range
{
	Position start;
	Position end;

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
	[[nodiscard]] constexpr LineNumIterator lineNumbers() const noexcept
	{
		return LineNumIterator{start.line, end.line + 1};
	}
};

} // namespace lsp
