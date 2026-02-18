#include <stdio.h>

int dotproduct(const int* arr1, const int* arr2, size_t size1, size_t size2){
    if (size1 != size2){
        return -1;
    }
    int result = 0;
    size_t i;
    for (i = 0; i <size1; i++){
        result += arr1[i] * arr2[i]; 
    }
    return result;
}

int main(int argc, char** argv){
    const int arr1[3] = {1, 2, 3};
    const int arr2[3] = {4, 5, 6};
    size_t size1 = sizeof(arr1) / sizeof(arr1[0]);
    size_t size2 = sizeof(arr2) / sizeof(arr2[0]);
    int prod = dotproduct(arr1, arr2, size1, size2);
    printf("O produto escalar dos arrays eh: %d", prod);
    return 0;
}