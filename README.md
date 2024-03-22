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
FIND ROOT FOR <poly> BETWEEN <a> AND <b> <SAVE AS <file>>
```

| Token                 | Description                                   | Constraints                                | Optional |
| --------------------- | --------------------------------------------- | ------------------------------------------ | -------- |
| <poly\>               | Polynomial name                               | Must have been declared with `LET` before  | No       |
| <a\>                  | First number for root                         | Must be an integer                         | No       |
| <b\>                  | Second number for root                        | Must be an integer                         | No       |
| <SAVE AS <file\>\>    | File where will be saved intermediate results | File name of maximum 256 characters        | Yes      |

:warning: Constraits also includes : a < b and P(a) * P(b) <= 0

#### Example

Using :
```
LET P(x) = x^2 - 4x
```

Find root :
```
FIND ROOT FOR P BETWEEN 0 AND 150                               =>  4.000000
```

Find root and save intermediate results :
```
FIND ROOT FOR P BETWEEN 0 AND 150 SAVE AS intermediate_results  =>  4.000000
```
Intermediates results will then be found in the fine named `intermediate_results.md` :
```md
# Recherche d'une racine entre 0.000000 et 150.000000
## Etapes intermédiaires
| Itération | a | b | c = (a + b) / 2 | P\(c\) |
| --------- | - | - | --------------- | ----- |
| 0 | 0.000000 | 150.000000 | 75.000000 | 5325.000000 |
| 1 | 0.000000 | 75.000000 | 37.500000 | 1256.250000 |
| 2 | 0.000000 | 37.500000 | 18.750000 | 276.562500 |
| 3 | 0.000000 | 18.750000 | 9.375000 | 50.390625 |
| 4 | 0.000000 | 9.375000 | 4.687500 | 3.222656 |
| 5 | 0.000000 | 4.687500 | 2.343750 | -3.881836 |
| 6 | 2.343750 | 4.687500 | 3.515625 | -1.702881 |
| 7 | 3.515625 | 4.687500 | 4.101562 | 0.416565 |
| 8 | 3.515625 | 4.101562 | 3.808594 | -0.728989 |
| 9 | 3.808594 | 4.101562 | 3.955078 | -0.177670 |
| 10 | 3.955078 | 4.101562 | 4.028320 | 0.114083 |
| 11 | 3.955078 | 4.028320 | 3.991699 | -0.033134 |
| 12 | 3.991699 | 4.028320 | 4.010010 | 0.040139 |
| 13 | 3.991699 | 4.010010 | 4.000854 | 0.003419 |
| 14 | 3.991699 | 4.000854 | 3.996277 | -0.014879 |
| 15 | 3.996277 | 4.000854 | 3.998566 | -0.005735 |
| 16 | 3.998566 | 4.000854 | 3.999710 | -0.001160 |
| 17 | 3.999710 | 4.000854 | 4.000282 | 0.001129 |
| 18 | 3.999710 | 4.000282 | 3.999996 | -0.000015 |
| 19 | 3.999996 | 4.000282 | 4.000139 | 0.000557 |
| 20 | 3.999996 | 4.000139 | 4.000068 | 0.000271 |
| 21 | 3.999996 | 4.000068 | 4.000032 | 0.000128 |
| 22 | 3.999996 | 4.000032 | 4.000014 | 0.000056 |
| 23 | 3.999996 | 4.000014 | 4.000005 | 0.000021 |
| 24 | 3.999996 | 4.000005 | 4.000001 | 0.000003 |
| 25 | 3.999996 | 4.000001 | 3.999998 | -0.000006 |
| 26 | 3.999998 | 4.000001 | 4.000000 | -0.000002 |
| 27 | 4.000000 | 4.000001 | 4.000000 | 0.000000 |
## Résultat trouvé
x = 4.000000
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
