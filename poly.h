#ifndef POLY_H
#define POLY_H

extern const short MAX_LEN;
extern const short MAX_FILE_NAME_LEN;

extern const char UNKNOWN_VAR;

extern const short CLASSIC_DISPLAY;
extern const short LIST_DISPLAY;

extern const short CLASSIC_ORDER;
extern const short ASCENDING_ORDER;
extern const short DESCENDING_ORDER;

extern const short NOT_DERIVED;
extern const short DERIVED;

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

typedef struct eval_at eval_at;
struct eval_at {
    short type;
    union {
        char var;
        char symconst[16];
        long num;
        long double float_val;
    };
};

typedef struct evaluated_polynomial evaluated_polynomial;
struct evaluated_polynomial {
    eval_at* at;
    polynomial* source;
    union {
        long res_num;
        long double res_float;
    };
};

typedef struct show_cmd show_cmd;
struct show_cmd {
    polynomial* p;
    short display;
    short order;
};

tmp_monomial* new_tmp_mono(monomial* m, char var);
void free_tmp_mono(tmp_monomial* m);

monomial* new_mono(long coef, long degree);
void inverse_mono(monomial* m);
void free_mono(monomial* m);

polynomial* new_poly(char var);
void add_poly(polynomial* p);
void add_mono(polynomial* p, monomial* m);
polynomial* get_poly(char name[MAX_LEN]);
short poly_name_exists(char name[MAX_LEN]);
void set_poly_name(polynomial* p, char name[MAX_LEN]);
int check_and_replace_var(polynomial* p, char var);
polynomial* copy_poly(polynomial* p);
void reduce_poly(polynomial* p);
void show_def(polynomial* p, short order);
void show_def_symconst(monomial* def, char symconst[MAX_LEN], short order);
void show_def_list(monomial* def, short order);
void show_poly_var(polynomial* p, char var, short order, short derived);
void show_poly_symconst(polynomial* p, char symconst[MAX_LEN], short order, short derived);
void show_poly_num(polynomial* p, long num, long res, short derived);
void show_poly_float(polynomial* p, long double float_val, long double res, short derived);
void show_poly_list(polynomial* p, short order);
void show_all_poly(short list, short order);
void derive_poly(polynomial* p, long n);
void inverse_poly(polynomial* p);
void poly_multiplication(polynomial* p1, polynomial* p2);
void poly_pow(polynomial* p1, long n);
void poly_addition(polynomial* p1, polynomial* p2);
void poly_substraction(polynomial* p1, polynomial* p2);
long double find_poly_root(polynomial* p, long double a, long double b, FILE* file);
void free_def(monomial* def);
void free_poly(polynomial* p);
void free_all_poly();

eval_at* new_eval_at_var(char var);
eval_at* new_eval_at_symconst(char symconst[MAX_LEN]);
eval_at* new_eval_at_num(long num);
eval_at* new_eval_at_float(long double float_val);
void free_eval_at(eval_at* at);

evaluated_polynomial* eval_poly(polynomial* p, eval_at* at);
void show_evaluated_poly(evaluated_polynomial* p, short derived);
void free_evaluated_poly(evaluated_polynomial* p);

show_cmd* new_show_cmd(polynomial* p, short display, short order);
void free_show_cmd(show_cmd* cmd);

#endif