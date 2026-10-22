#include<stdio.h>

int is_prime(unsigned long long n){
    if (n < 2){
        return 1;
    }
    unsigned long long div = 2;
    while( div*div <=n){
        if (n % div ==0){
            return 0;
        }
        div++;
    }
    return 1;
}


int main(int argc, char** argv){
    unsigned long long num;
    printf("Digite um numero inteiro positivo: ");
    scanf("%llu", &num);
    if(is_prime(num)){
        printf("%llu eh primo.\n", num);
    } else {
        printf("%llu nao eh primo.\n", num);
    }
    return 0;
}