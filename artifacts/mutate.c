#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>


int main() {
    size_t len;
    char buffer[1024];

    len = read(STDIN_FILENO, buffer, 1023);
    buffer[len] = '\0';

    if (len == 0) {
        printf("Пустая строка, нечего мутировать.\n");
        return 0;
    }

    // Инициализируем генератор случайных чисел
    srand((unsigned int)time(NULL));

    // Выбираем случайный индекс для мутации
    size_t rand_index = rand() % len;

    // Генерируем случайное значение для замены
    buffer[rand_index] = (char)(rand() % 256);

    // Выводим результат
    printf("%s\n", buffer);
    return 0;
}
