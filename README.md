# Polynomial interpreter

Polynomial operations real time interpreter with Automata theory graphs

Declare polynomials, show, derive, find roots, evaluate with an integer, a decimal, a constant or a variable, and do arithmetical operation on these polynomials.

## Usage

### Makefile

| Command          | Description            |
| ---------------- | ---------------------- |
| `make install`   | Install Lex and Yacc   |
| `make uninstall` | Uninstall Lex and Yacc |
| `make all`       | Compile project        |
| `make clean`     | Clean compiled files   |

### Run project
#### Interactive mode

```bash
make
./exec
```
#### File mode

:warning: The last command of the file must end with a ';' or a new line.
```bash
make
./exec < path/to/file
```

## Commands

See also [examples](examples).

### Declaration

Polynomial declaration works as this:
```
LET <poly>(<var>) = <def>
```

| Token   | Description             | Constraints                                                                                              | Optional |
| ------- | ----------------------- | -------------------------------------------------------------------------------------------------------- | -------- |
| <poly\> | Polynomial name         | Starts with a capitalized letter and may contain 14 other upper or lower letters, numbers or '_'         | No       |
| <var\>  | Polynomial's variable   | One lower letter                                                                                         | No       |
| <def\>  | Polynomial's definition | A succession of monomials (see section below)                                                            | No       |

_The program automatically reduces polynomials._

#### Polynomial definition

There are 2 ways to define the polynomial body :
- the classic way
- the list way

##### Classic way

It defines multiple monomials separated by + (plus), - (minus), * (multiply) or parenthesis. The monomials delcarations can be :
| Monomial | Interpreted result | Shown result |
| -------- | ------------------ | ------------ |
| 7        | 7.x^0              | 7            |
| 7x       | 7.x^1              | 7.x          |
| 7.x      | 7.x^1              | 7.x          |
| 7x^2     | 7.x^2              | 7.x^2        |
| 7.x^2    | 7.x^2              | 7.x^2        |
| x^2      | 0.x^2              | x^2          |

:warning: The degree must always be >= 0.\
:warning: The variable used must be the same as the one in the polynomial declaration. For example : P(x) = 2y would give an error.

For example :
```
LET P(x) = (1.x^2 + 3*3)^2 + 2x
```
gives :
```
P(x) = x^4 + 18.x^2 + 81 + 2.x
```

##### List way

It is declare in brackets where monomials are `(factor, degree)` separated by commas :
```
[(factor, degree), (factor, degree), ...]
```
:warning: The degree must always be >= 0.

For example :
```
LET P(x) = [(1,2), (0,3), (-4,1)]
```
gives :
```
P(x) = x^2 - 4.x
```

##### Avanced

It is also possible to combine both ways in polynomial declarations, or to use other polynomials and their derivations:

```
LET P(x) = x + ([(1, 2), (4, 6)]) * 2   =>  P(x) = x + 2.x^2 + 8.x^6
LET P1(x) = P(x) + 4                    =>  P1(x) = x + 2.x^2 + 8.x^6 + 4
LET P2(x) = P(6)                        =>  P2(x) = 373326
LET P3(x) = (P'(x))^2                   =>  P3(x) = 1 + 8.x + 96.x^5 + 16.x^2 + 384.x^6 + 2304.x^10
LET P4(x) = P'(3) * 5                   =>  P4(x) = 58385
```

### Arithmetical operations

Arithmetical operations exaclty as polynomial's definition part. The difference is that the result is saved. It is useful to calculate or symplify an operation.

#### Examples

```
(((1.x^2 + ([(3,0)])*3))^2 + 2x)    =>  x^4 + 18.x^2 + 2.x + 81
```

Using a previously defined P(x) = x^2 - 4.x :
```
P(x) * 2    =>  2.x^2 - 8.x
P(y)        =>  y^2 - 4.y
P(5)        =>  5
```
:warning: Only works with variables or integers.

Derivate P :
```
P'(x)   =>  2.x - 4
P'(y)   =>  2.y - 4
P'(5)   =>  6
```

Derivate P 2 times :
```
P''(x)  =>  2
```

### Show

`SHOW` is a command to display declared polynomials with `LET`.
```
SHOW <poly> <list> <order>
```

| Token    | Description             | Constraints                                                                                              | Optional |
| -------- | ----------------------- | -------------------------------------------------------------------------------------------------------- | -------- |
| <poly\>  | Polynomial name         | Must have been declared with `LET` before                                                                | Yes      |
| <list\>  | Display as list         | Must be `LIST`                                                                                           | Yes      |
| <order\> | Monomials display order | Must be `ASC` (ascending) or `DESC` (descending), sort by degree                                         | Yes      |

#### Example

Declaring :
```
LET P(x) = x^2 - 4x
LET P2(x) = x
```
##### Show all

```
SHOW
```
```
P(x) = x^2 - 4.x
P2(x) = x
```

##### Show a particular polynomial
```
SHOW P          =>  P(x) = x^2 - 4.x
```

##### Show as list
```
SHOW P LIST     =>  P(x) = [(1, 2),(-4, 1)]
```

##### Show ascending order
```
SHOW P ASC      =>  P(x) = -4.x + x^2
```

### Eval

Evaluate declared polynomials with `LET`.
```
EVAL <poly> AT <value>
```

| Token    | Description             | Constraints                                                                                              | Optional |
| -------- | ----------------------- | -------------------------------------------------------------------------------------------------------- | -------- |
| <poly\>  | Polynomial name         | Must have been declared with `LET` before                                                                | No       |
| <value\> | Value for evaluation    | Must be a variable, a symbolic constant, an integer or a float                                           | No       |

:warning: Symbolic constant starts with a lower letter and may contain 14 other upper or lower letters, numbers or '_'. Example : `pi`.

#### Example

Using :
```
LET P(x) = x^2 - 4x
```

Evaluate P :
```
EVAL P AT y         =>  P(y) = y^2 - 4.y
EVAL P AT pi        =>  P(pi) = pi^2 - 4.pi
EVAL P AT 4         =>  P(4) = 0
EVAL P AT 0.5       =>  P(0.5) = -1.75
```

### Derive

Derivate declared polynomials with `LET`.
```
DERIVE <<number> TIMES> <poly> <AT <value>>
```

| Token              | Description             | Constraints                                                                                              | Optional |
| ------------------ | ----------------------- | -------------------------------------------------------------------------------------------------------- | -------- |
| <poly\>            | Polynomial name         | Must have been declared with `LET` before                                                                | No       |
| <<number\> TIMES\> | Number of derivation    | Must be an integer followed by `TIMES`                                                                   | Yes      |
| <AT <value\>\>     | Evaluate derivation     | Must be a variable, a symbolic constant, an integer or a float preceded by `AT` (works as evaluate)      | Yes      |

#### Example

Using :
```
LET P(x) = x^2 - 4x
```

Derivate P :
```
DERIVE P                    =>  P'(x) = 2.x - 4
DERIVE 2 TIMES P            =>  P'(x) = 2
```

Derivate and evaluate P :
```
DERIVE P AT 5               =>  P'(5) = 6
DERIVE 2 TIMES P AT pi      =>  P'(pi) = 2
```

### Find root

Find the root between 2 numbers with a declared polynomials with `LET`.
```
FIND ROOT FOR <poly> BETWEEN <a> AND <b>
```

| Token   | Description            | Constraints                                | Optional |
| ------- | ---------------------- | ------------------------------------------ | -------- |
| <poly\> | Polynomial name        | Must have been declared with `LET` before  | No       |
| <a\>    | First number for root  | Must be an integer                         | No       |
| <b\>    | Second number for root | Must be an integer                         | No       |

:warning: Constraits also includes : a < b and P(a) * P(b) <= 0

#### Example

Using :
```
LET P(x) = x^2 - 4x
```

Find root :
```
FIND ROOT FOR P BETWEEN 0 AND 150   =>  4.000000
```

### Using a file

[examples/eval](examples/eval) :
```
LET P(x) = x + 4x^2 + 5 * x * x

EVAL P AT y
EVAL P AT pi
EVAL P AT 5
EVAL P AT 0.5

```
```bash
./exec < ./examples/eval
```
```
[LET] [Mode interactif]
Polynôme P ajouté

[EVAL] [Mode interactif]
P(y) = 9.y^2 + y

[EVAL] [Mode interactif]
P(pi) = 9.pi^2 + pi

[EVAL] [Mode interactif]
P(5) = 230

[EVAL] [Mode interactif]
P(0.5) = 2.75
```
