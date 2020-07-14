********************************
Solidity v0.7.0 Breaking Changes
********************************

This section highlights the main breaking changes introduced in Solidity
version 0.7.0, along with the reasoning behind the changes and how to update
affected code.
For the full list check
`the release changelog <https://github.com/ethereum/solidity/releases/tag/v0.7.0>`_.


Changes the Compiler Might not Warn About
=========================================

 * Exponentiation and shifts of literals by non-literals (e.g. ``1 << x`` or ``2 ** x``)
   will always use either the type ``uint256`` (for non-negative literals) or
   ``int256`` (for negative literals) to perform the operation in.
   Previously, the operation was performed in the type of the shift amount / the
   exponent which we think is misleading.


Changes to the Syntax
=====================

 * In external function and contract creation calls, Ether and gas is now specified using a new syntax:
   ``x.f{gas: 10000, value: 2 ether}(arg1, arg2)``.
   The old syntax -- ``x.f.gas(10000).value(2 ether)(arg1, arg2)`` -- will cause an error.
 * The global variable ``now`` is deprecated, ``block.timestamp`` should be used.
   We think that ``now`` is too generic for a global variable and could given the impression
   that it changes during transaction processing. ``block.timestamp`` correctly
   reflects the fact that it is just a property of the block.
 * NatSpec comments on variables are only allowed for public state variables and not
   for local or internal variables.

 * The token ``gwei`` is a keyword now (used to specify e.g. ``2 gwei`` as a number)
   and cannot be used as an identifier.


Inline Assembly
---------------

 * Disallow ``.`` in user-defined function and variable names in inline assembly.
   It is still valid if you use Solidity in Yul-only mode.

 * Slot and offset of storage pointer variable ``x`` are accessed via ``x.slot``
   and ``x.offset`` instead of ``x_slot`` and ``x_offset``.

Removal of Unused on Unsafe Features
====================================

Mappings outside Storage
------------------------

 * If a struct or array contains a mapping, it can only be used in storage.
   Previously, mapping members were silently skipped in memory, which we think
   can cause confusion or bugs.

 * Assignments to structs or arrays in storage does not work if they contain
   mappings.
   Previously, mappings were silently skipped during the copy operation, which
   we think is misleading and can cause bugs.

Functions and Events
--------------------

 * Visibility (``public`` / ``external``) is not needed for constructors anymore:
   We removed this feature because visibility for constructors is very different from
   visibility for functions and for constructors it mostly matters whether the
   contract is abstract or not.

 * Type Checker: Disallow virtual for library functions:
   Since libraries cannot inherit, library functions should not be virtual.

 * Multiple events with the same name and parameter types in the same
   inheritance hierarchy are disallowed.

 * ``using A for B`` only affects the contract it is mentioned in.
   Previously, the effect was inherited, so you have to repeat the ``using``
   statement in all derived contracts that make use of the feature.

Expressions
-----------

 * Shifts by signed types are disallowed.
   Previous versions did a runtime check for shifts by negative amounts,
   but we thought that shifts by negative types are overall not very useful.

 * The ``finney`` and ``szabo`` denominations were removed.
   We think they are not really used and people usually do not know
   their values by heart. Is is better to use explicit values like ``1e20``
   or the very common ``gwei``.


Interface Changes
=================

 * JSON AST: Members with value ``null`` are removed from JSON output.
 * NatSpec: Constructors and functions have consistent userdoc output.


How to update your code
=======================

This section gives detailed instructions on how to update prior code for every breaking change.

* Change ``x.f.value(...)()`` to ``x.f{value: ...}()``. Similarly ``(new C).value(...)()`` to
  ``new C{value: ...}()`` and ``x.f.gas(...).value(...)()`` to ``x.f{gas: ..., value: ...}()``.
* Change ``now`` to ``block.timestamp``.
* Change types of right operand in shift operators to unsigned types. For example change ``x >> (256 - y)`` to
  ``x >> uint(256 - y)``.
* Repeat the ``using A for B`` statements in all derived contracts if needed.
* Remove the ``public`` keyword from every constructor.
* Remove the ``internal`` keyword from every constructor and add ``abstract`` to the contract (if not already present).
* Change ``_slot`` and ``_offset`` suffixes in inline assembly to ``.slot`` and ``.offset``, respectively.
