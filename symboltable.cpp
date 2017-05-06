#include <iostream>
#include <string>
#include <stdlib.h>
using namespace std;

#define SIZE 10

struct SymbTableNode
{
	/* data */
	string name;
	string type;
	bool assig;
	struct SymbTableNode * Next;
};

class symboltable
{
	/* data */
	SymbTableNode *Nodes[SIZE];
	symboltable *Next;
	symboltable *Prev;
public:
	symboltable(){
		for(int i=0;i<SIZE;i++)
			Nodes[i]=NULL;
		Next=NULL;
		Prev=NULL;
	}
	int Hash(string name){
		int key = 0;
		for(int i = 0; i < name.length() ; i++ ){
			key+=name[i];
			//cout << key<<endl;
		}
		return key%SIZE;
	}
	void Insert(string name , string type, bool assg){
		int key = Hash(name);
		if(Nodes[key] == NULL ){
			Nodes[key] = new SymbTableNode();
			Nodes[key]->name = name;
			Nodes[key]->type = type;
			Nodes[key]->assig = assg;
			Nodes[key]->Next = NULL;
		}else{
			SymbTableNode *newNode = new SymbTableNode();
			newNode->name = name;
			newNode->type = type; 
			Nodes[key]->assig = assg;
			newNode->Next = Nodes[key];
			Nodes[key] = newNode;
		}
	}
	/*sets the identifier assigned boolean to true*/
	void SetAssigned(string name){
		SymbTableNode* temp = Search(name);
		temp->assig = true;
	}
	int Delete(string name ,string type){
		int key = Hash(name);
		if(Nodes[key] == NULL){
			cout<<"Node not found\n";
			return 0;
		}
		else{
			SymbTableNode * temp = Nodes[key];
			//temp is the first node
			if(temp->name == name && temp->type == type){
				Nodes[key] = temp->Next;
				cout<<"first node\n";
				return 1;
			}
			else if(temp->Next != NULL){
				cout<<"temp->Next->name "<<temp->Next->name<<" temp->Next->type "<<temp->Next->type<<endl;
				while(temp->Next->name != name){
					temp = temp->Next;
					if(temp == NULL)
						return 0;
				}	
				temp->Next = temp->Next->Next;
			}
		} 
	}
	SymbTableNode* Search(string name){
		int key  = Hash(name);
		SymbTableNode* temp = Nodes[key];
		while(temp->name!=name && temp->Next != NULL)
			temp=temp->Next;
		if(temp->name == name){
			return temp;
		}
		else{
			cout<<"Not Found\n";
			return NULL;
		}
	}
	void showSymbolTable(){
	    // Implement
	    for(int i = 0; i < SIZE; ++i){
	        cout<<i<<": ";

	        // Do not modify the head
	        SymbTableNode* temp = Nodes[i];

	        while( temp != NULL ){
	            cout<<"->[ "<<temp->name<<" | "<<temp->type<<" | " <<temp->assig<< "]\n";
				temp = temp->Next;
	        }

	        cout<<endl;
	    }
	}

};

/*int main(){
	symboltable x;
	x.Insert("AA","STRING");
	cout<<"Insert\n";
	x.Insert("ali","STRING");
	cout<<"Insert\n";
	x.Insert("AA","SG");
	cout<<"Insert\n";
	x.showSymbolTable();
	x.Delete("ali","STRING");
	x.showSymbolTable();
	x.Search("AA");
	//cout<<"Delete\n";
	cout<<"done\n";
}*/
