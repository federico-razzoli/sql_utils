# Test files for sql_utils

This file documents how tests for sql_utils must be written.

## Acceptance

All new features committed to master must be accompanied by reasonably complete tests.

Failing tests can be introduced to demonstrate a documented known bug that cannot
be fixed quickly. This is a step to make existing features more reliable. For new
features, normally this should not happen, because bugs should be fixed before being
committed. Exceptions can be made if bugs are not too risky, but cannot be fixed
quickly, and features add enough value to the library.

## File names

Each base code file must have a matching test file in the "test" directory,
with the "\_test" prefix followed by the name of the base code file.

## Test format

Tests must be separated by an empty line.

A test must begin with a comment that states which routine or view is being tested.

## Check results

A test can consist of multiple checks: results produced whose correctness is expected
to be checked at each test run.

Checks on 1 value can produce a single resultset. The first column, named "expect",
states which result the test must return to be considered successful. The second column,
named "result", is the result itself.

Checks on multiple values must return 2 resultsets. The first must have a single column
named expect. The second is the set of valued to be checked.

Expect strings for a single value must state an exact value, or a datatype, optionally
with size. Exact values, if they are strings, can optionally be anclosed between single
quotes to avoid ambiguities. Datatypes must be enclosed between "<" and ">" characters.
Size, if relevant, must be enclosed between "(" and ")", before ">". NULL must be written
as a datatype - otherwise, it means the string "NULL".

If the resultset must consist of multiple rows, the number of expected rows can be prefixed
to the expect string, followed by ":".

Examples for 1 value expectation string:

```
1
'1'
<bigint>
<bool>
<string>
<string(5)>
<NULL>
```

Examples for multiple row expectation strings:

```
<string(3)>,<int>,<NULL>
<int>,0
```

