#ifndef POLY_H
#define POLY_H

const char* INFO_MSG;
const char* ERR_MSG;
const char UNKNOWN_VAR;

typedef struct monomial monomial;
struct monomial {
    monomial* next;
    long coef;
    long degree;
};

typedef struct tmp_monomial tmp_monomial;
struct tmp_monomial {
    monomial* mono;
    char var;
};

typedef struct polynomial polynomial;
struct polynomial {
    polynomial* next;
    monomial* def;
    char name[16];
    char var;
};

void show_all_poly();
void free_all_poly();

polynomial* new_poly(char var);
void add_poly(polynomial* p);
void add_mono(polynomial* p, monomial* m);
short poly_name_exists(char name[16]);
void set_poly_name(polynomial* p, char name[16]);
int check_and_replace_var(polynomial* p, char var);
void show_poly(polynomial* p, short list, short order);
void free_poly(polynomial* p);

tmp_monomial* new_tmp_mono(monomial* m, char var);
void free_tmp_mono(tmp_monomial* m);

monomial* new_mono(long coef, long degree);
void inverse_mono(monomial* m);
void free_def(monomial* def);

#endif