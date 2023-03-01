#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "poly.h"

#define MAX_LEN 15

const char* INFO_MSG = "[\033[0;34mInfo\033[0m]";
const char* ERR_MSG = "[\033[0;31mErreur\033[0m]";

const char UNKNOWN_VAR = '?';

const short CLASSIC_DISPLAY_OPTION = 0;
const short LIST_DISPLAY_OPTION = 0;

const short CLASSIC_ORDER_OPTION = 0;
const short ASCENDING_ORDER_OPTION = 1;
const short DESCENDING_ORDER_OPTION = 2;

polynomial* FIRST = NULL;

void show_all_poly() {
    printf("\n%s Tous les polynômes :\n", INFO_MSG);

    polynomial* p = FIRST;
    while(p != NULL) {
        print_poly(p);
        p = p->next;
    }

    printf("\n");
}

void free_all_poly() {
    if (FIRST != NULL) {
        polynomial* pol = FIRST;
        polynomial* next;

        while(pol != NULL) {
            next = pol->next;
            free_poly(pol);
            pol = next;
        }
    }
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
    if(FIRST == NULL)
        FIRST = p;
    else {
        polynomial* pol = FIRST;
        while(pol->next != NULL)
            pol = pol->next;
        
        pol->next = p;
    }

    printf("\n%s Polynôme %s ajouté\n", INFO_MSG, p->name);
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

short poly_name_exists(char name[16]) {
    polynomial* pol = FIRST;
    while(pol != NULL) {
        if(strcmp(pol->name, name) == 0)
            return 1;

        pol = pol->next;
    }

    return 0;
}

void set_poly_name(polynomial* p, char name[16]) {
    strcpy(p->name, name);
}

int check_and_replace_var(polynomial* p, char var) {
    if(p->var == UNKNOWN_VAR) {
        p->var = var;
        return 1;
    }

    if(p->var != var)
        return 0;

    return 1;
}

void show_poly(polynomial* p, short list, short order) {
    printf("%s(%c) = ", p->name, p->var);

    monomial* m = p->def;
    short first_loop = 1;
    while(m != NULL) {
        if(!first_loop) {
            if(m->coef < 0)
                printf(" - ");
            else
                printf(" + ");
        } else if(m->coef < 0)
                printf("-");

        long coef = m->coef;
        if(m->coef < 0)
            coef = coef * -1;
        printf("%ld%c^%ld", coef, p->var, m->degree);

        /*if(m->coef > 0) {
            if(m->coef > 1 || m->degree == 0)
                printf("%ld", m->coef);

            if(m->degree > 0) {
                printf("%c", p->var);
                if(m->degree > 1)
                    printf("^%ld", m->degree);
            }
        }*/

        m = m->next;
        first_loop = 0;
    }

    printf("\n");
}

void free_poly(polynomial* p) {
    free_def(p->def);
    free(p);
}

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
    m->coef = m->coef * -1;
}

int get_def_length(monomial* def) {
    int count = 0;

    while(def != NULL) {
        count++;
        next = def->next;
    }

    return count;
}

void sort_def(monomial** array, int n, short ascending) {
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

void free_def(monomial* def) {
    monomial* next;

    while(def != NULL) {
        next = def->next;
        free(def);
        def = next;
    }
}