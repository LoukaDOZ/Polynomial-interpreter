#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "poly.h"

const short MAX_LEN = 15;
const short MAX_FILE_NAME_LEN = 256;

const char UNKNOWN_VAR = '?';

const short CLASSIC_DISPLAY = 0;
const short LIST_DISPLAY = 1;

const short CLASSIC_ORDER = 2;
const short ASCENDING_ORDER = 1;
const short DESCENDING_ORDER = 0;

const short NOT_DERIVED = 0;
const short DERIVED = 1;

const short EVALUATE_AT_VAR = 0;
const short EVALUATE_AT_SYMCONST = 1;
const short EVALUATE_AT_NUM = 2;
const short EVALUATE_AT_FLOAT = 3;

polynomial* LIST = NULL;

tmp_monomial* new_tmp_mono(monomial* m, char var) {
    tmp_monomial* tm = (tmp_monomial*) malloc(sizeof(tmp_monomial));

    tm->mono = m;
    tm->var = var;

    return tm;
}

void free_tmp_mono(tmp_monomial* m) {
    free(m);
}

monomial* new_mono(long coef, long degree) {
    monomial* m = (monomial*) malloc(sizeof(monomial));

    m->next = NULL;
    m->coef = coef;
    m->degree = degree;

    return m;
}

void inverse_mono(monomial* m) {
    m->coef *= -1;
}

void free_mono(monomial* m) {
    free(m);
}

polynomial* new_poly(char var) {
    polynomial* p = (polynomial*) malloc(sizeof(polynomial));

    p->next = NULL;
    p->def = NULL;
    strcpy(p->name, "\0");
    p->var = var;

    return p;
}

void add_poly(polynomial* p) {
    if(LIST == NULL)
        LIST = p;
    else {
        polynomial* pol = LIST;
        while(pol->next != NULL)
            pol = pol->next;
        
        pol->next = p;
    }
}

void add_mono(polynomial* p, monomial* m) {
    if(p->def == NULL)
        p->def = m;
    else {
        monomial* mono = p->def;
        while(mono->next != NULL)
            mono = mono->next;
    
        mono->next = m;
    }
}

polynomial* get_poly(char name[16]) {
    polynomial* p = LIST;

    while(p != NULL && strcmp(name, p->name) != 0)
        p = p->next;

    return p;
}

short poly_name_exists(char name[16]) {
    polynomial* p = get_poly(name);

    if(p == NULL)
        return 0;

    return 1;
}

void set_poly_name(polynomial* p, char name[16]) {
    strcpy(p->name, name);
}

int check_and_replace_var(polynomial* p, char var) {
    if(p->var == UNKNOWN_VAR) {
        p->var = var;
        return 1;
    }

    if(p->var != var && var != UNKNOWN_VAR)
        return 0;

    return 1;
}

polynomial* copy_poly(polynomial* p) {
    polynomial* copy = new_poly(p->var);
    set_poly_name(copy, p->name);

    monomial* m = p->def;
    while(m != NULL) {
        add_mono(copy, new_mono(m->coef, m->degree));
        m = m->next;
    }

    return copy;
}

void reduce_poly(polynomial* p) {
    monomial* current = p->def;
    monomial* current_prev = NULL;

    while(current != NULL) {
        monomial* m = current->next;
        monomial* prev = current;

        while(m != NULL) {
            if(m->degree == current->degree) {
                current->coef += m->coef;
                prev->next = m->next;
                free_mono(m);
                m = prev->next;
            } else {
                prev = m;
                m = m->next;
            }
        }

        if(current->coef == 0) {
            if(current_prev == NULL) {
                p->def = current->next;
                free_mono(current);
                current = p->def;
            } else {
                current_prev->next = current->next;
                free_mono(current);
                current = current_prev->next;
            }

            continue;
        }

        current_prev = current;
        current = current->next;
    }

    if(p->def == NULL)
        add_mono(p, new_mono(0,  0));
}

int get_def_length(monomial* def) {
    int count = 0;

    while(def != NULL) {
        count++;
        def = def->next;
    }

    return count;
}

void def_to_array(monomial* def, monomial** array, int n) {
    int i = 0;

    while(def != NULL && i < n) {
        array[i] = def;
        i++;
        def = def->next;
    }
}

void sort_def_array(monomial** array, int n, short ascending) {
    if(ascending) {
        for(int i = 0; i < n; i++) {
            int min = i;

            for(int j = i + 1; j < n; j++) {
                if(array[j]->degree < array[min]->degree)
                    min = j;
            }

            monomial* tmp = array[min];
            array[min] = array[i];
            array[i] = tmp;
        }
    } else {
        for(int i = 0; i < n; i++) {
            int max = i;

            for(int j = i + 1; j < n; j++) {
                if(array[j]->degree > array[max]->degree)
                    max = j;
            }

            monomial* tmp = array[max];
            array[max] = array[i];
            array[i] = tmp;
        }
    }
}

void show_mono(int pos, long coef, long degree, char symconst[16]) {
    long c = coef;

    if(pos > 0) {
        if(coef < 0) {
            printf(" - ");
            c *= -1;
        } else
            printf(" + ");
    } else if(coef < 0) {
        printf("-");
        c *= -1;
    }

    if(degree == 0 || (coef > 1 || coef < -1))
        printf("%ld", c);

    if(coef != 0 && degree > 0) {
        if(coef > 1 || coef < -1)
            printf(".");
        printf("%s", symconst);
    }

    if(degree > 1)
        printf("^%ld", degree);
}

void show_def(polynomial* p, short order) {
    char v[2];

    sprintf(v, "%c", p->var);
    show_def_symconst(p->def, v, order);
}

void show_def_symconst(monomial* def, char symconst[16], short order) {
    int n = get_def_length(def);
    monomial* array[n];

    def_to_array(def, array, n);
    if(order != CLASSIC_ORDER)
        sort_def_array(array, n, order);

    for(int i = 0; i < n; i++)
        show_mono(i, array[i]->coef, array[i]->degree, symconst);
}

void show_def_list(monomial* def, short order) {
    int n = get_def_length(def);
    monomial* array[n];

    def_to_array(def, array, n);
    if(order != CLASSIC_ORDER)
        sort_def_array(array, n, order);

    printf("[(%ld, %ld)", array[0]->coef, array[0]->degree);
    for(int i = 1; i < n; i++)
        printf(",(%ld, %ld)", array[i]->coef, array[i]->degree);
    printf("]");
}

void show_poly_var(polynomial* p, char var, short order, short derived) {
    char v[2];

    sprintf(v, "%c", var);
    show_poly_symconst(p, v, order, derived);
}

void show_poly_symconst(polynomial* p, char symconst[16], short order, short derived) {
    if(derived)
        printf("%s'(%s) = ", p->name, symconst);
    else
        printf("%s(%s) = ", p->name, symconst);

    show_def_symconst(p->def, symconst, order);
    printf("\n");
}

void show_poly_num(polynomial* p, long num, long res, short derived) {
    if(derived)
        printf("%s'(%ld) = %ld\n", p->name, num, res);
    else
        printf("%s(%ld) = %ld\n", p->name, num, res);
}

void show_poly_float(polynomial* p, long double float_val, long double res, short derived) {
    if(derived)
        printf("%s'(%LG) = %LG\n", p->name, float_val, res);
    else
        printf("%s(%LG) = %LG\n", p->name, float_val, res);
}

void show_poly_list(polynomial* p, short order) {
    printf("%s(%c) = ", p->name, p->var);
    show_def_list(p->def, order);
    printf("\n");
}

void show_all_poly(short list, short order) {
    polynomial* p = LIST;

    if(list) {
        while(p != NULL) {
            show_poly_list(p, order);
            p = p->next;
        }
    } else {
        while(p != NULL) {
            show_poly_var(p, p->var, order, NOT_DERIVED);
            p = p->next;
        } 
    }
}

void derive_poly(polynomial* p, long n) {
    monomial* m = p->def;
    while(m != NULL) {
        long coef = m->coef;
        long degree = 0;

        if(m->degree > n)
            degree = m->degree - n;

        for(long i = 0; i < n && coef != 0; i++)
            coef *= m->degree - i;

        m->coef = coef;
        m->degree = degree;
        m = m->next;
    }

    reduce_poly(p);
}

void inverse_poly(polynomial* p) {
    monomial* m = p->def;
    while(m != NULL) {
        inverse_mono(m);
        m = m->next;
    }
}

void poly_multiplication(polynomial* p1, polynomial* p2) {
    monomial* new = NULL;
    monomial* current = NULL;

    monomial* m1 = p1->def;
    while(m1 != NULL) {

        monomial* m2 = p2->def;
        while(m2 != NULL) {
            if(new == NULL) {
                new = new_mono(m1->coef * m2->coef, m1->degree + m2->degree);
                current = new;
            } else {
                current->next = new_mono(m1->coef * m2->coef, m1->degree + m2->degree);
                current = current->next;
            }
           
            m2 = m2->next;
        }

        m1 = m1->next;
    }

    free_def(p1->def);
    p1->def = new;
}

void poly_pow(polynomial* p1, long n) {
    polynomial* copy = copy_poly(p1);

    for(long i = 1; i < n; i++)
        poly_multiplication(p1, copy);

    free_poly(copy);
}

void poly_addition(polynomial* p1, polynomial* p2) {
    monomial* m = p2->def;
    while(m != NULL) {
        add_mono(p1, new_mono(m->coef, m->degree));
        m = m->next;
    }
}

void poly_substraction(polynomial* p1, polynomial* p2) {
    monomial* m = p2->def;
    while(m != NULL) {
        add_mono(p1, new_mono(m->coef * -1, m->degree));
        m = m->next;
    }
}

long double round_6_decimal(long double v) {
    char buff[32];

    sprintf(buff, "%.6Lf", v);

    return strtold(buff, NULL);
}

long double find_poly_root(polynomial* p, long double a, long double b, FILE* file) {
    long double sign, c, res;
    unsigned int i = 0;
    evaluated_polynomial* ep;

    ep = eval_poly(p, new_eval_at_float(a));
    sign = ep->res_float;
    free(ep);
    ep = eval_poly(p, new_eval_at_float(b));
    sign -= ep->res_float;
    free(ep);

    if(file != NULL) {
        fprintf(file, "# Recherche d'une racine entre %Lf et %Lf\n", a, b);
        fprintf(file, "## Etapes intermédiaires\n");
        fprintf(file, "| Itération | a | b | c = (a + b) / 2 | %s\\(c\\) |\n", p->name);
        fprintf(file, "| --------- | - | - | --------------- | ----- |\n");
    }

    while(round_6_decimal(b - a) > 0) {
        c = (a + b) / 2;
        ep = eval_poly(p, new_eval_at_float(c));
        res = round_6_decimal(ep->res_float);

        if(file != NULL)
            fprintf(file, "| %u | %Lf | %Lf | %Lf | %Lf |\n", i, a, b, c, res);

        if(res == 0)
            break;

        if(sign < 0) {
            if(res > 0)
                b = c;
            else
                a = c;
        } else {
            if(res > 0)
                a = c;
            else
                b = c;
        }

        free_evaluated_poly(ep);
        i++;
    }

    return round_6_decimal(c);
}

void free_def(monomial* def) {
    monomial* next;

    while(def != NULL) {
        next = def->next;
        free_mono(def);
        def = next;
    }
}

void free_poly(polynomial* p) {
    free_def(p->def);
    free(p);
}

void free_all_poly() {
    if (LIST != NULL) {
        polynomial* p = LIST;
        polynomial* next;

        while(p != NULL) {
            next = p->next;
            free_poly(p);
            p = next;
        }
    }
}

eval_at* new_eval_at_var(char var) {
    eval_at* at = (eval_at*) malloc(sizeof(eval_at));
    
    at->type = EVALUATE_AT_VAR;
    at->var = var;

    return at;
}

eval_at* new_eval_at_symconst(char symconst[16]) {
    eval_at* at = (eval_at*) malloc(sizeof(eval_at));
    
    at->type = EVALUATE_AT_SYMCONST;
    strcpy(at->symconst, symconst);

    return at;
}

eval_at* new_eval_at_num(long num) {
    eval_at* at = (eval_at*) malloc(sizeof(eval_at));
    
    at->type = EVALUATE_AT_NUM;
    at->num = num;

    return at;
}

eval_at* new_eval_at_float(long double float_val) {
    eval_at* at = (eval_at*) malloc(sizeof(eval_at));
    
    at->type = EVALUATE_AT_FLOAT;
    at->float_val = float_val;

    return at;
}

void free_eval_at(eval_at* at) {
    free(at);
}

evaluated_polynomial* eval_poly(polynomial* p, eval_at* at) {
    evaluated_polynomial* ep = (evaluated_polynomial*) malloc(sizeof(evaluated_polynomial));

    ep->at = at;
    ep->source = copy_poly(p);

    if(at->type == EVALUATE_AT_NUM) {
        ep->res_num = 0;

        monomial* m = p->def;
        while(m != NULL) {
            ep->res_num += m->coef * (long) pow((double) at->num, (double) m->degree);
            m = m->next;
        }
    } else {
        ep->res_float = 0;

        monomial* m = p->def;
        while(m != NULL) {
            ep->res_float += (long double) m->coef * (long double) pow((long double) at->float_val, (long double) m->degree);
            m = m->next;
        }
    }

    return ep;
}

void show_evaluated_poly(evaluated_polynomial* p, short derived) {
    if(p->at->type == EVALUATE_AT_VAR)
        show_poly_var(p->source, p->at->var, DESCENDING_ORDER, derived);
    else if(p->at->type == EVALUATE_AT_SYMCONST)
        show_poly_symconst(p->source, p->at->symconst, DESCENDING_ORDER, derived);
    else if(p->at->type == EVALUATE_AT_NUM)
        show_poly_num(p->source, p->at->num, p->res_num, derived);
    else
        show_poly_float(p->source, p->at->float_val, p->res_float, derived);
}

void free_evaluated_poly(evaluated_polynomial* p) {
    free_poly(p->source);
    free_eval_at(p->at);
    free(p);
}

show_cmd* new_show_cmd(polynomial* p, short display, short order) {
    show_cmd* cmd = (show_cmd*) malloc(sizeof(show_cmd));

    cmd->p = p;
    cmd->display = display;
    cmd->order = order;

    return cmd;
}

void free_show_cmd(show_cmd* cmd) {
    free(cmd);
}