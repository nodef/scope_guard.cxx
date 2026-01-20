[![Github Releases](https://img.shields.io/github/release/Neargye/scope_guard.svg)](https://github.com/Neargye/scope_guard/releases)
[![License](https://img.shields.io/github/license/Neargye/scope_guard.svg)](LICENSE)

# Scope Guard & Defer C++

Scope Guard statement invokes a function with deferred execution until surrounding function returns in cases:

* scope_exit - executing action on scope exit.

* scope_fail - executing action on scope exit when an exception has been thrown.

* scope_success - executing action on scope exit when no exceptions have been thrown.

Program control transferring does not influence Scope Guard statement execution. Hence, Scope Guard statement can be used to perform manual resource management, such as file descriptors closing, and to perform actions even if an error occurs.

## Features

* C++11
* Header-only
* Dependency-free
* Thin callback wrapping, no added std::function or virtual table penalties
* No implicitly ignored return, check callback return void
* Defer or Scope Guard syntax and "With" syntax

## [Examples](https://github.com/Neargye/scope_guard/blob/master/example)

* [Scope Guard on exit](https://github.com/Neargye/scope_guard/blob/master/example/scope_exit_example.cpp)

  ```cpp
  std::fstream file("test.txt");
  SCOPE_EXIT{ file.close(); }; // File closes when exit the enclosing scope or errors occur.
  ```

* [Scope Guard on fail](https://github.com/Neargye/scope_guard/blob/master/example/scope_fail_example.cpp)

  ```cpp
  persons.push_back(person); // Add the person to db.
  SCOPE_FAIL{ persons.pop_back(); }; // If errors occur, we should roll back.
  ```

* [Scope Guard on success](https://github.com/Neargye/scope_guard/blob/master/example/scope_success_example.cpp)

  ```cpp
  person = new Person{/*...*/};
  // ...
  SCOPE_SUCCESS{ persons.push_back(person); }; // If no errors occur, we should add the person to db.
  ```

* Custom Scope Guard

  ```cpp
  persons.push_back(person); // Add the person to db.

  MAKE_SCOPE_EXIT(scope_exit) { // Following block is executed when exit the enclosing scope or errors occur.
    persons.pop_back(); // If the db insertion fails, we should roll back.
  };
  // MAKE_SCOPE_EXIT(name) {action} - macro is used to create a new scope_exit object.
  scope_exit.dismiss(); // An exception was not thrown, so don't execute the scope_exit.
  ```

  ```cpp
  persons.push_back(person); // Add the person to db.

  auto scope_exit = make_scope_exit([]() { persons.pop_back(); });
  // make_scope_exit(A&& action) - function is used to create a new scope_exit object. It can be instantiated with a lambda function, a std::function<void()>, a functor, or a void(*)() function pointer.
  // ...
  scope_exit.dismiss(); // An exception was not thrown, so don't execute the scope_exit.
  ```

* With Scope Guard

  ```cpp
  std::fstream file("test.txt");
  WITH_SCOPE_EXIT({ file.close(); }) { // File closes when exit the enclosing with scope or errors occur.
    // ...
  };
  ```

## Installation

Run:

```bash
$ npm i scope_guard.cxx
```

And then include `scope_guard.hpp` as follows:

```cxx
// main.cxx
#include <scope_guard.hpp>

int main() { /* ... */ }
```

Finally, compile while adding the path `node_modules/scope_guard.cxx` to your compiler's include paths.

```bash
$ clang++ -I./node_modules/scope_guard.cxx main.cxx  # or, use g++
$ g++     -I./node_modules/scope_guard.cxx main.cxx
```

You may also use a simpler approach with the [cpoach](https://www.npmjs.com/package/cpoach.sh) tool, which automatically adds the necessary include paths of all the installed dependencies for your project.

```bash
$ cpoach clang++ main.cxx  # or, use g++
$ cpoach g++     main.cxx
```

## Synopsis

### Reference

#### scope_exit

* `scope_exit<F> make_scope_exit(F&& action);` - return scope_exit with the action.
* `SCOPE_EXIT{action};` - macro for creating scope_exit with the action.
* `MAKE_SCOPE_EXIT(name) {action};` - macro for creating named scope_exit with the action.
* `WITH_SCOPE_EXIT({action}) {/*...*/};` - macro for creating scope with scope_exit with the action.

#### scope_fail

* `scope_fail<F> make_scope_fail(F&& action);` - return scope_fail with the action.
* `SCOPE_FAIL{action};` - macro for creating scope_fail with the action.
* `MAKE_SCOPE_FAIL(name) {action};` - macro for creating named scope_fail with the action.
* `WITH_SCOPE_FAIL({action}) {/*...*/};` - macro for creating scope with scope_fail with the action.

#### scope_success

* `scope_success<F> make_scope_success(F&& action);` - return scope_success with the action.
* `SCOPE_SUCCESS{action};` - macro for creating scope_success with the action.
* `MAKE_SCOPE_SUCCESS(name) {action};` - macro for creating named scope_success with the action.
* `WITH_SCOPE_SUCCESS({action}) {/*...*/};` - macro for creating scope with scope_success with the action.

#### defer

* `DEFER{action};` - macro for creating defer with the action.
* `MAKE_DEFER(name) {action};` - macro for creating named defer with the action.
* `WITH_DEFER({action}) {/*...*/};` - macro for creating scope with defer with the action.

### Interface of scope_guard

scope_exit, scope_fail, scope_success implement scope_guard interface.

* `dismiss()` - dismiss executing action on scope exit.

#### Throwable settings

* `SCOPE_GUARD_NOTHROW_CONSTRUCTIBLE` define this to require nothrow constructible action.

* `SCOPE_GUARD_MAY_THROW_ACTION` define this to action may throw exceptions.

* `SCOPE_GUARD_NO_THROW_ACTION` define this to require noexcept action.

* `SCOPE_GUARD_SUPPRESS_THROW_ACTIONS` define this to exceptions during action will be suppressed.

* By default using `SCOPE_GUARD_MAY_THROW_ACTION`.

* `SCOPE_GUARD_CATCH_HANDLER` define this to add exceptions handler. If `SCOPE_GUARD_SUPPRESS_THROW_ACTIONS` is not defined, it will do nothing.

### Remarks

* If multiple Scope Guard statements appear in the same scope, the order they appear is the reverse of the order they are executed.

  ```cpp
  void f() {
    SCOPE_EXIT{ std::cout << "First" << std::endl; };
    SCOPE_EXIT{ std::cout << "Second" << std::endl; };
    SCOPE_EXIT{ std::cout << "Third" << std::endl; };
    ... // Other code.
    // Prints "Third".
    // Prints "Second".
    // Prints "First".
  }
  ```

## Integration

You should add required file [scope_guard.hpp](scope_guard.hpp).

## References

* [Andrei Alexandrescu "Systematic Error Handling in C++"](https://channel9.msdn.com/Shows/Going+Deep/C-and-Beyond-2012-Andrei-Alexandrescu-Systematic-Error-Handling-in-C)
* [Andrei Alexandrescu “Declarative Control Flow"](https://youtu.be/WjTrfoiB0MQ)

## Licensed under the [MIT License](LICENSE)

<br>
<br>


[![](https://raw.githubusercontent.com/qb40/designs/gh-pages/0/image/11.png)](https://wolfram77.github.io)<br>
[![SRC](https://img.shields.io/badge/src-repo-green?logo=Org)](https://github.com/Neargye/scope_guard)
[![ORG](https://img.shields.io/badge/org-nodef-green?logo=Org)](https://nodef.github.io)
![](https://ga-beacon.deno.dev/G-RC63DPBH3P:SH3Eq-NoQ9mwgYeHWxu7cw/github.com/nodef/scope_guard.cxx)
