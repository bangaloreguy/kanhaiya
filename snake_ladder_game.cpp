#include<iostream>
#include<stdlib.h>
#include<time.h>
using namespace std;
#define NBR_OF_CELLS 30
#define MAX_CELL 30

int snake_ladder(int *v)
{
	int next_dice=0;
	srand(time(NULL));
	int cur_cell=1;
	int move_nbr=0;
	while(true)
	{
		next_dice=rand()%6+1;
		move_nbr++;
		cout<<"Move#"<<move_nbr<<"; current cell is "<<cur_cell<<"; next dice is "<<next_dice<<endl;
		if(cur_cell+next_dice > MAX_CELL)	//if next cell exceeds max cell, make next move
			continue; 

		cur_cell=v[cur_cell+next_dice];
		if(cur_cell==MAX_CELL)
		{
			cout<<"Congrats: You reached to last cell "<<cur_cell<<" in "<<move_nbr<<" moves"<<endl;
			break;
		}
		if(move_nbr>=30)
		{
			cout<<"Couldn't reach to top even in 30 moves, Try again!"<<endl;
			break;
		}
	}
	return move_nbr;
		
}
int main()
{
	cout<<"Solution:Snake-Ladder Game from Geeksforgeeks\n";
	cout<<"Source:http://www.geeksforgeeks.org/snake-ladder-problem-2/\n";
	int cell[NBR_OF_CELLS];	//5*6 box, each cell represent one number
	int vertex[NBR_OF_CELLS+1];	//destination of each cell upon movement, if snake, move to -i cell, if ladder, move to +i.
	for(int i=1;i<=NBR_OF_CELLS; i++)
	{
		cell[i]=i;
		vertex[i]=i;
	}
	vertex[3]=22;
	vertex[5]=8;
	vertex[11]=26;
	vertex[20]=29;
	vertex[17]=4;
	vertex[19]=7;
	vertex[21]=9;
	vertex[27]=1;

	int nbrofmoves=snake_ladder(vertex);
	cout<<"Nbr of moves="<<nbrofmoves<<endl;
	return 0;
}
