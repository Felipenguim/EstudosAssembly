#include <stdio.h>
#include <stdlib.h>

struct node {
    int number;
    struct node* next;
};

struct node* list_create(){
    int value;
    struct node* node;
    struct node* head = NULL;
    while(scanf("%d", &value) == 1){
        node = malloc(sizeof(struct node));
        node->number = value;
        node->next = head;
        head = node;
    } 
    return head;
}

struct node* list_add_front(const int new_number, struct node* linked_list){
    //novo elemento para onde o head apontará 
    struct node* new_node ;
    new_node = malloc(sizeof(struct node));
    new_node->next = linked_list;
    new_node->number = new_number;
    linked_list = new_node;
    return linked_list;
    
}

struct node* list_add_back(const int new_number, struct node* linked_list){
    //novo elemento que apontará para NULL
    struct node* element = linked_list;
    struct node* new_node;
    new_node = malloc(sizeof(struct node));
    new_node->next = NULL;
    new_node->number = new_number;

    while (element->next != NULL){ //assumindo que já existe no mínimo mais de um elemento 
       element = element->next;
    }  
    element->next = new_node;
    return linked_list;
}

int sum_all_elements(struct node* head){
    struct node* element = head;
    int sum = 0;
    while (element != NULL){
        sum += element->number;
        element = element->next;
    }
    return sum;
}
void print_all_elements(struct node* head){
    struct node* element = head;
    
    while (element != NULL){
        printf("elemento: %d", element->number);
        printf("\n");
        element = element->next;
    }
    
}
int find_element_n(int idx, struct node* head){
    struct node* element = head;
    for (int i = 0; i < idx; i++){
        if(element == NULL){
            return 0;
        }
        if(idx == (i+1)){
            return element->number;
        }
        
        element = element->next;
    }
    return 0;
}

void free_linked_list(struct node* head){
    struct node* next;
    while(head != NULL){
        next = head->next;
        free(head);
        head = next;
    }
}


int main(int argc, char** argv){
    struct node* linked_list;
    
    printf("Digite os numeros (Ctrl+D para finalizar):\n");

    linked_list = list_create();

    printf("\nLista completa:\n");
    print_all_elements(linked_list);

    printf("\nSoma dos elementos: %d\n", sum_all_elements(linked_list));

    int n = 3;
    int value = find_element_n(n, linked_list);
    printf("\nElemento na posicao %d: %d\n", n, value);

    free_linked_list(linked_list);


    return 0;
}


// após finalizar ver sempre onde posso adicionar o const 