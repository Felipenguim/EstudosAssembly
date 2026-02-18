#include <stdio.h>

int sum_array(const int* arr, size_t size){
    int soma = 0;
    for (size_t i = 0; i<size; i++){
        soma += arr[i];
    }
    return soma;
    
}


int main(int argc, char** argv){
    const int arr[5] = {10, 10, 23, 45, 32};
    size_t size = sizeof(arr) / sizeof(arr[0]);
    int soma = sum_array(arr, size);
    printf("A soma dos elementos do array eh: %d", soma);
    return 0;
}