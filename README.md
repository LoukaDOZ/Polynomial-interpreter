# Polynomial interpreter

Polynomial operations real time interpreter with Automata theory graphs

Declare polynomials, show, derive, find roots, evaluate with an integer, a decimal, a constant or a variable, and do arithmetical operation on these polynomials.

## Usage

```bash
make
./prog <(optional) path of a file with commands in it>
```

## Examples

### Declaration

```
Let P(x) = [(1,2), (0,3), (-4,1)]  ~>  P(x) = x^2 – 4x
Let P(x) = (1.x^2 + 3*3)^2 + 2x  ~>  P(x) = x^4 + 18.x^2 + 2.x + 81
```

### Arithmetical operations

```
P(x) = x^2 – 4x
```
```
(((1.x^2 + ([(3,0)])*3))^2 + 2x)  ~>  x^4 + 18.x^2 + 2.x + 81
P’(x)  ~>  2.x – 4
P’’(x)  ~>  2
```

### Show

```
SHOW P DESC  ~>  P(x) = x^2 - 4.x
SHOW P ASC  ~>  P(x) = -4.x + x^2
```

### Eval

```
P(x) = x^2 – 4x
```
```
EVAL P AT y  ~>  P(y) = y^2 - 4.y
EVAL P AT pi  ~>  P(y) = pi^2 – 4.pi
EVAL P AT 4  ~>  P(y) = 0
EVAL P AT 0.5  ~>  P(0.5) = -1.75
```

### Derive

```
P(x) = x^2 – 4x
```
```
DERIVE 2 TIMES P  ~>  P'(x) = 2
DERIVE P AT y  ~>  P'(y) = 2.y – 4
```

### Find root

```
P(x) = x
```
```
FIND ROOT FOR P BETWEEN 0 AND 150 ~> 0.000000
```
