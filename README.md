
[![Build Status](https://travis-ci.org/viktor-shepel/frunzik.svg?branch=master)](https://travis-ci.org/viktor-shepel/frunzik)

## Overview
Frunzik is a library that provides functional programming primitives for C language under C99 standard.

## Installation

clone this repository to your project
```bash
$ git clone https://github.com/viktor-shepel/frunzik.git
```
build shared library `libfrunzik.so`
```bash
$ cd frunzik
$ make
```
link your code with `libfrunzik.so`.

<sub>In order to play with code samples put provided skeleton into `my-awesome-app.c` file and compile it as shown below.</sub>
```bash
$ gcc -I <path to>/frunzik/src -L <path to>/frunzik my-awesome-app.c -l frunzik -o my-awesome-app
```
```c
/* skeleton for `my-awesome-app.c` file */
#include "frunzik.h"

int main() {
  double input[] = { 1.0, 2.3, 8.08, -3.14 };
  list_t* grades = list_of(double, input, input + 4);

  return 0;
}
```
inform OS linker where `libfrunzik.so` resides
```bash
$ LD_LIBRARY_PATH=$LD_LIBRARY_PATH:<path to>/libfrunzic.so
$ export LD_LIBRARY_PATH
```
run your executable
```bash
$ ./my-awesome-app
```

## Documentation

### list_t
```c
struct list_t {
  void* head;
  list_t* tail;
};
```
Is a data structure that represents node within singly linked list.
Last element of a list has `tail` field assigned to `NULL`.

```c
// library treats this as empty list
list_t* empty_list = NULL;

// one element list
list_t* single_element_list = &(list_t) { 1, NULL };
```

### cons
```c
list_t* cons(void* head, list_t* tail)
```
Is a list constructor function.
It takes reference to object being inserted `head` and reference to existing list `tail` and produces new list.
This new list has `head` as its first element.
Use `cons` as prepend operation and `list_of`/`list` for inplace list construction.

```c
list_t* list = cons(1, cons(2, cons(3, NULL)));

/*
 * code above has next memory layout
 *
 *
 *                      1              2              3
 *                      ^              ^              ^
 *                      |              |              |
 *                      |              |              |
 *               +------|-+     +------|-+     +------|-+
 *               | head + |     | head + |     | head + |
 *               |        |     |        |     |        |
 * list  +------>+ tail +------>+ tail +------>+ tail +------> NULL
 *               +--------+     +--------+     +--------+
 */
```

### head
```c
void* head(list_t* list)
```

Is a list query function.
It returns first element inside `list` argument.
```c
list_t* list = list(1, 2, 3);
head(list) == 1;
```

### tail
```c
list_t* tail(list_t* list)
```

Is a list query function.
It returns list of all elements inside `list` argument except first.
```c
list_t* rest = list(2, 3);
list_t* list = cons(1, rest);
tail(list) == rest;
```

### is_empty
```c
bool is_empty(list_t* list)
```
Is a list query function.
It checks whether `list` arguments is empty list or not.
Function return `true` for empty list and `false` otherwise.

```c
is_empty(list()) == true;

is_empty(list(1, 2, 3)) == false;
```

### concat
```c
list_t* concat(list_t* left, list_t* right)
```
Is a list construction function.
It takes lists to be joined `left`/`right` and produces new list with `left` elements follow by ones from the `right`.
```c
list_t* a = list(1, 2, 3);
list_t* b = list(4, 5, 6);
concat(a, b); // --> list(1, 2, 3, 4, 5, 6)
```

### nth
```c
void* nth(size_t index, list_t* list)
```
Is a list query function.
It returns nth elemnet pointed by `index` from the `list`.
Behaviour is undefined once `index` value exceeds length of the `list`.
```c
list_t* list = list('a', 'b', 'c');

nth(0, list) == 'a';
nth(1, list) == 'b';
nth(2, list) == 'c';

// undefined behaviour, most likely ends up with segmentation fault
nth(3, list)
```

### length
```c
size_t length(list_t* list)
```
Is a list query function.
It returns length of the `list`.
```c
length(list()) == 0;

length(list(1, 2, 3)) == 3;
```

### list_of
```c
#define list_of(type, first, last)
```
Is a list construction macros.
It is used when you need construct list from array.
It takes `type` of array and adresses of `first` and `last` elements and produces new list that holds references to array elements between `first`/`last` items.
Be aware that lifetime managment is your responsibility once you reference objects with automatic storge duration.
```c
int x[] = { 1, 2, 3 };

list_t* list = list_of(int, x, x + 3);

// Ok. lifetimes of `x` and `list` match
nth(0, list) == &x[0];
nth(1, list) == &x[1];
nth(2, list) == &x[2];


// VS

list_t* foo() {
  int x[] = { 1, 2, 3 };
  
  // Is a big No No No.
  // here we reference `x` array that will be disposed after function call
  // returned list will hold references to deleted objects
  return list_of(int, x, x + 3); 
}

list_t* list = foo();

// Fail. `list` outlives `x`
nth(0, list) == &x[0];
nth(1, list) == &x[1];
nth(2, list) == &x[2];
```

### list
```c
#define list(...)
```
Is a list construction macros.
It is used when you need construct list from arbitrary number of references.
```c
list_t* list = list(1, 2, 3); // --> cons(1, cons(2, cons(3, NULL)))
```

### thunk_t
```c
typedef void* (*thunk_t)(list_t*)
```
Is a variadic function type.
It is used as a body of the first class function.
```c
int* number(int value) {
  int* number = gc_malloc(sizeof *number);
  
  return number ? (*number = value, number) : NULL;
}

void* sum_ints(list_t* arguments) {
  if (is_empty(arguments)) {
    return number(0);
  }
  
  int value = *(int*) head(arguments);
  
  return number(value + *(int*) sum_ints(tail(arguments)));
}

thunk_t sum = sum_ints;


*(int*) sum(list(number(1), number(10), number(100))) == 111;
```

### function_t
```c
struct function_t {
  thunk_t thunk;
  list_t* arguments;
};
```
Is a data structure that represents first class function.
It maintains executable code and its input data inside `thunk`/`arguments` fields.
Input data could be provided during application/bind phase see `apply`/`call`/`bind_args`.
```c
int* number(int value) {
  int* number = gc_malloc(sizeof *number);
  
  return number ? (*number = value, number) : NULL;
}

void* add_two_ints(list_t* arguments) {
  int x = *(int*) nth(0, arguments);
  int y = *(int*) nth(1, arguments);
  
  return number(x + y);
}

function_t* add = &(function_t) { add_two_ints, list() };
function_t* increment = &(function_t) { add_two_ints, list(number(1)) };

*(int*) call(add, number(1), number(100)) == 101;
*(int*) call(increment, number(100))      == 101;
```

### DEFINE_PUBLIC_FUNCTION / DEFINE_PRIVATE_FUNCTION
```c
#define DEFINE_PUBLIC_FUNCTION(name, body)
#define DEFINE_PRIVATE_FUNCTION(name, body)
```
Is a function construction macroses.
It wraps plain function into first class function.
`DEFINE_PUBLIC_FUNCTION` macros makes wrapper visible across different translation units while `DEFINE_PRIVATE_FUNCTION` restrict it to current one.
```c
void* add_two_ints(list_t* arguments) {
  int x = *(int*) nth(0, arguments);
  int y = *(int*) nth(1, arguments);
  
  return number(x + y);
}

funtion_t* public_add = &(funtion_t) { add_two_ints, NULL };
static funtion_t* private_add = &(funtion_t) { add_two_ints, NULL };

// VS

int add_two_ints(int x, int y) {
  return x + y;
}

DEFINE_PUBLIC_FUNCTION(
  public_add,
  RETURN_VALUE(add_two_ints, int, BIND_VALUE_ARG(int, 0), BIND_VALUE_ARG(int, 1))
)

DEFINE_PRIVATE_FUNCTION(
  private_add,
  RETURN_VALUE(add_two_ints, int, BIND_VALUE_ARG(int, 0), BIND_VALUE_ARG(int, 1))
)

```

### apply
```c
void* apply(function_t* fn, list_t* arguments)
```
Is a function application operation.
It applies function to list of supplied `arguments`
```c
int add_two_ints(int x, int y) {
  return x + y;
}

DEFINE_PRIVATE_FUNCTION(
  add,
  RETURN_VALUE(add_two_ints, int, BIND_VALUE_ARG(int, 0), BIND_VALUE_ARG(int, 1))
)

int* number(int value) {
  int* number = gc_malloc(sizeof *number);
  
  return number ? (*number = value, number) : NULL;
}

*(int*) apply(add, list(number(1), number(100))) == 101;
```

### call
```c
#define call(fn, ...)
```
Is a function application operation.
It applies function to comma separated arguments.
```c
int add_two_ints(int x, int y) {
  return x + y;
}

DEFINE_PRIVATE_FUNCTION(
  add,
  RETURN_VALUE(add_two_ints, int, BIND_VALUE_ARG(int, 0), BIND_VALUE_ARG(int, 1))
)

int* number(int value) {
  int* number = gc_malloc(sizeof *number);
  
  return number ? (*number = value, number) : NULL;
}

*(int*) call(add, number(1), number(100)) == 101;
```

### bind_args
```c
#define bind_args(fn, ...)
```
Is a bind operation on function arguments.
It binds supplied arguments to ones in function starting from left.
```c
#include <math.h>

DEFINE_PRIVATE_FUNCTION(
  power,
  RETURN_VALUE(pow, double, BIND_VALUE_ARG(double, 0), BIND_VALUE_ARG(double, 1))
)

double* number(double value) {
  double* number = gc_malloc(sizeof *number);
  
  return number ? (*number = value, number) : NULL;
}

function_t* binary_power = bind_args(power, number(2));

*(double*) call(binary_power, number(3)) == 8; // i.e. 2 ^ 3 == 8
```

### map / map_fn
```c
list_t* map(function_t* fn, list_t* list)
extern function_t* map_fn
```
Is a higher-order function in both plain/first class forms `map`/`map_fn`.
It applies a given function `fn` to each element of a `list` and return a list of results in the same order.
```c
int square_int_number(int x) {
  return x * x;
}

DEFINE_PRIVATE_FUNCTION(
  square_number,
  RETURN_VALUE(square_int_number, int, BIND_VALUE_ARG(int, 0))
)

int input[] = { 1, 2, 3 };
list_t* numbers = list_of(int, input, input + 3);
function_t* compute_squares = bind_args(map_fn, square_number);

map(square_number, numbers);          // --> list(1, 4, 9)
call(map_fn, square_number, numbers); // --> list(1, 4, 9)
call(compute_squares, numbers);       // --> list(1, 4, 9)
```

### filter / filter_fn
```c
list_t* filter(function_t* predicate, list_t* list)
extern function_t* filter_fn
```
Is a higher-order function in both plain/first class forms `filter`/`filter_fn`.
It applies `predicate` function to each element of a `list` and return a list of elements for which given predicate return `true`. Order of elements is preserved.
```c
bool is_even_int(int x) {
  return x % 2 == 0;
}

DEFINE_PRIVATE_FUNCTION(
  is_even,
  RETURN_VALUE(is_even_int, bool, BIND_VALUE_ARG(int, 0))
)

int input[] = { 1, 2, 3, 4, 5, 6 };
list_t* numbers = list_of(int, input, input + 6);
function_t* select_even = bind_args(filter_fn, is_even);

filter(is_even, numbers);           // --> list(2, 4, 6)
call(filter_fn, is_even, numbers);  // --> list(2, 4, 9)
call(select_even, numbers);         // --> list(2, 4, 9)
```

### fold / fold_fn
```c
void* fold(function_t* reducer, void* seed, list_t* list)
extern function_t* fold_fn
```
Is a higher-order function in both plain/first class forms `fold`/`fold_fn`.
It reduces elements of a `list` to a single value by recursive application of `reducer`.
Reducer has to have next signature.
```c
<return_type> reducer(<return_type> accumulator, <list_element_type> value) {
  return ...
}

// example: reduce list of ints to some boolean value
bool reducer(bool accumulator, int value) {
  return bool && (value < 10);
}

// example: reduce list of strings to list of persons
list_t* reducer(list_t* accumulator, char* name) {
  persont_t* person = person(name, "second name is unkown");
  
  return cons(person, accumulator);
}
```
First time the `reducer` is called `accumulator` argument points to `seed` value. All subsequent application of `reducer` has `accumulator` value equal to one returned from previous step. Reducer applied to list elements from left to right.
```c
int* number(int value) {
  int* number = gc_malloc(sizeof *number);
  
  return number ? (*number = value, number) : NULL;
}

int add_two_ints(int x, int y) {
  return x + y;
}

DEFINE_PRIVATE_FUNCTION(
  add,
  RETURN_VALUE(add_two_ints, int, BIND_VALUE_ARG(int, 0), BIND_VALUE_ARG(int, 1))
)

int input[] = { 1, 2, 3, 4, 5, 6 };
list_t* numbers = list_of(int, input, input + 6);
function_t* sum = bind_args(fold_fn, add, number(0));

*(int*) fold(add, number(0), numbers)          == 21;
*(int*) call(fold_fn, add, number(0), numbers) == 21;
*(int*) call(sum, numbers)                     == 21;
```

### range
```c
#define range(...)
```
Is a arithmetic progressions list constructor macros.
It takes `start`/`stop` and optionally `step` parameters and return list of monotonically increasing `int` numbers.
Result is left closed interval i.e. `[start, stop)`.
```c
range(-2, 3);    // --> list(-2, -1, 0, 1, 2)
range(0, 10, 2); // --> list( 0,  2, 4, 6, 8)
```

### compose
```c
#define compose(...)
```
Is a function composition macros `compose(fn`<sub>0</sub>`, fn`<sub>1</sub>`, ..., fn`<sub>n-1</sub>`, fn`<sub>n</sub>`)`.
It construct function that when applied pass return value of `fn`<sub>n</sub> as input for `fn`<sub>n-1</sub> and so on through functions chain.
```c
int* number(int value) {
  int* number = gc_malloc(sizeof *number);
  
  return number ? (*number = value, number) : NULL;
}

int multiple_of_ten_int(int x) {
  return 10 * x;
}

DEFINE_PRIVATE_FUNCTION(
  multiple_of_ten,
  RETURN_VALUE(multiple_of_ten_int, int, BIND_VALUE_ARG(int, 0))
)

int increment_int(int x) {
  return x + 1;
}

DEFINE_PRIVATE_FUNCTION(
  increment,
  RETURN_VALUE(increment_int, int, BIND_VALUE_ARG(int, 0))
)

function_t* computation = compose(
  multiple_of_ten,
  increment
);

*(int*) call(computation, number(3)) == 40; // --> multiple_of_ten(increment(3)) == 10 * (3 + 1) == 40
```
Practical sample
```c
int* number(int value) {
  int* number = gc_malloc(sizeof *number);
  
  return number ? (*number = value, number) : NULL;
}

bool is_positive_int(int x) {
  return x > 0;
}

int add_ints(int x, int y) {
  return x + y;
}

DEFINE_PRIVATE_FUNCTION(
  is_positive,
  RETURN_VALUE(is_positive_int, bool, BIND_VALUE_ARG(int, 0))
)

DEFINE_PRIVATE_FUNCTION(
  add,
  RETURN_VALUE(add_ints, int, BIND_VALUE_ARG(int, 0), BIND_VALUE_ARG(int, 1))
)

list_t* money_transfer_by_days = list(
  list(number(0), number(-10), number(3)),
  list(number(0), number(-10), number(3), number(-10), number(3)),
  list(number(0)),
  list(number(0), number(-10)),
);

function_t* sum = bind_args(fold_fn, add, number(0));
function_t* select_income = bind_args(filter_fn, is_positive);

function_t* earned_money = compose(
  sum,
  bind_args(map_fn, compose(sum, select_income)) 
);

*(int*) call(earned_money, money_transfer_by_days) == 9;
```
