#include<iostream>
#include<algorithm>
#include<vector>
#include<iomanip>
#include<fstream>
#define ROW 9
#define COL 9
using namespace std;

void create_sudoku(int **cell)
{
	for(int index=0;index<81;index++)
	{
		int row=index/ROW;	
		int col=index%COL;
		cell[row][col]=0;
	}
	cout<<"Enter sudoku configuration-> Row column value\n";
	ifstream in("in1.sudoku");
	int row,col,val=true;	
	
	int count;
	cout<<"Number of values\n";
	cin>>count;
	cout<<"Enter 0 to exit\n";
	for(int i=0;i<count;i++)
	{
		in>>row>>col>>val;
		cell[row-1][col-1]=val;
		cout<<"cell["<<row<<"]["<<col<<"]="<<cell[row-1][col-1]<<endl;
	}
}
bool validate_sudoku_cell(int **cell,int row,int col)
{
	int val=cell[row][col];
	//validate row
	//cout<<"validate row for cell["<<row+1<<"]["<<col+1<<"]"<<endl;
	for(int k=0;k<9;k++)
		if(k!=col && cell[row][k]==val)
			return false;

	//validate column
	//cout<<"validate column for cell["<<row+1<<"]["<<col+1<<"]"<<endl;
	for(int k=0;k<9;k++)
		if(k!=row && cell[k][col]==val)
			return false;

	//validate region
	//cout<<"validate region for cell["<<row+1<<"]["<<col+1<<"]"<<endl;
	int REG_LEN=3;
	int regI=row/REG_LEN;
	int regJ=col/REG_LEN;
	for(int i=0;i<REG_LEN;i++)
	{
		for(int j=0;j<REG_LEN;j++)
		{
			if(regI*REG_LEN+i==row && regJ*REG_LEN+j==col)
				continue;
			if(cell[regI*REG_LEN+i][regJ*REG_LEN+j]==cell[row][col])
				return false;
		}
	}
	return true;
}

bool validate_sudoku(int **cell)
{
	int index=0;
	int row,col;
	for(index=0;index<81;index++)
	{
		row=index/ROW;	
		col=index%COL;
		//validate row,col and region for this cell
		if(cell[row][col]!=0 && !validate_sudoku_cell(cell,row,col))
		{
			//cout<<"Validation failed for cell["<<row+1<<"]["<<col+1<<"]"<<endl;
			return false;
		}
	}	
	//cout<<"Sudoku validation succeeded"<<endl;
	return true;
}
void display_sudoku(int **cell)
{
	int index=0;
	int row,col;
	for(index=0;index<81;index++)
	{
		int row=index/ROW;
		int col=index%COL;
		if(index%9==0)
			cout<<endl;
		cout<<setw(2)<<cell[row][col]<<"  ";
	}
}
bool solve_sudoku(int **cell,int index)
{
	if(index>=80)
	{
		cout<<"Sudoku successfully solved"<<endl;
		return true;
	}
	int row=index/ROW;
	int col=index%COL;
	//skip filled entry
	if(cell[row][col]!=0)
	{
		if(solve_sudoku(cell,index+1))
			return true;
		else
			return false;
	}
	//try to fill values starting 1 and check if sudoku is solved. if not , check with next value until 9
	for(int val=1;val<=9;val++)
	{
		cell[row][col]=val;
		if(validate_sudoku_cell(cell,row,col))
		{
			if(solve_sudoku(cell,index+1))
				return true;
		}
		else
		{
			//cout<<"Sudoku not feasible for Cell ["<<row+1<<"]["<<col+1<<"]"<<endl;
			cell[row][col]=0;
		}
	}
	cout<<"Sudoku not possible:Blocking Cell is ["<<row+1<<"]["<<col+1<<"]"<<endl;
	return false;
	
}
int main()
{
	cout<<"Sudoku solver Program\n";
	int **cell=new int*[COL];
	for(int i=0;i<ROW;i++)
		cell[i]=new int[ROW];
	create_sudoku(cell);
	if(!validate_sudoku(cell))
		return 0;
	cout<<"Displaying initial Sudoku"<<endl;
	display_sudoku(cell);
	int res=solve_sudoku(cell,0);
	//if(solve_sudoku(cell,0))
	cout<<"Displaying solved Sudoku"<<endl;
	display_sudoku(cell);
	if(!res)
		cout<<"Sudoku not created"<<endl;
	return 0;
}		
