#include <stdio.h>
#include <conio.h>

int CharacterTyped;
main()
{
    CharacterTyped =1;
    while (CharacterTyped != 0)
        {
        CharacterTyped=getch();
        }
    CharacterTyped = getch();
    if (CharacterTyped==59)
        puts("F1 Key von pressovitched!!!");
}
