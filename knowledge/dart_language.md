---
title: Asynchrony support
description: Information on writing asynchronous code in Dart.
short-title: Async
prevpage:
  url: /language/modifier-reference
  title: Class modifiers reference
nextpage:
  url: /language/concurrency
  title: Concurrency
---

<?code-excerpt replace="/ *\/\/\s+ignore_for_file:[^\n]+\n//g; /(^|\n) *\/\/\s+ignore:[^\n]+\n/$1/g; /(\n[^\n]+) *\/\/\s+ignore:[^\n]+\n/$1\n/g; / *\/\/\s+ignore:[^\n]+//g; /([A-Z]\w*)\d\b/$1/g"?>

Dart libraries are full of functions that
return [`Future`][] or [`Stream`][] objects.
These functions are _asynchronous_:
they return after setting up
a possibly time-consuming operation
(such as I/O),
without waiting for that operation to complete.

The `async` and `await` keywords support asynchronous programming,
letting you write asynchronous code that
looks similar to synchronous code.


## Handling Futures

When you need the result of a completed Future,
you have two options:

* Use `async` and `await`, as described here and in the
  [asynchronous programming codelab](/codelabs/async-await).
* Use the Future API, as described
  [in the library tour](/guides/libraries/library-tour#future).

Code that uses `async` and `await` is asynchronous,
but it looks a lot like synchronous code.
For example, here's some code that uses `await`
to wait for the result of an asynchronous function:

<?code-excerpt "misc/lib/language_tour/async.dart (await-lookUpVersion)"?>
```dart
await lookUpVersion();
```

To use `await`, code must be in an `async` function—a
function marked as `async`:

<?code-excerpt "misc/lib/language_tour/async.dart (checkVersion)" replace="/async|await/[!$&!]/g"?>
{% prettify dart tag=pre+code %}
Future<void> checkVersion() [!async!] {
  var version = [!await!] lookUpVersion();
  // Do something with version
}
{% endprettify %}

{{site.alert.note}}
  Although an `async` function might perform time-consuming operations, 
  it doesn't wait for those operations. 
  Instead, the `async` function executes only
  until it encounters its first `await` expression.
  Then it returns a `Future` object,
  resuming execution only after the `await` expression completes.
{{site.alert.end}}

Use `try`, `catch`, and `finally` to handle errors and cleanup
in code that uses `await`:

<?code-excerpt "misc/lib/language_tour/async.dart (try-catch)"?>
```dart
try {
  version = await lookUpVersion();
} catch (e) {
  // React to inability to look up the version
}
```

You can use `await` multiple times in an `async` function.
For example, the following code waits three times
for the results of functions:

<?code-excerpt "misc/lib/language_tour/async.dart (repeated-await)"?>
```dart
var entrypoint = await findEntryPoint();
var exitCode = await runExecutable(entrypoint, args);
await flushThenExit(exitCode);
```

In <code>await <em>expression</em></code>,
the value of <code><em>expression</em></code> is usually a Future;
if it isn't, then the value is automatically wrapped in a Future.
This Future object indicates a promise to return an object.
The value of <code>await <em>expression</em></code> is that returned object.
The await expression makes execution pause until that object is available.

**If you get a compile-time error when using `await`,
make sure `await` is in an `async` function.**
For example, to use `await` in your app's `main()` function,
the body of `main()` must be marked as `async`:

<?code-excerpt "misc/lib/language_tour/async.dart (main)" replace="/async|await/[!$&!]/g"?>
{% prettify dart tag=pre+code %}
void main() [!async!] {
  checkVersion();
  print('In main: version is ${[!await!] lookUpVersion()}');
}
{% endprettify %}

{{site.alert.note}}
  The preceding example uses an `async` function (`checkVersion()`)
  without waiting for a result—a practice that can cause problems
  if the code assumes that the function has finished executing.
  To avoid this problem,
  use the [unawaited_futures linter rule][].
{{site.alert.end}}

For an interactive introduction to using futures, `async`, and `await`,
see the [asynchronous programming codelab](/codelabs/async-await).


## Declaring async functions

An `async` function is a function whose body is marked with
the `async` modifier.

Adding the `async` keyword to a function makes it return a Future.
For example, consider this synchronous function,
which returns a String:

<?code-excerpt "misc/lib/language_tour/async.dart (sync-lookUpVersion)"?>
```dart
String lookUpVersion() => '1.0.0';
```

If you change it to be an `async` function—for example,
because a future implementation will be time consuming—the
returned value is a Future:

<?code-excerpt "misc/lib/language_tour/async.dart (async-lookUpVersion)"?>
```dart
Future<String> lookUpVersion() async => '1.0.0';
```

Note that the function's body doesn't need to use the Future API.
Dart creates the Future object if necessary.
If your function doesn't return a useful value,
make its return type `Future<void>`.

For an interactive introduction to using futures, `async`, and `await`,
see the [asynchronous programming codelab](/codelabs/async-await).

{% comment %}
TODO #1117: Where else should we cover generalized void?
{% endcomment %}


## Handling Streams

When you need to get values from a Stream,
you have two options:

* Use `async` and an _asynchronous for loop_ (`await for`).
* Use the Stream API, as described
  [in the library tour](/guides/libraries/library-tour#stream).

{{site.alert.note}}
  Before using `await for`, be sure that it makes the code clearer and that you
  really do want to wait for all of the stream's results. For example, you
  usually should **not** use `await for` for UI event listeners, because UI
  frameworks send endless streams of events.
{{site.alert.end}}

An asynchronous for loop has the following form:

<?code-excerpt "misc/lib/language_tour/async.dart (await-for)"?>
```dart
await for (varOrType identifier in expression) {
  // Executes each time the stream emits a value.
}
```

The value of <code><em>expression</em></code> must have type Stream.
Execution proceeds as follows:

1. Wait until the stream emits a value.
2. Execute the body of the for loop,
   with the variable set to that emitted value.
3. Repeat 1 and 2 until the stream is closed.

To stop listening to the stream,
you can use a `break` or `return` statement,
which breaks out of the for loop
and unsubscribes from the stream.

**If you get a compile-time error when implementing an asynchronous for loop,
make sure the `await for` is in an `async` function.**
For example, to use an asynchronous for loop in your app's `main()` function,
the body of `main()` must be marked as `async`:

<?code-excerpt "misc/lib/language_tour/async.dart (number_thinker)" replace="/async|await for/[!$&!]/g"?>
{% prettify dart tag=pre+code %}
void main() [!async!] {
  // ...
  [!await for!] (final request in requestServer) {
    handleRequest(request);
  }
  // ...
}
{% endprettify %}

For more information about asynchronous programming, in general, see the
[dart:async](/guides/libraries/library-tour#dartasync---asynchronous-programming)
section of the library tour.

[`Future`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-async/Future-class.html
[`Stream`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-async/Stream-class.html
[unawaited_futures linter rule]: /tools/linter-rules/unawaited_futures


---
title: Branches 
description: Learn how to use branches to control the flow of your Dart code.
prevpage:
  url: /language/loops
  title: Loops
nextpage:
  url: /language/error-handling
  title: Error handling
---

This page shows how you can control the flow of your Dart code using branches:

- `if` statements and elements
- `if-case` statements and elements
- `switch` statements and expressions

You can also manipulate control flow in Dart using:

- [Loops][], like `for` and `while`
- [Exceptions][], like `try`, `catch`, and `throw`

## If

Dart supports `if` statements with optional `else` clauses.
The condition in parentheses after `if` must be
an expression that evaluates to a [boolean][]:

<?code-excerpt "language/lib/control_flow/branches.dart (if-else)"?>
```dart
if (isRaining()) {
  you.bringRainCoat();
} else if (isSnowing()) {
  you.wearJacket();
} else {
  car.putTopDown();
}
```

To learn how to use `if` in an expression context, 
check out [Conditional expressions][].

### If-case

Dart `if` statements support `case` clauses followed by a [pattern][]: 

<?code-excerpt "language/lib/control_flow/branches.dart (if-case)"?>
```dart
if (pair case [int x, int y]) return Point(x, y);
```

If the pattern matches the value,
then the branch executes with any variables the pattern defines in scope.

In the previous example,
the list pattern `[int x, int y]` matches the value `pair`,
so the branch `return Point(x, y)` executes with the variables that
the pattern defined, `x` and `y`.

Otherwise, control flow progresses to the `else` branch
to execute, if there is one:

<?code-excerpt "language/lib/control_flow/branches.dart (if-case-else)"?>
```dart 
if (pair case [int x, int y]) {
  print('Was coordinate array $x,$y');
} else {
  throw FormatException('Invalid coordinates.');
}
```

The if-case statement provides a way to match and
[destructure][] against a _single_ pattern. 
To test a value against _multiple_ patterns, use [switch](#switch).

{{site.alert.version-note}}
  Case clauses in if statements require
  a [language version][] of at least 3.0.
{{site.alert.end}}

<a id="switch"></a>
## Switch statements

A `switch` statement evaluates a value expression against a series of cases.
Each `case` clause is a [pattern][] for the value to match against.
You can use [any kind of pattern][] for a case.

When the value matches a case's pattern, the case body executes. 
Non-empty `case` clauses jump to the end of the switch after completion.
They do not require a `break` statement.
Other valid ways to end a non-empty `case` clause are a
[`continue`][break], [`throw`][], or [`return`][] statement.

Use a `default` or [wildcard `_`][] clause to
execute code when no `case` clause matches:

<?code-excerpt "language/lib/control_flow/branches.dart (switch)"?>
```dart
var command = 'OPEN';
switch (command) {
  case 'CLOSED':
    executeClosed();
  case 'PENDING':
    executePending();
  case 'APPROVED':
    executeApproved();
  case 'DENIED':
    executeDenied();
  case 'OPEN':
    executeOpen();
  default:
    executeUnknown();
}
```

<a id="switch-share"></a>

Empty cases fall through to the next case, allowing cases to share a body. 
For an empty case that does not fall through,
use [`break`][break] for its body.
For non-sequential fall-through,
you can use a [`continue` statement][break] and a label:

<?code-excerpt "language/lib/control_flow/branches.dart (switch-empty)"?>
```dart
switch (command) {
  case 'OPEN':
    executeOpen();
    continue newCase; // Continues executing at the newCase label.

  case 'DENIED': // Empty case falls through.
  case 'CLOSED':
    executeClosed(); // Runs for both DENIED and CLOSED,

  newCase:
  case 'PENDING':
    executeNowClosed(); // Runs for both OPEN and PENDING.
}
```

You can use [logical-or patterns][] to allow cases to share a body or a guard.
To learn more about patterns and case clauses, 
check out the patterns documentation on [Switch statements and expressions][].

[Switch statements and expressions]: /language/patterns#switch-statements-and-expressions

### Switch expressions

A `switch` _expression_ produces a value based on the expression
body of whichever case matches. 
You can use a switch expression wherever Dart allows expressions,
_except_ at the start of an expression statement. For example:

```dart
var x = switch (y) { ... };

print(switch (x) { ... });

return switch (x) { ... };
```

If you want to use a switch at the start of an expression statement,
use a [switch statement](#switch-statements).

Switch expressions allow you to rewrite a switch _statement_ like this:

<?code-excerpt "language/lib/control_flow/branches.dart (switch-stmt)"?>
```dart
// Where slash, star, comma, semicolon, etc., are constant variables...
switch (charCode) {
  case slash || star || plus || minus: // Logical-or pattern
    token = operator(charCode);
  case comma || semicolon: // Logical-or pattern
    token = punctuation(charCode);
  case >= digit0 && <= digit9: // Relational and logical-and patterns
    token = number();
  default:
    throw FormatException('Invalid');
}
```

Into an _expression_, like this:

<?code-excerpt "language/lib/control_flow/branches.dart (switch-exp)"?>
```dart
token = switch (charCode) {
  slash || star || plus || minus => operator(charCode),
  comma || semicolon => punctuation(charCode),
  >= digit0 && <= digit9 => number(),
  _ => throw FormatException('Invalid')
};
```

The syntax of a `switch` expression differs from `switch` statement syntax:

- Cases _do not_ start with the `case` keyword.
- A case body is a single expression instead of a series of statements.
- Each case must have a body; there is no implicit fallthrough for empty cases.
- Case patterns are separated from their bodies using `=>` instead of `:`.
- Cases are separated by `,` (and an optional trailing `,` is allowed).
- Default cases can _only_ use `_`, instead of allowing both `default` and `_`.

{{site.alert.version-note}}
  Switch expressions require a [language version][] of at least 3.0.
{{site.alert.end}}

### Exhaustiveness checking

Exhaustiveness checking is a feature that reports a
compile-time error if it's possible for a value to enter a switch but
not match any of the cases.

<?code-excerpt "language/lib/control_flow/branches.dart (exh-bool)"?>
```dart
// Non-exhaustive switch on bool?, missing case to match null possibility:
switch (nullableBool) {
  case true:
    print('yes');
  case false:
    print('no');
}
```

A default case (`default` or `_`) covers all possible values that
can flow through a switch.
This makes a switch on any type exhaustive.

[Enums][enum] and [sealed types][sealed] are particularly useful for
switches because, even without a default case, 
their possible values are known and fully enumerable. 
Use the [`sealed` modifier][sealed] on a class to enable
exhaustiveness checking when switching over subtypes of that class:

<?code-excerpt "language/lib/patterns/algebraic_datatypes.dart (algebraic_datatypes)"?>
```dart
sealed class Shape {}

class Square implements Shape {
  final double length;
  Square(this.length);
}

class Circle implements Shape {
  final double radius;
  Circle(this.radius);
}

double calculateArea(Shape shape) => switch (shape) {
      Square(length: var l) => l * l,
      Circle(radius: var r) => math.pi * r * r
    };
```

If anyone were to add a new subclass of `Shape`, 
this `switch` expression would be incomplete. 
Exhaustiveness checking would inform you of the missing subtype.
This allows you to use Dart in a somewhat 
[functional algebraic datatype style](https://en.wikipedia.org/wiki/Algebraic_data_type). 

<a id="when"></a>
## Guard clause

To set an optional guard clause after a `case` clause, use the keyword `when`.
A guard clause can follow `if case`, and
both `switch` statements and expressions.

```dart
// Switch statement:
switch (something) {
  case somePattern when some || boolean || expression:
    //             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Guard clause.
    body;
}

// Switch expression:
var value = switch (something) {
  somePattern when some || boolean || expression => body,
  //               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Guard clause.
}

// If-case statement:
if (something case somePattern when some || boolean || expression) {
  //                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Guard clause.
  body;
}
```

Guards evaluate an arbitrary boolean expression _after_ matching.
This allows you to add further constraints on
whether a case body should execute.
When the guard clause evaluates to false, 
execution proceeds to the next case rather
than exiting the entire switch.

[language version]: /guides/language/evolution#language-versioning
[loops]: /language/loops
[exceptions]: /language/error-handling
[conditional expressions]: /language/operators#conditional-expressions
[boolean]: /language/built-in-types#booleans
[pattern]: /language/patterns
[enum]: /language/enums
[`throw`]: /language/error-handling#throw
[`return`]: /language/functions#return-values
[wildcard `_`]: /language/pattern-types#wildcard
[break]: /language/loops#break-and-continue
[sealed]: /language/class-modifiers#sealed
[any kind of pattern]: /language/pattern-types
[destructure]: /language/patterns#destructuring
[section on switch]: /language/patterns#switch-statements-and-expressions
[logical-or patterns]: /language/patterns#or-pattern-switch


---
title: Built-in types
description: Information on the types Dart supports.
prevpage:
  url: /language/keywords
  title: Keywords
nextpage:
  url: /language/records
  title: Records
---

The Dart language has special support for the following:

- [Numbers](#numbers) (`int`, `double`)
- [Strings](#strings) (`String`)
- [Booleans](#booleans) (`bool`)
- [Records][] (`(value1, value2)`)
- [Lists][] (`List`, also known as *arrays*)
- [Sets][] (`Set`)
- [Maps][] (`Map`)
- [Runes](#runes-and-grapheme-clusters) (`Runes`; often replaced by the `characters` API)
- [Symbols](#symbols) (`Symbol`)
- The value `null` (`Null`)

This support includes the ability to create objects using literals.
For example, `'this is a string'` is a string literal,
and `true` is a boolean literal.

Because every variable in Dart refers to an object—an instance of a
*class*—you can usually use *constructors* to initialize variables. Some
of the built-in types have their own constructors. For example, you can
use the `Map()` constructor to create a map.

Some other types also have special roles in the Dart language:

* `Object`: The superclass of all Dart classes except `Null`.
* `Enum`: The superclass of all enums.
* `Future` and `Stream`: Used in [asynchrony support][].
* `Iterable`: Used in [for-in loops][iteration] and
  in synchronous [generator functions][].
* `Never`: Indicates that an expression can never
  successfully finish evaluating.
  Most often used for functions that always throw an exception.
* `dynamic`: Indicates that you want to disable static checking.
  Usually you should use `Object` or `Object?` instead.
* `void`: Indicates that a value is never used.
  Often used as a return type.

The `Object`, `Object?`, `Null`, and `Never` classes
have special roles in the class hierarchy.
Learn about these roles in [Understanding null safety][].

{% comment %}
If we decide to cover `dynamic` more,
here's a nice example that illustrates what dynamic does:
  dynamic a = 2;
  String b = a; // No problem! Until runtime, when you get an uncaught error.

  Object c = 2;
  String d = c;  // Problem!
{% endcomment %}


## Numbers

Dart numbers come in two flavors:

[`int`][]

:   Integer values no larger than 64 bits,
    [depending on the platform][dart-numbers].
    On native platforms, values can be from
    -2<sup>63</sup> to 2<sup>63</sup> - 1.
    On the web, integer values are represented as JavaScript numbers
    (64-bit floating-point values with no fractional part)
    and can be from -2<sup>53</sup> to 2<sup>53</sup> - 1.

[`double`][]

:   64-bit (double-precision) floating-point numbers, as specified by
    the IEEE 754 standard.

Both `int` and `double` are subtypes of [`num`][].
The num type includes basic operators such as +, -, /, and \*,
and is also where you'll find `abs()`,` ceil()`,
and `floor()`, among other methods.
(Bitwise operators, such as \>\>, are defined in the `int` class.)
If num and its subtypes don't have what you're looking for, the
[dart:math][] library might.

Integers are numbers without a decimal point. Here are some examples of
defining integer literals:

<?code-excerpt "misc/lib/language_tour/built_in_types.dart (integer-literals)"?>
```dart
var x = 1;
var hex = 0xDEADBEEF;
```

If a number includes a decimal, it is a double. Here are some examples
of defining double literals:

<?code-excerpt "misc/lib/language_tour/built_in_types.dart (double-literals)"?>
```dart
var y = 1.1;
var exponents = 1.42e5;
```

You can also declare a variable as a num. If you do this, the variable
can have both integer and double values.

<?code-excerpt "misc/lib/language_tour/built_in_types.dart (declare-num)"?>
```dart
num x = 1; // x can have both int and double values
x += 2.5;
```

Integer literals are automatically converted to doubles when necessary:

<?code-excerpt "misc/lib/language_tour/built_in_types.dart (int-to-double)"?>
```dart
double z = 1; // Equivalent to double z = 1.0.
```

Here's how you turn a string into a number, or vice versa:

<?code-excerpt "misc/test/language_tour/built_in_types_test.dart (number-conversion)"?>
```dart
// String -> int
var one = int.parse('1');
assert(one == 1);

// String -> double
var onePointOne = double.parse('1.1');
assert(onePointOne == 1.1);

// int -> String
String oneAsString = 1.toString();
assert(oneAsString == '1');

// double -> String
String piAsString = 3.14159.toStringAsFixed(2);
assert(piAsString == '3.14');
```

The `int` type specifies the traditional bitwise shift (`<<`, `>>`, `>>>`),
complement (`~`), AND (`&`), OR (`|`), and XOR (`^`) operators,
which are useful for manipulating and masking flags in bit fields.
For example:

<?code-excerpt "misc/test/language_tour/built_in_types_test.dart (bit-shifting)"?>
```dart
assert((3 << 1) == 6); // 0011 << 1 == 0110
assert((3 | 4) == 7); // 0011 | 0100 == 0111
assert((3 & 4) == 0); // 0011 & 0100 == 0000
```

For more examples, see the
[bitwise and shift operator][] section.

Literal numbers are compile-time constants.
Many arithmetic expressions are also compile-time constants,
as long as their operands are
compile-time constants that evaluate to numbers.

<?code-excerpt "misc/lib/language_tour/built_in_types.dart (const-num)"?>
```dart
const msPerSecond = 1000;
const secondsUntilRetry = 5;
const msUntilRetry = secondsUntilRetry * msPerSecond;
```

For more information, see [Numbers in Dart][dart-numbers].


## Strings

A Dart string (`String` object) holds a sequence of UTF-16 code units.
You can use either
single or double quotes to create a string:

<?code-excerpt "misc/lib/language_tour/built_in_types.dart (quoting)"?>
```dart
var s1 = 'Single quotes work well for string literals.';
var s2 = "Double quotes work just as well.";
var s3 = 'It\'s easy to escape the string delimiter.';
var s4 = "It's even easier to use the other delimiter.";
```

You can put the value of an expression inside a string by using
`${`*`expression`*`}`. If the expression is an identifier, you can skip
the {}. To get the string corresponding to an object, Dart calls the
object's `toString()` method.

<?code-excerpt "misc/test/language_tour/built_in_types_test.dart (string-interpolation)"?>
```dart
var s = 'string interpolation';

assert('Dart has $s, which is very handy.' ==
    'Dart has string interpolation, '
        'which is very handy.');
assert('That deserves all caps. '
        '${s.toUpperCase()} is very handy!' ==
    'That deserves all caps. '
        'STRING INTERPOLATION is very handy!');
```

{{site.alert.note}}
  The `==` operator tests whether two objects are equivalent. Two
  strings are equivalent if they contain the same sequence of code
  units.
{{site.alert.end}}

You can concatenate strings using adjacent string literals or the `+`
operator:

<?code-excerpt "misc/test/language_tour/built_in_types_test.dart (adjacent-string-literals)"?>
```dart
var s1 = 'String '
    'concatenation'
    " works even over line breaks.";
assert(s1 ==
    'String concatenation works even over '
        'line breaks.');

var s2 = 'The + operator ' + 'works, as well.';
assert(s2 == 'The + operator works, as well.');
```

To create a multi-line string, use a triple quote with
either single or double quotation marks:

<?code-excerpt "misc/lib/language_tour/built_in_types.dart (triple-quotes)"?>
```dart
var s1 = '''
You can create
multi-line strings like this one.
''';

var s2 = """This is also a
multi-line string.""";
```

You can create a "raw" string by prefixing it with `r`:

<?code-excerpt "misc/lib/language_tour/built_in_types.dart (raw-strings)"?>
```dart
var s = r'In a raw string, not even \n gets special treatment.';
```

See [Runes and grapheme clusters](#runes-and-grapheme-clusters) for details on how
to express Unicode characters in a string.

Literal strings are compile-time constants,
as long as any interpolated expression is a compile-time constant
that evaluates to null or a numeric, string, or boolean value.

<?code-excerpt "misc/lib/language_tour/built_in_types.dart (string-literals)"?>
```dart
// These work in a const string.
const aConstNum = 0;
const aConstBool = true;
const aConstString = 'a constant string';

// These do NOT work in a const string.
var aNum = 0;
var aBool = true;
var aString = 'a string';
const aConstList = [1, 2, 3];

const validConstString = '$aConstNum $aConstBool $aConstString';
// const invalidConstString = '$aNum $aBool $aString $aConstList';
```

For more information on using strings, check out
[Strings and regular expressions](/guides/libraries/library-tour#strings-and-regular-expressions).


## Booleans

To represent boolean values, Dart has a type named `bool`. Only two
objects have type bool: the boolean literals `true` and `false`,
which are both compile-time constants.

Dart's type safety means that you can't use code like
<code>if (<em>nonbooleanValue</em>)</code> or
<code>assert (<em>nonbooleanValue</em>)</code>.
Instead, explicitly check for values, like this:

<?code-excerpt "misc/test/language_tour/built_in_types_test.dart (no-truthy)"?>
```dart
// Check for an empty string.
var fullName = '';
assert(fullName.isEmpty);

// Check for zero.
var hitPoints = 0;
assert(hitPoints <= 0);

// Check for null.
var unicorn = null;
assert(unicorn == null);

// Check for NaN.
var iMeantToDoThis = 0 / 0;
assert(iMeantToDoThis.isNaN);
```

## Runes and grapheme clusters

In Dart, [runes][] expose the Unicode code points of a string.
You can use the [characters package][]
to view or manipulate user-perceived characters,
also known as
[Unicode (extended) grapheme clusters.][grapheme clusters]

Unicode defines a unique numeric value for each letter, digit,
and symbol used in all of the world's writing systems.
Because a Dart string is a sequence of UTF-16 code units,
expressing Unicode code points within a string requires
special syntax.
The usual way to express a Unicode code point is
`\uXXXX`, where XXXX is a 4-digit hexadecimal value.
For example, the heart character (♥) is `\u2665`.
To specify more or less than 4 hex digits,
place the value in curly brackets.
For example, the laughing emoji (😆) is `\u{1f606}`.

If you need to read or write individual Unicode characters,
use the `characters` getter defined on String
by the characters package.
The returned [`Characters`][] object is the string as
a sequence of grapheme clusters.
Here's an example of using the characters API:

<?code-excerpt "misc/lib/language_tour/characters.dart"?>
```dart
import 'package:characters/characters.dart';

void main() {
  var hi = 'Hi 🇩🇰';
  print(hi);
  print('The end of the string: ${hi.substring(hi.length - 1)}');
  print('The last character: ${hi.characters.last}');
}
```

The output, depending on your environment, looks something like this:

```terminal
$ dart run bin/main.dart
Hi 🇩🇰
The end of the string: ???
The last character: 🇩🇰
```

For details on using the characters package to manipulate strings,
see the [example][characters example] and [API reference][characters API]
for the characters package.

## Symbols

A [`Symbol`][] object
represents an operator or identifier declared in a Dart program. You
might never need to use symbols, but they're invaluable for APIs that
refer to identifiers by name, because minification changes identifier
names but not identifier symbols.

To get the symbol for an identifier, use a symbol literal, which is just
`#` followed by the identifier:

```nocode
#radix
#bar
```

{% comment %}
The code from the following excerpt isn't actually what is being shown in the page

<?code-excerpt "misc/lib/language_tour/built_in_types.dart (symbols)"?>
```dart
void main() {
  print(Function.apply(int.parse, ['11']));
  print(Function.apply(int.parse, ['11'], {#radix: 16}));
}
```
{% endcomment %}

Symbol literals are compile-time constants.



[Records]: /language/records
[Lists]: /language/collections#lists
[Sets]: /language/collections#sets
[Maps]: /language/collections#maps
[asynchrony support]: /language/async
[iteration]: /guides/libraries/library-tour#iteration
[generator functions]: /language/functions#generators
[Understanding null safety]: /null-safety/understanding-null-safety#top-and-bottom
[`int`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-core/int-class.html
[`double`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-core/double-class.html
[`num`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-core/num-class.html
[dart:math]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-math
[bitwise and shift operator]: /language/operators#bitwise-and-shift-operators
[dart-numbers]: /guides/language/numbers
[runes]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-core/Runes-class.html
[characters package]: {{site.pub-pkg}}/characters
[grapheme clusters]: https://unicode.org/reports/tr29/#Grapheme_Cluster_Boundaries
[`Characters`]: {{site.pub-api}}/characters/latest/characters/Characters-class.html
[characters API]: {{site.pub-api}}/characters
[characters example]: {{site.pub-pkg}}/characters/example
[`Symbol`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-core/Symbol-class.html


---
title: Callable objects
description: Learn how to create and use callable objects in Dart.
js: [{url: 'https://dartpad.dev/inject_embed.dart.js', defer: true}]
toc: false
prevpage:
  url: /language/extension-methods
  title: Extension methods
nextpage:
  url: /language/class-modifiers
  title: Class modifiers
---

To allow an instance of your Dart class to be called like a function,
implement the `call()` method.

The `call()` method allows an instance of any class that defines it to emulate a function.
This method supports the same functionality as normal [functions][]
such as parameters and return types.

In the following example, the `WannabeFunction` class defines a `call()` function
that takes three strings and concatenates them, separating each with a space,
and appending an exclamation. Click **Run** to execute the code.

<?code-excerpt "misc/lib/language_tour/callable_objects.dart"?>
```dart:run-dartpad:height-350px:ga_id-callable_objects
class WannabeFunction {
  String call(String a, String b, String c) => '$a $b $c!';
}

var wf = WannabeFunction();
var out = wf('Hi', 'there,', 'gang');

void main() => print(out);
```

[functions]: /language/functions


---
title: Class modifiers for API maintainers
description: >-
 How to use the class modifiers added in Dart 3.0
 to make your package's API more robust and maintainable.
prevpage:
  url: /language/class-modifiers
  title: Class modifiers
nextpage:
  url: /language/modifier-reference
  title: Class modifiers reference
---

Dart 3.0 adds a few [new modifiers][class modifiers]
that you can place on class and [mixin declarations][mixin].
If you are the author of a library package,
these modifiers give you more control over what users are allowed to do
with the types that your package exports.
This can make it easier to evolve your package,
and easier to know if a change to your code may break users.

[class modifiers]: /language/class-modifiers
[mixin]: /language/mixins

Dart 3.0 also includes a [breaking change](/resources/dart-3-migration#mixin)
around using classes as mixins.
This change might not break *your* class,
but it could break *users* of your class.

This guide walks you through these changes
so you know how to use the new modifiers,
and how they affect users of your libraries.

## The `mixin` modifier on classes

The most important modifier to be aware of is `mixin`.
Language versions prior to Dart 3.0 allow any class to be used as a mixin
in another class's `with` clause, _UNLESS_ the class:

*   Declares any non-factory constructors.
*   Extends any class other than `Object`.

This makes it easy to accidentally break someone else's code,
by adding a constructor or `extends` clause to a class
without realizing that others are using it in a `with` clause.

Dart 3.0 no longer allows classes to be used as mixins by default.
Instead, you must explicitly opt-in to that behavior by declaring a `mixin class`:

```dart
mixin class Both {}

class UseAsMixin with Both {}
class UseAsSuperclass extends Both {}
```

If you update your package to Dart 3.0 and don't change any of your code,
you may not see any errors.
But you may inadvertently break users of your package
if they were using your classes as mixins.

### Migrating classes as mixins

If the class has a non-factory constructor, an `extends` clause,
or a `with` clause, then it already can't be used as a mixin.
Behavior won't change with Dart 3.0; 
there's nothing to worry about and nothing you need to do.

In practice, this describes about 90% of existing classes.
For the remaining classes that can be used as mixins,
you have to decide what you want to support.

Here are a few questions to help decide. The first is pragmatic:

*   **Do you want to risk breaking any users?** If the answer is a hard "no",
    then place `mixin` before any and all classes that
    [could be used as a mixin](#the-mixin-modifier-on-classes).
    This exactly preserves the existing behavior of your API.

On the other hand, if you want to take this opportunity to rethink the
affordances your API offers, then you may want to *not* turn it into a `mixin
class`. Consider these two design questions:

*   **Do you want users to be able to construct instances of it directly?**
    In other words, is the class deliberately not abstract?

*   **Do you *want* people to be able to use the declaration as a mixin?**
    In other words, do you want them to be able to use it in `with` clauses?

If the answer to both is "yes", then make it a mixin class. If the answer to
the second is "no", then just leave it as a class. If the answer to the first
is "no" and the second is "yes", then change it from a class to a mixin
declaration.

The last two options, leaving it a class or turning it into a pure mixin,
are breaking API changes. You'll want to bump the major version of your package
if you do this.

## Other opt-in modifiers

Handling classes as mixins is the only critical change in Dart 3.0
that affects the API of your package. Once you've gotten this far,
you can stop if you don't want to make other changes
to what your package allows users to do.

Note that if you do continue and use any of the modifiers described below,
it is potentially a breaking change to your package's API which necessitates
a major version increment.

## The `interface` modifier

Dart doesn't have a separate syntax for declaring pure interfaces.
Instead, you declare an abstract class that happens to contain only
abstract methods.
When a user sees that class in your package's API,
they may not know if it contains code they can reuse by extending the class,
or whether it is instead meant to be used as an interface.

You can clarify that by putting the [`interface`](/language/class-modifiers#interface)
modifier on the class.
That allows the class to be used in an `implements` clause,
but prevents it from being used in `extends`.

Even when the class *does* have non-abstract methods, you may want to prevent
users from extending it.
Inheritance is one of the most powerful kinds of coupling in software,
because it enables code reuse.
But that coupling is also [dangerous and fragile][].
When inheritance crosses package boundaries,
it can be hard to evolve the superclass without breaking subclasses.

[dangerous and fragile]: https://en.wikipedia.org/wiki/Fragile_base_class

Marking the class `interface` lets users construct it (unless it's [also marked
`abstract`](/language/class-modifiers#abstract-interface))
and implement the class's interface,
but prevents them from reusing any of its code.

When a class is marked `interface`, the restriction can be ignored within
the library where the class is declared.
Inside the library, you're free to extend it since it's all your code
and presumably you know what you're doing.
The restriction applies to other packages,
and even other libraries within your own package.

## The `base` modifier

The [`base`](/language/class-modifiers#base)
modifier is somewhat the opposite of `interface`.
It allows you to use the class in an `extends` clause,
or use a mixin or mixin class in a `with` clause.
But, it disallows code outside of the class's library
from using the class or mixin in an `implements` clause.

This ensures that every object that is an instance
of your class or mixin's interface inherits your actual implementation.
In particular, this means that every instance will include
all of the private members your class or mixin declares.
This can help prevent runtime errors that might otherwise occur.

Consider this library:

```dart
// a.dart
class A {
  void _privateMethod() {
    print('I inherited from A');
  }
}

void callPrivateMethod(A a) {
  a._privateMethod();
}
```

This code seems fine on its own,
but there's nothing preventing a user from creating another library like this:

```dart
// b.dart
import 'a.dart';

class B implements A {
  // No implementation of _privateMethod()!
}

main() {
  callPrivateMethod(B()); // Runtime exception!
}
```

Adding the `base` modifier to the class can help prevent these runtime errors.
As with `interface`, you can ignore this restriction
in the same library where the `base` class or mixin is declared.
Then subclasses in the same library
will be reminded to implement the private methods.
But note that the next section *does* apply:

### Base transitivity

The goal of marking a class `base` is to ensure that
every instance of that type concretely inherits from it.
To maintain this, the base restriction is "contagious".
Every subtype of a type marked `base` -- *direct or indirect* --
must also prevent being implemented.
That means it must be marked `base`
(or `final` or `sealed`, which we'll get to next).

Applying `base` to a type requires some care, then.
It affects not just what users can do with your class or mixin,
but also the affordances *their* subclasses can offer.
Once you've put `base` on a type, the whole hierarchy under it
is prohibited from being implemented.

That sounds intense, but it's how most other programming languages
have always worked.
Most don't have implicit interfaces at all,
so when you declare a class in Java, C#, or other languages,
you effectively have the same constraint.

## The `final` modifier

If you want all of the restrictions of both `interface` and `base`,
you can mark a class or mixin class [`final`](/language/class-modifiers#final).
This prevents anyone outside of your library from creating
any kind of subtype of it:
no using it in `implements`, `extends`, `with`, or `on` clauses.

This is the most restrictive for users of the class.
All they can do is construct it (unless it's marked `abstract`).
In return, you have the fewest restrictions as the class maintainer.
You can add new methods, turn constructors into factory constructors, etc.
without worrying about breaking any downstream users.

## The `sealed` modifer

The last modifier, [`sealed`](/language/class-modifiers#sealed), is special.
It exists primarily to enable [exhaustiveness checking][] in pattern matching.
If a switch has cases for every direct subtype of a type marked `sealed`,
then the compiler knows the switch is exhaustive.

[exhaustiveness checking]: /language/branches#exhaustiveness-checking

```dart
// amigos.dart
sealed class Amigo {}
class Lucky extends Amigo {}
class Dusty extends Amigo {}
class Ned extends Amigo {}

String lastName(Amigo amigo) =>
    switch (amigo) {
      case Lucky _ => 'Day';
      case Dusty _ => 'Bottoms';
      case Ned _   => 'Nederlander';
    }
```

This switch has a case for each of the subtypes of `Amigo`.
The compiler knows that every instance of `Amigo` must be an instance of one
of those subtypes, so it knows the switch is safely exhaustive and doesn't
require any final default case.

For this to be sound, the compiler enforces two restrictions:

1.  The sealed class can't itself be directly constructible.
    Otherwise, you could have an instance of `Amigo` that isn't
    an instance of *any* of the subtypes.
    So every `sealed` class is implicitly `abstract` too.

2.  Every direct subtype of the sealed type must be in the same library
    where the sealed type is declared.
    This way, the compiler can find them all. It knows that there aren't
    other hidden subtypes floating around that would not match any of the cases.

The second restriction is similar to `final`.
Like `final`, it means that a class marked `sealed` can't be directly
extended, implemented, or mixed in outside of the library where it's declared.
But, unlike `base` and `final`, there is no *transitive* restriction:

```dart
// amigo.dart
sealed class Amigo {}
class Lucky extends Amigo {}
class Dusty extends Amigo {}
class Ned extends Amigo {}

// other.dart

// This is an error:
class Bad extends Amigo {}

// But these are both fine:
class OtherLucky extends Lucky {}
class OtherDusty implements Dusty {}
```

Of course, if you *want* the subtypes of your sealed type
to be restricted as well, you can get that by marking them
using `interface`, `base`, `final`, or `sealed`.

### `sealed` versus `final`

If you have a class that you don't want users to be able to directly subtype,
when should you use `sealed` versus `final`?
A couple of simple rules:

*   If you want users to be able to directly construct instances of the class,
    then it *can't* use `sealed` since sealed types are implicitly abstract.

*   If the class has no subtypes in your library, then there's no point in using
    `sealed` since you get no exhaustiveness checking benefits.

Otherwise, if the class does have some subtypes that you define,
then `sealed` is likely what you want.
If users see that the class has a few subtypes, it's handy to be able
to handle each of them separately as switch cases
and have the compiler know that the entire type is covered.

Using `sealed` does mean that if you later add another subtype to the library,
it's a breaking API change.
When a new subtype appears,
all of those existing switches become non-exhaustive
since they don't handle the new type.
It's exactly like adding a new value to an enum.

Those non-exhaustive switch compile errors are *useful* to users
because they draw the user's attention to places in their code
where they'll need to handle the new type.

But it does mean that whenever you add a new subtype, it's a breaking change.
If you want the freedom to add new subtypes in a non-breaking way,
then it's better to mark the supertype using `final` instead of `sealed`.
That means that when a user switches on a value of that supertype,
even if they have cases for all of the subtypes,
the compiler will force them to add another default case.
That default case will then be what is executed if you add more subtypes later.

## Summary

As an API designer,
these new modifiers give you control over how users work with your code,
and conversely how you are able to evolve your code without breaking theirs.

But these options carry complexity with them:
you now have more choices to make as an API designer.
Also, since these features are new,
we still don't know what the best practices will be.
Every language's ecosystem is different and has different needs.

Fortunately, you don't need to figure it out all at once.
We chose the defaults deliberately so that even if you do nothing,
your classes mostly have the same affordances they had before 3.0.
If you just want to keep your API the way it was,
put `mixin` on the classes that already supported that, and you're done.

Over time, as you get a sense of where you want finer control,
you can consider applying some of the other modifiers:

*   Use `interface` to prevent users from reusing your class's code
    while allowing them to re-implement its interface.

*   Use `base` to require users to reuse your class's code
    and ensure every instance of your class's type is an instance
    of that actual class or a subclass.

*   Use `final` to completely prevent a class from being extended.

*   Use `sealed` to opt in to exhaustiveness checking on a family of subtypes.

When you do, increment the major version when publishing your package,
since these modifiers all imply restrictions that are breaking changes.


---
title: Class modifiers
description: >-
  Modifier keywords for class declarations to control external library access.
prevpage:
  url: /language/callable-objects
  title: Callable objects
nextpage:
  url: /language/class-modifiers-for-apis
  title: Class modifiers for API maintainers
---

<?code-excerpt replace="/ *\/\/\s+ignore_for_file:[^\n]+\n//g; /(^|\n) *\/\/\s+ignore: (stable|beta|dev)[^\n]+\n/$1/g; /(\n[^\n]+) *\/\/\s+ignore: (stable|beta|dev)[^\n]+\n/$1\n/g; /. • (lib|test)\/\w+\.dart:\d+:\d+//g"?>

{{site.alert.version-note}}
  Class modifiers, besides `abstract`, require
  a [language version][] of at least 3.0.
{{site.alert.end}}

Class modifiers control how a class or mixin can be used, both
[from within its own library](#abstract), and from outside of the library where
it's defined.

Modifier keywords come before a class or mixin declaration.
For example, writing `abstract class` defines an abstract class.
The full set of modifiers that can appear before a class declaration include:

- `abstract`
- `base`
- `final`
- `interface`
- `sealed`
- [`mixin`][class, mixin, or mixin class]

Only the `base` modifier can appear before a mixin declaration. The modifiers do
not apply to other declarations like `enum`, `typedef`, or `extension`.

When deciding whether to use class modifiers, consider the intended uses of the
class, and what behaviors the class needs to be able to rely on.

{{site.alert.note}}
  If you maintain a library, read the
  [Class modifiers for API maintainers](/language/class-modifiers-for-apis)
  page for guidance on how to navigate these changes for your libraries. 
{{site.alert.end}}

## No modifier

To allow unrestricted permission to construct or subtype from any library,
use a `class` or `mixin` declaration without a modifier. By default, you can:

- [Construct][] new instances of a class.
- [Extend][] a class to create a new subtype.
- [Implement][] a class or mixin's interface.
- [Mix in][mixin] a mixin or mixin class.

## `abstract`

To define a class that doesn't require a full, concrete implementation of its
entire interface, use the `abstract` modifier.

Abstract classes cannot be constructed from any library, whether its own or
an outside library. Abstract classes often have [abstract methods][].

<?code-excerpt "language/lib/class_modifiers/ex1/a.dart"?>
```dart
// Library a.dart
abstract class Vehicle {
  void moveForward(int meters);
}
```

<?code-excerpt "language/lib/class_modifiers/ex1/b.dart"?>
```dart
// Library b.dart
import 'a.dart';

// Error: Cannot be constructed
Vehicle myVehicle = Vehicle();

// Can be extended
class Car extends Vehicle {
  int passengers = 4;
  // ···
}

// Can be implemented
class MockVehicle implements Vehicle {
  @override
  void moveForward(int meters) {
    // ...
  }
}
```

If you want your abstract class to appear to be instantiable,
define a [factory constructor][].

## `base`

To enforce inheritance of a class or mixin's implementation, use the `base` modifier.
A base class disallows implementation outside of its own library. This guarantees:

- The base class constructor is called whenever an instance of a subtype of the
class is created.
- All implemented private members exist in subtypes.
- A new implemented member in a `base` class does not break subtypes,
since all subtypes inherit the new member.
  - This is true unless the subtype already declares a member with the same name
  and an incompatible signature.

You must mark any class which implements or extends a base class as
`base`, `final`, or `sealed`. This prevents outside libraries from
breaking the base class guarantees.

<?code-excerpt "language/lib/class_modifiers/ex2/a.dart"?>
```dart
// Library a.dart
base class Vehicle {
  void moveForward(int meters) {
    // ...
  }
}
```

<?code-excerpt "language/lib/class_modifiers/ex2/b.dart"?>
```dart
// Library b.dart
import 'a.dart';

// Can be constructed
Vehicle myVehicle = Vehicle();

// Can be extended
base class Car extends Vehicle {
  int passengers = 4;
  // ...
}

// ERROR: Cannot be implemented
base class MockVehicle implements Vehicle {
  @override
  void moveForward() {
    // ...
  }
}
```

## `interface`

To define an interface, use the `interface` modifier. Libraries outside of the
interface's own defining library can implement the interface, but not extend it.
This guarantees:

- When one of the class's instance methods calls another instance method on `this`,
it will always invoke a known implementation of the method from the same library.
- Other libraries can't override methods that the interface
class's own methods might later call in unexpected ways.
This reduces the [fragile base class problem][].

<?code-excerpt "language/lib/class_modifiers/ex3/a.dart"?>
```dart
// Library a.dart
interface class Vehicle {
  void moveForward(int meters) {
    // ...
  }
}
```

<?code-excerpt "language/lib/class_modifiers/ex3/b.dart"?>
```dart
// Library b.dart
import 'a.dart';

// Can be constructed
Vehicle myVehicle = Vehicle();

// ERROR: Cannot be inherited
class Car extends Vehicle {
  int passengers = 4;
  // ...
}

// Can be implemented
class MockVehicle implements Vehicle {
  @override
  void moveForward(int meters) {
    // ...
  }
}
```

### `abstract interface`

The most common use for the `interface` modifier is to define a pure interface. 
[Combine](#combining-modifiers) the `interface` and [`abstract`](#abstract)
modifiers for an `abstract interface class`.

Like an `interface` class, other libraries can implement, but cannot inherit,
a pure interface. Like an `abstract` class, a pure interface can have
abstract members.

## `final` 

To close the type hierarchy, use the `final` modifier.
This prevents subtyping from a class outside of the current library. 
Disallowing both inheritance and implementation prevents subtyping entirely.
This guarantees:

- You can safely add incremental changes to the API.
- You can call instance methods knowing that they haven't been overwritten in a
third-party subclass.

Final classes can be extended or implemented within the
same library. The `final` modifier encompasses the effects of `base`, and
therefore any subclasses must also be marked `base`, `final`, or `sealed`.

<?code-excerpt "language/lib/class_modifiers/ex4/a.dart"?>
```dart
// Library a.dart
final class Vehicle {
  void moveForward(int meters) {
    // ...
  }
}
```

<?code-excerpt "language/lib/class_modifiers/ex4/b.dart"?>
```dart
// Library b.dart
import 'a.dart';

// Can be constructed
Vehicle myVehicle = Vehicle();

// ERROR: Cannot be inherited
class Car extends Vehicle {
  int passengers = 4;
  // ...
}

class MockVehicle implements Vehicle {
  // ERROR: Cannot be implemented
  @override
  void moveForward(int meters) {
    // ...
  }
}
```

## `sealed`

To create a known, enumerable set of subtypes, use the `sealed` modifier.
This allows you to create a switch over those subtypes that is statically ensured
to be [_exhaustive_][exhaustive].

The `sealed` modifier prevents a class from being extended or
implemented outside its own library. Sealed classes are implicitly
[abstract](#abstract).

- They cannot be constructed themselves.
- They can have [factory constructors](/language/constructors#factory-constructors).
- They can define constructors for their subclasses to use.

Subclasses of sealed classes are, however, not implicitly abstract.

The compiler is aware of any possible direct subtypes
because they can only exist in the same library. 
This allows the compiler to alert you when a switch does not
exhaustively handle all possible subtypes in its cases:

<?code-excerpt "language/lib/class_modifiers/ex5/sealed.dart"?>
```dart
sealed class Vehicle {}

class Car extends Vehicle {}

class Truck implements Vehicle {}

class Bicycle extends Vehicle {}

// ERROR: Cannot be instantiated
Vehicle myVehicle = Vehicle();

// Subclasses can be instantiated
Vehicle myCar = Car();

String getVehicleSound(Vehicle vehicle) {
  // ERROR: The switch is missing the Bicycle subtype or a default case.
  return switch (vehicle) {
    Car() => 'vroom',
    Truck() => 'VROOOOMM',
  };
}
```

If you don't want [exhaustive switching][exhaustive], 
or want to be able to add subtypes later without breaking the API, 
use the [`final`](#final) modifier. For a more in depth comparison,
read [`sealed` versus `final`](/language/class-modifiers-for-apis#sealed-versus-final).

## Combining modifiers

You can combine some modifiers for layered restrictions. 
A class declaration can be, in order:

1. (Optional) `abstract`, describing whether the class can contain abstract members
and prevents instantiation.
2. (Optional) One of `base`, `interface`, `final` or `sealed`, describing
restrictions on other libraries subtyping the class.
3. (Optional) `mixin`, describing whether the declaration can be mixed in.
4. The `class` keyword itself.

You can't combine some modifiers because they are contradictory, redundant, or
otherwise mutually exclusive:

* `abstract` with `sealed`. A [sealed](#sealed) class is always implicitly
[abstract](#abstract).
* `interface`, `final` or `sealed` with `mixin`. These access modifiers
prevent [mixing in][mixin].

See the [Class modifiers reference][] for complete guidance.

[Class modifiers reference]: /language/modifier-reference


[language version]: /guides/language/evolution#language-versioning
[class, mixin, or mixin class]: /language/mixins#class-mixin-or-mixin-class
[mixin]: /language/mixins
[fragile base class problem]: https://en.wikipedia.org/wiki/Fragile_base_class
[`noSuchMethod`]: /language/extend#nosuchmethod
[construct]: /language/constructors
[extend]: /language/extend
[implement]: /language/classes#implicit-interfaces
[factory constructor]: /language/constructors#factory-constructors
[exhaustive]: /language/branches#exhaustiveness-checking
[abstract methods]: /language/methods#abstract-methods
[syntax specification]: https://github.com/dart-lang/language/blob/main/accepted/3.0/class-modifiers/feature-specification.md#syntax


---
title: Classes
description: Summary of classes, class instances, and their members.
prevpage:
  url: /language/error-handling
  title: Error handling
nextpage:
  url: /language/constructors
  title: Constructors
---

<?code-excerpt replace="/ *\/\/\s+ignore_for_file:[^\n]+\n//g; /(^|\n) *\/\/\s+ignore:[^\n]+\n/$1/g; /(\n[^\n]+) *\/\/\s+ignore:[^\n]+\n/$1\n/g; / *\/\/\s+ignore:[^\n]+//g; /([A-Z]\w*)\d\b/$1/g"?>

Dart is an object-oriented language with classes and mixin-based
inheritance. Every object is an instance of a class, and all classes
except `Null` descend from [`Object`][].
*Mixin-based inheritance* means that although every class
(except for the [top class][top-and-bottom], `Object?`)
has exactly one superclass, a class body can be reused in
multiple class hierarchies.
[Extension methods][] are a way to
add functionality to a class without changing the class or creating a subclass.
[Class modifiers][] allow you to control how libraries can subtype a class.


## Using class members

Objects have *members* consisting of functions and data (*methods* and
*instance variables*, respectively). When you call a method, you *invoke*
it on an object: the method has access to that object's functions and
data.

Use a dot (`.`) to refer to an instance variable or method:

<?code-excerpt "misc/test/language_tour/classes_test.dart (object-members)"?>
```dart
var p = Point(2, 2);

// Get the value of y.
assert(p.y == 2);

// Invoke distanceTo() on p.
double distance = p.distanceTo(Point(4, 4));
```

Use `?.` instead of `.` to avoid an exception
when the leftmost operand is null:

<?code-excerpt "misc/test/language_tour/classes_test.dart (safe-member-access)"?>
```dart
// If p is non-null, set a variable equal to its y value.
var a = p?.y;
```


## Using constructors

You can create an object using a *constructor*.
Constructor names can be either <code><em>ClassName</em></code> or
<code><em>ClassName</em>.<em>identifier</em></code>. For example,
the following code creates `Point` objects using the
`Point()` and `Point.fromJson()` constructors:

<?code-excerpt "misc/test/language_tour/classes_test.dart (object-creation)" replace="/ as .*?;/;/g"?>
```dart
var p1 = Point(2, 2);
var p2 = Point.fromJson({'x': 1, 'y': 2});
```

The following code has the same effect, but
uses the optional `new` keyword before the constructor name:

<?code-excerpt "misc/test/language_tour/classes_test.dart (object-creation-new)" replace="/ as .*?;/;/g"?>
```dart
var p1 = new Point(2, 2);
var p2 = new Point.fromJson({'x': 1, 'y': 2});
```

Some classes provide [constant constructors][].
To create a compile-time constant using a constant constructor,
put the `const` keyword before the constructor name:

<?code-excerpt "misc/test/language_tour/classes_test.dart (const)"?>
```dart
var p = const ImmutablePoint(2, 2);
```

Constructing two identical compile-time constants results in a single,
canonical instance:

<?code-excerpt "misc/test/language_tour/classes_test.dart (identical)"?>
```dart
var a = const ImmutablePoint(1, 1);
var b = const ImmutablePoint(1, 1);

assert(identical(a, b)); // They are the same instance!
```

Within a _constant context_, you can omit the `const` before a constructor
or literal. For example, look at this code, which creates a const map:

<?code-excerpt "misc/test/language_tour/classes_test.dart (const-context-withconst)" replace="/pointAndLine1/pointAndLine/g"?>
```dart
// Lots of const keywords here.
const pointAndLine = const {
  'point': const [const ImmutablePoint(0, 0)],
  'line': const [const ImmutablePoint(1, 10), const ImmutablePoint(-2, 11)],
};
```

You can omit all but the first use of the `const` keyword:

<?code-excerpt "misc/test/language_tour/classes_test.dart (const-context-noconst)" replace="/pointAndLine2/pointAndLine/g"?>
```dart
// Only one const, which establishes the constant context.
const pointAndLine = {
  'point': [ImmutablePoint(0, 0)],
  'line': [ImmutablePoint(1, 10), ImmutablePoint(-2, 11)],
};
```

If a constant constructor is outside of a constant context
and is invoked without `const`,
it creates a **non-constant object**:

<?code-excerpt "misc/test/language_tour/classes_test.dart (nonconst-const-constructor)"?>
```dart
var a = const ImmutablePoint(1, 1); // Creates a constant
var b = ImmutablePoint(1, 1); // Does NOT create a constant

assert(!identical(a, b)); // NOT the same instance!
```


## Getting an object's type

To get an object's type at runtime,
you can use the `Object` property `runtimeType`,
which returns a [`Type`][] object.

<?code-excerpt "misc/test/language_tour/classes_test.dart (runtimeType)"?>
```dart
print('The type of a is ${a.runtimeType}');
```

{{site.alert.warn}}
  Use a [type test operator][] rather than `runtimeType`
  to test an object's type.
  In production environments, the test `object is Type` is more stable
  than the test `object.runtimeType == Type`.
{{site.alert.end}}

Up to here, you've seen how to _use_ classes.
The rest of this section shows how to _implement_ classes.


## Instance variables

Here's how you declare instance variables:

<?code-excerpt "misc/lib/language_tour/classes/point_with_main.dart (class)"?>
```dart
class Point {
  double? x; // Declare instance variable x, initially null.
  double? y; // Declare y, initially null.
  double z = 0; // Declare z, initially 0.
}
```

All uninitialized instance variables have the value `null`.

All instance variables generate an implicit *getter* method.
Non-final instance variables and
`late final` instance variables without initializers also generate
an implicit *setter* method. For details,
check out [Getters and setters][].

If you initialize a non-`late` instance variable where it's declared,
the value is set when the instance is created,
which is before the constructor and its initializer list execute.
As a result, non-`late` instance variable initializers can't access `this`.

<?code-excerpt "misc/lib/language_tour/classes/point_with_main.dart (class+main)" replace="/(double .*?;).*/$1/g" plaster="none"?>
```dart
class Point {
  double? x; // Declare instance variable x, initially null.
  double? y; // Declare y, initially null.
}

void main() {
  var point = Point();
  point.x = 4; // Use the setter method for x.
  assert(point.x == 4); // Use the getter method for x.
  assert(point.y == null); // Values default to null.
}
```

Instance variables can be `final`,
in which case they must be set exactly once.
Initialize `final`, non-`late` instance variables
at declaration,
using a constructor parameter, or
using a constructor's [initializer list][]:

<?code-excerpt "misc/lib/effective_dart/usage_good.dart (field-init-at-decl)"?>
```dart
class ProfileMark {
  final String name;
  final DateTime start = DateTime.now();

  ProfileMark(this.name);
  ProfileMark.unnamed() : name = '';
}
```

If you need to assign the value of a `final` instance variable
after the constructor body starts, you can use one of the following:

* Use a [factory constructor][].
* Use `late final`, but [_be careful:_][late-final-ivar]
  a `late final` without an initializer adds a setter to the API.

## Implicit interfaces

Every class implicitly defines an interface containing all the instance
members of the class and of any interfaces it implements. If you want to
create a class A that supports class B's API without inheriting B's
implementation, class A should implement the B interface.

A class implements one or more interfaces by declaring them in an
`implements` clause and then providing the APIs required by the
interfaces. For example:

<?code-excerpt "misc/lib/language_tour/classes/impostor.dart"?>
```dart
// A person. The implicit interface contains greet().
class Person {
  // In the interface, but visible only in this library.
  final String _name;

  // Not in the interface, since this is a constructor.
  Person(this._name);

  // In the interface.
  String greet(String who) => 'Hello, $who. I am $_name.';
}

// An implementation of the Person interface.
class Impostor implements Person {
  String get _name => '';

  String greet(String who) => 'Hi $who. Do you know who I am?';
}

String greetBob(Person person) => person.greet('Bob');

void main() {
  print(greetBob(Person('Kathy')));
  print(greetBob(Impostor()));
}
```

Here's an example of specifying that a class implements multiple
interfaces:

<?code-excerpt "misc/lib/language_tour/classes/misc.dart (point_interfaces)"?>
```dart
class Point implements Comparable, Location {...}
```


## Class variables and methods

Use the `static` keyword to implement class-wide variables and methods.

### Static variables

Static variables (class variables) are useful for class-wide state and
constants:

<?code-excerpt "misc/lib/language_tour/classes/misc.dart (static-field)"?>
```dart
class Queue {
  static const initialCapacity = 16;
  // ···
}

void main() {
  assert(Queue.initialCapacity == 16);
}
```

Static variables aren't initialized until they're used.

{{site.alert.note}}
  This page follows the [style guide
  recommendation](/effective-dart/style#identifiers)
  of preferring `lowerCamelCase` for constant names.
{{site.alert.end}}

### Static methods

Static methods (class methods) don't operate on an instance, and thus
don't have access to `this`.
They do, however, have access to static variables.
As the following example shows,
you invoke static methods directly on a class:

<?code-excerpt "misc/lib/language_tour/classes/point_with_distance_method.dart"?>
```dart
import 'dart:math';

class Point {
  double x, y;
  Point(this.x, this.y);

  static double distanceBetween(Point a, Point b) {
    var dx = a.x - b.x;
    var dy = a.y - b.y;
    return sqrt(dx * dx + dy * dy);
  }
}

void main() {
  var a = Point(2, 2);
  var b = Point(4, 4);
  var distance = Point.distanceBetween(a, b);
  assert(2.8 < distance && distance < 2.9);
  print(distance);
}
```

{{site.alert.note}}
  Consider using top-level functions, instead of static methods, for
  common or widely used utilities and functionality.
{{site.alert.end}}

You can use static methods as compile-time constants. For example, you
can pass a static method as a parameter to a constant constructor.


[`Object`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-core/Object-class.html
[top-and-bottom]: /null-safety/understanding-null-safety#top-and-bottom
[Extension methods]: /language/extension-methods
[Class modifiers]: /language/class-modifiers
[constant constructors]: /language/constructors#constant-constructors
[`Type`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-core/Type-class.html
[type test operator]: /language/operators#type-test-operators
[Getters and setters]: /language/methods#getters-and-setters
[initializer list]: /language/constructors#initializer-list
[factory constructor]: /language/constructors#factory-constructors
[late-final-ivar]: /effective-dart/design#avoid-public-late-final-fields-without-initializers


---
title: Collections
description: Summary of the different types of collections in Dart.
prevpage:
  url: /language/records
  title: Records
nextpage:
  url: /language/generics
  title: Generics
---

Dart has built-in support for list, set, and map [collections][].
To learn more about configuring the types collections contain,
check out [Generics][].

## Lists

Perhaps the most common collection in nearly every programming language
is the *array*, or ordered group of objects. In Dart, arrays are
[`List`][] objects, so most people just call them *lists*.

Dart list literals are denoted by
a comma separated list of expressions or values,
enclosed in square brackets (`[]`).
Here's a simple Dart list:

<?code-excerpt "misc/lib/language_tour/built_in_types.dart (list-literal)"?>
```dart
var list = [1, 2, 3];
```

{{site.alert.note}}
  Dart infers that `list` has type `List<int>`. If you try to add non-integer
  objects to this list, the analyzer or runtime raises an error. For more
  information, read about [type inference][].
{{site.alert.end}}

<a id="trailing-comma"></a>
You can add a comma after the last item in a Dart collection literal.
This _trailing comma_ doesn't affect the collection,
but it can help prevent copy-paste errors.

<?code-excerpt "misc/lib/language_tour/built_in_types.dart (trailing-commas)"?>
```dart
var list = [
  'Car',
  'Boat',
  'Plane',
];
```

Lists use zero-based indexing, where 0 is the index of the first value
and `list.length - 1` is the index of the last value. 
You can get a list's length using the `.length` property
and access a list's values using the subscript operator (`[]`):

<?code-excerpt "misc/test/language_tour/built_in_types_test.dart (list-indexing)"?>
```dart
var list = [1, 2, 3];
assert(list.length == 3);
assert(list[1] == 2);

list[1] = 1;
assert(list[1] == 1);
```

To create a list that's a compile-time constant,
add `const` before the list literal:

<?code-excerpt "misc/lib/language_tour/built_in_types.dart (const-list)"?>
```dart
var constantList = const [1, 2, 3];
// constantList[1] = 1; // This line will cause an error.
```

For more information about lists, refer to the Lists section of the
[Library tour](/guides/libraries/library-tour#lists).

## Sets

A set in Dart is an unordered collection of unique items.
Dart support for sets is provided by set literals and the
[`Set`][] type.

Here is a simple Dart set, created using a set literal:

<?code-excerpt "misc/lib/language_tour/built_in_types.dart (set-literal)"?>
```dart
var halogens = {'fluorine', 'chlorine', 'bromine', 'iodine', 'astatine'};
```

{{site.alert.note}}
  Dart infers that `halogens` has the type `Set<String>`. If you try to add the
  wrong type of value to the set, the analyzer or runtime raises an error. For
  more information, read about
  [type inference.](/language/type-system#type-inference)
{{site.alert.end}}

To create an empty set, use `{}` preceded by a type argument,
or assign `{}` to a variable of type `Set`:

<?code-excerpt "misc/lib/language_tour/built_in_types.dart (set-vs-map)"?>
```dart
var names = <String>{};
// Set<String> names = {}; // This works, too.
// var names = {}; // Creates a map, not a set.
```

{{site.alert.info}}
  **Set or map?** The syntax for map literals is similar to that for set
  literals. Because map literals came first, `{}` defaults to the `Map` type. If
  you forget the type annotation on `{}` or the variable it's assigned to, then
  Dart creates an object of type `Map<dynamic, dynamic>`.
{{site.alert.end}}

Add items to an existing set using the `add()` or `addAll()` methods:

<?code-excerpt "misc/lib/language_tour/built_in_types.dart (set-add-items)"?>
```dart
var elements = <String>{};
elements.add('fluorine');
elements.addAll(halogens);
```

Use `.length` to get the number of items in the set:

<?code-excerpt "misc/test/language_tour/built_in_types_test.dart (set-length)"?>
```dart
var elements = <String>{};
elements.add('fluorine');
elements.addAll(halogens);
assert(elements.length == 5);
```

To create a set that's a compile-time constant,
add `const` before the set literal:

<?code-excerpt "misc/lib/language_tour/built_in_types.dart (const-set)"?>
```dart
final constantSet = const {
  'fluorine',
  'chlorine',
  'bromine',
  'iodine',
  'astatine',
};
// constantSet.add('helium'); // This line will cause an error.
```

For more information about sets, refer to the Sets section of the
[Library tour](/guides/libraries/library-tour#sets).

## Maps

In general, a map is an object that associates keys and values. Both
keys and values can be any type of object. Each *key* occurs only once,
but you can use the same *value* multiple times. Dart support for maps
is provided by map literals and the [`Map`][] type.

Here are a couple of simple Dart maps, created using map literals:

<?code-excerpt "misc/lib/language_tour/built_in_types.dart (map-literal)"?>
```dart
var gifts = {
  // Key:    Value
  'first': 'partridge',
  'second': 'turtledoves',
  'fifth': 'golden rings'
};

var nobleGases = {
  2: 'helium',
  10: 'neon',
  18: 'argon',
};
```

{{site.alert.note}}
  Dart infers that `gifts` has the type `Map<String, String>` and `nobleGases`
  has the type `Map<int, String>`. If you try to add the wrong type of value to
  either map, the analyzer or runtime raises an error. For more information,
  read about [type inference][].
{{site.alert.end}}

You can create the same objects using a Map constructor:

<?code-excerpt "misc/lib/language_tour/built_in_types.dart (map-constructor)"?>
```dart
var gifts = Map<String, String>();
gifts['first'] = 'partridge';
gifts['second'] = 'turtledoves';
gifts['fifth'] = 'golden rings';

var nobleGases = Map<int, String>();
nobleGases[2] = 'helium';
nobleGases[10] = 'neon';
nobleGases[18] = 'argon';
```

{{site.alert.note}}
  If you come from a language like C# or Java, you might expect to see `new Map()` 
  instead of just `Map()`. In Dart, the `new` keyword is optional.
  For details, see [Using constructors][].
{{site.alert.end}}

Add a new key-value pair to an existing map
using the subscript assignment operator (`[]=`):

<?code-excerpt "misc/lib/language_tour/built_in_types.dart (map-add-item)"?>
```dart
var gifts = {'first': 'partridge'};
gifts['fourth'] = 'calling birds'; // Add a key-value pair
```

Retrieve a value from a map using the subscript operator (`[]`):

<?code-excerpt "misc/test/language_tour/built_in_types_test.dart (map-retrieve-item)"?>
```dart
var gifts = {'first': 'partridge'};
assert(gifts['first'] == 'partridge');
```

If you look for a key that isn't in a map, you get `null` in return:

<?code-excerpt "misc/test/language_tour/built_in_types_test.dart (map-missing-key)"?>
```dart
var gifts = {'first': 'partridge'};
assert(gifts['fifth'] == null);
```

Use `.length` to get the number of key-value pairs in the map:

<?code-excerpt "misc/test/language_tour/built_in_types_test.dart (map-length)"?>
```dart
var gifts = {'first': 'partridge'};
gifts['fourth'] = 'calling birds';
assert(gifts.length == 2);
```

To create a map that's a compile-time constant,
add `const` before the map literal:

<?code-excerpt "misc/lib/language_tour/built_in_types.dart (const-map)"?>
```dart
final constantMap = const {
  2: 'helium',
  10: 'neon',
  18: 'argon',
};

// constantMap[2] = 'Helium'; // This line will cause an error.
```

For more information about maps, refer to the Maps section of the
[Library tour](/guides/libraries/library-tour#maps).

## Operators

### Spread operators

Dart supports the **spread operator** (`...`) and the
**null-aware spread operator** (`...?`) in list, map, and set literals.
Spread operators provide a concise way to insert multiple values into a collection.

For example, you can use the spread operator (`...`) to insert
all the values of a list into another list:

<?code-excerpt "misc/test/language_tour/built_in_types_test.dart (list-spread)"?>
```dart
var list = [1, 2, 3];
var list2 = [0, ...list];
assert(list2.length == 4);
```

If the expression to the right of the spread operator might be null,
you can avoid exceptions by using a null-aware spread operator (`...?`):

<?code-excerpt "misc/test/language_tour/built_in_types_test.dart (list-null-spread)"?>
```dart
var list2 = [0, ...?list];
assert(list2.length == 1);
```

For more details and examples of using the spread operator, see the
[spread operator proposal.][spread proposal]

<a id="collection-operators"></a>
### Control-flow operators

Dart offers **collection if** and **collection for** for use in list, map,
and set literals. You can use these operators to build collections using
conditionals (`if`) and repetition (`for`).

Here's an example of using **collection if**
to create a list with three or four items in it:

<?code-excerpt "misc/test/language_tour/built_in_types_test.dart (list-if)"?>
```dart
var nav = ['Home', 'Furniture', 'Plants', if (promoActive) 'Outlet'];
```

Dart also supports [if-case][] inside collection literals:

```dart
var nav = ['Home', 'Furniture', 'Plants', if (login case 'Manager') 'Inventory'];
```

Here's an example of using **collection for**
to manipulate the items of a list before
adding them to another list:

<?code-excerpt "misc/test/language_tour/built_in_types_test.dart (list-for)"?>
```dart
var listOfInts = [1, 2, 3];
var listOfStrings = ['#0', for (var i in listOfInts) '#$i'];
assert(listOfStrings[1] == '#1');
```

For more details and examples of using collection `if` and `for`, see the
[control flow collections proposal.][collections proposal]

[collections]: /guides/libraries/library-tour#collections
[type inference]: /language/type-system#type-inference
[`List`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-core/List-class.html
[`Map`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-core/Map-class.html
[Using constructors]: /language/classes#using-constructors
[collections proposal]: https://github.com/dart-lang/language/blob/main/accepted/2.3/control-flow-collections/feature-specification.md
[spread proposal]: https://github.com/dart-lang/language/blob/main/accepted/2.3/spread-collections/feature-specification.md
[generics]: /language/generics
[`Set`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-core/Set-class.html
[if-case]: /language/branches#if-case


---
title: Comments
description: The different comment types in Dart.
prevpage:
  url: /language/operators
  title: Operators
nextpage:
  url: /language/metadata
  title: Metadata
---

Dart supports single-line comments, multi-line comments, and
documentation comments.


## Single-line comments

A single-line comment begins with `//`. Everything between `//` and the
end of line is ignored by the Dart compiler.

<?code-excerpt "misc/lib/language_tour/comments.dart (single-line-comments)"?>
```dart
void main() {
  // TODO: refactor into an AbstractLlamaGreetingFactory?
  print('Welcome to my Llama farm!');
}
```

## Multi-line comments

A multi-line comment begins with `/*` and ends with `*/`. Everything
between `/*` and `*/` is ignored by the Dart compiler (unless the
comment is a documentation comment; see the next section). Multi-line
comments can nest.

<?code-excerpt "misc/lib/language_tour/comments.dart (multi-line-comments)"?>
```dart
void main() {
  /*
   * This is a lot of work. Consider raising chickens.

  Llama larry = Llama();
  larry.feed();
  larry.exercise();
  larry.clean();
   */
}
```

## Documentation comments

Documentation comments are multi-line or single-line comments that begin
with `///` or `/**`. Using `///` on consecutive lines has the same
effect as a multi-line doc comment.

Inside a documentation comment, the analyzer ignores all text
unless it is enclosed in brackets. Using brackets, you can refer to
classes, methods, fields, top-level variables, functions, and
parameters. The names in brackets are resolved in the lexical scope of
the documented program element.

Here is an example of documentation comments with references to other
classes and arguments:

<?code-excerpt "misc/lib/language_tour/comments.dart (doc-comments)"?>
```dart
/// A domesticated South American camelid (Lama glama).
///
/// Andean cultures have used llamas as meat and pack
/// animals since pre-Hispanic times.
///
/// Just like any other animal, llamas need to eat,
/// so don't forget to [feed] them some [Food].
class Llama {
  String? name;

  /// Feeds your llama [food].
  ///
  /// The typical llama eats one bale of hay per week.
  void feed(Food food) {
    // ...
  }

  /// Exercises your llama with an [activity] for
  /// [timeLimit] minutes.
  void exercise(Activity activity, int timeLimit) {
    // ...
  }
}
```

In the class's generated documentation, `[feed]` becomes a link
to the docs for the `feed` method,
and `[Food]` becomes a link to the docs for the `Food` class.

To parse Dart code and generate HTML documentation, you can use Dart's
documentation generation tool, [`dart doc`](/tools/dart-doc).
For an example of generated documentation, see the 
[Dart API documentation.]({{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}) 
For advice on how to structure your comments, see
[Effective Dart: Documentation.](/effective-dart/documentation)


---
title: Concurrency in Dart
description: >-
  Use isolates to enable parallel code execution on multiple processor cores.
short-title: Concurrency
prevpage:
  url: /language/async
  title: Async
---

<?code-excerpt path-base="concurrency"?>

<style>
  article img {
    padding: 15px 0;
  }
</style>

Dart supports concurrent programming with async-await, isolates, and
classes such as `Future` and `Stream`.
This page gives an overview of async-await, `Future`, and `Stream`,
but it's mostly about isolates.

Within an app, all Dart code runs in an _isolate._
Each Dart isolate has a single thread of execution and
shares no mutable objects with other isolates.
To communicate with each other,
isolates use message passing.
Many Dart apps use only one isolate, the _main isolate_.
You can create additional isolates to enable
parallel code execution on multiple processor cores.

Although Dart's isolate model is built with underlying primitives
such as processes and threads
that the operating system provides,
the Dart VM's use of these primitives
is an implementation detail that this page doesn't discuss.

## Asynchrony types and syntax

If you're already familiar with `Future`, `Stream`, and async-await,
then you can skip ahead to the [isolates section][].

[isolates section]: #how-isolates-work


### Future and Stream types

The Dart language and libraries use `Future` and `Stream` objects to
represent values to be provided in the future.
For example, a promise to eventually provide an `int` value
is typed as `Future<int>`.
A promise to provide a series of `int` values
has the type `Stream<int>`.

As another example, consider the dart:io methods for reading files.
The synchronous `File` method [`readAsStringSync()`][]
reads a file synchronously,
blocking until the file is either fully read or an error occurs.
The method then either returns an object of type `String`
or throws an exception.
The asynchronous equivalent, [`readAsString()`][],
immediately returns an object of type `Future<String>`.
At some point in the future,
the `Future<String>` completes with either a string value or an error.

[`readAsStringSync()`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-io/File/readAsStringSync.html
[`readAsString()`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-io/File/readAsString.html


#### Why asynchronous code matters

It matters whether a method is synchronous or asynchronous
because most apps need to do more than one thing at a time.

Asynchronous computations are often the result of performing computations
outside of the current Dart code; 
this includes computations that don't complete immediately, 
and where you aren't willing to block your Dart code waiting for the result.
For example, an app might start an HTTP request,
but need to update its display or respond to user input
before the HTTP request completes.
Asynchronous code helps apps stay responsive.

These scenarios include operating system calls like
non-blocking I/O, performing an HTTP request, or communicating with a browser. 
Other scenarios include waiting for computations
performed in another Dart isolate as described below, 
or maybe just waiting for a timer to trigger. 
All of these processes either run in a different thread, 
or are handled by the operating system or the Dart runtime, 
which allows Dart code to run concurrently with the computation.


### The async-await syntax

The `async` and `await` keywords provide
a declarative way to define asynchronous functions
and use their results.

Here's an example of some synchronous code
that blocks while waiting for file I/O:

<?code-excerpt "lib/sync_number_of_keys.dart"?>
```dart
const String filename = 'with_keys.json';

void main() {
  // Read some data.
  final fileData = _readFileSync();
  final jsonData = jsonDecode(fileData);

  // Use that data.
  print('Number of JSON keys: ${jsonData.length}');
}

String _readFileSync() {
  final file = File(filename);
  final contents = file.readAsStringSync();
  return contents.trim();
}
```

Here's similar code, but with changes (highlighted) to make it asynchronous:

<?code-excerpt "lib/async_number_of_keys.dart" replace="/async|await|readAsString\(\)/[!$&!]/g; /Future<\w+\W/[!$&!]/g;"?>
{% prettify dart tag=pre+code %}
const String filename = 'with_keys.json';

void main() [!async!] {
  // Read some data.
  final fileData = [!await!] _readFileAsync();
  final jsonData = jsonDecode(fileData);

  // Use that data.
  print('Number of JSON keys: ${jsonData.length}');
}

[!Future<String>!] _readFileAsync() [!async!] {
  final file = File(filename);
  final contents = [!await!] file.[!readAsString()!];
  return contents.trim();
}
{% endprettify %}

The `main()` function uses the `await` keyword in front of `_readFileAsync()`
to let other Dart code (such as event handlers) use the CPU
while native code (file I/O) executes.
Using `await` also has the effect of
converting the `Future<String>` returned by `_readFileAsync()` into a `String`.
As a result, the `contents` variable has the implicit type `String`.

{{site.alert.note}}
  The `await` keyword works only in functions that
  have `async` before the function body.
{{site.alert.end}}

As the following figure shows,
the Dart code pauses while `readAsString()` executes non-Dart code,
in either the Dart virtual machine (VM) or the operating system (OS).
Once `readAsString()` returns a value, Dart code execution resumes.

![Flowchart-like figure showing app code executing from start to exit, waiting for native I/O in between](/assets/img/language/concurrency/basics-await.png)

If you'd like to learn more about using `async`, `await`, and futures,
visit the [asynchronous programming codelab][].

[asynchronous programming codelab]: /codelabs/async-await


## How isolates work

Most modern devices have multi-core CPUs.
To take advantage of multiple cores,
developers sometimes use shared-memory threads running concurrently.
However, shared-state concurrency is
[error prone](https://en.wikipedia.org/wiki/Race_condition#In_software) and
can lead to complicated code.

Instead of threads, all Dart code runs inside of isolates.
Each isolate has its own memory heap,
ensuring that none of the state in an isolate is accessible from
any other isolate.
No shared state between isolates means concurrency complexities like 
[mutexes or locks](https://en.wikipedia.org/wiki/Lock_(computer_science))
and [data races](https://en.wikipedia.org/wiki/Race_condition#Data_race)
won't occur in Dart. That said,
isolates don't prevent race conditions all together.


Using isolates, your Dart code can perform multiple independent tasks at once,
using additional processor cores if they're available.
Isolates are like threads or processes,
but each isolate has its own memory and a single thread running an event loop.

{{site.alert.info}}
  **Platform note:**
    Only the [Dart Native platform][] implements isolates.
    To learn more about the Dart Web platform,
    see the [Concurrency on the web](#concurrency-on-the-web) section.
{{site.alert.end}}

[Dart Native platform]: /overview#platform

### The main isolate

You often don't need to think about isolates at all.
Dart programs run in the main isolate by default.
It's the thread where a program starts to run and execute, 
as shown in the following figure:

![A figure showing a main isolate, which runs `main()`, responds to events, and then exits](/assets/img/language/concurrency/basics-main-isolate.png)

Even single-isolate programs can execute smoothly.
Before continuing to the next line of code, these apps use
[async-await][] to wait for asynchronous operations to complete.
A well-behaved app starts quickly,
getting to the event loop as soon as possible.
The app then responds to each queued event promptly,
using asynchronous operations as necessary.

[async-await]: {{site.url}}/codelabs/async-await

### The isolate life cycle

As the following figure shows,
every isolate starts by running some Dart code,
such as the `main()` function.
This Dart code might register some event listeners—to 
respond to user input or file I/O, for example.
When the isolate's initial function returns,
the isolate stays around if it needs to handle events.
After handling the events, the isolate exits.

![A more general figure showing that any isolate runs some code, optionally responds to events, and then exits](/assets/img/language/concurrency/basics-isolate.png)


### Event handling

In a client app, the main isolate's event queue might contain
repaint requests and notifications of tap and other UI events.
For example, the following figure shows a repaint event,
followed by a tap event, followed by two repaint events.
The event loop takes events from the queue in first in, first out order.

![A figure showing events being fed, one by one, into the event loop](/assets/img/language/concurrency/event-loop.png)

Event handling happens on the main isolate after `main()` exits.
In the following figure, after `main()` exits,
the main isolate handles the first repaint event.
After that, the main isolate handles the tap event,
followed by a repaint event.

![A figure showing the main isolate executing event handlers, one by one](/assets/img/language/concurrency/event-handling.png)

If a synchronous operation takes too much processing time,
the app can become unresponsive.
In the following figure, the tap-handling code takes too long,
so subsequent events are handled too late.
The app might appear to freeze,
and any animation it performs might be jerky.

![A figure showing a tap handler with a too-long execution time](/assets/img/language/concurrency/event-jank.png)

In client apps, the result of a too-lengthy synchronous operation is often
[janky (non-smooth) UI animation][jank].
Worse, the UI might become completely unresponsive.

[jank]: {{site.flutter-docs}}/perf/rendering-performance


### Background workers

If your app's UI becomes unresponsive due to 
a time-consuming computation—[parsing a large JSON file][json], 
for example—consider offloading that computation to a worker isolate,
often called a _background worker._
A common case, shown in the following figure,
is spawning a simple worker isolate that
performs a computation and then exits.
The worker isolate returns its result in a message when the worker exits.

[json]: {{site.flutter-docs}}/cookbook/networking/background-parsing

![A figure showing a main isolate and a simple worker isolate](/assets/img/language/concurrency/isolate-bg-worker.png)

Each isolate message can deliver one object,
which includes anything that's transitively reachable from that object.
Not all object types are sendable, and
the send fails if any transitively reachable object is unsendable.
For example, you can send an object of type `List<Object>` only if
none of the objects in the list is unsendable.
If one of the objects is, say, a `Socket`, then
the send fails because sockets are unsendable.

For information on the kinds of objects that you can send in messages,
see the API reference documentation for the [`send()` method][].

A worker isolate can perform I/O
(reading and writing files, for example), set timers, and more.
It has its own memory and
doesn't share any state with the main isolate.
The worker isolate can block without affecting other isolates.

[`send()` method]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-isolate/SendPort/send.html

## Code examples

This section discusses some examples
that use the `Isolate` API
to implement isolates.

### Implementing a simple worker isolate

These examples implement a main isolate
that spawns a simple worker isolate.
[`Isolate.run()`][] simplifies the steps behind
setting up and managing worker isolates:

1. Spawns (starts and creates) an isolate
2. Runs a function on the spawned isolate
3. Captures the result
4. Returns the result to the main isolate
5. Terminates the isolate once work is complete
6. Checks, captures, and throws exceptions and errors back to the main isolate

[`Isolate.run()`]: {{site.dart-api}}/dev/dart-isolate/Isolate/run.html

{{site.alert.flutter-note}}
  If you're using Flutter,
  you can use [Flutter's `compute` function][]
  instead of `Isolate.run()`.
  On the [web](#web), the `compute` function falls back
  to running the specified function on the current event loop.
  Use `Isolate.run()` when targeting native platforms only,
  for a more ergonomic API.
{{site.alert.end}}

[native and non-native platforms]: /overview#platform
[Flutter's `compute` function]: {{site.flutter-api}}/flutter/foundation/compute.html

#### Running an existing method in a new isolate

The main isolate contains the code that spawns a new isolate: 

<?code-excerpt "lib/simple_worker_isolate.dart (main)"?>
```dart
const String filename = 'with_keys.json';

void main() async {
  // Read some data.
  final jsonData = await Isolate.run(_readAndParseJson);

  // Use that data.
  print('Number of JSON keys: ${jsonData.length}');
}
```

The spawned isolate executes the function
passed as the first argument, `_readAndParseJson`:

<?code-excerpt "lib/simple_worker_isolate.dart (spawned)"?>
```dart
Future<Map<String, dynamic>> _readAndParseJson() async {
  final fileData = await File(filename).readAsString();
  final jsonData = jsonDecode(fileData) as Map<String, dynamic>;
  return jsonData;
}
```

1. `Isolate.run()` spawns an isolate, the background worker,
   while `main()` waits for the result.

2. The spawned isolate executes the argument passed to `run()`:
   the function `_readAndParseJson()`.

3. `Isolate.run()` takes the result from `return`
   and sends the value back to the main isolate,
   shutting down the worker isolate.

4. The worker isolate *transfers* the memory holding the result
   to the main isolate. It *does not copy* the data.
   The worker isolate performs a verification pass to ensure
   the objects are allowed to be transferred.

`_readAndParseJson()` is an existing,
asynchronous function that could just as easily
run directly in the main isolate.
Using `Isolate.run()` to run it instead enables concurrency.
The worker isolate completely abstracts the computations
of `_readAndParseJson()`. It can complete without blocking the main isolate.

The result of `Isolate.run()` is always a Future,
because code in the main isolate continues to run.
Whether the computation the worker isolate executes
is synchronous or asynchronous doesn't impact the
main isolate, because it's running concurrently either way.

For the complete program, check out the [send_and_receive.dart][] sample.

{% comment %}
TODO:
Should create a diagram for the current example.
Previous example's diagram and text for reference:

  The following figure illustrates the communication between
  the main isolate and the worker isolate:
  
  ![A figure showing the previous snippets of code running in the main isolate and in the worker isolate](/assets/img/language/concurrency/isolate-api.png)
{% endcomment %}

#### Sending closures with isolates

You can also create a simple worker isolate with `run()` using a
function literal, or closure, directly in the main isolate.

<?code-excerpt "lib/simple_isolate_closure.dart (main)"?>
```dart
const String filename = 'with_keys.json';

void main() async {
  // Read some data.
  final jsonData = await Isolate.run(() async {
    final fileData = await File(filename).readAsString();
    final jsonData = jsonDecode(fileData) as Map<String, dynamic>;
    return jsonData;
  });

  // Use that data.
  print('Number of JSON keys: ${jsonData.length}');
}
```

This example accomplishes the same as the previous.
A new isolate spawns, computes something, and sends back the result.

However, now the isolate sends a [closure][].
Closures are less limited than typical named functions,
both in how they function and how they're written into the code.
In this example, `Isolate.run()` executes what looks like local code, concurrently.
In that sense, you can imagine `run()` to work like a control flow operator
for "run in parallel".

[closure]: /language/functions#anonymous-functions

### Sending multiple messages between isolates

`Isolate.run()` abstracts a handful of lower-level, 
isolate-related API to simplify isolate management:

* [`Isolate.spawn()`][] and [`Isolate.exit()`][]
* [`ReceivePort`][] and [`SendPort`][]

[`Isolate.exit()`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-isolate/Isolate/exit.html
[`Isolate.spawn()`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-isolate/Isolate/spawn.html
[`ReceivePort`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-isolate/ReceivePort-class.html
[`SendPort`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-isolate/SendPort-class.html

You can use these primitives directly for more granular
control over isolate functionality. For example, `run()` shuts
down its isolate after returning a single message. 
What if you want to allow multiple messages to pass between isolates?
You can set up your own isolate much the same way `run()` is implemented,
just utilizing the [`send()` method][] of `SendPort` in a slightly different way.

One common pattern, which the following figure shows,
is for the main isolate to send a request message to the worker isolate,
which then sends one or more reply messages.

![A figure showing the main isolate spawning the isolate and then sending a request message, which the worker isolate responds to with a reply message; two request-reply cycles are shown](/assets/img/language/concurrency/isolate-custom-bg-worker.png)

Check out the [long_running_isolate.dart][] sample,
which shows how to spawn a long-running isolate
that receives and sends messages multiple times between isolates.

{% assign samples = "https://github.com/dart-lang/samples/tree/main/isolates" %}

[isolate samples]: {{ samples }}
[send_and_receive.dart]: {{ samples }}/bin/send_and_receive.dart
[long_running_isolate.dart]: {{ samples }}/bin/long_running_isolate.dart


## Performance and isolate groups

When an isolate calls [`Isolate.spawn()`][],
the two isolates have the same executable code
and are in the same _isolate group_.
Isolate groups enable performance optimizations such as sharing code;
a new isolate immediately runs the code owned by the isolate group.
Also, `Isolate.exit()` works only when the isolates
are in the same isolate group.

In some special cases,
you might need to use [`Isolate.spawnUri()`][],
which sets up the new isolate with a copy of the code
that's at the specified URI.
However, `spawnUri()` is much slower than `spawn()`,
and the new isolate isn't in its spawner's isolate group.
Another performance consequence is that message passing
is slower when isolates are in different groups.

[`Isolate.spawnUri()`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-isolate/Isolate/spawnUri.html

{{site.alert.flutter-note}}
  Flutter doesn't support `Isolate.spawnUri()`.
{{site.alert.end}}

<a id="web"></a>
## Concurrency on the web

All Dart apps can use `async-await`, `Future`, and `Stream`
for non-blocking, interleaved computations.
The [Dart web platform][], however, does not support isolates.
Dart web apps can use [web workers][] to
run scripts in background threads
similar to isolates.
Web workers' functionality and capabilities
differ somewhat from isolates, though.

For instance, when web workers send data between threads,
they copy the data back and forth.
Data copying can be very slow, though,
especially for large messages. 
Isolates do the same, but also provide APIs
that can more efficiently _transfer_
the memory that holds the message instead.

Creating web workers and isolates also differs.
You can only create web workers by declaring
a separate program entrypoint and compiling it separately.
Starting a web worker is similar to using `Isolate.spawnUri` to start an isolate.
You can also start an isolate with `Isolate.spawn`,
which requires fewer resources because it
[reuses some of the same code and data](#performance-and-isolate-groups)
as the spawning isolate. 
Web workers don't have an equivalent API.

[Dart web platform]: /overview#platform
[web workers]: https://developer.mozilla.org/docs/Web/API/Web_Workers_API/Using_web_workers


---
title: Constructors
description: Everything about using constructors in Dart.
js: [{url: 'https://dartpad.dev/inject_embed.dart.js', defer: true}]
prevpage:
  url: /language/classes
  title: Classes
nextpage:
  url: /language/methods
  title: Methods
---

<?code-excerpt replace="/ *\/\/\s+ignore_for_file:[^\n]+\n//g; /(^|\n) *\/\/\s+ignore:[^\n]+\n/$1/g; /(\n[^\n]+) *\/\/\s+ignore:[^\n]+\n/$1\n/g; / *\/\/\s+ignore:[^\n]+//g; /([A-Z]\w*)\d\b/$1/g"?>

Declare a constructor by creating a function with the same name as its
class (plus, optionally, an additional identifier as described in
[Named constructors](#named-constructors)). 

Use the most common constructor, the generative constructor, to create a new
instance of a class, and [initializing formal parameters](#initializing-formal-parameters)
to instantiate any instance variables, if necessary:

<?code-excerpt "misc/lib/language_tour/classes/point_alt.dart (idiomatic-constructor)" plaster="none"?>
```dart
class Point {
  double x = 0;
  double y = 0;

  // Generative constructor with initializing formal parameters:
  Point(this.x, this.y);
}
```

The `this` keyword refers to the current instance.

{{site.alert.note}}
  Use `this` only when there is a name conflict. 
  Otherwise, Dart style omits the `this`.
{{site.alert.end}}


## Initializing formal parameters

Dart has *initializing formal parameters* to simplify the common pattern of
assigning a constructor argument to an instance variable. 
Use `this.propertyName` directly in the constructor declaration,
and omit the body. 

Initializing parameters also allow you to initialize
non-nullable or `final` instance variables,
which both must be initialized or provided a default value:

<?code-excerpt "misc/lib/language_tour/classes/point.dart (constructor-initializer)" plaster="none"?>
```dart
class Point {
  final double x;
  final double y;

  Point(this.x, this.y);
  // Sets the x and y instance variables
  // before the constructor body runs.
}
```

The variables introduced by the initializing formals
are implicitly final and only in scope of the
[initializer list](/language/constructors#initializer-list).

If you need to perform some logic that cannot be expressed in the initializer list,
create a [factory constructor](#factory-constructors) 
(or [static method][]) with that logic
and then pass the computed values to a normal constructor.


## Default constructors

If you don't declare a constructor, a default constructor is provided
for you. The default constructor has no arguments and invokes the
no-argument constructor in the superclass.


## Constructors aren't inherited

Subclasses don't inherit constructors from their superclass. A subclass
that declares no constructors has only the default (no argument, no
name) constructor.


## Named constructors

Use a named constructor to implement multiple constructors for a class
or to provide extra clarity:

<?code-excerpt "misc/lib/language_tour/classes/point.dart (named-constructor)" replace="/Point\.\S*/[!$&!]/g" plaster="none"?>
{% prettify dart tag=pre+code %}
const double xOrigin = 0;
const double yOrigin = 0;

class Point {
  final double x;
  final double y;

  Point(this.x, this.y);

  // Named constructor
  [!Point.origin()!]
      : x = xOrigin,
        y = yOrigin;
}
{% endprettify %}

Remember that constructors are not inherited, which means that a
superclass's named constructor is not inherited by a subclass. If you
want a subclass to be created with a named constructor defined in the
superclass, you must implement that constructor in the subclass.


## Invoking a non-default superclass constructor

By default, a constructor in a subclass calls the superclass's unnamed,
no-argument constructor.
The superclass's constructor is called at the beginning of the
constructor body. If an [initializer list](#initializer-list)
is also being used, it executes before the superclass is called.
In summary, the order of execution is as follows:

1. initializer list
1. superclass's no-arg constructor
1. main class's no-arg constructor

If the superclass doesn't have an unnamed, no-argument constructor,
then you must manually call one of the constructors in the
superclass. Specify the superclass constructor after a colon (`:`), just
before the constructor body (if any).

In the following example, the constructor for the Employee class calls the named
constructor for its superclass, Person. Click **Run** to execute the code.

<?code-excerpt "misc/lib/language_tour/classes/employee.dart (super)" plaster="none"?>
```dart:run-dartpad:height-450px:ga_id-non_default_superclass_constructor
class Person {
  String? firstName;

  Person.fromJson(Map data) {
    print('in Person');
  }
}

class Employee extends Person {
  // Person does not have a default constructor;
  // you must call super.fromJson().
  Employee.fromJson(super.data) : super.fromJson() {
    print('in Employee');
  }
}

void main() {
  var employee = Employee.fromJson({});
  print(employee);
  // Prints:
  // in Person
  // in Employee
  // Instance of 'Employee'
}
```

Because the arguments to the superclass constructor are evaluated before
invoking the constructor, an argument can be an expression such as a
function call:

<?code-excerpt "misc/lib/language_tour/classes/employee.dart (method-then-constructor)"?>
```dart
class Employee extends Person {
  Employee() : super.fromJson(fetchDefaultData());
  // ···
}
```

{{site.alert.warning}}
  Arguments to the superclass constructor don't have access to `this`. For
  example, arguments can call static methods but not instance methods.
{{site.alert.end}}

### Super parameters

To avoid having to manually pass each parameter
into the super invocation of a constructor,
you can use super-initializer parameters to forward parameters
to the specified or default superclass constructor.
This feature can't be used with redirecting constructors.
Super-initializer parameters have similar syntax and semantics to
[initializing formal parameters](#initializing-formal-parameters):

<?code-excerpt "misc/lib/language_tour/classes/super_initializer_parameters.dart (positional)" plaster="none"?>
```dart
class Vector2d {
  final double x;
  final double y;

  Vector2d(this.x, this.y);
}

class Vector3d extends Vector2d {
  final double z;

  // Forward the x and y parameters to the default super constructor like:
  // Vector3d(final double x, final double y, this.z) : super(x, y);
  Vector3d(super.x, super.y, this.z);
}
```

Super-initializer parameters cannot be positional 
if the super-constructor invocation already has positional arguments,
but they can always be named:

<?code-excerpt "misc/lib/language_tour/classes/super_initializer_parameters.dart (named)" plaster="none"?>
```dart
class Vector2d {
  // ...

  Vector2d.named({required this.x, required this.y});
}

class Vector3d extends Vector2d {
  // ...

  // Forward the y parameter to the named super constructor like:
  // Vector3d.yzPlane({required double y, required this.z})
  //       : super.named(x: 0, y: y);
  Vector3d.yzPlane({required super.y, required this.z}) : super.named(x: 0);
}
```

{{site.alert.version-note}}
  Using super-initializer parameters 
  requires a [language version][] of at least 2.17.
  If you're using an earlier language version,
  you must manually pass in all super constructor parameters.
{{site.alert.end}}

## Initializer list

Besides invoking a superclass constructor, you can also initialize
instance variables before the constructor body runs. Separate
initializers with commas.

<?code-excerpt "misc/lib/language_tour/classes/point_alt.dart (initializer-list)"?>
```dart
// Initializer list sets instance variables before
// the constructor body runs.
Point.fromJson(Map<String, double> json)
    : x = json['x']!,
      y = json['y']! {
  print('In Point.fromJson(): ($x, $y)');
}
```

{{site.alert.warning}}
  The right-hand side of an initializer doesn't have access to `this`.
{{site.alert.end}}

During development, you can validate inputs by using `assert` in the
initializer list.

<?code-excerpt "misc/lib/language_tour/classes/point_alt.dart (initializer-list-with-assert)" replace="/assert\(.*?\)/[!$&!]/g"?>
{% prettify dart tag=pre+code %}
Point.withAssert(this.x, this.y) : [!assert(x >= 0)!] {
  print('In Point.withAssert(): ($x, $y)');
}
{% endprettify %}

Initializer lists are handy when setting up final fields. The following example
initializes three final fields in an initializer list. Click **Run** to execute
the code.

<?code-excerpt "misc/lib/language_tour/classes/point_with_distance_field.dart"?>
```dart:run-dartpad:height-340px:ga_id-initializer_list
import 'dart:math';

class Point {
  final double x;
  final double y;
  final double distanceFromOrigin;

  Point(double x, double y)
      : x = x,
        y = y,
        distanceFromOrigin = sqrt(x * x + y * y);
}

void main() {
  var p = Point(2, 3);
  print(p.distanceFromOrigin);
}
```


## Redirecting constructors

Sometimes a constructor's only purpose is to redirect to another
constructor in the same class. A redirecting constructor's body is
empty, with the constructor call
(using `this` instead of the class name)
appearing after a colon (:).

<?code-excerpt "misc/lib/language_tour/classes/point_redirecting.dart"?>
```dart
class Point {
  double x, y;

  // The main constructor for this class.
  Point(this.x, this.y);

  // Delegates to the main constructor.
  Point.alongXAxis(double x) : this(x, 0);
}
```


## Constant constructors

If your class produces objects that never change, you can make these
objects compile-time constants. To do this, define a `const` constructor
and make sure that all instance variables are `final`.

<?code-excerpt "misc/lib/language_tour/classes/immutable_point.dart"?>
```dart
class ImmutablePoint {
  static const ImmutablePoint origin = ImmutablePoint(0, 0);

  final double x, y;

  const ImmutablePoint(this.x, this.y);
}
```

Constant constructors don't always create constants.
For details, see the section on
[using constructors][].


## Factory constructors

Use the `factory` keyword when implementing a constructor that doesn't
always create a new instance of its class. For example, a factory
constructor might return an instance from a cache, or it might
return an instance of a subtype.
Another use case for factory constructors is
initializing a final variable using
logic that can't be handled in the initializer list.

{{site.alert.tip}}
  Another way to handle late initialization of a final variable
  is to [use `late final` (carefully!)][late-final-ivar].
{{site.alert.end}}

In the following example,
the `Logger` factory constructor returns objects from a cache,
and the `Logger.fromJson` factory constructor
initializes a final variable from a JSON object.

<?code-excerpt "misc/lib/language_tour/classes/logger.dart"?>
```dart
class Logger {
  final String name;
  bool mute = false;

  // _cache is library-private, thanks to
  // the _ in front of its name.
  static final Map<String, Logger> _cache = <String, Logger>{};

  factory Logger(String name) {
    return _cache.putIfAbsent(name, () => Logger._internal(name));
  }

  factory Logger.fromJson(Map<String, Object> json) {
    return Logger(json['name'].toString());
  }

  Logger._internal(this.name);

  void log(String msg) {
    if (!mute) print(msg);
  }
}
```

{{site.alert.note}}
  Factory constructors have no access to `this`.
{{site.alert.end}}

Invoke a factory constructor just like you would any other constructor:

<?code-excerpt "misc/lib/language_tour/classes/logger.dart (logger)"?>
```dart
var logger = Logger('UI');
logger.log('Button clicked');

var logMap = {'name': 'UI'};
var loggerJson = Logger.fromJson(logMap);
```

[language version]: /guides/language/evolution#language-versioning
[using constructors]: /language/classes#using-constructors
[late-final-ivar]: /effective-dart/design#avoid-public-late-final-fields-without-initializers
[static method]: /language/classes#static-methods


---
title: Enumerated types
description: Learn about the enum type in Dart.
short-title: Enums
prevpage:
  url: /language/mixins
  title: Mixins
nextpage:
  url: /language/extension-methods
  title: Extension methods
---

Enumerated types, often called _enumerations_ or _enums_,
are a special kind of class used to represent
a fixed number of constant values.

{{site.alert.note}}
  All enums automatically extend the [`Enum`][] class.
  They are also sealed,
  meaning they cannot be subclassed, implemented, mixed in,
  or otherwise explicitly instantiated.

  Abstract classes and mixins can explicitly implement or extend `Enum`,
  but unless they are then implemented by or mixed into an enum declaration,
  no objects can actually implement the type of that class or mixin.
{{site.alert.end}}

## Declaring simple enums

To declare a simple enumerated type,
use the `enum` keyword and
list the values you want to be enumerated:

<?code-excerpt "misc/lib/language_tour/classes/enum.dart (enum)"?>
```dart
enum Color { red, green, blue }
```

{{site.alert.tip}}
  You can also use [trailing commas][] when declaring an enumerated type
  to help prevent copy-paste errors.
{{site.alert.end}}

## Declaring enhanced enums

Dart also allows enum declarations to declare classes
with fields, methods, and const constructors
which are limited to a fixed number of known constant instances.

To declare an enhanced enum,
follow a syntax similar to normal [classes][],
but with a few extra requirements:

* Instance variables must be `final`,
  including those added by [mixins][].
* All [generative constructors][] must be constant.
* [Factory constructors][] can only return
  one of the fixed, known enum instances.
* No other class can be extended as [`Enum`] is automatically extended.
* There cannot be overrides for `index`, `hashCode`, the equality operator `==`.
* A member named `values` cannot be declared in an enum,
  as it would conflict with the automatically generated static `values` getter.
* All instances of the enum must be declared
  in the beginning of the declaration,
  and there must be at least one instance declared.

Instance methods in an enhanced enum can use `this` to
reference the current enum value.

Here is an example that declares an enhanced enum
with multiple instances, instance variables,
getters, and an implemented interface:

<?code-excerpt "misc/lib/language_tour/classes/enum.dart (enhanced)"?>
```dart
enum Vehicle implements Comparable<Vehicle> {
  car(tires: 4, passengers: 5, carbonPerKilometer: 400),
  bus(tires: 6, passengers: 50, carbonPerKilometer: 800),
  bicycle(tires: 2, passengers: 1, carbonPerKilometer: 0);

  const Vehicle({
    required this.tires,
    required this.passengers,
    required this.carbonPerKilometer,
  });

  final int tires;
  final int passengers;
  final int carbonPerKilometer;

  int get carbonFootprint => (carbonPerKilometer / passengers).round();

  bool get isTwoWheeled => this == Vehicle.bicycle;

  @override
  int compareTo(Vehicle other) => carbonFootprint - other.carbonFootprint;
}
```

{{site.alert.version-note}}
  Enhanced enums require a [language version][] of at least 2.17.
{{site.alert.end}}

## Using enums

Access the enumerated values like
any other [static variable][]:

<?code-excerpt "misc/lib/language_tour/classes/enum.dart (access)"?>
```dart
final favoriteColor = Color.blue;
if (favoriteColor == Color.blue) {
  print('Your favorite color is blue!');
}
```

Each value in an enum has an `index` getter,
which returns the zero-based position of the value in the enum declaration.
For example, the first value has index 0,
and the second value has index 1.

<?code-excerpt "misc/lib/language_tour/classes/enum.dart (index)"?>
```dart
assert(Color.red.index == 0);
assert(Color.green.index == 1);
assert(Color.blue.index == 2);
```

To get a list of all the enumerated values,
use the enum's `values` constant.

<?code-excerpt "misc/lib/language_tour/classes/enum.dart (values)"?>
```dart
List<Color> colors = Color.values;
assert(colors[2] == Color.blue);
```

You can use enums in [switch statements][], and
you'll get a warning if you don't handle all of the enum's values:

<?code-excerpt "misc/lib/language_tour/classes/enum.dart (switch)"?>
```dart
var aColor = Color.blue;

switch (aColor) {
  case Color.red:
    print('Red as roses!');
  case Color.green:
    print('Green as grass!');
  default: // Without this, you see a WARNING.
    print(aColor); // 'Color.blue'
}
```

If you need to access the name of an enumerated value,
such as `'blue'` from `Color.blue`,
use the `.name` property:

<?code-excerpt "misc/lib/language_tour/classes/enum.dart (name)"?>
```dart
print(Color.blue.name); // 'blue'
```

You can access a member of an enum value
like you would on a normal object:

<?code-excerpt "misc/lib/language_tour/classes/enum.dart (method-call)"?>
```dart
print(Vehicle.car.carbonFootprint);
```

[`Enum`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-core/Enum-class.html
[trailing commas]: /language/collections#lists
[classes]: /language/classes
[mixins]: /language/mixins
[generative constructors]: /language/constructors#constant-constructors
[Factory constructors]: /language/constructors#factory-constructors
[language version]: /guides/language/evolution#language-versioning
[static variable]: /language/classes#class-variables-and-methods
[switch statements]: /language/branches#switch


---
title: Error handling
description: Learn about handling errors and exceptions in Dart.
prevpage:
  url: /language/branches
  title: Branches
nextpage:
  url: /language/classes
  title: Classes
---

## Exceptions

Your Dart code can throw and catch exceptions. Exceptions are errors
indicating that something unexpected happened. If the exception isn't
caught, the [isolate][] that raised the exception is suspended,
and typically the isolate and its program are terminated.

In contrast to Java, all of Dart's exceptions are unchecked exceptions.
Methods don't declare which exceptions they might throw, and you aren't
required to catch any exceptions.

Dart provides [`Exception`][] and [`Error`][]
types, as well as numerous predefined subtypes. You can, of course,
define your own exceptions. However, Dart programs can throw any
non-null object—not just Exception and Error objects—as an exception.

### Throw

Here's an example of throwing, or *raising*, an exception:

<?code-excerpt "misc/lib/language_tour/exceptions.dart (throw-FormatException)"?>
```dart
throw FormatException('Expected at least 1 section');
```

You can also throw arbitrary objects:

<?code-excerpt "misc/lib/language_tour/exceptions.dart (out-of-llamas)"?>
```dart
throw 'Out of llamas!';
```

{{site.alert.note}}
  Production-quality code usually throws types that implement [`Error`][] or
  [`Exception`][].
{{site.alert.end}}

Because throwing an exception is an expression, you can throw exceptions
in =\> statements, as well as anywhere else that allows expressions:

<?code-excerpt "misc/lib/language_tour/exceptions.dart (throw-is-an-expression)"?>
```dart
void distanceTo(Point other) => throw UnimplementedError();
```


### Catch

Catching, or capturing, an exception stops the exception from
propagating (unless you rethrow the exception).
Catching an exception gives you a chance to handle it:

<?code-excerpt "misc/lib/language_tour/exceptions.dart (try)"?>
```dart
try {
  breedMoreLlamas();
} on OutOfLlamasException {
  buyMoreLlamas();
}
```

To handle code that can throw more than one type of exception, you can
specify multiple catch clauses. The first catch clause that matches the
thrown object's type handles the exception. If the catch clause does not
specify a type, that clause can handle any type of thrown object:

<?code-excerpt "misc/lib/language_tour/exceptions.dart (try-catch)"?>
```dart
try {
  breedMoreLlamas();
} on OutOfLlamasException {
  // A specific exception
  buyMoreLlamas();
} on Exception catch (e) {
  // Anything else that is an exception
  print('Unknown exception: $e');
} catch (e) {
  // No specified type, handles all
  print('Something really unknown: $e');
}
```

As the preceding code shows, you can use either `on` or `catch` or both.
Use `on` when you need to specify the exception type. Use `catch` when
your exception handler needs the exception object.

You can specify one or two parameters to `catch()`.
The first is the exception that was thrown,
and the second is the stack trace (a [`StackTrace`][] object).

<?code-excerpt "misc/lib/language_tour/exceptions.dart (try-catch-2)" replace="/\(e.*?\)/[!$&!]/g"?>
{% prettify dart tag=pre+code %}
try {
  // ···
} on Exception catch [!(e)!] {
  print('Exception details:\n $e');
} catch [!(e, s)!] {
  print('Exception details:\n $e');
  print('Stack trace:\n $s');
}
{% endprettify %}

To partially handle an exception,
while allowing it to propagate,
use the `rethrow` keyword.

<?code-excerpt "misc/test/language_tour/exceptions_test.dart (rethrow)" replace="/rethrow;/[!$&!]/g"?>
{% prettify dart tag=pre+code %}
void misbehave() {
  try {
    dynamic foo = true;
    print(foo++); // Runtime error
  } catch (e) {
    print('misbehave() partially handled ${e.runtimeType}.');
    [!rethrow;!] // Allow callers to see the exception.
  }
}

void main() {
  try {
    misbehave();
  } catch (e) {
    print('main() finished handling ${e.runtimeType}.');
  }
}
{% endprettify %}


### Finally

To ensure that some code runs whether or not an exception is thrown, use
a `finally` clause. If no `catch` clause matches the exception, the
exception is propagated after the `finally` clause runs:

<?code-excerpt "misc/lib/language_tour/exceptions.dart (finally)"?>
```dart
try {
  breedMoreLlamas();
} finally {
  // Always clean up, even if an exception is thrown.
  cleanLlamaStalls();
}
```

The `finally` clause runs after any matching `catch` clauses:

<?code-excerpt "misc/lib/language_tour/exceptions.dart (try-catch-finally)"?>
```dart
try {
  breedMoreLlamas();
} catch (e) {
  print('Error: $e'); // Handle the exception first.
} finally {
  cleanLlamaStalls(); // Then clean up.
}
```

Learn more by reading the
[Exceptions](/guides/libraries/library-tour#exceptions)
section of the library tour.

## Assert

During development, use an assert 
statement— `assert(<condition>, <optionalMessage>);` —to
disrupt normal execution if a boolean condition is false. 

<?code-excerpt "misc/test/language_tour/control_flow_test.dart (assert)"?>
```dart
// Make sure the variable has a non-null value.
assert(text != null);

// Make sure the value is less than 100.
assert(number < 100);

// Make sure this is an https URL.
assert(urlString.startsWith('https'));
```

To attach a message to an assertion,
add a string as the second argument to `assert`
(optionally with a [trailing comma][]):

<?code-excerpt "misc/test/language_tour/control_flow_test.dart (assert-with-message)"?>
```dart
assert(urlString.startsWith('https'),
    'URL ($urlString) should start with "https".');
```

The first argument to `assert` can be any expression that
resolves to a boolean value. If the expression's value
is true, the assertion succeeds and execution
continues. If it's false, the assertion fails and an exception (an
[`AssertionError`][]) is thrown.

When exactly do assertions work?
That depends on the tools and framework you're using:

* Flutter enables assertions in [debug mode.][Flutter debug mode]
* Development-only tools such as [`webdev serve`][]
  typically enable assertions by default.
* Some tools, such as [`dart run`][] and [`dart compile js`][]
  support assertions through a command-line flag: `--enable-asserts`.

In production code, assertions are ignored, and
the arguments to `assert` aren't evaluated.

[trailing comma]: /language/collections#trailing-comma
[`AssertionError`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-core/AssertionError-class.html
[Flutter debug mode]: {{site.flutter-docs}}/testing/debugging#debug-mode-assertions
[`webdev serve`]: /tools/webdev#serve
[`dart run`]: /tools/dart-run
[`dart compile js`]: /tools/dart-compile#js

[isolate]: /language/concurrency#how-isolates-work
[`Error`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-core/Error-class.html
[`Exception`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-core/Exception-class.html
[`StackTrace`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-core/StackTrace-class.html


---
title: Extend a class
description: Learn how to create subclasses from a superclass.
prevpage:
  url: /language/methods
  title: Methods
nextpage:
  url: /language/mixins
  title: Mixins
---

Use `extends` to create a subclass, and `super` to refer to the
superclass:

<?code-excerpt "misc/lib/language_tour/classes/extends.dart" replace="/extends|super/[!$&!]/g"?>
{% prettify dart tag=pre+code %}
class Television {
  void turnOn() {
    _illuminateDisplay();
    _activateIrSensor();
  }
  // ···
}

class SmartTelevision [!extends!] Television {
  void turnOn() {
    [!super!].turnOn();
    _bootNetworkInterface();
    _initializeMemory();
    _upgradeApps();
  }
  // ···
}
{% endprettify %}

For another usage of `extends`, see the discussion of
[parameterized types][] on the Generics page.

## Overriding members

Subclasses can override instance methods (including [operators][]),
getters, and setters.
You can use the `@override` annotation to indicate that you are
intentionally overriding a member:

<?code-excerpt "misc/lib/language_tour/metadata/television.dart (override)" replace="/@override/[!$&!]/g"?>
{% prettify dart tag=pre+code %}
class Television {
  // ···
  set contrast(int value) {...}
}

class SmartTelevision extends Television {
  [!@override!]
  set contrast(num value) {...}
  // ···
}
{% endprettify %}

An overriding method declaration must match
the method (or methods) that it overrides in several ways:

* The return type must be the same type as (or a subtype of)
  the overridden method's return type.
* Argument types must be the same type as (or a supertype of)
  the overridden method's argument types.
  In the preceding example, the `contrast` setter of `SmartTelevision`
  changes the argument type from `int` to a supertype, `num`.
* If the overridden method accepts _n_ positional parameters,
  then the overriding method must also accept _n_ positional parameters.
* A [generic method][] can't override a non-generic one,
  and a non-generic method can't override a generic one.

Sometimes you might want to narrow the type of
a method parameter or an instance variable.
This violates the normal rules, and
it's similar to a downcast in that it can cause a type error at runtime.
Still, narrowing the type is possible
if the code can guarantee that a type error won't occur.
In this case, you can use the 
[`covariant` keyword](/guides/language/sound-problems#the-covariant-keyword)
in a parameter declaration.
For details, see the 
[Dart language specification][].

{{site.alert.warning}}
  If you override `==`, you should also override Object's `hashCode` getter.
  For an example of overriding `==` and `hashCode`, see
  [Implementing map keys](/guides/libraries/library-tour#implementing-map-keys).
{{site.alert.end}}

## noSuchMethod()

To detect or react whenever code attempts to use a non-existent method or
instance variable, you can override `noSuchMethod()`:

<?code-excerpt "misc/lib/language_tour/classes/no_such_method.dart" replace="/noSuchMethod(?!,)/[!$&!]/g"?>
{% prettify dart tag=pre+code %}
class A {
  // Unless you override noSuchMethod, using a
  // non-existent member results in a NoSuchMethodError.
  @override
  void [!noSuchMethod!](Invocation invocation) {
    print('You tried to use a non-existent member: '
        '${invocation.memberName}');
  }
}
{% endprettify %}

You **can't invoke** an unimplemented method unless
**one** of the following is true:

* The receiver has the static type `dynamic`.

* The receiver has a static type that
defines the unimplemented method (abstract is OK),
and the dynamic type of the receiver has an implementation of `noSuchMethod()`
that's different from the one in class `Object`.

For more information, see the informal
[noSuchMethod forwarding specification.](https://github.com/dart-lang/language/blob/main/archive/feature-specifications/nosuchmethod-forwarding.md)

[parameterized types]: /language/generics#restricting-the-parameterized-type
[operators]: /language/methods#operators
[generic method]: /language/generics#using-generic-methods
[Dart language specification]: /guides/language/spec


---
title: Extension methods
description: Learn how to add to existing APIs.
prevpage:
  url: /language/enums
  title: Enums
nextpage:
  url: /language/callable-objects
  title: Callable objects
---

Extension methods add functionality to existing libraries.
You might use extension methods without even knowing it.
For example, when you use code completion in an IDE,
it suggests extension methods alongside regular methods.

<iframe width="560" height="315"
src="https://www.youtube.com/embed/D3j0OSfT9ZI"
frameborder="0"
allow="accelerometer; encrypted-media; gyroscope; picture-in-picture"
allowfullscreen>
</iframe>
_If you like to learn by watching videos,
here's a good overview of extension methods._

## Overview

When you're using someone else's API or
when you implement a library that's widely used,
it's often impractical or impossible to change the API.
But you might still want to add some functionality.

For example, consider the following code that parses a string into an integer:

```dart
int.parse('42')
```

It might be nice—shorter and easier to use with tools—to
have that functionality be on `String` instead:

```dart
'42'.parseInt()
```

To enable that code,
you can import a library that contains an extension of the `String` class:

<?code-excerpt "extension_methods/lib/string_extensions/usage_simple_extension.dart (basic)" replace="/  print/print/g"?>
```dart
import 'string_apis.dart';
// ···
print('42'.parseInt()); // Use an extension method.
```

Extensions can define not just methods,
but also other members such as getter, setters, and operators.
Also, extensions can have names, which can be helpful if an API conflict arises.
Here's how you might implement the extension method `parseInt()`,
using an extension (named `NumberParsing`) that operates on strings:

<?code-excerpt "extension_methods/lib/string_extensions/string_apis.dart (parseInt)"?>
```dart
extension NumberParsing on String {
  int parseInt() {
    return int.parse(this);
  }
  // ···
}
```
<div class="prettify-filename">lib/string_apis.dart</div>

The next section describes how to _use_ extension methods.
After that are sections about _implementing_ extension methods.


## Using extension methods

Like all Dart code, extension methods are in libraries.
You've already seen how to use an extension method—just 
import the library it's in, and use it like an ordinary method:

<?code-excerpt "extension_methods/lib/string_extensions/usage_simple_extension.dart (import-and-use)" replace="/  print/print/g"?>
```dart
// Import a library that contains an extension on String.
import 'string_apis.dart';
// ···
print('42'.padLeft(5)); // Use a String method.
print('42'.parseInt()); // Use an extension method.
```

That's all you usually need to know to use extension methods.
As you write your code, you might also need to know
how extension methods depend on static types (as opposed to `dynamic`) and
how to resolve [API conflicts](#api-conflicts).

### Static types and dynamic

You can't invoke extension methods on variables of type `dynamic`.
For example, the following code results in a runtime exception:

<?code-excerpt "extension_methods/lib/string_extensions/usage_simple_extension.dart (dynamic)" plaster="none" replace="/  \/\/ print/print/g"?>
```dart
dynamic d = '2';
print(d.parseInt()); // Runtime exception: NoSuchMethodError
```

Extension methods _do_ work with Dart's type inference.
The following code is fine because
the variable `v` is inferred to have type `String`:

<?code-excerpt "extension_methods/lib/string_extensions/usage_simple_extension.dart (var)"?>
```dart
var v = '2';
print(v.parseInt()); // Output: 2
```

The reason that `dynamic` doesn't work is that
extension methods are resolved against the static type of the receiver.
Because extension methods are resolved statically,
they're as fast as calling a static function.

For more information about static types and `dynamic`, see
[The Dart type system](/language/type-system).

### API conflicts

If an extension member conflicts with
an interface or with another extension member,
then you have a few options.

One option is changing how you import the conflicting extension,
using `show` or `hide` to limit the exposed API:

<?code-excerpt "extension_methods/lib/string_extensions/usage_import.dart" replace="/  //g"?>
```dart
// Defines the String extension method parseInt().
import 'string_apis.dart';

// Also defines parseInt(), but hiding NumberParsing2
// hides that extension method.
import 'string_apis_2.dart' hide NumberParsing2;

// ···
// Uses the parseInt() defined in 'string_apis.dart'.
print('42'.parseInt());
```

Another option is applying the extension explicitly,
which results in code that looks as if the extension is a wrapper class:

<?code-excerpt "extension_methods/lib/string_extensions/usage_explicit.dart" replace="/  //g"?>
```dart
// Both libraries define extensions on String that contain parseInt(),
// and the extensions have different names.
import 'string_apis.dart'; // Contains NumberParsing extension.
import 'string_apis_2.dart'; // Contains NumberParsing2 extension.

// ···
// print('42'.parseInt()); // Doesn't work.
print(NumberParsing('42').parseInt());
print(NumberParsing2('42').parseInt());
```

If both extensions have the same name,
then you might need to import using a prefix:

<?code-excerpt "extension_methods/lib/string_extensions/usage_prefix.dart" replace="/  //g"?>
```dart
// Both libraries define extensions named NumberParsing
// that contain the extension method parseInt(). One NumberParsing
// extension (in 'string_apis_3.dart') also defines parseNum().
import 'string_apis.dart';
import 'string_apis_3.dart' as rad;

// ···
// print('42'.parseInt()); // Doesn't work.

// Use the ParseNumbers extension from string_apis.dart.
print(NumberParsing('42').parseInt());

// Use the ParseNumbers extension from string_apis_3.dart.
print(rad.NumberParsing('42').parseInt());

// Only string_apis_3.dart has parseNum().
print('42'.parseNum());
```

As the example shows,
you can invoke extension methods implicitly even if you import using a prefix.
The only time you need to use the prefix is
to avoid a name conflict when invoking an extension explicitly.


## Implementing extension methods

Use the following syntax to create an extension:

```
extension <extension name>? on <type> {
  (<member definition>)*
}
```

For example, here's how you might implement an extension on the `String` class:

<?code-excerpt "extension_methods/lib/string_extensions/string_apis.dart"?>
```dart
extension NumberParsing on String {
  int parseInt() {
    return int.parse(this);
  }

  double parseDouble() {
    return double.parse(this);
  }
}
```
<div class="prettify-filename">lib/string_apis.dart</div>

The members of an extension can be methods, getters, setters, or operators.
Extensions can also have static fields and static helper methods.
To access static members outside the extension declaration, 
invoke them through the declaration name like [class variables and methods][]. 

[class variables and methods]: /language/classes#class-variables-and-methods

### Unnamed extensions

When declaring an extension, you can omit the name.
Unnamed extensions are visible only
in the library where they're declared.
Since they don't have a name,
they can't be explicitly applied
to resolve [API conflicts](#api-conflicts).

<?code-excerpt "extension_methods/lib/string_extensions/string_apis_unnamed.dart (unnamed)"?>
```dart
extension on String {
  bool get isBlank => trim().isEmpty;
}
```

{{site.alert.note}}
  You can invoke an unnamed extension's static members
  only within the extension declaration.
{{site.alert.end}}

## Implementing generic extensions

Extensions can have generic type parameters.
For example, here's some code that extends the built-in `List<T>` type
with a getter, an operator, and a method:

<?code-excerpt "extension_methods/lib/fancylist.dart"?>
```dart
extension MyFancyList<T> on List<T> {
  int get doubleLength => length * 2;
  List<T> operator -() => reversed.toList();
  List<List<T>> split(int at) => [sublist(0, at), sublist(at)];
}
```

The type `T` is bound based on the static type of the list that
the methods are called on.
{% comment %}
TODO (https://github.com/dart-lang/site-www/issues/2171):
Add more info about generic extensions. 
For example, in the following code, `T` is `PENDING` because PENDING:

[PENDING: example]

[PENDING: Explain why it matters in normal usage.]
{% endcomment %}

## Resources

For more information about extension methods, see the following:

* [Article: Dart Extension Methods Fundamentals][article]
* [Feature specification][specification]
* [Extension methods sample][sample]

[specification]: https://github.com/dart-lang/language/blob/main/accepted/2.7/static-extension-methods/feature-specification.md#dart-static-extension-methods-design
[article]: https://medium.com/dartlang/extension-methods-2d466cd8b308
[sample]: https://github.com/dart-lang/samples/tree/main/extension_methods


---
title: Functions
description: Everything about functions in Dart.
js: [{url: 'https://dartpad.dev/inject_embed.dart.js', defer: true}]
prevpage:
  url: /language/pattern-types
  title: Pattern types
nextpage:
  url: /language/loops
  title: Loops
---

Dart is a true object-oriented language, so even functions are objects
and have a type, [Function.][Function API reference]
This means that functions can be assigned to variables or passed as arguments
to other functions. You can also call an instance of a Dart class as if
it were a function. For details, see [Callable objects][].

Here's an example of implementing a function:

<?code-excerpt "misc/lib/language_tour/functions.dart (function)"?>
```dart
bool isNoble(int atomicNumber) {
  return _nobleGases[atomicNumber] != null;
}
```

Although Effective Dart recommends
[type annotations for public APIs][],
the function still works if you omit the types:

<?code-excerpt "misc/lib/language_tour/functions.dart (function-omitting-types)"?>
```dart
isNoble(atomicNumber) {
  return _nobleGases[atomicNumber] != null;
}
```

For functions that contain just one expression, you can use a shorthand
syntax:

<?code-excerpt "misc/lib/language_tour/functions.dart (function-shorthand)"?>
```dart
bool isNoble(int atomicNumber) => _nobleGases[atomicNumber] != null;
```

The <code>=> <em>expr</em></code> syntax is a shorthand for
<code>{ return <em>expr</em>; }</code>. The `=>` notation
is sometimes referred to as _arrow_ syntax.

{{site.alert.note}}
  Only an *expression*—not a *statement*—can appear between the arrow (=\>) and
  the semicolon (;). For example, you can't put an [if statement][]
  there, but you can use a [conditional expression][].
{{site.alert.end}}

## Parameters

A function can have any number of *required positional* parameters. These can be
followed either by *named* parameters or by *optional positional* parameters
(but not both).

{{site.alert.note}}
  Some APIs—notably [Flutter][] widget constructors—use only named
  parameters, even for parameters that are mandatory. See the next section for
  details.
{{site.alert.end}}

You can use [trailing commas][] when you pass arguments to a function
or when you define function parameters.


### Named parameters

Named parameters are optional
unless they're explicitly marked as `required`.

When defining a function, use
<code>{<em>param1</em>, <em>param2</em>, …}</code>
to specify named parameters.
If you don't provide a default value
or mark a named parameter as `required`,
their types must be nullable
as their default value will be `null`:

<?code-excerpt "misc/lib/language_tour/functions.dart (specify-named-parameters)"?>
```dart
/// Sets the [bold] and [hidden] flags ...
void enableFlags({bool? bold, bool? hidden}) {...}
```

When calling a function, 
you can specify named arguments using
<code><em>paramName</em>: <em>value</em></code>. 
For example:

<?code-excerpt "misc/lib/language_tour/functions.dart (use-named-parameters)"?>
```dart
enableFlags(bold: true, hidden: false);
```

<a id="default-parameters"></a>
To define a default value for a named parameter besides `null`,
use `=` to specify a default value.
The specified value must be a compile-time constant.
For example:

<?code-excerpt "misc/lib/language_tour/functions.dart (named-parameter-default-values)"?>
```dart
/// Sets the [bold] and [hidden] flags ...
void enableFlags({bool bold = false, bool hidden = false}) {...}

// bold will be true; hidden will be false.
enableFlags(bold: true);
```

If you instead want a named parameter to be mandatory,
requiring callers to provide a value for the parameter,
annotate them with `required`:

<?code-excerpt "misc/lib/language_tour/functions.dart (required-named-parameters)" replace="/required/[!$&!]/g"?>
```dart
const Scrollbar({super.key, [!required!] Widget child});
```

If someone tries to create a `Scrollbar`
without specifying the `child` argument,
then the analyzer reports an issue.

{{site.alert.note}}
  A parameter marked as `required`
  can still be nullable:

  <?code-excerpt "misc/lib/language_tour/functions.dart (required-named-parameters-nullable)" replace="/Widget\?/[!$&!]/g; /ScrollbarTwo/Scrollbar/g;"?>
  ```dart
  const Scrollbar({super.key, required [!Widget?!] child});
  ```
{{site.alert.end}}

You might want to place positional arguments first,
but Dart doesn't require it.
Dart allows named arguments to be placed anywhere in the
argument list when it suits your API:

<?code-excerpt "misc/lib/language_tour/functions.dart (named-arguments-anywhere)"?>
```dart
repeat(times: 2, () {
  ...
});
```

### Optional positional parameters

Wrapping a set of function parameters in `[]`
marks them as optional positional parameters.
If you don't provide a default value,
their types must be nullable
as their default value will be `null`:

<?code-excerpt "misc/test/language_tour/functions_test.dart (optional-positional-parameters)"?>
```dart
String say(String from, String msg, [String? device]) {
  var result = '$from says $msg';
  if (device != null) {
    result = '$result with a $device';
  }
  return result;
}
```

Here's an example of calling this function
without the optional parameter:

<?code-excerpt "misc/test/language_tour/functions_test.dart (call-without-optional-param)"?>
```dart
assert(say('Bob', 'Howdy') == 'Bob says Howdy');
```

And here's an example of calling this function with the third parameter:

<?code-excerpt "misc/test/language_tour/functions_test.dart (call-with-optional-param)"?>
```dart
assert(say('Bob', 'Howdy', 'smoke signal') ==
    'Bob says Howdy with a smoke signal');
```

To define a default value for an optional positional parameter besides `null`,
use `=` to specify a default value.
The specified value must be a compile-time constant.
For example:

<?code-excerpt "misc/test/language_tour/functions_test.dart (optional-positional-param-default)"?>
```dart
String say(String from, String msg, [String device = 'carrier pigeon']) {
  var result = '$from says $msg with a $device';
  return result;
}

assert(say('Bob', 'Howdy') == 'Bob says Howdy with a carrier pigeon');
```


## The main() function

Every app must have a top-level `main()` function, which serves as the
entrypoint to the app. The `main()` function returns `void` and has an
optional `List<String>` parameter for arguments.

Here's a simple `main()` function:

<?code-excerpt "misc/test/samples_test.dart (hello-world)"?>
```dart
void main() {
  print('Hello, World!');
}
```

Here's an example of the `main()` function for a command-line app that
takes arguments:

<?code-excerpt "misc/test/language_tour/functions_test.dart (main-args)"?>
```dart
// Run the app like this: dart args.dart 1 test
void main(List<String> arguments) {
  print(arguments);

  assert(arguments.length == 2);
  assert(int.parse(arguments[0]) == 1);
  assert(arguments[1] == 'test');
}
```

You can use the [args library]({{site.pub-pkg}}/args) to
define and parse command-line arguments.

## Functions as first-class objects

You can pass a function as a parameter to another function. For example:

<?code-excerpt "misc/lib/language_tour/functions.dart (function-as-param)"?>
```dart
void printElement(int element) {
  print(element);
}

var list = [1, 2, 3];

// Pass printElement as a parameter.
list.forEach(printElement);
```

You can also assign a function to a variable, such as:

<?code-excerpt "misc/test/language_tour/functions_test.dart (function-as-var)"?>
```dart
var loudify = (msg) => '!!! ${msg.toUpperCase()} !!!';
assert(loudify('hello') == '!!! HELLO !!!');
```

This example uses an anonymous function.
More about those in the next section.

## Anonymous functions

Most functions are named, such as `main()` or `printElement()`.
You can also create a nameless function
called an _anonymous function_, or sometimes a _lambda_ or _closure_.
You might assign an anonymous function to a variable so that,
for example, you can add or remove it from a collection.

An anonymous function looks similar
to a named function—zero or more parameters, separated by commas
and optional type annotations, between parentheses.

The code block that follows contains the function's body:

<code>
([[<em>Type</em>] <em>param1</em>[, …]]) { <br>
&nbsp;&nbsp;<em>codeBlock</em>; <br>
}; <br>
</code>

The following example defines an anonymous function
with an untyped parameter, `item`,
and passes it to the `map` function.
The function, invoked for each item in the list,
converts each string to uppercase.
Then in the anonymous function passed to `forEach`,
each converted string is printed out alongside its length.

<?code-excerpt "misc/test/language_tour/functions_test.dart (anonymous-function)"?>
```dart
const list = ['apples', 'bananas', 'oranges'];
list.map((item) {
  return item.toUpperCase();
}).forEach((item) {
  print('$item: ${item.length}');
});
```

Click **Run** to execute the code.

<?code-excerpt "misc/test/language_tour/functions_test.dart (anonymous-function-main)"?>
```dart:run-dartpad:height-400px:ga_id-anonymous_functions
void main() {
  const list = ['apples', 'bananas', 'oranges'];
  list.map((item) {
    return item.toUpperCase();
  }).forEach((item) {
    print('$item: ${item.length}');
  });
}
```

If the function contains only a single expression or return statement,
you can shorten it using arrow notation. 
Paste the following line into DartPad and click **Run**
to verify that it is functionally equivalent.

<?code-excerpt "misc/test/language_tour/functions_test.dart (anon-func)"?>
```dart
list
    .map((item) => item.toUpperCase())
    .forEach((item) => print('$item: ${item.length}'));
```


## Lexical scope

Dart is a lexically scoped language, which means that the scope of
variables is determined statically, simply by the layout of the code.
You can "follow the curly braces outwards" to see if a variable is in
scope.

Here is an example of nested functions with variables at each scope
level:

<?code-excerpt "misc/test/language_tour/functions_test.dart (nested-functions)"?>
```dart
bool topLevel = true;

void main() {
  var insideMain = true;

  void myFunction() {
    var insideFunction = true;

    void nestedFunction() {
      var insideNestedFunction = true;

      assert(topLevel);
      assert(insideMain);
      assert(insideFunction);
      assert(insideNestedFunction);
    }
  }
}
```

Notice how `nestedFunction()` can use variables from every level, all
the way up to the top level.


## Lexical closures

A *closure* is a function object that has access to variables in its
lexical scope, even when the function is used outside of its original
scope.

Functions can close over variables defined in surrounding scopes. In the
following example, `makeAdder()` captures the variable `addBy`. Wherever the
returned function goes, it remembers `addBy`.

<?code-excerpt "misc/test/language_tour/functions_test.dart (function-closure)"?>
```dart
/// Returns a function that adds [addBy] to the
/// function's argument.
Function makeAdder(int addBy) {
  return (int i) => addBy + i;
}

void main() {
  // Create a function that adds 2.
  var add2 = makeAdder(2);

  // Create a function that adds 4.
  var add4 = makeAdder(4);

  assert(add2(3) == 5);
  assert(add4(3) == 7);
}
```


## Testing functions for equality

Here's an example of testing top-level functions, static methods, and
instance methods for equality:

<?code-excerpt "misc/lib/language_tour/function_equality.dart"?>
```dart
void foo() {} // A top-level function

class A {
  static void bar() {} // A static method
  void baz() {} // An instance method
}

void main() {
  Function x;

  // Comparing top-level functions.
  x = foo;
  assert(foo == x);

  // Comparing static methods.
  x = A.bar;
  assert(A.bar == x);

  // Comparing instance methods.
  var v = A(); // Instance #1 of A
  var w = A(); // Instance #2 of A
  var y = w;
  x = w.baz;

  // These closures refer to the same instance (#2),
  // so they're equal.
  assert(y.baz == x);

  // These closures refer to different instances,
  // so they're unequal.
  assert(v.baz != w.baz);
}
```


## Return values

All functions return a value. If no return value is specified, the
statement `return null;` is implicitly appended to the function body.

<?code-excerpt "misc/test/language_tour/functions_test.dart (implicit-return-null)"?>
```dart
foo() {}

assert(foo() == null);
```

To return multiple values in a function, aggregate the values in a [record][].

```dart
(String, int) foo() {
  return ('something', 42);
}
```

## Generators

When you need to lazily produce a sequence of values,
consider using a _generator function_.
Dart has built-in support for two kinds of generator functions:

* **Synchronous** generator: Returns an [`Iterable`] object.
* **Asynchronous** generator: Returns a [`Stream`] object.

To implement a **synchronous** generator function,
mark the function body as `sync*`,
and use `yield` statements to deliver values:

<?code-excerpt "misc/test/language_tour/async_test.dart (sync-generator)"?>
```dart
Iterable<int> naturalsTo(int n) sync* {
  int k = 0;
  while (k < n) yield k++;
}
```

To implement an **asynchronous** generator function,
mark the function body as `async*`,
and use `yield` statements to deliver values:

<?code-excerpt "misc/test/language_tour/async_test.dart (async-generator)"?>
```dart
Stream<int> asynchronousNaturalsTo(int n) async* {
  int k = 0;
  while (k < n) yield k++;
}
```

If your generator is recursive,
you can improve its performance by using `yield*`:

<?code-excerpt "misc/test/language_tour/async_test.dart (recursive-generator)"?>
```dart
Iterable<int> naturalsDownFrom(int n) sync* {
  if (n > 0) {
    yield n;
    yield* naturalsDownFrom(n - 1);
  }
}
```

[`Iterable`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-core/Iterable-class.html
[`Stream`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-async/Stream-class.html
[record]: /language/records#multiple-returns

[Function API reference]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-core/Function-class.html
[Callable objects]: /language/callable-objects
[type annotations for public APIs]: /effective-dart/design#do-type-annotate-fields-and-top-level-variables-if-the-type-isnt-obvious
[if statement]: /language/branches#if
[conditional expression]: /language/operators#conditional-expressions
[Flutter]: {{site.flutter}}
[trailing commas]: /language/collections#lists


---
title: Generics
description: Learn about generic types in Dart.
prevpage:
  url: /language/collections
  title: Collections
nextpage:
  url: /language/typedefs
  title: Typedefs
---

<?code-excerpt replace="/ *\/\/\s+ignore_for_file:[^\n]+\n//g; /(^|\n) *\/\/\s+ignore:[^\n]+\n/$1/g; /(\n[^\n]+) *\/\/\s+ignore:[^\n]+\n/$1\n/g; / *\/\/\s+ignore:[^\n]+//g; /([A-Z]\w*)\d\b/$1/g"?>

If you look at the API documentation for the basic array type,
[`List`][], you'll see that the
type is actually `List<E>`. The \<...\> notation marks List as a
*generic* (or *parameterized*) type—a type that has formal type
parameters. [By convention][], most type variables have single-letter names,
such as E, T, S, K, and V.

## Why use generics?

Generics are often required for type safety, but they have more benefits
than just allowing your code to run:

* Properly specifying generic types results in better generated code.
* You can use generics to reduce code duplication.

If you intend for a list to contain only strings, you can
declare it as `List<String>` (read that as "list of string"). That way
you, your fellow programmers, and your tools can detect that assigning a non-string to
the list is probably a mistake. Here's an example:

{:.fails-sa}
```dart
var names = <String>[];
names.addAll(['Seth', 'Kathy', 'Lars']);
names.add(42); // Error
```

Another reason for using generics is to reduce code duplication.
Generics let you share a single interface and implementation between
many types, while still taking advantage of static
analysis. For example, say you create an interface for
caching an object:

<?code-excerpt "misc/lib/language_tour/generics/cache.dart (ObjectCache)"?>
```dart
abstract class ObjectCache {
  Object getByKey(String key);
  void setByKey(String key, Object value);
}
```

You discover that you want a string-specific version of this interface,
so you create another interface:

<?code-excerpt "misc/lib/language_tour/generics/cache.dart (StringCache)"?>
```dart
abstract class StringCache {
  String getByKey(String key);
  void setByKey(String key, String value);
}
```

Later, you decide you want a number-specific version of this
interface... You get the idea.

Generic types can save you the trouble of creating all these interfaces.
Instead, you can create a single interface that takes a type parameter:

<?code-excerpt "misc/lib/language_tour/generics/cache.dart (Cache)"?>
```dart
abstract class Cache<T> {
  T getByKey(String key);
  void setByKey(String key, T value);
}
```

In this code, T is the stand-in type. It's a placeholder that you can
think of as a type that a developer will define later.


## Using collection literals

List, set, and map literals can be parameterized. Parameterized literals are
just like the literals you've already seen, except that you add
<code>&lt;<em>type</em>></code> (for lists and sets) or
<code>&lt;<em>keyType</em>, <em>valueType</em>></code> (for maps)
before the opening bracket. Here is an example of using typed literals:

<?code-excerpt "misc/lib/language_tour/generics/misc.dart (collection-literals)"?>
```dart
var names = <String>['Seth', 'Kathy', 'Lars'];
var uniqueNames = <String>{'Seth', 'Kathy', 'Lars'};
var pages = <String, String>{
  'index.html': 'Homepage',
  'robots.txt': 'Hints for web robots',
  'humans.txt': 'We are people, not machines'
};
```


## Using parameterized types with constructors

To specify one or more types when using a constructor, put the types in
angle brackets (`<...>`) just after the class name. For example:

<?code-excerpt "misc/test/language_tour/generics_test.dart (constructor-1)"?>
```dart
var nameSet = Set<String>.from(names);
```

The following code creates a map that has integer keys and values of
type View:

<?code-excerpt "misc/test/language_tour/generics_test.dart (constructor-2)"?>
```dart
var views = Map<int, View>();
```


## Generic collections and the types they contain

Dart generic types are *reified*, which means that they carry their type
information around at runtime. For example, you can test the type of a
collection:

<?code-excerpt "misc/test/language_tour/generics_test.dart (generic-collections)"?>
```dart
var names = <String>[];
names.addAll(['Seth', 'Kathy', 'Lars']);
print(names is List<String>); // true
```

{{site.alert.note}}
  In contrast, generics in Java use *erasure*, which means that generic
  type parameters are removed at runtime. In Java, you can test whether
  an object is a List, but you can't test whether it's a `List<String>`.
{{site.alert.end}}


## Restricting the parameterized type

When implementing a generic type,
you might want to limit the types that can be provided as arguments,
so that the argument must be a subtype of a particular type.
You can do this using `extends`.

A common use case is ensuring that a type is non-nullable
by making it a subtype of `Object`
(instead of the default, [`Object?`][top-and-bottom]).

<?code-excerpt "misc/lib/language_tour/generics/misc.dart (non-nullable)"?>
```dart
class Foo<T extends Object> {
  // Any type provided to Foo for T must be non-nullable.
}
```

You can use `extends` with other types besides `Object`.
Here's an example of extending `SomeBaseClass`,
so that members of `SomeBaseClass` can be called on objects of type `T`:

<?code-excerpt "misc/lib/language_tour/generics/base_class.dart" replace="/extends SomeBaseClass(?=. \{)/[!$&!]/g"?>
{% prettify dart tag=pre+code %}
class Foo<T [!extends SomeBaseClass!]> {
  // Implementation goes here...
  String toString() => "Instance of 'Foo<$T>'";
}

class Extender extends SomeBaseClass {...}
{% endprettify %}

It's OK to use `SomeBaseClass` or any of its subtypes as the generic argument:

<?code-excerpt "misc/test/language_tour/generics_test.dart (SomeBaseClass-ok)" replace="/Foo.\w+./[!$&!]/g"?>
{% prettify dart tag=pre+code %}
var someBaseClassFoo = [!Foo<SomeBaseClass>!]();
var extenderFoo = [!Foo<Extender>!]();
{% endprettify %}

It's also OK to specify no generic argument:

<?code-excerpt "misc/test/language_tour/generics_test.dart (no-generic-arg-ok)" replace="/expect\((.*?).toString\(\), .(.*?).\);/print($1); \/\/ $2/g"?>
```dart
var foo = Foo();
print(foo); // Instance of 'Foo<SomeBaseClass>'
```

Specifying any non-`SomeBaseClass` type results in an error:

{:.fails-sa}
{% prettify dart tag=pre+code %}
var foo = [!Foo<Object>!]();
{% endprettify %}


## Using generic methods

Methods and functions also allow type arguments:

<!-- {{site.dartpad}}/a02c53b001977efa4d803109900f21bb -->
<!-- https://gist.github.com/a02c53b001977efa4d803109900f21bb -->
<?code-excerpt "misc/test/language_tour/generics_test.dart (method)" replace="/<T.(?=\()|T/[!$&!]/g"?>
{% prettify dart tag=pre+code %}
[!T!] first[!<T>!](List<[!T!]> ts) {
  // Do some initial work or error checking, then...
  [!T!] tmp = ts[0];
  // Do some additional checking or processing...
  return tmp;
}
{% endprettify %}

Here the generic type parameter on `first` (`<T>`)
allows you to use the type argument `T` in several places:

* In the function's return type (`T`).
* In the type of an argument (`List<T>`).
* In the type of a local variable (`T tmp`).

[`List`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-core/List-class.html
[By convention]: /effective-dart/design#do-follow-existing-mnemonic-conventions-when-naming-type-parameters
[top-and-bottom]: /null-safety/understanding-null-safety#top-and-bottom


---
title: Introduction to Dart
description: A brief introduction to Dart programs and important concepts.
short-title: Dart basics
nextpage:
  url: /language/variables
  title: Variables
---

This page provides a brief introduction to the Dart language
through samples of its main features. 

To learn more about the Dart language, 
visit the in-depth, individual topic pages
listed under **Language** in the left side menu.

For coverage of Dart's core libraries, check out the [library tour](/guides/libraries/library-tour).
You can also visit the [Dart cheatsheet codelab](/codelabs/dart-cheatsheet),
for a more hands-on introduction.


## Hello World

Every app requires the top-level `main()` function, where execution starts.
Functions that don't explicitly return a value have the `void` return type.
To display text on the console, you can use the top-level `print()` function:

<?code-excerpt "misc/test/samples_test.dart (hello-world)"?>
```dart
void main() {
  print('Hello, World!');
}
```
Read more about [the `main()` function][] in Dart,
including optional parameters for command-line arguments.

[the `main()` function]: /language/functions#the-main-function

## Variables

Even in [type-safe](https://dart.dev/language/type-system) Dart code,
you can declare most variables without explicitly specifying their type using `var`. 
Thanks to type inference, these variables' types are determined by their initial values: 


<?code-excerpt "misc/test/samples_test.dart (var)"?>
```dart
var name = 'Voyager I';
var year = 1977;
var antennaDiameter = 3.7;
var flybyObjects = ['Jupiter', 'Saturn', 'Uranus', 'Neptune'];
var image = {
  'tags': ['saturn'],
  'url': '//path/to/saturn.jpg'
};
```

[Read more](/language/variables) about variables in Dart, 
including default values, the `final` and `const` keywords, and static types.


## Control flow statements

Dart supports the usual control flow statements:

<?code-excerpt "misc/test/samples_test.dart (control-flow)"?>
```dart
if (year >= 2001) {
  print('21st century');
} else if (year >= 1901) {
  print('20th century');
}

for (final object in flybyObjects) {
  print(object);
}

for (int month = 1; month <= 12; month++) {
  print(month);
}

while (year < 2016) {
  year += 1;
}
```

Read more about control flow statements in Dart,
including [`break` and `continue`](/language/loops),
[`switch` and `case`](/language/branches),
and [`assert`](/language/error-handling#assert).


## Functions

[We recommend](/effective-dart/design#types)
specifying the types of each function's arguments and return value:

<?code-excerpt "misc/test/samples_test.dart (functions)"?>
```dart
int fibonacci(int n) {
  if (n == 0 || n == 1) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
}

var result = fibonacci(20);
```

A shorthand `=>` (_arrow_) syntax is handy for functions that
contain a single statement.
This syntax is especially useful when passing anonymous functions as arguments:

<?code-excerpt "misc/test/samples_test.dart (arrow)"?>
```dart
flybyObjects.where((name) => name.contains('turn')).forEach(print);
```

Besides showing an anonymous function (the argument to `where()`),
this code shows that you can use a function as an argument:
the top-level `print()` function is an argument to `forEach()`.

[Read more](/language/functions) about functions in Dart,
including optional parameters, default parameter values, and lexical scope.


## Comments

Dart comments usually start with `//`.

```dart
// This is a normal, one-line comment.

/// This is a documentation comment, used to document libraries,
/// classes, and their members. Tools like IDEs and dartdoc treat
/// doc comments specially.

/* Comments like these are also supported. */
```

[Read more](/language/comments) about comments in Dart,
including how the documentation tooling works.


## Imports

To access APIs defined in other libraries, use `import`.

<?code-excerpt "misc/test/samples_test.dart (import)" plaster="none"?>
```
// Importing core libraries
import 'dart:math';

// Importing libraries from external packages
import 'package:test/test.dart';

// Importing files
import 'path/to/my_other_file.dart';
```

[Read more](/language/libraries) 
about libraries and visibility in Dart,
including library prefixes, `show` and `hide`, 
and lazy loading through the `deferred` keyword.


## Classes

Here's an example of a class with three properties, two constructors,
and a method. One of the properties can't be set directly, so it's
defined using a getter method (instead of a variable). The method 
uses string interpolation to print variables' string equivalents inside
of string literals. 

<?code-excerpt "misc/lib/samples/spacecraft.dart (class)"?>
```dart
class Spacecraft {
  String name;
  DateTime? launchDate;

  // Read-only non-final property
  int? get launchYear => launchDate?.year;

  // Constructor, with syntactic sugar for assignment to members.
  Spacecraft(this.name, this.launchDate) {
    // Initialization code goes here.
  }

  // Named constructor that forwards to the default one.
  Spacecraft.unlaunched(String name) : this(name, null);

  // Method.
  void describe() {
    print('Spacecraft: $name');
    // Type promotion doesn't work on getters.
    var launchDate = this.launchDate;
    if (launchDate != null) {
      int years = DateTime.now().difference(launchDate).inDays ~/ 365;
      print('Launched: $launchYear ($years years ago)');
    } else {
      print('Unlaunched');
    }
  }
}
```

[Read more](/language/built-in-types#strings) about strings,
including string interpolation, literals, expressions, and the `toString()` method.

You might use the `Spacecraft` class like this:

<?code-excerpt "misc/test/samples_test.dart (use class)" plaster="none"?>
```dart
var voyager = Spacecraft('Voyager I', DateTime(1977, 9, 5));
voyager.describe();

var voyager3 = Spacecraft.unlaunched('Voyager III');
voyager3.describe();
```

[Read more](/language/classes) about classes in Dart,
including initializer lists, optional `new` and `const`, redirecting constructors,
`factory` constructors, getters, setters, and much more.


## Enums

Enums are a way of enumerating a predefined set of values or instances
in a way which ensures that there cannot be any other instances of that type.

Here is an example of a simple `enum` that defines
a simple list of predefined planet types:

<?code-excerpt "misc/lib/samples/spacecraft.dart (simple-enum)"?>
```dart
enum PlanetType { terrestrial, gas, ice }
```

Here is an example of an enhanced enum declaration
of a class describing planets,
with a defined set of constant instances,
namely the planets of our own solar system.

<?code-excerpt "misc/lib/samples/spacecraft.dart (enhanced-enum)"?>
```dart
/// Enum that enumerates the different planets in our solar system
/// and some of their properties.
enum Planet {
  mercury(planetType: PlanetType.terrestrial, moons: 0, hasRings: false),
  venus(planetType: PlanetType.terrestrial, moons: 0, hasRings: false),
  // ···
  uranus(planetType: PlanetType.ice, moons: 27, hasRings: true),
  neptune(planetType: PlanetType.ice, moons: 14, hasRings: true);

  /// A constant generating constructor
  const Planet(
      {required this.planetType, required this.moons, required this.hasRings});

  /// All instance variables are final
  final PlanetType planetType;
  final int moons;
  final bool hasRings;

  /// Enhanced enums support getters and other methods
  bool get isGiant =>
      planetType == PlanetType.gas || planetType == PlanetType.ice;
}
```

You might use the `Planet` enum like this:

<?code-excerpt "misc/test/samples_test.dart (use enum)" plaster="none"?>
```dart
final yourPlanet = Planet.earth;

if (!yourPlanet.isGiant) {
  print('Your planet is not a "giant planet".');
}
```

[Read more](/language/enums) about enums in Dart,
including enhanced enum requirements, automatically introduced properties,
accessing enumerated value names, switch statement support, and much more.


## Inheritance

Dart has single inheritance.

<?code-excerpt "misc/lib/samples/spacecraft.dart (extends)"?>
```dart
class Orbiter extends Spacecraft {
  double altitude;

  Orbiter(super.name, DateTime super.launchDate, this.altitude);
}
```

[Read more](/language/extend) 
about extending classes, the optional `@override` annotation, and more.


## Mixins

Mixins are a way of reusing code in multiple class hierarchies. The following is
a mixin declaration:

<?code-excerpt "misc/lib/samples/spacecraft.dart (mixin)"?>
```dart
mixin Piloted {
  int astronauts = 1;

  void describeCrew() {
    print('Number of astronauts: $astronauts');
  }
}
```

To add a mixin's capabilities to a class, just extend the class with the mixin.

<?code-excerpt "misc/lib/samples/spacecraft.dart (mixin-use)" replace="/with/[!$&!]/g"?>
{% prettify dart tag=pre+code %}
class PilotedCraft extends Spacecraft [!with!] Piloted {
  // ···
}
{% endprettify %}

`PilotedCraft` now has the `astronauts` field as well as the `describeCrew()` method.

[Read more](/language/mixins) about mixins.


## Interfaces and abstract classes

All classes implicitly define an interface. 
Therefore, you can implement any class.

<?code-excerpt "misc/lib/samples/spacecraft.dart (implements)"?>
```dart
class MockSpaceship implements Spacecraft {
  // ···
}
```

Read more about [implicit interfaces](/language/classes#implicit-interfaces), or
about the explicit [`interface` keyword](/language/class-modifiers#interface).

You can create an abstract class
to be extended (or implemented) by a concrete class. 
Abstract classes can contain abstract methods (with empty bodies).

<?code-excerpt "misc/lib/samples/spacecraft.dart (abstract)" replace="/abstract/[!$&!]/g"?>
{% prettify dart tag=pre+code %}
[!abstract!] class Describable {
  void describe();

  void describeWithEmphasis() {
    print('=========');
    describe();
    print('=========');
  }
}
{% endprettify %}

Any class extending `Describable` has the `describeWithEmphasis()` method, 
which calls the extender's implementation of `describe()`.

[Read more](/language/class-modifiers#abstract) 
about abstract classes and methods.


## Async

Avoid callback hell and make your code much more readable by
using `async` and `await`.

<?code-excerpt "misc/test/samples_test.dart (async)" replace="/async/[!$&!]/g"?>
{% prettify dart tag=pre+code %}
const oneSecond = Duration(seconds: 1);
// ···
Future<void> printWithDelay(String message) [!async!] {
  await Future.delayed(oneSecond);
  print(message);
}
{% endprettify %}

The method above is equivalent to:

<?code-excerpt "misc/test/samples_test.dart (Future.then)"?>
```dart
Future<void> printWithDelay(String message) {
  return Future.delayed(oneSecond).then((_) {
    print(message);
  });
}
```

As the next example shows, `async` and `await` help make asynchronous code
easy to read.

<?code-excerpt "misc/test/samples_test.dart (await)"?>
```dart
Future<void> createDescriptions(Iterable<String> objects) async {
  for (final object in objects) {
    try {
      var file = File('$object.txt');
      if (await file.exists()) {
        var modified = await file.lastModified();
        print(
            'File for $object already exists. It was modified on $modified.');
        continue;
      }
      await file.create();
      await file.writeAsString('Start describing $object in this file.');
    } on IOException catch (e) {
      print('Cannot create description for $object: $e');
    }
  }
}
```

You can also use `async*`, which gives you a nice, readable way to build streams.

<?code-excerpt "misc/test/samples_test.dart (async*)"?>
```dart
Stream<String> report(Spacecraft craft, Iterable<String> objects) async* {
  for (final object in objects) {
    await Future.delayed(oneSecond);
    yield '${craft.name} flies by $object';
  }
}
```

[Read more](/language/async) about
asynchrony support, including `async` functions, `Future`, `Stream`,
and the asynchronous loop (`await for`).


## Exceptions

To raise an exception, use `throw`:

<?code-excerpt "misc/test/samples_test.dart (throw)"?>
```dart
if (astronauts == 0) {
  throw StateError('No astronauts.');
}
```

To catch an exception, use a `try` statement with `on` or `catch` (or both):

<?code-excerpt "misc/test/samples_test.dart (try)" replace="/on.*e\)/[!$&!]/g"?>
{% prettify dart tag=pre+code %}
Future<void> describeFlybyObjects(List<String> flybyObjects) async {
  try {
    for (final object in flybyObjects) {
      var description = await File('$object.txt').readAsString();
      print(description);
    }
  } [!on IOException catch (e)!] {
    print('Could not describe object: $e');
  } finally {
    flybyObjects.clear();
  }
}
{% endprettify %}

Note that the code above is asynchronous;
`try` works for both synchronous code and code in an `async` function.

[Read more](/language/error-handling#exceptions) about exceptions, 
including stack traces, `rethrow`, 
and the difference between `Error` and `Exception`.


## Important concepts

As you continue to learn about the Dart language, 
keep these facts and concepts in mind:

-   Everything you can place in a variable is an *object*, and every
    object is an instance of a *class*. Even numbers, functions, and
    `null` are objects.
    With the exception of `null` (if you enable [sound null safety][ns]),
    all objects inherit from the [`Object`][] class.

    {{site.alert.version-note}}
      [Null safety][ns] was introduced in Dart 2.12.
      Using null safety requires a [language version][] of at least 2.12.
    {{site.alert.end}}

-   Although Dart is strongly typed, type annotations are optional
    because Dart can infer types. In `var number = 101`, `number`
    is inferred to be of type `int`.

-   If you enable [null safety][ns],
    variables can't contain `null` unless you say they can.
    You can make a variable nullable by
    putting a question mark (`?`) at the end of its type.
    For example, a variable of type `int?` might be an integer,
    or it might be `null`.
    If you _know_ that an expression never evaluates to `null`
    but Dart disagrees,
    you can add `!` to assert that it isn't null
    (and to throw an exception if it is).
    An example: `int x = nullableButNotNullInt!`

-   When you want to explicitly say
    that any type is allowed, use the type `Object?`
    (if you've enabled null safety), `Object`,
    or—if you must defer type checking until runtime—the
    [special type `dynamic`][ObjectVsDynamic].

-   Dart supports generic types, like `List<int>` (a list of integers)
    or `List<Object>` (a list of objects of any type).

-   Dart supports top-level functions (such as `main()`), as well as
    functions tied to a class or object (*static* and *instance
    methods*, respectively). You can also create functions within
    functions (*nested* or *local functions*).

-   Similarly, Dart supports top-level *variables*, as well as variables
    tied to a class or object (static and instance variables). Instance
    variables are sometimes known as *fields* or *properties*.

-   Unlike Java, Dart doesn't have the keywords `public`, `protected`,
    and `private`. If an identifier starts with an underscore (`_`), it's
    private to its library. For details, see
    [Libraries and imports][].

-   *Identifiers* can start with a letter or underscore (`_`), followed by any
    combination of those characters plus digits.

-   Dart has both *expressions* (which have runtime values) and
    *statements* (which don't).
    For example, the [conditional expression][]
    `condition ? expr1 : expr2` has a value of `expr1` or `expr2`.
    Compare that to an [if-else statement][], which has no value.
    A statement often contains one or more expressions,
    but an expression can't directly contain a statement.

-   Dart tools can report two kinds of problems: _warnings_ and _errors_.
    Warnings are just indications that your code might not work, but
    they don't prevent your program from executing. Errors can be either
    compile-time or run-time. A compile-time error prevents the code
    from executing at all; a run-time error results in an
    [exception][] being raised while the code executes.


## Additional resources

You can find more documentation and code samples in the
[library tour](/guides/libraries/library-tour)
and the [Dart API reference]({{site.dart-api}}).
This site's code follows the conventions in the
[Dart style guide](/effective-dart/style).

[Dart language specification]: /guides/language/spec
[Comments]: /language/comments
[built-in types]: /language/built-in-types
[Strings]: /language/built-in-types#strings
[The main() function]: /language/functions#the-main-function
[ns]: /null-safety
[`Object`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-core/Object-class.html
[language version]: /guides/language/evolution#language-versioning
[ObjectVsDynamic]: /effective-dart/design#avoid-using-dynamic-unless-you-want-to-disable-static-checking
[Libraries and imports]: /language/libraries
[conditional expression]: /language/operators#conditional-expressions
[if-else statement]: /language/branches#if
[exception]: /language/error-handling#exceptions


---
title: Keywords
description: Keywords in Dart.
toc: false
prevpage:
  url: /language/libraries
  title: Libraries
nextpage:
  url: /language/built-in-types
  title: Built-in types
---

The following table lists the words that the Dart language treats specially.

{% assign ckw = '&nbsp;<sup title="contextual keyword" alt="contextual keyword">1</sup>' %}
{% assign bii = '&nbsp;<sup title="built-in-identifier" alt="built-in-identifier">2</sup>' %}
{% assign lrw = '&nbsp;<sup title="limited reserved word" alt="limited reserved word">3</sup>' %}
<div class="table-wrapper" markdown="1">
| [abstract][]{{bii}}   | [else][]                 | [import][]{{bii}}     | [show][]{{ckw}}    |
| [as][]{{bii}}         | [enum][]                 | [in][]                | [static][]{{bii}}  |
| [assert][]            | [export][]{{bii}}        | [interface][]{{bii}}  | [super][]          |
| [async][]{{ckw}}      | [extends][]              | [is][]                | [switch][]         |
| [await][]{{lrw}}      | [extension][]{{bii}}     | [late][]{{bii}}       | [sync][]{{ckw}}    |
| [base][]{{bii}}       | [external][]{{bii}}      | [library][]{{bii}}    | [this][]           |
| [break][]             | [factory][]{{bii}}       | [mixin][]{{bii}}      | [throw][]          |
| [case][]              | [false][]                | [new][]               | [true][]           |
| [catch][]             | [final (variable)][]     | [null][]              | [try][]            |
| [class][]             | [final (class)][]{{bii}} | [on][]{{ckw}}         | [typedef][]{{bii}} |
| [const][]             | [finally][]              | [operator][]{{bii}}   | [var][]            |
| [continue][]          | [for][]                  | [part][]{{bii}}       | [void][]           |
| [covariant][]{{bii}}  | [Function][]{{bii}}      | [required][]{{bii}}   | [when][]           |
| [default][]           | [get][]{{bii}}           | [rethrow][]           | [while][]          |
| [deferred][]{{bii}}   | [hide][]{{ckw}}          | [return][]            | [with][]           |
| [do][]                | [if][]                   | [sealed][]{{bii}}     | [yield][]{{lrw}}   |
| [dynamic][]{{bii}}    | [implements][]{{bii}}    | [set][]{{bii}}        |                    |
{:.table .table-striped .nowrap}
</div>

[abstract]: /language/class-modifiers#abstract
[as]: /language/operators#type-test-operators
[assert]: /language/error-handling#assert
[async]: /language/async
[await]: /language/async
[base]: /language/class-modifiers#base
[break]: /language/loops#break-and-continue
[case]: /language/branches#switch
[catch]: /language/error-handling#catch
[class]: /language/classes#instance-variables
[const]: /language/variables#final-and-const
[continue]: /language/loops#break-and-continue
[covariant]: /guides/language/sound-problems#the-covariant-keyword
[default]: /language/branches#switch
[deferred]: /language/libraries#lazily-loading-a-library
[do]: /language/loops#while-and-do-while
[dynamic]: /language#important-concepts
[else]: /language/branches#if
[enum]: /language/enums
[export]: /guides/libraries/create-packages
[extends]: /language/extend
[extension]: /language/extension-methods
[external]: https://spec.dart.dev/DartLangSpecDraft.pdf#External%20Functions
[factory]: /language/constructors#factory-constructors
[false]: /language/built-in-types#booleans
[final (variable)]: /language/variables#final-and-const
[final (class)]: /language/class-modifiers#final
[finally]: /language/error-handling#finally
[for]: /language/loops#for-loops
[Function]: /language/functions
[get]: /language/methods#getters-and-setters
[hide]: /language/libraries#importing-only-part-of-a-library
[if]: /language/branches#if
[implements]: /language/classes#implicit-interfaces
[import]: /language/libraries#using-libraries
[in]: /language/loops#for-loops
[interface]: /language/class-modifiers#interface
[is]: /language/operators#type-test-operators
[late]: /language/variables#late-variables
[library]: /language/libraries
[mixin]: /language/mixins
[new]: /language/classes#using-constructors
[null]: /language/variables#default-value
[on]: /language/error-handling#catch
[operator]: /language/methods#operators
[part]: /guides/libraries/create-packages#organizing-a-package
[required]: /language/functions#named-parameters
[rethrow]: /language/error-handling#catch
[return]: /language/functions#return-values
[sealed]: /language/class-modifiers#sealed
[set]: /language/methods#getters-and-setters
[show]: /language/libraries#importing-only-part-of-a-library
[static]: /language/classes#class-variables-and-methods
[super]: /language/extend
[switch]: /language/branches#switch
[sync]: /language/functions#generators
[this]: /language/constructors
[throw]: /language/error-handling#throw
[true]: /language/built-in-types#booleans
[try]: /language/error-handling#catch
[typedef]: /language/typedefs
[var]: /language/variables
[void]: /language/built-in-types
[when]: /language/branches#when
[with]: /language/mixins
[while]: /language/loops#while-and-do-while
[yield]: /language/functions#generators

Avoid using these words as identifiers.
However, if necessary, the keywords marked with superscripts can be identifiers:

* Words with the superscript **1** are **contextual keywords**,
  which have meaning only in specific places.
  They're valid identifiers everywhere.

* Words with the superscript **2** are **built-in identifiers**.
  These keywords are valid identifiers in most places,
  but they can't be used as class or type names, or as import prefixes.

* Words with the superscript **3** are limited reserved words related to
  [asynchrony support][].
  You can't use `await` or `yield` as an identifier
  in any function body marked with `async`, `async*`, or `sync*`.

All other words in the table are **reserved words**,
which can't be identifiers.

[asynchrony support]: /language/async


---
title: Libraries & imports
short-title: Libraries
description: Guidance on importing and implementing libraries.
prevpage:
  url: /language/metadata
  title: Metadata
nextpage:
  url: /language/keywords
  title: Keywords
---

The `import` and `library` directives can help you create a
modular and shareable code base. Libraries not only provide APIs, but
are a unit of privacy: identifiers that start with an underscore (`_`)
are visible only inside the library. *Every Dart file (plus its parts) is a
[library][]*, even if it doesn't use a [`library`](#library-directive) directive.

Libraries can be distributed using [packages](/guides/packages).

{{site.alert.info}}
  If you're curious why Dart uses underscores instead of
  access modifier keywords like `public` or `private`, see
  [SDK issue 33383](https://github.com/dart-lang/sdk/issues/33383).
{{site.alert.end}}

[library]: /tools/pub/glossary#library

## Using libraries

Use `import` to specify how a namespace from one library is used in the
scope of another library.

For example, Dart web apps generally use the [dart:html][]
library, which they can import like this:

<?code-excerpt "misc/test/language_tour/browser_test.dart (dart-html-import)"?>
```dart
import 'dart:html';
```

The only required argument to `import` is a URI specifying the
library.
For built-in libraries, the URI has the special `dart:` scheme.
For other libraries, you can use a file system path or the `package:`
scheme. The `package:` scheme specifies libraries provided by a package
manager such as the pub tool. For example:

<?code-excerpt "misc/test/language_tour/browser_test.dart (package-import)"?>
```dart
import 'package:test/test.dart';
```

{{site.alert.note}}
  *URI* stands for uniform resource identifier.
  *URLs* (uniform resource locators) are a common kind of URI.
{{site.alert.end}}

### Specifying a library prefix

If you import two libraries that have conflicting identifiers, then you
can specify a prefix for one or both libraries. For example, if library1
and library2 both have an Element class, then you might have code like
this:

<?code-excerpt "misc/lib/language_tour/libraries/import_as.dart" replace="/(lib\d)\.dart/package:$1\/$&/g"?>
```dart
import 'package:lib1/lib1.dart';
import 'package:lib2/lib2.dart' as lib2;

// Uses Element from lib1.
Element element1 = Element();

// Uses Element from lib2.
lib2.Element element2 = lib2.Element();
```

### Importing only part of a library

If you want to use only part of a library, you can selectively import
the library. For example:

<?code-excerpt "misc/lib/language_tour/libraries/show_hide.dart" replace="/(lib\d)\.dart/package:$1\/$&/g"?>
```dart
// Import only foo.
import 'package:lib1/lib1.dart' show foo;

// Import all names EXCEPT foo.
import 'package:lib2/lib2.dart' hide foo;
```

<a id="deferred-loading"></a>
#### Lazily loading a library

_Deferred loading_ (also called _lazy loading_)
allows a web app to load a library on demand,
if and when the library is needed.
Here are some cases when you might use deferred loading:

* To reduce a web app's initial startup time.
* To perform A/B testing—trying out
  alternative implementations of an algorithm, for example.
* To load rarely used functionality, such as optional screens and dialogs.

{{site.alert.warn}}
  **Only `dart compile js` supports deferred loading.**
  Flutter and the Dart VM don't support deferred loading.
  To learn more, see
  [issue #33118](https://github.com/dart-lang/sdk/issues/33118) and
  [issue #27776.](https://github.com/dart-lang/sdk/issues/27776)
{{site.alert.end}}

To lazily load a library, you must first
import it using `deferred as`.

<?code-excerpt "misc/lib/language_tour/libraries/greeter.dart (import)" replace="/hello\.dart/package:greetings\/$&/g"?>
```dart
import 'package:greetings/hello.dart' deferred as hello;
```

When you need the library, invoke
`loadLibrary()` using the library's identifier.

<?code-excerpt "misc/lib/language_tour/libraries/greeter.dart (loadLibrary)"?>
```dart
Future<void> greet() async {
  await hello.loadLibrary();
  hello.printGreeting();
}
```

In the preceding code,
the `await` keyword pauses execution until the library is loaded.
For more information about `async` and `await`,
see [asynchrony support](/language/async).

You can invoke `loadLibrary()` multiple times on a library without problems.
The library is loaded only once.

Keep in mind the following when you use deferred loading:

* A deferred library's constants aren't constants in the importing file.
  Remember, these constants don't exist until the deferred library is loaded.
* You can't use types from a deferred library in the importing file.
  Instead, consider moving interface types to a library imported by
  both the deferred library and the importing file.
* Dart implicitly inserts `loadLibrary()` into the namespace that you define
  using <code>deferred as <em>namespace</em></code>.
  The `loadLibrary()` function returns a [`Future`](/guides/libraries/library-tour#future).

### The `library` directive {#library-directive}

To specify library-level [doc comments][] or [metadata annotations][],
attach them to a `library` declaration at the start of the file.

<?code-excerpt "misc/lib/effective_dart/docs_good.dart (library-doc)"?>
{% prettify dart tag=pre+code %}
/// A really great test library.
@TestOn('browser')
library;
{% endprettify %}

## Implementing libraries

See
[Create Packages](/guides/libraries/create-packages)
for advice on how to implement a package, including:

* How to organize library source code.
* How to use the `export` directive.
* When to use the `part` directive.
* How to use conditional imports and exports to implement
  a library that supports multiple platforms.

[dart:html]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-html
[doc comments]: /effective-dart/documentation#consider-writing-a-library-level-doc-comment
[metadata annotations]: /language/metadata


---
title: Loops 
description: Learn how to use loops to control the flow of your Dart code.
prevpage:
  url: /language/functions
  title: Functions
nextpage:
  url: /language/branches
  title: Branches
---

This page shows how you can control the flow of your Dart code using loops and
supporting statements:

-   `for` loops
-   `while` and `do while` loops
-   `break` and `continue`

You can also manipulate control flow in Dart using:

- [Branching][], like `if` and `switch`
- [Exceptions][], like `try`, `catch`, and `throw`

## For loops

You can iterate with the standard `for` loop. For example:

<?code-excerpt "language/test/control_flow/loops_test.dart (for)"?>
```dart
var message = StringBuffer('Dart is fun');
for (var i = 0; i < 5; i++) {
  message.write('!');
}
```

Closures inside of Dart's `for` loops capture the _value_ of the index.
This avoids a common pitfall found in JavaScript. For example, consider:

<?code-excerpt "language/test/control_flow/loops_test.dart (for-and-closures)"?>
```dart
var callbacks = [];
for (var i = 0; i < 2; i++) {
  callbacks.add(() => print(i));
}

for (final c in callbacks) {
  c();
}
```

The output is `0` and then `1`, as expected. In contrast, the example
would print `2` and then `2` in JavaScript.

Sometimes you might not need to know the current iteration counter
when iterating over an [`Iterable`][] type, like `List` or `Set`.
In that case, use the `for-in` loop for cleaner code:

<?code-excerpt "language/lib/control_flow/loops.dart (collection)"?>
```dart
for (final candidate in candidates) {
  candidate.interview();
}
```

To process the values obtained from the iterable, 
you can also use a [pattern][] in a `for-in` loop:

<?code-excerpt "language/lib/control_flow/loops.dart (collection-for-pattern)"?>
```dart
for (final Candidate(:name, :yearsExperience) in candidates) {
  print('$name has $yearsExperience of experience.');
}
```

{{site.alert.tip}}
  To practice using `for-in`, follow the
  [Iterable collections codelab](/codelabs/iterables).
{{site.alert.end}}

Iterable classes also have a [forEach()][] method as another option:

<?code-excerpt "language/test/control_flow/loops_test.dart (for-each)"?>
```dart
var collection = [1, 2, 3];
collection.forEach(print); // 1 2 3
```


## While and do-while

A `while` loop evaluates the condition before the loop:

<?code-excerpt "language/lib/control_flow/loops.dart (while)"?>
```dart
while (!isDone()) {
  doSomething();
}
```

A `do`-`while` loop evaluates the condition *after* the loop:

<?code-excerpt "language/lib/control_flow/loops.dart (do-while)"?>
```dart
do {
  printLine();
} while (!atEndOfPage());
```


## Break and continue

Use `break` to stop looping:

<?code-excerpt "language/lib/control_flow/loops.dart (while-break)"?>
```dart
while (true) {
  if (shutDownRequested()) break;
  processIncomingRequests();
}
```

Use `continue` to skip to the next loop iteration:

<?code-excerpt "language/lib/control_flow/loops.dart (for-continue)"?>
```dart
for (int i = 0; i < candidates.length; i++) {
  var candidate = candidates[i];
  if (candidate.yearsExperience < 5) {
    continue;
  }
  candidate.interview();
}
```

If you're using an [`Iterable`][] such as a list or set,
how you write the previous example might differ:

<?code-excerpt "language/lib/control_flow/loops.dart (where)"?>
```dart
candidates
    .where((c) => c.yearsExperience >= 5)
    .forEach((c) => c.interview());
```

[exceptions]: /language/error-handling
[branching]: /language/branches
[iteration]: /guides/libraries/library-tour#iteration
[forEach()]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-core/Iterable/forEach.html
[`Iterable`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-core/Iterable-class.html
[pattern]: /language/patterns


---
title: Metadata
description: Metadata and annotations in Dart.
toc: false
prevpage:
  url: /language/comments
  title: Comments
nextpage:
  url: /language/libraries
  title: Libraries
---


Use metadata to give additional information about your code. A metadata
annotation begins with the character `@`, followed by either a reference
to a compile-time constant (such as `deprecated`) or a call to a
constant constructor.

Four annotations are available to all Dart code: 
[`@Deprecated`][], [`@deprecated`][], [`@override`][], and [`@pragma`][]. 
For examples of using `@override`,
see [Extending a class][].
Here's an example of using the `@Deprecated` annotation:

<?code-excerpt "misc/lib/language_tour/metadata/television.dart (deprecated)" replace="/@Deprecated.*/[!$&!]/g"?>
{% prettify dart tag=pre+code %}
class Television {
  /// Use [turnOn] to turn the power on instead.
  [!@Deprecated('Use turnOn instead')!]
  void activate() {
    turnOn();
  }

  /// Turns the TV's power on.
  void turnOn() {...}
  // ···
}
{% endprettify %}

You can use `@deprecated` if you don't want to specify a message.
However, we [recommend][dep-lint] always
specifying a message with `@Deprecated`.

You can define your own metadata annotations. Here's an example of
defining a `@Todo` annotation that takes two arguments:

<?code-excerpt "misc/lib/language_tour/metadata/todo.dart"?>
```dart
class Todo {
  final String who;
  final String what;

  const Todo(this.who, this.what);
}
```

And here's an example of using that `@Todo` annotation:

<?code-excerpt "misc/lib/language_tour/metadata/misc.dart"?>
```dart
@Todo('Dash', 'Implement this function')
void doSomething() {
  print('Do something');
}
```

Metadata can appear before a library, class, typedef, type parameter,
constructor, factory, function, field, parameter, or variable
declaration and before an import or export directive.

[`@Deprecated`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-core/Deprecated-class.html
[`@deprecated`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-core/deprecated-constant.html
[`@override`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-core/override-constant.html
[`@pragma`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-core/pragma-class.html
[dep-lint]: /tools/linter-rules/provide_deprecation_message
[Extending a class]: /language/extend


---
title: Methods
description: Learn about methods in Dart.
prevpage:
  url: /language/constructors
  title: Constructors
nextpage:
  url: /language/extend
  title: Extend a class
---

Methods are functions that provide behavior for an object.

## Instance methods

Instance methods on objects can access instance variables and `this`.
The `distanceTo()` method in the following sample is an example of an
instance method:

<?code-excerpt "misc/lib/language_tour/classes/point.dart (class-with-distanceTo)" plaster="none"?>
```dart
import 'dart:math';

class Point {
  final double x;
  final double y;

  Point(this.x, this.y);

  double distanceTo(Point other) {
    var dx = x - other.x;
    var dy = y - other.y;
    return sqrt(dx * dx + dy * dy);
  }
}
```

## Operators

Operators are instance methods with special names.
Dart allows you to define operators with the following names:

`<`  | `+`  | `|`  | `>>>`
`>`  | `/`  | `^`  | `[]`
`<=` | `~/` | `&`  | `[]=`
`>=` | `*`  | `<<` | `~`
`-`  | `%`  | `>>` | `==`
{:.table}

{{site.alert.note}}
  You may have noticed that some [operators][], like `!=`, aren't in
  the list of names. That's because they're just syntactic sugar. For example,
  the expression `e1 != e2` is syntactic sugar for `!(e1 == e2)`.
{{site.alert.end}}

{%- comment %}
  Internal note from https://github.com/dart-lang/site-www/pull/2691#discussion_r506184100:
  -  `??`, `&&` and `||` are excluded because they are lazy / short-circuiting operators
  - `!` is probably excluded for historical reasons
{% endcomment %}

An operator declaration is identified using the built-in identifier `operator`.
The following example defines vector 
addition (`+`), subtraction (`-`), and equality (`==`):

<?code-excerpt "misc/lib/language_tour/classes/vector.dart"?>
```dart
class Vector {
  final int x, y;

  Vector(this.x, this.y);

  Vector operator +(Vector v) => Vector(x + v.x, y + v.y);
  Vector operator -(Vector v) => Vector(x - v.x, y - v.y);

  @override
  bool operator ==(Object other) =>
      other is Vector && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);
}

void main() {
  final v = Vector(2, 3);
  final w = Vector(2, 2);

  assert(v + w == Vector(4, 5));
  assert(v - w == Vector(0, 1));
}
```


## Getters and setters

Getters and setters are special methods that provide read and write
access to an object's properties. Recall that each instance variable has
an implicit getter, plus a setter if appropriate. You can create
additional properties by implementing getters and setters, using the
`get` and `set` keywords:

<?code-excerpt "misc/lib/language_tour/classes/rectangle.dart"?>
```dart
class Rectangle {
  double left, top, width, height;

  Rectangle(this.left, this.top, this.width, this.height);

  // Define two calculated properties: right and bottom.
  double get right => left + width;
  set right(double value) => left = value - width;
  double get bottom => top + height;
  set bottom(double value) => top = value - height;
}

void main() {
  var rect = Rectangle(3, 4, 20, 15);
  assert(rect.left == 3);
  rect.right = 12;
  assert(rect.left == -8);
}
```

With getters and setters, you can start with instance variables, later
wrapping them with methods, all without changing client code.

{{site.alert.note}}
  Operators such as increment (++) work in the expected way, whether or
  not a getter is explicitly defined. To avoid any unexpected side
  effects, the operator calls the getter exactly once, saving its value
  in a temporary variable.
{{site.alert.end}}

## Abstract methods

Instance, getter, and setter methods can be abstract, defining an
interface but leaving its implementation up to other classes.
Abstract methods can only exist in [abstract classes][] or [mixins][].

To make a method abstract, use a semicolon (;) instead of a method body:

<?code-excerpt "misc/lib/language_tour/classes/doer.dart"?>
```dart
abstract class Doer {
  // Define instance variables and methods...

  void doSomething(); // Define an abstract method.
}

class EffectiveDoer extends Doer {
  void doSomething() {
    // Provide an implementation, so the method is not abstract here...
  }
}
```

[operators]: /language/operators
[abstract classes]: /language/class-modifiers#abstract
[mixins]: /language/mixins


---
title: Mixins
description: Learn how to add to features to a class in Dart.
toc: false
prevpage:
  url: /language/extend
  title: Extend a class
nextpage:
  url: /language/enums
  title: Enums
---

<?code-excerpt replace="/ *\/\/\s+ignore_for_file:[^\n]+\n//g; /(^|\n) *\/\/\s+ignore:[^\n]+\n/$1/g; /(\n[^\n]+) *\/\/\s+ignore:[^\n]+\n/$1\n/g; / *\/\/\s+ignore:[^\n]+//g; /([A-Z]\w*)\d\b/$1/g"?>

Mixins are a way of defining code that can be reused in multiple class hierarchies.
They are intended to provide member implementations en masse. 

To use a mixin, use the `with` keyword followed by one or more mixin
names. The following example shows two classes that use mixins:

<?code-excerpt "misc/lib/language_tour/classes/orchestra.dart (Musician and Maestro)" replace="/(with.*) \{/[!$1!] {/g"?>
{% prettify dart tag=pre+code %}
class Musician extends Performer [!with Musical!] {
  // ···
}

class Maestro extends Person [!with Musical, Aggressive, Demented!] {
  Maestro(String maestroName) {
    name = maestroName;
    canConduct = true;
  }
}
{% endprettify %}

To define a mixin, use the `mixin` declaration. 
In the rare case where you need to define both a mixin _and_ a class, you can use
the [`mixin class` declaration](#class-mixin-or-mixin-class).

Mixins and mixin classes cannot have an `extends` clause,
and must not declare any generative constructors.

For example:

<?code-excerpt "misc/lib/language_tour/classes/orchestra.dart (Musical)"?>
```dart
mixin Musical {
  bool canPlayPiano = false;
  bool canCompose = false;
  bool canConduct = false;

  void entertainMe() {
    if (canPlayPiano) {
      print('Playing piano');
    } else if (canConduct) {
      print('Waving hands');
    } else {
      print('Humming to self');
    }
  }
}
```

Sometimes you might want to restrict the types that can use a mixin.
For example, the mixin might depend on being able to invoke a method
that the mixin doesn't define.
As the following example shows, you can restrict a mixin's use
by using the `on` keyword to specify the required superclass:

<?code-excerpt "misc/lib/language_tour/classes/orchestra.dart (mixin-on)" plaster="none" replace="/on Musician2/[!on Musician!]/g" ?>
```dart
class Musician {
  // ...
}
mixin MusicalPerformer [!on Musician!] {
  // ...
}
class SingerDancer extends Musician with MusicalPerformer {
  // ...
}
```

In the preceding code,
only classes that extend or implement the `Musician` class
can use the mixin `MusicalPerformer`.
Because `SingerDancer` extends `Musician`,
`SingerDancer` can mix in `MusicalPerformer`.

## `class`, `mixin`, or `mixin class`?

{{site.alert.version-note}}
  The `mixin class` declaration requires a [language version][] of at least 3.0.
{{site.alert.end}}

A `mixin` declaration defines a mixin. A `class` declaration defines a [class][].
A `mixin class` declaration defines a class that is usable as both a regular class
and a mixin, with the same name and the same type.

Any restrictions that apply to classes or mixins also apply to mixin classes:

- Mixins can't have `extends` or `with` clauses, so neither can a `mixin class`.
- Classes can't have an `on` clause, so neither can a `mixin class`. 

### `abstract mixin class`

You can achieve similar behavior to the `on` directive for a mixin class. 
Make the mixin class `abstract` and define the abstract methods its behavior 
depends on:

```dart
abstract mixin class Musician {
  // No 'on' clause, but an abstract method that other types must define if 
  // they want to use (mix in or extend) Musician: 
  void playInstrument(String instrumentName);

  void playPiano() {
    playInstrument('Piano');
  }
  void playFlute() {
    playInstrument('Flute');
  }
}

class Virtuoso with Musician { // Use Musician as a mixin
  void playInstrument(String instrumentName) {
    print('Plays the $instrumentName beautifully');
  }  
} 

class Novice extends Musician { // Use Musician as a class
  void playInstrument(String instrumentName) {
    print('Plays the $instrumentName poorly');
  }  
} 
```

By declaring the `Musician` mixin as abstract, you force any type that uses
it to define the abstract method upon which its behavior depends. 

This is similar to how the `on` directive ensures a mixin has access to any
interfaces it depends on by specifying the superclass of that interface.

[language version]: /guides/language/evolution#language-versioning
[class]: /language/classes
[class modifiers]: /language/class-modifiers


---
title: Class modifiers reference
description: >-
  The allowed and disallowed combinations of class modifiers.
prevpage:
  url: /language/class-modifiers
  title: Class modifiers
nextpage:
  url: /language/async
  title: Asynchronous support
---

This page contains reference information for
[class modifiers](/language/class-modifiers).

## Valid combinations

The valid combinations of class modifiers and their resulting capabilities are:

<div class="table-wrapper" markdown="1">
| Declaration | [Construct][]? | [Extend][]? | [Implement][]? | [Mix in][]? | [Exhaustive][]? |
|--|--|--|--|--|--|
|`class`                    |**Yes**|**Yes**|**Yes**|No     |No     | |
|`base class`               |**Yes**|**Yes**|No     |No     |No     |
|`interface class`          |**Yes**|No     |**Yes**|No     |No     |
|`final class`              |**Yes**|No     |No     |No     |No     |
|`sealed class`             |No     |No     |No     |No     |**Yes**|
|`abstract class`           |No     |**Yes**|**Yes**|No     |No     |
|`abstract base class`      |No     |**Yes**|No     |No     |No     |
|`abstract interface class` |No     |No     |**Yes**|No     |No     |
|`abstract final class`     |No     |No     |No     |No     |No     |
|`mixin class`              |**Yes**|**Yes**|**Yes**|**Yes**|No     |
|`base mixin class`         |**Yes**|**Yes**|No     |**Yes**|No     |
|`abstract mixin class`     |No     |**Yes**|**Yes**|**Yes**|No     |
|`abstract base mixin class`|No     |**Yes**|No     |**Yes**|No     |
|`mixin`                    |No     |No     |**Yes**|**Yes**|No     |
|`base mixin`               |No     |No     |No     |**Yes**|No     |
{:.table .table-striped .nowrap}
</div>

[Construct]: /language/classes#using-constructors
[Extend]: /language/extend
[Implement]: /language/classes#implicit-interfaces
[Mix in]: /language/mixins
[Exhaustive]: /language/branches#exhaustiveness-checking

## Invalid combinations

Certain [combinations](/language/class-modifiers#combining-modifiers)
of modifiers are not allowed:

<div class="table-wrapper" markdown="1">
| Combination | Reasoning |
|--|--|
|`base`, `interface`, and `final`  |All control the same two capabilities (`extend` and `implement`), so are mutually exclusive. |
|`sealed` and `abstract` |Neither can be constructed, so are redundant together. |
|`sealed` with `base`, `interface`, or `final` | `sealed` types already cannot be mixed in, extended or implemented from another library, so are redundant to combine with the listed modifiers. |
|`mixin` and `abstract` |Neither can be constructed, so are redundant together. |
|`mixin` and `interface`, `final`, or `sealed` |A `mixin` or `mixin class` declaration is intended to be mixed in, which the listed modifiers prevent. |
|`enum` and any modifiers |`enum` declarations cannot be extended, implemented, mixed in, and can always be instantiated, so no modifiers apply to `enum` declarations. |
{:.table .table-striped .nowrap}
</div>


---
title: Operators
description: Learn about the operators Dart supports.
prevpage:
  url: /language/variables
  title: Variables
nextpage:
  url: /language/comments
  title: Comments
---

<?code-excerpt replace="/ *\/\/\s+ignore_for_file:[^\n]+\n//g; /(^|\n) *\/\/\s+ignore:[^\n]+\n/$1/g; /(\n[^\n]+) *\/\/\s+ignore:[^\n]+\n/$1\n/g; / *\/\/\s+ignore:[^\n]+//g; /([A-Z]\w*)\d\b/$1/g"?>

<a name="operators"></a>

Dart supports the operators shown in the following table.
The table shows Dart's operator associativity 
and [operator precedence](#operator-precedence-example) from highest to lowest,
which are an **approximation** of Dart's operator relationships.
You can implement many of these [operators as class members][].

|-----------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+---------------|
| Description                             | Operator                                                                                                                                                                                          | Associativity |
|-----------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+---------------|
| unary postfix                           | <code><em>expr</em>++</code>    <code><em>expr</em>--</code>    `()`    `[]`    `?[]`    `.`    `?.`    `!`                                                                                       | None          |
| unary prefix                            | <code>-<em>expr</em></code>    <code>!<em>expr</em></code>    <code>~<em>expr</em></code>    <code>++<em>expr</em></code>    <code>--<em>expr</em></code>      <code>await <em>expr</em></code>    | None          |
| multiplicative                          | `*`    `/`    `%`    `~/`                                                                                                                                                                         | Left          |
| additive                                | `+`    `-`                                                                                                                                                                                        | Left          |
| shift                                   | `<<`    `>>`    `>>>`                                                                                                                                                                             | Left          |
| bitwise AND                             | `&`                                                                                                                                                                                               | Left          |
| bitwise XOR                             | `^`                                                                                                                                                                                               | Left          |
| bitwise OR                              | `|`                                                                                                                                                                                               | Left          |
| relational&nbsp;and&nbsp;type&nbsp;test | `>=`    `>`    `<=`    `<`    `as`    `is`    `is!`                                                                                                                                               | None          |
| equality                                | `==`    `!=`                                                                                                                                                                                      | None          |
| logical AND                             | `&&`                                                                                                                                                                                              | Left          |
| logical OR                              | `||`                                                                                                                                                                                              | Left          |
| if null                                 | `??`                                                                                                                                                                                              | Left          |
| conditional                             | <code><em>expr1</em> ? <em>expr2</em> : <em>expr3</em></code>                                                                                                                                     | Right         |
| cascade                                 | `..` &nbsp;&nbsp; `?..`                                                                                                                                                                           | Left          |
| assignment                              | `=`    `*=`    `/=`    `+=`    `-=`    `&=`    `^=`    <em>etc.</em>                                                                                                                              | Right         |
{:.table .table-striped}

{{site.alert.warning}}
  The previous table should only be used as a helpful guide.
  The notion of operator precedence and associativity
  is an approximation of the truth found in the language grammar.
  You can find the authoritative behavior of Dart's operator relationships
  in the grammar defined in the [Dart language specification][].
{{site.alert.end}}

When you use operators, you create expressions. Here are some examples
of operator expressions:

<?code-excerpt "misc/test/language_tour/operators_test.dart (expressions)" replace="/,//g"?>
```dart
a++
a + b
a = b
a == b
c ? a : b
a is T
```

## Operator precedence example

In the [operator table](#operators),
each operator has higher precedence than the operators in the rows
that follow it. For example, the multiplicative operator `%` has higher
precedence than (and thus executes before) the equality operator `==`,
which has higher precedence than the logical AND operator `&&`. That
precedence means that the following two lines of code execute the same
way:

<?code-excerpt "misc/test/language_tour/operators_test.dart (precedence)"?>
```dart
// Parentheses improve readability.
if ((n % i == 0) && (d % i == 0)) ...

// Harder to read, but equivalent.
if (n % i == 0 && d % i == 0) ...
```

{{site.alert.warning}}
  For operators that take two operands, the leftmost operand determines which
  method is used. For example, if you have a `Vector` object and
  a `Point` object, then `aVector + aPoint` uses `Vector` addition (`+`).
{{site.alert.end}}


## Arithmetic operators

Dart supports the usual arithmetic operators, as shown in the following table.

|-----------------------------+-------------------------------------------|
| Operator                    | Meaning                                   |
|-----------------------------+-------------------------------------------|
| `+`                         | Add
| `-`                         | Subtract
| <code>-<em>expr</em></code> | Unary minus, also known as negation (reverse the sign of the expression)
| `*`                         | Multiply
| `/`                         | Divide
| `~/`                        | Divide, returning an integer result
| `%`                         | Get the remainder of an integer division (modulo)
{:.table .table-striped}

Example:

<?code-excerpt "misc/test/language_tour/operators_test.dart (arithmetic)"?>
```dart
assert(2 + 3 == 5);
assert(2 - 3 == -1);
assert(2 * 3 == 6);
assert(5 / 2 == 2.5); // Result is a double
assert(5 ~/ 2 == 2); // Result is an int
assert(5 % 2 == 1); // Remainder

assert('5/2 = ${5 ~/ 2} r ${5 % 2}' == '5/2 = 2 r 1');
```

Dart also supports both prefix and postfix increment and decrement
operators.

|-----------------------------+-------------------------------------------|
| Operator                    | Meaning                                   |
|-----------------------------+-------------------------------------------|
| <code>++<em>var</em></code> | <code><em>var</em> = <em>var</em> + 1</code> (expression value is <code><em>var</em> + 1</code>)
| <code><em>var</em>++</code> | <code><em>var</em> = <em>var</em> + 1</code> (expression value is <code><em>var</em></code>)
| <code>--<em>var</em></code> | <code><em>var</em> = <em>var</em> - 1</code> (expression value is <code><em>var</em> - 1</code>)
| <code><em>var</em>--</code> | <code><em>var</em> = <em>var</em> - 1</code> (expression value is <code><em>var</em></code>)
{:.table .table-striped}

Example:

<?code-excerpt "misc/test/language_tour/operators_test.dart (increment-decrement)"?>
```dart
int a;
int b;

a = 0;
b = ++a; // Increment a before b gets its value.
assert(a == b); // 1 == 1

a = 0;
b = a++; // Increment a after b gets its value.
assert(a != b); // 1 != 0

a = 0;
b = --a; // Decrement a before b gets its value.
assert(a == b); // -1 == -1

a = 0;
b = a--; // Decrement a after b gets its value.
assert(a != b); // -1 != 0
```


## Equality and relational operators

The following table lists the meanings of equality and relational operators.

|-----------+-------------------------------------------|
| Operator  | Meaning                                   |
|-----------+-------------------------------------------|
| `==`      |       Equal; see discussion below
| `!=`      |       Not equal
| `>`       |       Greater than
| `<`       |       Less than
| `>=`      |       Greater than or equal to
| `<=`      |       Less than or equal to
{:.table .table-striped}

To test whether two objects x and y represent the same thing, use the
`==` operator. (In the rare case where you need to know whether two
objects are the exact same object, use the [identical()][]
function instead.) Here's how the `==` operator works:

1.  If *x* or *y* is null, return true if both are null, and false if only
    one is null.

2.  Return the result of invoking the `==` method on *x* with the argument *y*.
    (That's right, operators such as `==` are methods that
    are invoked on their first operand.
    For details, see [Operators][].)

Here's an example of using each of the equality and relational
operators:

<?code-excerpt "misc/test/language_tour/operators_test.dart (relational)"?>
```dart
assert(2 == 2);
assert(2 != 3);
assert(3 > 2);
assert(2 < 3);
assert(3 >= 3);
assert(2 <= 3);
```


## Type test operators

The `as`, `is`, and `is!` operators are handy for checking types at
runtime.

|-----------+-------------------------------------------|
| Operator  | Meaning                                   |
|-----------+-------------------------------------------|
| `as`      | Typecast (also used to specify [library prefixes][])
| `is`      | True if the object has the specified type
| `is!`     | True if the object doesn't have the specified type
{:.table .table-striped}

The result of `obj is T` is true if `obj` implements the interface
specified by `T`. For example, `obj is Object?` is always true.

Use the `as` operator to cast an object to a particular type if and only if
you are sure that the object is of that type. Example:

<?code-excerpt "misc/lib/language_tour/classes/employee.dart (emp as Person)"?>
```dart
(employee as Person).firstName = 'Bob';
```

If you aren't sure that the object is of type `T`, then use `is T` to check the
type before using the object.
<?code-excerpt "misc/lib/language_tour/classes/employee.dart (emp is Person)"?>
```dart
if (employee is Person) {
  // Type check
  employee.firstName = 'Bob';
}
```

{{site.alert.note}}
  The code isn't equivalent. If `employee` is null or not a `Person`, the
  first example throws an exception; the second does nothing.
{{site.alert.end}}

## Assignment operators

As you've already seen, you can assign values using the `=` operator.
To assign only if the assigned-to variable is null,
use the `??=` operator.

<?code-excerpt "misc/test/language_tour/operators_test.dart (assignment)"?>
```dart
// Assign value to a
a = value;
// Assign value to b if b is null; otherwise, b stays the same
b ??= value;
```

Compound assignment operators such as `+=` combine
an operation with an assignment.

| `=`  | `*=`  | `%=`  | `>>>=` | `^=`
| `+=` | `/=`  | `<<=` | `&=`   | `|=`
| `-=` | `~/=` | `>>=`
{:.table}

Here's how compound assignment operators work:

|-----------+----------------------+-----------------------|
|           | Compound assignment  | Equivalent expression |
|-----------+----------------------+-----------------------|
|**For an operator <em>op</em>:** | <code>a <em>op</em>= b</code> | <code>a = a <em>op</em> b</code>
|**Example:**                     |`a += b`                       | `a = a + b`
{:.table}

The following example uses assignment and compound assignment
operators:

<?code-excerpt "misc/test/language_tour/operators_test.dart (op-assign)"?>
```dart
var a = 2; // Assign using =
a *= 3; // Assign and multiply: a = a * 3
assert(a == 6);
```


## Logical operators

You can invert or combine boolean expressions using the logical
operators.

|-----------------------------+-------------------------------------------|
| Operator                    | Meaning                                   |
|-----------------------------+-------------------------------------------|
| <code>!<em>expr</em></code> | inverts the following expression (changes false to true, and vice versa)
| `||`                        | logical OR
| `&&`                        | logical AND
{:.table .table-striped}

Here's an example of using the logical operators:

<?code-excerpt "misc/lib/language_tour/operators.dart (op-logical)"?>
```dart
if (!done && (col == 0 || col == 3)) {
  // ...Do something...
}
```


## Bitwise and shift operators

You can manipulate the individual bits of numbers in Dart. Usually,
you'd use these bitwise and shift operators with integers.

|-----------------------------+-------------------------------------------|
| Operator                    | Meaning                                   |
|-----------------------------+-------------------------------------------|
| `&`                         | AND
| `|`                         | OR
| `^`                         | XOR
| <code>~<em>expr</em></code> | Unary bitwise complement (0s become 1s; 1s become 0s)
| `<<`                        | Shift left
| `>>`                        | Shift right
| `>>>`                       | Unsigned shift right
{:.table .table-striped}

{{site.alert.note}}
  The behavior of bitwise operations with large or negative operands
  might differ between platforms.
  To learn more, check out
  [Bitwise operations platform differences][].
{{site.alert.end}}

Here's an example of using bitwise and shift operators:

<?code-excerpt "misc/test/language_tour/operators_test.dart (op-bitwise)"?>
```dart
final value = 0x22;
final bitmask = 0x0f;

assert((value & bitmask) == 0x02); // AND
assert((value & ~bitmask) == 0x20); // AND NOT
assert((value | bitmask) == 0x2f); // OR
assert((value ^ bitmask) == 0x2d); // XOR

assert((value << 4) == 0x220); // Shift left
assert((value >> 4) == 0x02); // Shift right

// Shift right example that results in different behavior on web
// because the operand value changes when masked to 32 bits:
assert((-value >> 4) == -0x03);

assert((value >>> 4) == 0x02); // Unsigned shift right
assert((-value >>> 4) > 0); // Unsigned shift right
```

{{site.alert.version-note}}
  The `>>>` operator (known as _triple-shift_ or _unsigned shift_)
  requires a [language version][] of at least 2.14.
{{site.alert.end}}

[Bitwise operations platform differences]: /guides/language/numbers#bitwise-operations

## Conditional expressions

Dart has two operators that let you concisely evaluate expressions
that might otherwise require [if-else][] statements:

<code><em>condition</em> ? <em>expr1</em> : <em>expr2</em></code>
: If _condition_ is true, evaluates _expr1_ (and returns its value);
  otherwise, evaluates and returns the value of _expr2_.

<code><em>expr1</em> ?? <em>expr2</em></code>
: If _expr1_ is non-null, returns its value;
  otherwise, evaluates and returns the value of _expr2_.

When you need to assign a value
based on a boolean expression,
consider using `?` and `:`.

<?code-excerpt "misc/lib/language_tour/operators.dart (if-then-else-operator)"?>
```dart
var visibility = isPublic ? 'public' : 'private';
```

If the boolean expression tests for null,
consider using `??`.

<?code-excerpt "misc/test/language_tour/operators_test.dart (if-null)"?>
```dart
String playerName(String? name) => name ?? 'Guest';
```

The previous example could have been written at least two other ways,
but not as succinctly:

<?code-excerpt "misc/test/language_tour/operators_test.dart (if-null-alt)"?>
```dart
// Slightly longer version uses ?: operator.
String playerName(String? name) => name != null ? name : 'Guest';

// Very long version uses if-else statement.
String playerName(String? name) {
  if (name != null) {
    return name;
  } else {
    return 'Guest';
  }
}
```

## Cascade notation

Cascades (`..`, `?..`) allow you to make a sequence of operations
on the same object. In addition to accessing instance members,
you can also call instance methods on that same object.
This often saves you the step of creating a temporary variable and
allows you to write more fluid code.

Consider the following code:

<?code-excerpt "misc/lib/language_tour/cascades.dart (cascade)"?>
```dart
var paint = Paint()
  ..color = Colors.black
  ..strokeCap = StrokeCap.round
  ..strokeWidth = 5.0;
```

The constructor, `Paint()`,
returns a `Paint` object.
The code that follows the cascade notation operates
on this object, ignoring any values that
might be returned.

The previous example is equivalent to this code:

<?code-excerpt "misc/lib/language_tour/cascades.dart (cascade-expanded)"?>
```dart
var paint = Paint();
paint.color = Colors.black;
paint.strokeCap = StrokeCap.round;
paint.strokeWidth = 5.0;
```

If the object that the cascade operates on can be null,
then use a _null-shorting_ cascade (`?..`) for the first operation.
Starting with `?..` guarantees that none of the cascade operations
are attempted on that null object.

<?code-excerpt "misc/test/language_tour/browser_test.dart (cascade-operator)"?>
```dart
querySelector('#confirm') // Get an object.
  ?..text = 'Confirm' // Use its members.
  ..classes.add('important')
  ..onClick.listen((e) => window.alert('Confirmed!'))
  ..scrollIntoView();
```

{{site.alert.version-note}}
  The `?..` syntax requires a [language version][] of at least 2.12.
{{site.alert.end}}

The previous code is equivalent to the following:

<?code-excerpt "misc/test/language_tour/browser_test.dart (cascade-operator-example-expanded)"?>
```dart
var button = querySelector('#confirm');
button?.text = 'Confirm';
button?.classes.add('important');
button?.onClick.listen((e) => window.alert('Confirmed!'));
button?.scrollIntoView();
```

You can also nest cascades. For example:

<?code-excerpt "misc/lib/language_tour/operators.dart (nested-cascades)"?>
```dart
final addressBook = (AddressBookBuilder()
      ..name = 'jenny'
      ..email = 'jenny@example.com'
      ..phone = (PhoneNumberBuilder()
            ..number = '415-555-0100'
            ..label = 'home')
          .build())
    .build();
```

Be careful to construct your cascade on a function that returns
an actual object. For example, the following code fails:

<?code-excerpt "misc/lib/language_tour/operators.dart (cannot-cascade-on-void)" plaster="none"?>
```dart
var sb = StringBuffer();
sb.write('foo')
  ..write('bar'); // Error: method 'write' isn't defined for 'void'.
```

The `sb.write()` call returns void,
and you can't construct a cascade on `void`.

{{site.alert.note}}
  Strictly speaking, the "double dot" notation for cascades isn't an operator.
  It's just part of the Dart syntax.
{{site.alert.end}}

## Other operators

You've seen most of the remaining operators in other examples:

|----------+------------------------------+--------------------|
| Operator | Name                         | Meaning            |
|----------+------------------------------+--------------------|
| `()`     | Function application         | Represents a function call
| `[]`     | Subscript access             | Represents a call to the overridable `[]` operator; example: `fooList[1]` passes the int `1` to `fooList` to access the element at index `1`
| `?[]`    | Conditional subscript access | Like `[]`, but the leftmost operand can be null; example: `fooList?[1]` passes the int `1` to `fooList` to access the element at index `1` unless `fooList` is null (in which case the expression evaluates to null)
| `.`      | Member access                | Refers to a property of an expression; example: `foo.bar` selects property `bar` from expression `foo`
| `?.`     | Conditional member access    | Like `.`, but the leftmost operand can be null; example: `foo?.bar` selects property `bar` from expression `foo` unless `foo` is null (in which case the value of `foo?.bar` is null)
| `!`      | Null assertion operator      | Casts an expression to its underlying non-nullable type, throwing a runtime exception if the cast fails; example: `foo!.bar` asserts `foo` is non-null and selects the property `bar`, unless `foo` is null in which case a runtime exception is thrown
{:.table .table-striped}

For more information about the `.`, `?.`, and `..` operators, see
[Classes][].


[operators as class members]: /language/methods#operators
[Dart language specification]: /guides/language/spec
[identical()]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-core/identical.html
[Operators]: /language/methods#operators
[library prefixes]: /language/libraries#specifying-a-library-prefix
[if-else]: /language/branches#if
[language version]: /guides/language/evolution#language-versioning
[Classes]: /language/classes


---
title: Pattern types
description: Pattern type reference in Dart.
prevpage:
  url: /language/patterns
  title: Patterns
nextpage:
  url: /language/functions
  title: Functions
---

This page is a reference for the different kinds of patterns.
For an overview of how patterns work, where you can use them in Dart, and common
use cases, visit the main [Patterns][] page.

#### Pattern precedence

Similar to [operator precedence](/language/operators#operator-precedence-example),
pattern evaluation adheres to precedence rules.
You can use [parenthesized patterns](#parenthesized) to 
evaluate lower-precedence patterns first.  

This document lists the pattern types in ascending order of precedence:

* [Logical-or](#logical-or) patterns are lower-precedence than [logical-and](#logical-and),
logical-and patterns are lower-precedence than [relational](#relational) patterns,
and so on. 

* Post-fix unary patterns ([cast](#cast), [null-check](#null-check),
and [null-assert](#null-assert)) share the same level of precedence. 

* The remaining primary patterns share the highest precedence.
Collection-type ([record](#record), [list](#list), and [map](#map))
and [Object](#object) patterns encompass other
data, so are evaluated first as outer-patterns. 

## Logical-or

`subpattern1 || subpattern2`

A logical-or pattern separates subpatterns by `||` and matches if any of the
branches match. Branches are evaluated left-to-right. Once a branch matches, the
rest are not evaluated.

<?code-excerpt "language/lib/patterns/pattern_types.dart (logical-or)"?>
```dart
var isPrimary = switch (color) {
  Color.red || Color.yellow || Color.blue => true,
  _ => false
};
```

Subpatterns in a logical-or pattern can bind variables, but the branches must
define the same set of variables, because only one branch will be evaluated when
the pattern matches.

## Logical-and	

`subpattern1 && subpattern2`

A pair of patterns separated by `&&` matches only if both subpatterns match. If the
left branch does not match, the right branch is not evaluated.

Subpatterns in a logical-and pattern can bind variables, but the variables in
each subpattern must not overlap, because they will both be bound if the pattern
matches:

<?code-excerpt "language/lib/patterns/pattern_types.dart (logical-and)"?>
```dart
switch ((1, 2)) {
  // Error, both subpatterns attempt to bind 'b'.
  case (var a, var b) && (var b, var c): // ...
}
```

## Relational

`== expression`

`< expression`

Relational patterns compare the matched value to a given constant using any of
the equality or relational operators: `==`, `!=`, `<`, `>`, `<=`, and `>=`.

The pattern matches when calling the appropriate operator on the matched value
with the constant as an argument returns `true`.

Relational patterns are useful for matching on numeric ranges, especially when
combined with the [logical-and pattern](#logical-and):

<?code-excerpt "language/lib/patterns/pattern_types.dart (relational)"?>
```dart
String asciiCharType(int char) {
  const space = 32;
  const zero = 48;
  const nine = 57;

  return switch (char) {
    < space => 'control',
    == space => 'space',
    > space && < zero => 'punctuation',
    >= zero && <= nine => 'digit',
    _ => ''
  };
}
```

## Cast

`foo as String`

A cast pattern lets you insert a [type cast][] in the middle of destructuring,
before passing the value to another subpattern:

<?code-excerpt "language/lib/patterns/pattern_types.dart (cast)"?>
```dart
(num, Object) record = (1, 's');
var (i as int, s as String) = record;
```

Cast patterns will [throw][] if the value doesn't have the stated type.
Like the [null-assert pattern](#null-assert), this lets you forcibly assert the
expected type of some destructured value.

## Null-check	

`subpattern?`

Null-check patterns match first if the value is not null, and then match the inner
pattern against that same value. They let you bind a variable whose type is the
non-nullable base type of the nullable value being matched.

To treat `null` values as match failures
without throwing, use the null-check pattern.

<?code-excerpt "language/lib/patterns/pattern_types.dart (null-check)"?>
```dart
String? maybeString = 'nullable with base type String';
switch (maybeString) {
  case var s?:
  // 's' has type non-nullable String here.
}
```

To match when the value _is_ null, use the [constant pattern](#constant) `null`.

## Null-assert	

`subpattern!`

Null-assert patterns match first if the object is not null, then on the value.
They permit non-null values to flow through, but [throw][] if the matched value
is null. 

To ensure `null` values are not silently treated as match failures,
use a null-assert pattern while matching:

<?code-excerpt "language/lib/patterns/pattern_types.dart (null-assert-match)"?>
```dart
List<String?> row = ['user', null];
switch (row) {
  case ['user', var name!]: // ...
  // 'name' is a non-nullable string here.
}
```

To eliminate `null` values from variable declaration patterns,
use the null-assert pattern:

<?code-excerpt "language/lib/patterns/pattern_types.dart (null-assert-dec)"?>
```dart
(int?, int?) position = (2, 3);

var (x!, y!) = position;
```

To match when the value _is_ null, use the [constant pattern](#constant) `null`.

## Constant	

`123, null, 'string', math.pi, SomeClass.constant, const Thing(1, 2), const (1 + 2)`

Constant patterns match when the value is equal to the constant: 

<?code-excerpt "language/lib/patterns/pattern_types.dart (constant)"?>
```dart
switch (number) {
  // Matches if 1 == number.
  case 1: // ...
}
```

You can use simple literals and references to named constants directly as constant patterns:

- Number literals (`123`, `45.56`)
- Boolean literals (`true`)
- String literals (`'string'`)
- Named constants (`someConstant`, `math.pi`, `double.infinity`)
- Constant constructors (`const Point(0, 0)`)
- Constant collection literals (`const []`, `const {1, 2}`)

More complex constant expressions must be parenthesized and prefixed with
`const` (`const (1 + 2)`):

<?code-excerpt "language/lib/patterns/pattern_types.dart (complex-constant)"?>
```dart
// List or map pattern:
case [a, b]: // ...

// List or map literal:
case const [a, b]: // ...
```

## Variable

`var bar, String str, final int _`

Variable patterns bind new variables to values that have been matched or destructured. 
They usually occur as part of a [destructuring pattern][destructure] to
capture a destructured value.

The variables are in scope in a region of code that is only reachable when the
pattern has matched.

<?code-excerpt "language/lib/patterns/pattern_types.dart (variable)"?>
```dart
switch ((1, 2)) {
  // 'var a' and 'var b' are variable patterns that bind to 1 and 2, respectively.
  case (var a, var b): // ...
  // 'a' and 'b' are in scope in the case body.
}
```

A _typed_ variable pattern only matches if the matched value has the declared type,
and fails otherwise:

<?code-excerpt "language/lib/patterns/pattern_types.dart (variable-typed)"?>
```dart
switch ((1, 2)) {
  // Does not match.
  case (int a, String b): // ...
}
```

You can use a [wildcard pattern](#wildcard) as a variable pattern. 

## Identifier	

`foo, _`

Identifier patterns may behave like a [constant pattern](#constant) or like a
[variable pattern](#variable), depending on the context where they appear:

- [Declaration][] context: declares a new variable with identifier name:
  `var (a, b) = (1, 2);`
- [Assignment][] context: assigns to existing variable with identifier name:
  `(a, b) = (3, 4);`
- [Matching][] context: treated as a named constant pattern (unless its name is `_`):
  <?code-excerpt "language/lib/patterns/pattern_types.dart (match-context)"?>
  ```dart
  const c = 1;
  switch (2) {
    case c:
      print('match $c');
    default:
      print('no match'); // Prints "no match".
  }
  ``` 
- [Wildcard](#wildcard) identifier in any context: matches any value and discards it:
  `case [_, var y, _]: print('The middle element is $y');`

## Parenthesized

`(subpattern)`

Like parenthesized expressions, parentheses in a pattern let you control
[pattern precedence](#pattern-precedence) and insert a lower-precedence
pattern where a higher precedence one is expected.

For example, imagine the boolean constants `x`, `y`, and `z` are 
equal to `true`, `true`, and `false`, respectively:

<?code-excerpt "language/lib/patterns/pattern_types.dart (parens)"?>
``` dart
// ...
x || y && z => 'matches true',
(x || y) && z => 'matches false',
// ...
```

In the first case, the logical-and pattern `y && z` evaluates first because
logical-and patterns have higher precedence than logical-or.
In the next case, the logical-or pattern is parenthesized. It evaluates first,
which results in a different match.


## List

`[subpattern1, subpattern2]`

A list pattern matches values that implement [`List`][], and then recursively
matches its subpatterns against the list's elements to destructure them by position:

<?code-excerpt "language/lib/patterns/switch.dart (list-pattern)"?>
```dart
const a = 'a';
const b = 'b';
switch (obj) {
  // List pattern [a, b] matches obj first if obj is a list with two fields,
  // then if its fields match the constant subpatterns 'a' and 'b'.
  case [a, b]:
    print('$a, $b');
}
```  

List patterns require that the number of elements in the pattern match the entire
list. You can, however, use a [rest element](#rest-element) as a place holder to
account for any number of elements in a list. 

### Rest element

List patterns can contain _one_ rest element (`...`) which allows matching lists
of arbitrary lengths.

<?code-excerpt "language/lib/patterns/pattern_types.dart (rest)"?>
```dart
var [a, b, ..., c, d] = [1, 2, 3, 4, 5, 6, 7];
// Prints "1 2 6 7".
print('$a $b $c $d');
```

A rest element can also have a subpattern that collects elements that don't match
the other subpatterns in the list, into a new list:

<?code-excerpt "language/lib/patterns/pattern_types.dart (rest-sub)"?>
```dart
var [a, b, ...rest, c, d] = [1, 2, 3, 4, 5, 6, 7];
// Prints "1 2 [3, 4, 5] 6 7".
print('$a $b $rest $c $d');
```

## Map

`{"key": subpattern1, someConst: subpattern2}`

Map patterns match values that implement [`Map`][], and then recursively 
match its subpatterns against the map's keys to destructure them.

Map patterns don't require the pattern to match the entire map. A map pattern
ignores any keys that the map contains that aren't matched by the pattern.

## Record

`(subpattern1, subpattern2)`

`(x: subpattern1, y: subpattern2)`

Record patterns match a [record][] object and destructure its fields.
If the value isn't a record with the same [shape][] as the pattern, the match
fails. Otherwise, the field subpatterns are matched against the corresponding
fields in the record.

Record patterns require that the pattern match the entire record. To destructure 
a record with _named_ fields using a pattern, include the field names in the pattern:

<?code-excerpt "language/lib/patterns/pattern_types.dart (record)"?>
```dart
var (myString: foo, myNumber: bar) = (myString: 'string', myNumber: 1);
```

The getter name can be omitted and inferred from the [variable pattern](#variable)
or [identifier pattern](#identifier) in the field subpattern. These pairs of
patterns are each equivalent:

<?code-excerpt "language/lib/patterns/pattern_types.dart (record-getter)"?>
```dart
// Record pattern with variable subpatterns:
var (untyped: untyped, typed: int typed) = record;
var (:untyped, :int typed) = record;

switch (record) {
  case (untyped: var untyped, typed: int typed): // ...
  case (:var untyped, :int typed): // ...
}

// Record pattern wih null-check and null-assert subpatterns:
switch (record) {
  case (checked: var checked?, asserted: var asserted!): // ...
  case (:var checked?, :var asserted!): // ...
}

// Record pattern wih cast subpattern:
var (untyped: untyped as int, typed: typed as String) = record;
var (:untyped as int, :typed as String) = record;
```

## Object

`SomeClass(x: subpattern1, y: subpattern2)`

Object patterns check the matched value against a given named type to destructure
data using getters on the object's properties. They are [refuted][]
if the value doesn't have the same type.

<?code-excerpt "language/lib/patterns/pattern_types.dart (object)"?>
```dart
switch (shape) {
  // Matches if shape is of type Rect, and then against the properties of Rect.
  case Rect(width: var w, height: var h): // ...
}
```  

The getter name can be omitted and inferred from the [variable pattern](#variable)
or [identifier pattern](#identifier) in the field subpattern:

<?code-excerpt "language/lib/patterns/pattern_types.dart (object-getter)"?>
```dart
// Binds new variables x and y to the values of Point's x and y properties.
var Point(:x, :y) = Point(1, 2);
```

Object patterns don't require the pattern to match the entire object.
If an object has extra fields that the pattern doesn't destructure, it can still match.

## Wildcard

`_`

A pattern named `_` is a wildcard, either a [variable pattern](#variable) or
[identifier pattern](#identifier), that doesn't bind or assign to any variable.

It's useful as a placeholder in places where you need a subpattern in order to
destructure later positional values:

<?code-excerpt "language/lib/patterns/pattern_types.dart (wildcard)"?>
```dart
var list = [1, 2, 3];
var [_, two, _] = list;
```

A wildcard name with a type annotation is useful when you want to test a value's
type but not bind the value to a name:

<?code-excerpt "language/lib/patterns/pattern_types.dart (wildcard-typed)"?>
```dart
switch (record) {
  case (int _, String _):
    print('First field is int and second is String.');
}
```

[Patterns]: /language/patterns
[type cast]: /language/operators#type-test-operators
[destructure]: /language/patterns#destructuring
[throw]: /language/error-handling#throw
[Declaration]: /language/patterns#variable-declaration
[Assignment]: /language/patterns#variable-assignment
[Matching]: /language/patterns#matching
[`List`]: /language/collections#lists
[`Map`]: /language/collections#maps
[refuted]: /resources/glossary#refutable-pattern
[record]: /language/records
[shape]: /language/records#record-types
[switch]: /language/branches#switch


---
title: Patterns
description: Summary of patterns in Dart.
prevpage:
  url: /language/type-system
  title: Type system
nextpage:
  url: /language/pattern-types
  title: Pattern types
---

{{site.alert.version-note}}
  Patterns require a [language version][] of at least 3.0.
{{site.alert.end}}

Patterns are a syntactic category in the Dart language, like statements and expressions.
A pattern represents the shape of a set of values that it may match against actual
values.

This page describes:
- What patterns do.
- Where patterns are allowed in Dart code.
- What the common use cases for patterns are.

To learn about the different kinds of patterns, visit the [pattern types][types]
page.

## What patterns do

In general, a pattern may **match** a value, **destructure** a value, or both,
depending on the context and shape of the pattern.

First, _pattern matching_ allows you to check whether a given value:
- Has a certain shape.
- Is a certain constant.
- Is equal to something else.
- Has a certain type.

Then, _pattern destructuring_ provides you with a convenient declarative syntax to
break that value into its constituent parts. The same pattern can also let you 
bind variables to some or all of those parts in the process.

### Matching

A pattern always tests against a value to determine if the value has the form
you expect. In other words, you are checking if the value _matches_ the pattern. 

What constitutes a match depends on [what kind of pattern][types] you are using.
For example, a constant pattern matches if the value is equal to the pattern's 
constant:

<?code-excerpt "language/lib/patterns/switch.dart (constant-pattern)"?>
```dart
switch (number) {
  // Constant pattern matches if 1 == number.
  case 1:
    print('one');
}
```

Many patterns make use of subpatterns, sometimes called _outer_ and _inner_
patterns, respectively. Patterns match recursively on their subpatterns.
For example, the individual fields of any [collection-type][] pattern could be 
[variable patterns][variable] or [constant patterns][constant]:

<?code-excerpt "language/lib/patterns/switch.dart (list-pattern)"?>
```dart
const a = 'a';
const b = 'b';
switch (obj) {
  // List pattern [a, b] matches obj first if obj is a list with two fields,
  // then if its fields match the constant subpatterns 'a' and 'b'.
  case [a, b]:
    print('$a, $b');
}
```

To ignore parts of a matched value, you can use a [wildcard pattern][]
as a placeholder. In the case of list patterns, you can use a [rest element][].

### Destructuring

When an object and pattern match, the pattern can then access the object's data 
and extract it in parts. In other words, the pattern _destructures_ the object:

<?code-excerpt "language/lib/patterns/destructuring.dart (list-pattern)"?>
```dart
var numList = [1, 2, 3];
// List pattern [a, b, c] destructures the three elements from numList...
var [a, b, c] = numList;
// ...and assigns them to new variables.
print(a + b + c);
```

You can nest [any kind of pattern][types] inside a destructuring pattern. 
For example, this case pattern matches and destructures a two-element
list whose first element is `'a'` or `'b'`:

<?code-excerpt "language/lib/patterns/destructuring.dart (nested-pattern)"?>
```dart
switch (list) {
  case ['a' || 'b', var c]:
    print(c);
}
```

## Places patterns can appear

You can use patterns in several places in the Dart language:

<a id="pattern-uses"></a>

- Local variable [declarations](#variable-declaration) and [assignments](#variable-assignment)
- [for and for-in loops][for]
- [if-case][if] and [switch-case][switch]
- Control flow in [collection literals][]

This section describes common use cases for matching and destructuring with patterns.

### Variable declaration

You can use a _pattern variable declaration_ anywhere Dart allows local variable
declaration. 
The pattern matches against the value on the right of the declaration.
Once matched, it destructures the value and binds it to new local variables:

<?code-excerpt "language/lib/patterns/destructuring.dart (variable-declaration)"?>
```dart
// Declares new variables a, b, and c.
var (a, [b, c]) = ('str', [1, 2]);
```

A pattern variable declaration must start with either `var` or `final`, followed
by a pattern. 

### Variable assignment 

A _variable assignment pattern_ falls on the left side of an assignment.
First, it destructures the matched object. Then it assigns the values to
_existing_ variables, instead of binding new ones. 

Use a variable assignment pattern to swap the values of two variables without
declaring a third temporary one:

<?code-excerpt "language/lib/patterns/destructuring.dart (variable-assignment)"?>
```dart
var (a, b) = ('left', 'right');
(b, a) = (a, b); // Swap.
print('$a $b'); // Prints "right left".
```

### Switch statements and expressions

Every case clause contains a pattern. This applies to [switch statements][switch]
and [expressions][], as well as [if-case statements][if].
You can use [any kind of pattern][types] in a case.

_Case patterns_ are [refutable][].
They allow control flow to either:
- Match and destructure the object being switched on.
- Continue execution if the object doesn't match.

The values that a pattern destructures in a case become local variables.
Their scope is only within the body of that case.

<?code-excerpt "language/lib/patterns/switch.dart (switch-statement)"?>
```dart
switch (obj) {
  // Matches if 1 == obj.
  case 1:
    print('one');

  // Matches if the value of obj is between the
  // constant values of 'first' and 'last'.
  case >= first && <= last:
    print('in range');

  // Matches if obj is a record with two fields,
  // then assigns the fields to 'a' and 'b'.
  case (var a, var b):
    print('a = $a, b = $b');

  default:
}
```

<a id="or-pattern-switch"></a>

[Logical-or patterns][logical-or] are useful for having multiple cases share a
body in switch expressions or statements:

<?code-excerpt "language/lib/patterns/switch.dart (or-share-body)"?>
```dart
var isPrimary = switch (color) {
  Color.red || Color.yellow || Color.blue => true,
  _ => false
};
```

Switch statements can have multiple cases share a body
[without using logical-or patterns][share], but they are
still uniquely useful for allowing multiple cases to share a [guard][]:

<?code-excerpt "language/lib/patterns/switch.dart (or-share-guard)"?>
```dart
switch (shape) {
  case Square(size: var s) || Circle(size: var s) when s > 0:
    print('Non-empty symmetric shape');
}
```

[Guard clauses][guard] evaluate an arbitrary conditon as part of a case, without
exiting the switch if the condition is false
(like using an `if` statement in the case body would cause).

<?code-excerpt "language/lib/control_flow/branches.dart (guard)"?>
```dart
switch (pair) {
  case (int a, int b):
    if (a > b) print('First element greater');
  // If false, prints nothing and exits the switch.
  case (int a, int b) when a > b:
    // If false, prints nothing but proceeds to next case.
    print('First element greater');
  case (int a, int b):
    print('First element not greater');
}
```

### For and for-in loops

You can use patterns in [for and for-in loops][for] to iterate-over and destructure
values in a collection.

This example uses [object destructuring][object] in a for-in loop to destructure
the [`MapEntry`][] objects that a `<Map>.entries` call returns:

<?code-excerpt "language/lib/patterns/for_in.dart (for-in-pattern)"?>
```dart
Map<String, int> hist = {
  'a': 23,
  'b': 100,
};

for (var MapEntry(key: key, value: count) in hist.entries) {
  print('$key occurred $count times');
}
```

The object pattern checks that `hist.entries` has the named type `MapEntry`,
and then recurses into the named field subpatterns `key` and `value`.
It calls the `key` getter and `value` getter on the `MapEntry` in each iteration,
and binds the results to local variables `key` and `count`, respectively.

Binding the result of a getter call to a variable of the same name is a common
use case, so object patterns can also infer the getter name from the
[variable subpattern][variable]. This allows you to simplify the variable pattern
from something redundant like `key: key` to just `:key`:

<?code-excerpt "language/lib/patterns/for_in.dart (for-in-short)"?>
```dart
for (var MapEntry(:key, value: count) in hist.entries) {
  print('$key occurred $count times');
}
```

## Use cases for patterns

The [previous section](#places-patterns-can-appear)
describes _how_ patterns fit into other Dart code constructs. 
You saw some interesting use cases as examples, like [swapping](#variable-assignment)
the values of two variables, or
[destructuring key-value pairs](#for-and-for-in-loops)
in a map. This section describes even more use cases, answering:

- _When and why_ you might want to use patterns.
- What kinds of problems they solve.
- Which idioms they best suit.

### Destructuring multiple returns

[Records][] allow aggregating and returning multiple values from a single function
call. Patterns add the ability to destructure a record's fields
directly into local variables, inline with the function call.

Instead of individually declaring new local variables for each record field,
like this:

<?code-excerpt "language/lib/patterns/destructuring.dart (destructure-multiple-returns-1)"?>
```dart
var info = userInfo(json);
var name = info.$1;
var age = info.$2;
```

You can destructure the fields of a record that a function returns into local
variables using a [variable declaration](#variable-declaration) or
[assigment pattern](#variable-assignment), and a record pattern as its subpattern:

<?code-excerpt "language/lib/patterns/destructuring.dart (destructure-multiple-returns-2)"?>
```dart
var (name, age) = userInfo(json);
```

### Destructuring class instances

[Object patterns][object] match against named object types, allowing
you to destructure their data using the getters the object's class already exposes.

To destructure an instance of a class, use the named type, 
followed by the properties to 
destructure enclosed in parentheses:

<?code-excerpt "language/lib/patterns/destructuring.dart (destructure-class-instances)"?>
```dart
final Foo myFoo = Foo(one: 'one', two: 2);
var Foo(:one, :two) = myFoo;
print('one $one, two $two');
```

### Algebraic data types 

Object destructuring and switch cases are conducive to writing
code in an [algebraic data type][] style.
Use this method when:
- You have a family of related types.
- You have an operation that needs specific behavior for each type.
- You want to group that behavior in one place instead of spreading it across all
the different type definitions. 

Instead of implementing the operation as an instance method for every type,
keep the operation's variations in a single function that switches over the subtypes:

<?code-excerpt "language/lib/patterns/algebraic_datatypes.dart (algebraic_datatypes)"?>
```dart
sealed class Shape {}

class Square implements Shape {
  final double length;
  Square(this.length);
}

class Circle implements Shape {
  final double radius;
  Circle(this.radius);
}

double calculateArea(Shape shape) => switch (shape) {
      Square(length: var l) => l * l,
      Circle(radius: var r) => math.pi * r * r
    };
```

### Validating incoming JSON

[Map][] and [list][] patterns work well for destructuring key-value pairs in
JSON data:

<?code-excerpt "language/lib/patterns/json.dart (json-1)"?>
```dart 
var json = {
  'user': ['Lily', 13]
};
var {'user': [name, age]} = json;
```

If you know that the JSON data has the structure you expect,
the previous example is realistic.
But data typically comes from an external source, like over the network.
You need to validate it first to confirm its structure. 

Without patterns, validation is verbose:

<?code-excerpt "language/lib/patterns/json.dart (json-2)"?>
```dart
if (json is Map<String, Object?> &&
    json.length == 1 &&
    json.containsKey('user')) {
  var user = json['user'];
  if (user is List<Object> &&
      user.length == 2 &&
      user[0] is String &&
      user[1] is int) {
    var name = user[0] as String;
    var age = user[1] as int;
    print('User $name is $age years old.');
  }
}
```

A single [case pattern](#switch-statements-and-expressions)
can achieve the same validation.
Single cases work best as [if-case][if] statements.
Patterns provide a more declarative, and much less verbose
method of validating JSON:

<?code-excerpt "language/lib/patterns/json.dart (json-3)"?>
```dart
if (json case {'user': [String name, int age]}) {
  print('User $name is $age years old.');
}
```

This case pattern simultaneously validates that:

- `json` is a map, because it must first match the outer [map pattern][map] to proceed.
  - And, since it's a map, it also confirms `json` is not null.
- `json` contains a key `user`.
- The key `user` pairs with a list of two values.
- The types of the list values are `String` and `int`.
- The new local variables to hold the values are `String` and `int`. 


[language version]: /guides/language/evolution#language-versioning
[types]: /language/pattern-types
[collection-type]: /language/collections
[wildcard pattern]: /language/pattern-types#wildcard
[rest element]: /language/pattern-types#rest-element
[null-check pattern]: /language/pattern-types#null-check
[for]: /language/loops#for-loops
[if]: /language/branches#if-case
[switch]: /language/branches#switch-statements
[expressions]: /language/branches#switch-expressions
[collection literals]: /language/collections#control-flow-operators
[null-assert pattern]: /language/pattern-types#null-assert
[record]: /language/pattern-types#record
[Records]: /language/records
[refutable]: /resources/glossary#refutable-pattern
[constant]: /language/pattern-types#constant
[list]: /language/pattern-types#list
[map]: /language/pattern-types#map
[variable]: /language/pattern-types#variable
[logical-or]: /language/pattern-types#logical-or
[share]: /language/branches#switch-share
[guard]: /language/branches#guard-clause
[relational]: /language/pattern-types#relational
[check]: /language/pattern-types#null-check
[assert]: /language/pattern-types#null-assert
[object]: /language/pattern-types#object
[`MapEntry`]: {{site.dart-api}}/{{site.data.pkg-vers.SDK.channel}}/dart-core/MapEntry-class.html
[algebraic data type]: https://en.wikipedia.org/wiki/Algebraic_data_type


---
title: Records
description: Summary of the record data structure in Dart.
prevpage:
  url: /language/built-in-types
  title: Built-in types
nextpage:
  url: /language/collections
  title: Collections
---

{{site.alert.version-note}}
  Records require a [language version][] of at least 3.0.
{{site.alert.end}}

Records are an anonymous, immutable, aggregate type. Like other [collection types][], 
they let you bundle multiple objects into a single object. Unlike other collection 
types, records are fixed-sized, heterogeneous, and typed.

Records are real values; you can store them in variables, 
nest them, pass them to and from functions, 
and store them in data structures such as lists, maps, and sets.

## Record syntax

_Records expressions_ are comma-delimited lists of named or positional fields,
enclosed in parentheses:

<?code-excerpt "language/test/records_test.dart (record-syntax)"?>
```dart
var record = ('first', a: 2, b: true, 'last');
```

_Record type annotations_ are comma-delimited lists of types enclosed in parentheses.
You can use record type annotations to define return types and parameter types.
For example, the following `(int, int)` statements are record type annotations:

<?code-excerpt "language/test/records_test.dart (record-type-annotation)"?>
```dart
(int, int) swap((int, int) record) {
  var (a, b) = record;
  return (b, a);
}
```

Fields in record expressions and type annotations mirror
how [parameters and arguments][] work in functions. 
Positional fields go directly inside the parentheses:

<?code-excerpt "language/test/records_test.dart (record-type-declaration)"?>
```dart
// Record type annotation in a variable declaration:
(String, int) record;

// Initialize it with a record expression:
record = ('A string', 123);
```

In a record type annotation, named fields go inside a curly brace-delimited
section of type-and-name pairs, after all positional fields. In a record
expression, the names go before each field value with a colon after:

<?code-excerpt "language/test/records_test.dart (record-type-named-declaration)"?>
```dart
// Record type annotation in a variable declaration:
({int a, bool b}) record;

// Initialize it with a record expression:
record = (a: 123, b: true);
```

The names of named fields in a record type are part of
the [record's type definition](#record-types), or its _shape_. 
Two records with named fields with
different names have different types:

<?code-excerpt "language/test/records_test.dart (record-type-mismatched-names)"?>
```dart
({int a, int b}) recordAB = (a: 1, b: 2);
({int x, int y}) recordXY = (x: 3, y: 4);

// Compile error! These records don't have the same type.
// recordAB = recordXY;
```

In a record type annotation, you can also name the *positional* fields, but
these names are purely for documentation and don't affect the record's type:

<?code-excerpt "language/test/records_test.dart (record-type-matched-names)"?>
```dart
(int a, int b) recordAB = (1, 2);
(int x, int y) recordXY = (3, 4);

recordAB = recordXY; // OK.
```

This is similar to how positional parameters
in a function declaration or function typedef
can have names but those names don't affect the signature of the function.

For more information and examples, check out 
[Record types](#record-types) and [Record equality](#record-equality).

## Record fields

Record fields are accessible through built-in getters. Records are immutable,
so fields do not have setters. 

Named fields expose getters of the same name. Positional fields expose getters
of the name `$<position>`, skipping named fields:

<?code-excerpt "language/test/records_test.dart (record-getters)"?>
```dart
var record = ('first', a: 2, b: true, 'last');

print(record.$1); // Prints 'first'
print(record.a); // Prints 2
print(record.b); // Prints true
print(record.$2); // Prints 'last'
```

To streamline record field access even more, 
check out the page on [Patterns][pattern].

## Record types

There is no type declaration for individual record types. Records are structurally
typed based on the types of their fields. A record's _shape_ (the set of its fields,
the fields' types, and their names, if any) uniquely determines the type of a record. 

Each field in a record has its own type. Field types can differ within the same
record. The type system is aware of each field's type wherever it is accessed
from the record:

<?code-excerpt "language/test/records_test.dart (record-getters-two)"?>
```dart
(num, Object) pair = (42, 'a');

var first = pair.$1; // Static type `num`, runtime type `int`.
var second = pair.$2; // Static type `Object`, runtime type `String`.
```

Consider two unrelated libraries that create records with the same set of fields.
The type system understands that those records are the same type even though the
libraries are not coupled to each other.

## Record equality

Two records are equal if they have the same _shape_ (set of fields),
and their corresponding fields have the same values.
Since named field _order_ is not part of a record's shape, the order of named
fields does not affect equality.

For example:

<?code-excerpt "language/test/records_test.dart (record-shape)"?>
```dart
(int x, int y, int z) point = (1, 2, 3);
(int r, int g, int b) color = (1, 2, 3);

print(point == color); // Prints 'true'.
```

<?code-excerpt "language/test/records_test.dart (record-shape-mismatch)"?>
```dart
({int x, int y, int z}) point = (x: 1, y: 2, z: 3);
({int r, int g, int b}) color = (r: 1, g: 2, b: 3);

print(point == color); // Prints 'false'. Lint: Equals on unrelated types.
```

Records automatically define `hashCode` and `==` methods based on the structure
of their fields.

## Multiple returns

Records allow functions to return multiple values bundled together.
To retrieve record values from a return,
destructure the values into local variables using [pattern matching][pattern].

<?code-excerpt "language/test/records_test.dart (record-multiple-returns)"?>
```dart
// Returns multiple values in a record:
(String, int) userInfo(Map<String, dynamic> json) {
  return (json['name'] as String, json['age'] as int);
}

final json = <String, dynamic>{
  'name': 'Dash',
  'age': 10,
  'color': 'blue',
};

// Destructures using a record pattern:
var (name, age) = userInfo(json);

/* Equivalent to:
  var info = userInfo(json);
  var name = info.$1;
  var age  = info.$2;
*/
```

You can return multiple values from a function without records,
but other methods come with downsides.
For example, creating a class is much more verbose, and using other collection
types like `List` or `Map` loses type safety. 

{{site.alert.note}}
  Records' multiple-return and heterogeneous-type characteristics enable
  parallelization of futures of different types, which you can read about in the
  [Library tour][].
{{site.alert.end}}

[language version]: /guides/language/evolution#language-versioning
[collection types]: /language/collections
[pattern]: /language/patterns#destructuring-multiple-returns
[Library tour]: /guides/libraries/library-tour#handling-errors-for-multiple-futures
[parameters and arguments]: /language/functions#parameters


---
title: The Dart type system
description: Why and how to write sound Dart code.
prevpage:
  url: /language/typedefs
  title: Typedefs
nextpage:
  url: /language/patterns
  title: Patterns
---
<?code-excerpt replace="/ *\/\/\s+ignore_for_file:[^\n]+\n//g; /([A-Z]\w*)\d\b/$1/g; /\b(main)\d\b/$1/g; /(^|\n) *\/\/\s+ignore:[^\n]+\n/$1/g; /(\n[^\n]+) *\/\/\s+ignore:[^\n]+\n/$1\n/g"?>
<?code-excerpt path-base="type_system"?>

The Dart language is type safe: it uses a combination of static type checking
and [runtime checks](#runtime-checks) to
ensure that a variable's value always matches the variable's static type,
sometimes referred to as sound typing.
Although _types_ are mandatory, type _annotations_ are optional
because of [type inference](#type-inference).

One benefit of static type checking is the ability to find bugs
at compile time using Dart's [static analyzer.][analysis]

You can fix most static analysis errors by adding type annotations to generic
classes. The most common generic classes are the collection types
`List<T>` and `Map<K,V>`.

For example, in the following code the `printInts()` function prints an integer list,
and `main()` creates a list and passes it to `printInts()`.

{:.fails-sa}
<?code-excerpt "lib/strong_analysis.dart (opening-example)" replace="/list(?=\))/[!$&!]/g"?>
```dart
void printInts(List<int> a) => print(a);

void main() {
  final list = [];
  list.add(1);
  list.add('2');
  printInts([!list!]);
}
```

The preceding code results in a type error on `list` (highlighted
above) at the call of `printInts(list)`:

{:.console-output}
<?code-excerpt "analyzer-results-stable.txt" retain="/strong_analysis.*List.*argument_type_not_assignable/" replace="/-(.*?):(.*?):(.*?)-/-/g; /. • (lib|test)\/\w+\.dart:\d+:\d+//g"?>
```nocode
error - The argument type 'List<dynamic>' can't be assigned to the parameter type 'List<int>'. - argument_type_not_assignable
```

The error highlights an unsound implicit cast from `List<dynamic>` to `List<int>`.
The `list` variable has static type `List<dynamic>`. This is because the
initializing declaration `var list = []` doesn't provide the analyzer with
enough information for it to infer a type argument more specific than `dynamic`.
The `printInts()` function expects a parameter of type `List<int>`,
causing a mismatch of types.

When adding a type annotation (`<int>`) on creation of the list
(highlighted below) the analyzer complains that
a string argument can't be assigned to an `int` parameter. 
Removing the quotes in `list.add('2')` results in code
that passes static analysis and runs with no errors or warnings.

{:.passes-sa}
<?code-excerpt "test/strong_test.dart (opening-example)" replace="/<int.(?=\[)|2/[!$&!]/g"?>
```dart
void printInts(List<int> a) => print(a);

void main() {
  final list = [!<int>!][];
  list.add(1);
  list.add([!2!]);
  printInts(list);
}
```

[Try it in DartPad]({{site.dartpad}}/25074a51a00c71b4b000f33b688dedd0).

## What is soundness?

*Soundness* is about ensuring your program can't get into certain
invalid states. A sound *type system* means you can never get into
a state where an expression evaluates to a value that doesn't match
the expression's static type. For example, if an expression's static
type is `String`, at runtime you are guaranteed to only get a string
when you evaluate it.

Dart's type system, like the type systems in Java and C#, is sound. It
enforces that soundness using a combination of static checking
(compile-time errors) and runtime checks. For example, assigning a `String`
to `int` is a compile-time error. Casting an object to a `String` using
`as String` fails with a runtime error if the object isn't a `String`.


## The benefits of soundness

A sound type system has several benefits:

* Revealing type-related bugs at compile time.<br>
  A sound type system forces code to be unambiguous about its types,
  so type-related bugs that might be tricky to find at runtime are
  revealed at compile time.

* More readable code.<br>
  Code is easier to read because you can rely on a value actually having
  the specified type. In sound Dart, types can't lie.

* More maintainable code.<br>
  With a sound type system, when you change one piece of code, the
  type system can warn you about the other pieces
  of code that just broke.

* Better ahead of time (AOT) compilation.<br>
  While AOT compilation is possible without types, the generated
  code is much less efficient.


## Tips for passing static analysis

Most of the rules for static types are easy to understand.
Here are some of the less obvious rules:

* Use sound return types when overriding methods.
* Use sound parameter types when overriding methods.
* Don't use a dynamic list as a typed list.

Let's see these rules in detail, with examples that use the following
type hierarchy:

<img src="/assets/img/language/type-hierarchy.png" alt="a hierarchy of animals where the supertype is Animal and the subtypes are Alligator, Cat, and HoneyBadger. Cat has the subtypes of Lion and MaineCoon">

<a name="use-proper-return-types"></a>
### Use sound return types when overriding methods

The return type of a method in a subclass must be the same type or a
subtype of the return type of the method in the superclass. 
Consider the getter method in the `Animal` class:

<?code-excerpt "lib/animal.dart (Animal)" replace="/Animal get.*/[!$&!]/g"?>
```dart
class Animal {
  void chase(Animal a) { ... }
  [!Animal get parent => ...!]
}
```

The `parent` getter method returns an `Animal`. In the `HoneyBadger` subclass,
you can replace the getter's return type with `HoneyBadger` 
(or any other subtype of `Animal`), but an unrelated type is not allowed.

{:.passes-sa}
<?code-excerpt "lib/animal.dart (HoneyBadger)" replace="/(\w+)(?= get)/[!$&!]/g"?>
```dart
class HoneyBadger extends Animal {
  @override
  void chase(Animal a) { ... }

  @override
  [!HoneyBadger!] get parent => ...
}
```

{:.fails-sa}
<?code-excerpt "lib/animal.dart (HoneyBadger)" replace="/HoneyBadger/[!Root!]/g"?>
```dart
class [!Root!] extends Animal {
  @override
  void chase(Animal a) { ... }

  @override
  [!Root!] get parent => ...
}
```

<a name="use-proper-param-types"></a>
### Use sound parameter types when overriding methods

The parameter of an overridden method must have either the same type
or a supertype of the corresponding parameter in the superclass.
Don't "tighten" the parameter type by replacing the type with a
subtype of the original parameter.

{{site.alert.note}}
  If you have a valid reason to use a subtype, you can use the
  [`covariant` keyword](/guides/language/sound-problems#the-covariant-keyword).
{{site.alert.end}}

Consider the `chase(Animal)` method for the `Animal` class:

<?code-excerpt "lib/animal.dart (Animal)" replace="/void chase.*/[!$&!]/g"?>
```dart
class Animal {
  [!void chase(Animal a) { ... }!]
  Animal get parent => ...
}
```

The `chase()` method takes an `Animal`. A `HoneyBadger` chases anything.
It's OK to override the `chase()` method to take anything (`Object`).

{:.passes-sa}
<?code-excerpt "lib/animal.dart (chase-Object)" replace="/Object/[!$&!]/g"?>
```dart
class HoneyBadger extends Animal {
  @override
  void chase([!Object!] a) { ... }

  @override
  Animal get parent => ...
}
```

The following code tightens the parameter on the `chase()` method
from `Animal` to `Mouse`, a subclass of `Animal`.

{:.fails-sa}
<?code-excerpt "lib/incorrect_animal.dart (chase-mouse)" replace="/Mouse/[!$&!]/g"?>
```dart
class [!Mouse!] extends Animal { ... }

class Cat extends Animal {
  @override
  void chase([!Mouse!] a) { ... }
}
```

This code is not type safe because it would then be possible to define
a cat and send it after an alligator:

<?code-excerpt "lib/incorrect_animal.dart (would-not-be-type-safe)" replace="/Alligator/[!$&!]/g"?>
```dart
Animal a = Cat();
a.chase([!Alligator!]()); // Not type safe or feline safe.
```

### Don't use a dynamic list as a typed list

A `dynamic` list is good when you want to have a list with
different kinds of things in it. However, you can't use a
`dynamic` list as a typed list.

This rule also applies to instances of generic types.

The following code creates a `dynamic` list of `Dog`, and assigns it to
a list of type `Cat`, which generates an error during static analysis.

{:.fails-sa}
<?code-excerpt "lib/incorrect_animal.dart (invalid-dynamic-list)" replace="/(<dynamic\x3E)(.*?)Error/[!$1!]$2Error/g"?>
```dart
void main() {
  List<Cat> foo = [!<dynamic>!][Dog()]; // Error
  List<dynamic> bar = <dynamic>[Dog(), Cat()]; // OK
}
```

## Runtime checks

Runtime checks deal with type safety issues
that can't be detected at compile time.

For example, the following code throws an exception at runtime
because it's an error to cast a list of dogs to a list of cats:

{:.runtime-fail}
<?code-excerpt "test/strong_test.dart (runtime-checks)" replace="/animals as[^;]*/[!$&!]/g"?>
```dart
void main() {
  List<Animal> animals = [Dog()];
  List<Cat> cats = [!animals as List<Cat>!];
}
```


## Type inference

The analyzer can infer types for fields, methods, local variables,
and most generic type arguments.
When the analyzer doesn't have enough information to infer
a specific type, it uses the `dynamic` type.

Here's an example of how type inference works with generics.
In this example, a variable named `arguments` holds a map that
pairs string keys with values of various types.

If you explicitly type the variable, you might write this:

<?code-excerpt "lib/strong_analysis.dart (type-inference-1-orig)" replace="/Map<String, dynamic\x3E/[!$&!]/g"?>
```dart
[!Map<String, dynamic>!] arguments = {'argA': 'hello', 'argB': 42};
```

Alternatively, you can use `var` or `final` and let Dart infer the type:

<?code-excerpt "lib/strong_analysis.dart (type-inference-1)" replace="/var/[!$&!]/g"?>
```dart
[!var!] arguments = {'argA': 'hello', 'argB': 42}; // Map<String, Object>
```

The map literal infers its type from its entries,
and then the variable infers its type from the map literal's type.
In this map, the keys are both strings, but the values have different
types (`String` and `int`, which have the upper bound `Object`).
So the map literal has the type `Map<String, Object>`,
and so does the `arguments` variable.


### Field and method inference

A field or method that has no specified type and that overrides
a field or method from the superclass, inherits the type of the
superclass method or field.

A field that does not have a declared or inherited type but that is declared
with an initial value, gets an inferred type based on the initial value.

### Static field inference

Static fields and variables get their types inferred from their
initializer. Note that inference fails if it encounters a cycle
(that is, inferring a type for the variable depends on knowing the
type of that variable).

### Local variable inference

Local variable types are inferred from their initializer, if any.
Subsequent assignments are not taken into account.
This may mean that too precise a type may be inferred.
If so, you can add a type annotation.

{:.fails-sa}
<?code-excerpt "lib/strong_analysis.dart (local-var-type-inference-error)"?>
```dart
var x = 3; // x is inferred as an int.
x = 4.0;
```

{:.passes-sa}
<?code-excerpt "lib/strong_analysis.dart (local-var-type-inference-ok)"?>
```dart
num y = 3; // A num can be double or int.
y = 4.0;
```

### Type argument inference

Type arguments to constructor calls and
[generic method](/language/generics#using-generic-methods) invocations
are inferred based on a combination of downward information from the context
of occurrence, and upward information from the arguments to the constructor
or generic method. If inference is not doing what you want or expect,
you can always explicitly specify the type arguments.

{:.passes-sa}
<?code-excerpt "lib/strong_analysis.dart (type-arg-inference)"?>
```dart
// Inferred as if you wrote <int>[].
List<int> listOfInt = [];

// Inferred as if you wrote <double>[3.0].
var listOfDouble = [3.0];

// Inferred as Iterable<int>.
var ints = listOfDouble.map((x) => x.toInt());
```

In the last example, `x` is inferred as `double` using downward information.
The return type of the closure is inferred as `int` using upward information.
Dart uses this return type as upward information when inferring the `map()`
method's type argument: `<int>`.


## Substituting types

When you override a method, you are replacing something of one type (in the
old method) with something that might have a new type (in the new method).
Similarly, when you pass an argument to a function,
you are replacing something that has one type (a parameter
with a declared type) with something that has another type
(the actual argument). When can you replace something that
has one type with something that has a subtype or a supertype?

When substituting types, it helps to think in terms of _consumers_
and _producers_. A consumer absorbs a type and a producer generates a type.

**You can replace a consumer's type with a supertype and a producer's
type with a subtype.**

Let's look at examples of simple type assignment and assignment with
generic types.

### Simple type assignment

When assigning objects to objects, when can you replace a type with a
different type? The answer depends on whether the object is a consumer
or a producer.

Consider the following type hierarchy:

<img src="/assets/img/language/type-hierarchy.png" alt="a hierarchy of animals where the supertype is Animal and the subtypes are Alligator, Cat, and HoneyBadger. Cat has the subtypes of Lion and MaineCoon">

Consider the following simple assignment where `Cat c` is a _consumer_
and `Cat()` is a _producer_:

<?code-excerpt "lib/strong_analysis.dart (Cat-Cat-ok)"?>
```dart
Cat c = Cat();
```

In a consuming position, it's safe to replace something that consumes a
specific type (`Cat`) with something that consumes anything (`Animal`),
so replacing `Cat c` with `Animal c` is allowed, because `Animal` is
a supertype of `Cat`.

{:.passes-sa}
<?code-excerpt "lib/strong_analysis.dart (Animal-Cat-ok)"?>
```dart
Animal c = Cat();
```

But replacing `Cat c` with `MaineCoon c` breaks type safety, because the
superclass may provide a type of Cat with different behaviors, such
as `Lion`:

{:.fails-sa}
<?code-excerpt "lib/strong_analysis.dart (MaineCoon-Cat-err)"?>
```dart
MaineCoon c = Cat();
```

In a producing position, it's safe to replace something that produces a
type (`Cat`) with a more specific type (`MaineCoon`). So, the following
is allowed:

{:.passes-sa}
<?code-excerpt "lib/strong_analysis.dart (Cat-MaineCoon-ok)"?>
```dart
Cat c = MaineCoon();
```

### Generic type assignment

Are the rules the same for generic types? Yes. Consider the hierarchy
of lists of animals—a `List` of `Cat` is a subtype of a `List` of
`Animal`, and a supertype of a `List` of `MaineCoon`:

<img src="/assets/img/language/type-hierarchy-generics.png" alt="List<Animal> -> List<Cat> -> List<MaineCoon>">

In the following example, 
you can assign a `MaineCoon` list to `myCats`
because `List<MaineCoon>` is a subtype of `List<Cat>`:

{:.passes-sa}
<?code-excerpt "lib/strong_analysis.dart (generic-type-assignment-MaineCoon)" replace="/<MaineCoon/<[!MaineCoon!]/g"?>
```dart
List<[!MaineCoon!]> myMaineCoons = ...
List<Cat> myCats = myMaineCoons;
```

What about going in the other direction? 
Can you assign an `Animal` list to a `List<Cat>`?

{:.fails-sa}
<?code-excerpt "lib/strong_analysis.dart (generic-type-assignment-Animal)" replace="/<Animal/<[!Animal!]/g"?>
```dart
List<[!Animal!]> myAnimals = ...
List<Cat> myCats = myAnimals;
```

This assignment doesn't pass static analysis 
because it creates an implicit downcast, 
which is disallowed from non-`dynamic` types such as `Animal`.

To make this type of code pass static analysis, 
you can use an explicit cast. 

<?code-excerpt "lib/strong_analysis.dart (generic-type-assignment-implied-cast)" replace="/as.*(?=;)/[!$&!]/g"?>
```dart
List<Animal> myAnimals = ...
List<Cat> myCats = myAnimals [!as List<Cat>!];
```

An explicit cast might still fail at runtime, though,
depending on the actual type of the list being cast (`myAnimals`).

### Methods

When overriding a method, the producer and consumer rules still apply.
For example:

<img src="/assets/img/language/consumer-producer-methods.png" alt="Animal class showing the chase method as the consumer and the parent getter as the producer">

For a consumer (such as the `chase(Animal)` method), you can replace
the parameter type with a supertype. For a producer (such as
the `parent` getter method), you can replace the return type with
a subtype.

For more information, see
[Use sound return types when overriding methods](#use-proper-return-types)
and [Use sound parameter types when overriding methods](#use-proper-param-types).


## Other resources

The following resources have further information on sound Dart:

* [Fixing common type problems](/guides/language/sound-problems) - 
  Errors you may encounter when writing sound Dart code, and how to fix them.
* [Fixing type promotion failures](/tools/non-promotion-reasons) - 
  Understand and learn how to fix type promotion errors.
* [Sound null safety](/null-safety) - 
  Learn about writing code with sound null safety.
* [Customizing static analysis][analysis] - 
  How to set up and customize the analyzer and linter
  using an analysis options file.


[analysis]: /tools/analysis
[language version]: /guides/language/evolution#language-versioning
[null safety]: /null-safety


---
title: Typedefs
description: Learn about type aliases in Dart.
toc: false
prevpage:
  url: /language/generics
  title: Generics
nextpage:
  url: /language/type-system
  title: Type system
---

<?code-excerpt replace="/ *\/\/\s+ignore_for_file:[^\n]+\n//g; /(^|\n) *\/\/\s+ignore:[^\n]+\n/$1/g; /(\n[^\n]+) *\/\/\s+ignore:[^\n]+\n/$1\n/g; / *\/\/\s+ignore:[^\n]+//g; /([A-Z]\w*)\d\b/$1/g"?>

A type alias—often called a _typedef_ because
it's declared with the keyword `typedef`—is
a concise way to refer to a type.
Here's an example of declaring and using a type alias named `IntList`:

<?code-excerpt "misc/lib/language_tour/typedefs/misc.dart (int-list)"?>
```dart
typedef IntList = List<int>;
IntList il = [1, 2, 3];
```

A type alias can have type parameters:

<?code-excerpt "misc/lib/language_tour/typedefs/misc.dart (list-mapper)"?>
```dart
typedef ListMapper<X> = Map<X, List<X>>;
Map<String, List<String>> m1 = {}; // Verbose.
ListMapper<String> m2 = {}; // Same thing but shorter and clearer.
```

{{site.alert.version-note}}
  Before 2.13, typedefs were restricted to function types.
  Using the new typedefs requires a [language version][] of at least 2.13.
{{site.alert.end}}

We recommend using [inline function types][] instead of typedefs for functions,
in most situations.
However, function typedefs can still be useful:

<?code-excerpt "misc/lib/language_tour/typedefs/misc.dart (compare)"?>
```dart
typedef Compare<T> = int Function(T a, T b);

int sort(int a, int b) => a - b;

void main() {
  assert(sort is Compare<int>); // True!
}
```

[language version]: /guides/language/evolution#language-versioning
[inline function types]: /effective-dart/design#prefer-inline-function-types-over-typedefs


---
title: Variables
description: Learn about variables in Dart.
prevpage:
  url: /language
  title: Basics
nextpage:
  url: /language/operators
  title: Operators
---

<?code-excerpt replace="/ *\/\/\s+ignore_for_file:[^\n]+\n//g; /(^|\n) *\/\/\s+ignore:[^\n]+\n/$1/g; /(\n[^\n]+) *\/\/\s+ignore:[^\n]+\n/$1\n/g; / *\/\/\s+ignore:[^\n]+//g; /([A-Z]\w*)\d\b/$1/g"?>

Here's an example of creating a variable and initializing it:

<?code-excerpt "misc/lib/language_tour/variables.dart (var-decl)"?>
```dart
var name = 'Bob';
```

Variables store references. The variable called `name` contains a
reference to a `String` object with a value of "Bob".

The type of the `name` variable is inferred to be `String`,
but you can change that type by specifying it.
If an object isn't restricted to a single type,
specify the `Object` type (or `dynamic` if necessary).

<?code-excerpt "misc/lib/language_tour/variables.dart (type-decl)"?>
```dart
Object name = 'Bob';
```

Another option is to explicitly declare the type that would be inferred:

<?code-excerpt "misc/lib/language_tour/variables.dart (static-types)"?>
```dart
String name = 'Bob';
```

{{site.alert.note}}
  This page follows the
  [style guide recommendation](/effective-dart/design#types)
  of using `var`, rather than type annotations, for local variables.
{{site.alert.end}}

## Null safety

The Dart language enforces sound null safety.

Null safety prevents an error that results from unintentional access
of variables set to `null`. The error is called a null dereference error.
A null dereference error occurs when you access a property or call a method
on an expression that evaluates to `null`.
An exception to this rule is when `null` supports the property or method,
like `toString()` or `hashCode`. With null safety, the Dart compiler
detects these potential errors at compile time.

For example, say you want to find the absolute value of an `int` variable `i`.
If `i` is `null`, calling `i.abs()` causes a null dereference error.
In other languages, trying this could lead to a runtime error,
but Dart's compiler prohibits these actions.
Therefore, Dart apps can't cause runtime errors.

Null safety introduces three key changes:

1.  When you specify a type for a variable, parameter, or another
    relevant component, you can control whether the type allows `null`.
    To enable nullability, you add a `?` to the end of the type declaration.

    ```dart
    String? name  // Nullable type. Can be `null` or string.

    String name   // Non-nullable type. Cannot be `null` but can be string.
    ```

2.  You must initialize variables before using them.
    Nullable variables default to `null`, so they are initialized by default.
    Dart doesn't set initial values to non-nullable types.
    It forces you to set an initial value.
    Dart doesn't allow you to observe an uninitialized variable.
    This prevents you from accessing properties or calling methods
    where the receiver's type can be `null`
    but `null` doesn't support the method or property used.

3.  You can't access properties or call methods on an expression with a
    nullable type. The same exception applies where it's a property or method that `null` supports like `hashCode` or `toString()`.

Sound null safety changes potential **runtime errors**
into **edit-time** analysis errors.
Null safety flags a non-null variable when it has been either:

* Not initialized with a non-null value.
* Assigned a `null` value.

This check allows you to fix these errors _before_ deploying your app.

## Default value

Uninitialized variables that have a nullable type
have an initial value of `null`.
Even variables with numeric types are initially null,
because numbers—like everything else in Dart—are objects.

<?code-excerpt "misc/test/language_tour/variables_test.dart (var-null-init)"?>
```dart
int? lineCount;
assert(lineCount == null);
```

{{site.alert.note}}
  Production code ignores the `assert()` call. During development, on the other
  hand, <code>assert(<em>condition</em>)</code> throws an exception if
  _condition_ is false. For details, check out [Assert][].
{{site.alert.end}}

With null safety, you must initialize the values
of non-nullable variables before you use them:

<?code-excerpt "misc/lib/language_tour/variables.dart (var-ns-init)"?>
```dart
int lineCount = 0;
```

You don't have to initialize a local variable where it's declared,
but you do need to assign it a value before it's used.
For example, the following code is valid because
Dart can detect that `lineCount` is non-null by the time
it's passed to `print()`:

<?code-excerpt "misc/lib/language_tour/variables.dart (var-ns-flow)"?>
```dart
int lineCount;

if (weLikeToCount) {
  lineCount = countLines();
} else {
  lineCount = 0;
}

print(lineCount);
```

Top-level and class variables are lazily initialized;
the initialization code runs
the first time the variable is used.


## Late variables

The `late` modifier has two use cases:

* Declaring a non-nullable variable that's initialized after its declaration.
* Lazily initializing a variable.

Often Dart's control flow analysis can detect when a non-nullable variable
is set to a non-null value before it's used,
but sometimes analysis fails.
Two common cases are top-level variables and instance variables:
Dart often can't determine whether they're set,
so it doesn't try.

If you're sure that a variable is set before it's used,
but Dart disagrees,
you can fix the error by marking the variable as `late`:

<?code-excerpt "misc/lib/language_tour/variables.dart (var-late-top-level)" replace="/late/[!$&!]/g"?>
```dart
[!late!] String description;

void main() {
  description = 'Feijoada!';
  print(description);
}
```

{{site.alert.warn}}
  If you fail to initialize a `late` variable,
  a runtime error occurs when the variable is used.
{{site.alert.end}}

When you mark a variable as `late` but initialize it at its declaration,
then the initializer runs the first time the variable is used.
This lazy initialization is handy in a couple of cases:

* The variable might not be needed,
  and initializing it is costly.
* You're initializing an instance variable,
  and its initializer needs access to `this`.

In the following example,
if the `temperature` variable is never used,
then the expensive `readThermometer()` function is never called:

<?code-excerpt "misc/lib/language_tour/variables.dart (var-late-lazy)" replace="/late/[!$&!]/g"?>
```dart
// This is the program's only call to readThermometer().
[!late!] String temperature = readThermometer(); // Lazily initialized.
```


## Final and const

If you never intend to change a variable, use `final` or `const`, either
instead of `var` or in addition to a type. A final variable can be set
only once; a const variable is a compile-time constant. (Const variables
are implicitly final.)

{{site.alert.note}}
  [Instance variables][] can be `final` but not `const`.
{{site.alert.end}}

Here's an example of creating and setting a `final` variable:

<?code-excerpt "misc/lib/language_tour/variables.dart (final)"?>
```dart
final name = 'Bob'; // Without a type annotation
final String nickname = 'Bobby';
```

You can't change the value of a `final` variable:

{:.fails-sa}
<?code-excerpt "misc/lib/language_tour/variables.dart (cant-assign-to-final)"?>
```dart
name = 'Alice'; // Error: a final variable can only be set once.
```

Use `const` for variables that you want to be **compile-time constants**. If
the const variable is at the class level, mark it `static const`.
Where you declare the variable, set the value to a compile-time constant
such as a number or string literal, a const
variable, or the result of an arithmetic operation on constant numbers:

<?code-excerpt "misc/lib/language_tour/variables.dart (const)"?>
```dart
const bar = 1000000; // Unit of pressure (dynes/cm2)
const double atm = 1.01325 * bar; // Standard atmosphere
```

The `const` keyword isn't just for declaring constant variables.
You can also use it to create constant _values_,
as well as to declare constructors that _create_ constant values.
Any variable can have a constant value.

<?code-excerpt "misc/lib/language_tour/variables.dart (const-vs-final)"?>
```dart
var foo = const [];
final bar = const [];
const baz = []; // Equivalent to `const []`
```

You can omit `const` from the initializing expression of a `const` declaration,
like for `baz` above. For details, see [DON'T use const redundantly][].

You can change the value of a non-final, non-const variable,
even if it used to have a `const` value:

<?code-excerpt "misc/lib/language_tour/variables.dart (reassign-to-non-final)"?>
```dart
foo = [1, 2, 3]; // Was const []
```

You can't change the value of a `const` variable:

{:.fails-sa}
<?code-excerpt "misc/lib/language_tour/variables.dart (cant-assign-to-const)"?>
```dart
baz = [42]; // Error: Constant variables can't be assigned a value.
```

You can define constants that use
[type checks and casts][] (`is` and `as`),
[collection `if`][],
and [spread operators][] (`...` and `...?`):

<?code-excerpt "misc/lib/language_tour/variables.dart (const-dart-25)"?>
```dart
const Object i = 3; // Where i is a const Object with an int value...
const list = [i as int]; // Use a typecast.
const map = {if (i is int) i: 'int'}; // Use is and collection if.
const set = {if (list is List<int>) ...list}; // ...and a spread.
```

{{site.alert.note}}
  Although a `final` object cannot be modified,
  its fields can be changed. 
  In comparison, a `const` object and its fields
  cannot be changed: they're _immutable_.
{{site.alert.end}}

For more information on using `const` to create constant values, see
[Lists][], [Maps][], and [Classes][].


[Assert]: /language/error-handling#assert
[Instance variables]: /language/classes#instance-variables
[DON'T use const redundantly]: /effective-dart/usage#dont-use-const-redundantly
[type checks and casts]: /language/operators#type-test-operators
[collection `if`]: /language/collections#control-flow-operators
[spread operators]: /language/collections#spread-operators
[Lists]: /language/collections#lists
[Maps]: /language/collections#maps
[Classes]: /language/classes


