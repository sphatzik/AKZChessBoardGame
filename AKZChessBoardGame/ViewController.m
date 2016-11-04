//
//  ViewController.m
//  AKZChessBoardGame
//
//  Created by minus one on 31/10/16.
//  Copyright © 2016 Spyridon Chatzikotoulas. All rights reserved.
//

#import "ViewController.h"
#import "RWTreeNode.h"


@interface ViewController (){
    UIImageView *boardCell[65];
    UIImageView *pawnCell[2];
}

@end

int cellWidth = 0;
int squares= 64;
int pawns=2;
int which=-1;
int positionTarget = 0, positionKnight=0, closest=0;
float cellX[65], cellY[65];
int board[9][9];
int LeftX, topY;


int a[9][9],j,ith,jth, counter, pathCounter=0;
NSMutableArray *arrayOfNodes, *arrayWithPath;
BOOL found=0;

NSInteger findX;
NSInteger findY;
NSInteger targetX;
NSInteger targetY;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reDrawBoard];  //method that draws the chess board, the knoght pawn and the target pawn.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark detect touch events and user interaction

-(void)calculateButton:(UIButton*)sender{
    
    if(positionTarget!=0 || positionKnight!=0){
        [self findSolution];
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{  //detect movements of the pawns
    
    UITouch *tap = [[event allTouches] anyObject];
    
    CGPoint location = [tap locationInView:self.view];
    
    int i;
    
    for(i=0; i<pawns; i++){
        if([tap view]==pawnCell[i]){
            pawnCell[i].center = location;
            which=i;
        }
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self touchesBegan:touches withEvent:event];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    int min = cellWidth*cellWidth*2;
    int i=0;
    float dSquare = 0;
    float dX, dY;
    
    
    if(which!=-1){
        if(pawnCell[which].center.x > LeftX && pawnCell[which].center.x < LeftX+8.5*cellWidth && pawnCell[which].center.y > topY && pawnCell[which].center.y<topY+8.5*cellWidth){
            dX = pawnCell[which].center.x - cellX[1];
            dY = pawnCell[which].center.y - cellY[1];
            
            min = dX*dX + dY*dY +1;
            
            for(i=1;i<=squares;i++){
                dX = pawnCell[which].center.x - cellX[i];
                dY = pawnCell[which].center.y - cellY[i];
                
                dSquare =  dX*dX + dY*dY;
                
                if(dSquare<min){
                    min=dSquare;
                    if(which==0){
                        positionKnight=i;
                        closest=i;
                    }
                    else{
                        positionTarget=i;
                        closest=i;
                    }
                }
            }
            
            pawnCell[which].center = CGPointMake(cellX[closest], cellY[closest]);
        }
    }
    
}


#pragma mark calculate paths for the pawn

-(void)findSolution{ //calculate the solution table
    
    int k=0;
    
    for(int i=1; i<9; i++){
        for(int j=1; j<9; j++){
            k++;
            board[i][j]=k;
        }
    }
    
    for(int i=1; i<9; i++){
        for(int j=1; j<9; j++){
            if(board[i][j]==positionKnight){
                ith=i;
                jth=j;
                NSLog(@"Poistion of the knight %d ,%d",i,j);
            }
            if(board[i][j]==positionTarget){
                findX=i;
                findY=j;
                targetX=findX;
                targetY=findY;
                NSLog(@"Poistion of the Target %d ,%d",i,j);
            }
        }
    }
    
    [self findPaths];
    
    positionKnight=0;
    positionTarget=0;
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self reDrawBoard];
    });
}

-(void)findPaths{
    
    void ch(int,int,int[9][9]);
    arrayOfNodes = [[NSMutableArray alloc]init];
    arrayWithPath = [[NSMutableArray alloc]init];
    
    counter=0;
    pathCounter=0;
    
    if(ith<=0 || jth<=0){
        NSLog(@"Location is out of ChessBoard");
    }
    
    for(int i=1;i<=8;i++){
        for(int j=1;j<=8;j++){
            if(i==ith && j==jth){
                a[i][j]=0;
            }
            else{
                a[i][j]=9;
            }
        }
    }
    
    for(int k=0;k<=8;k++){
        for(int i=1;i<=8;i++){
            for(int j=1;j<=8;j++){
                if(a[i][j]==k){
                    ch(i,j,a);
                }
            }
        }
    }
    
    if(a[targetX][targetY]>3){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"More than 3 moves in order to reach this position" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else{
        while(!found){
            found = [self calculateMoves];
        }
    }
    found=0;
    [self showPath];
    NSLog(@"%@",arrayWithPath);
}

-(void)showPath{
    
    int position1=0, position2=0;
    
    for(int i=0; i<arrayWithPath.count ; i++){
        RWTreeNodeObject<NSString*> *root;
        RWTreeNodeObject<NSString*> *n1;
        
        root = [arrayWithPath objectAtIndex:i];
        n1 = [root.children objectAtIndex:0];
        
        position1 = (root.valueX.intValue-1)*8 + root.valueY.intValue;
        boardCell[position1].image = [UIImage imageNamed: @"greenTile.png"];
        position2 = (n1.valueX.intValue-1)*8 + n1.valueY.intValue;
        boardCell[position2].image = [UIImage imageNamed: @"greenTile.png"];
    }
}


void ch(int i,int j,int a[9][9]){
    
    RWTreeNodeObject<NSString*> *root;
    RWTreeNodeObject<NSString*> *n1;
    RWTreeNodeObject<NSString*> *n2;
    RWTreeNodeObject<NSString*> *n3;
    RWTreeNodeObject<NSString*> *n4;
    RWTreeNodeObject<NSString*> *n5;
    RWTreeNodeObject<NSString*> *n6;
    RWTreeNodeObject<NSString*> *n7;
    RWTreeNodeObject<NSString*> *n8;
    
    
    root = [[RWTreeNodeObject alloc]initWithValue:[NSString stringWithFormat:@"%d",i] valueY:[NSString stringWithFormat:@"%d",j]];
    
    if(a[i-2][j+1]==9 && i-2>=1 && j+1<=8){
        a[i-2][j+1]=a[i][j]+1;
        n1 = [[RWTreeNodeObject alloc]initWithValue:[NSString stringWithFormat:@"%d",i-2] valueY:[NSString stringWithFormat:@"%d",j+1]];
        [root addChild:n1];
    }
    if(a[i-2][j-1]==9 && i-2>=1 && j-1>=1){
        a[i-2][j-1]=a[i][j]+1;
        n2 = [[RWTreeNodeObject alloc]initWithValue:[NSString stringWithFormat:@"%d",i-2] valueY:[NSString stringWithFormat:@"%d",j-1]];
        [root addChild:n2];
    }
    if(a[i+2][j+1]==9 && i+2<=8 && j+1<=8){
        a[i+2][j+1]=a[i][j]+1;
        n3 = [[RWTreeNodeObject alloc]initWithValue:[NSString stringWithFormat:@"%d",i+2] valueY:[NSString stringWithFormat:@"%d",j+1]];
        [root addChild:n3];
    }
    if(a[i+2][j-1]==9 && i+2<=8 && j-1>=1){
        a[i+2][j-1]=a[i][j]+1;
        n4 = [[RWTreeNodeObject alloc]initWithValue:[NSString stringWithFormat:@"%d",i+2] valueY:[NSString stringWithFormat:@"%d",j-1]];
        [root addChild:n4];
    }
    if(a[i-1][j+2]==9 && i-1>=1 && j+2<=8){
        a[i-1][j+2]=a[i][j]+1;
        n5 = [[RWTreeNodeObject alloc]initWithValue:[NSString stringWithFormat:@"%d",i-1] valueY:[NSString stringWithFormat:@"%d",j+2]];
        [root addChild:n5];
    }
    if(a[i-1][j-2]==9 && i-1>=1 && j-2>=1){
        a[i-1][j-2]=a[i][j]+1;
        n6 = [[RWTreeNodeObject alloc]initWithValue:[NSString stringWithFormat:@"%d",i-1] valueY:[NSString stringWithFormat:@"%d",j-2]];
        [root addChild:n6];
    }
    if(a[i+1][j+2]==9 && i+1<=8 && j+2<=8){
        a[i+1][j+2]=a[i][j]+1;
        n7 = [[RWTreeNodeObject alloc]initWithValue:[NSString stringWithFormat:@"%d",i+1] valueY:[NSString stringWithFormat:@"%d",j+2]];
        [root addChild:n7];
    }
    if(a[i+1][j-2]==9 && i+1<=8 && j-2>=1){
        a[i+1][j-2]=a[i][j]+1;
        n8 = [[RWTreeNodeObject alloc]initWithValue:[NSString stringWithFormat:@"%d",i+1] valueY:[NSString stringWithFormat:@"%d",j-2]];
        [root addChild:n8];
    }
    
    [arrayOfNodes insertObject:root atIndex:counter];
    counter++;
}

-(BOOL)calculateMoves{
    
    RWTreeNodeObject<NSString*> *root;
    RWTreeNodeObject<NSString*> *n1;
    
    RWTreeNodeObject<NSString*> *rootPath;
    RWTreeNodeObject<NSString*> *nPath;
    
    
    for(int i=0; i<arrayOfNodes.count ;i++){
        root = [arrayOfNodes objectAtIndex:i];
        for(int j=0;j<root.children.count;j++){
            n1 = [root.children objectAtIndex:j];
            
            if(n1.valueX.intValue == findX && n1.valueY.intValue == findY){
                rootPath = [[RWTreeNodeObject alloc]initWithValue:root.valueX valueY:root.valueY];
                nPath = [[RWTreeNodeObject alloc]initWithValue:n1.valueX valueY:n1.valueY];
                [rootPath addChild:nPath];
                [arrayWithPath insertObject:rootPath atIndex:pathCounter];
                pathCounter++;
                
                if(rootPath.valueX.intValue != ith || rootPath.valueY.intValue != jth){
                    findX = rootPath.valueX.integerValue;
                    findY = rootPath.valueY.integerValue;
                }
                else{
                    found=1;
                    break;
                }
            }
        }
    }
    
    return found;
}

#pragma mark drawing method

-(void)reDrawBoard{

    
    for (UIView *subUIView in self.view.subviews) {  //remove subviews before re draw
        [subUIView removeFromSuperview];
    }
    
    int i=0;
    int row, col;
    row=0;
    col=0;
    int firstColor = 0;
    LeftX = [[UIScreen mainScreen] bounds].size.width;
    topY = [[UIScreen mainScreen] bounds].size.height;
    int scaleX = 0;
    int scaleY = 6;
    
    //Detect Devices width
    
    if(LeftX==375){
        cellWidth = 40;
        scaleX = 14;
    }
    else if(LeftX==414){
        cellWidth = 40;
        scaleX = 10;
    }
    else if(LeftX==320){
        cellWidth = 36;
        scaleX = 18;
    }
    
    topY = topY/scaleY;
    LeftX = LeftX/scaleX;
    
    
    for(i=1; i<=64; i++){ //draw board
        
        if(firstColor==0){
            boardCell[i] = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"blackTile"]];
        }
        else{
            boardCell[i] =  [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"whiteTile"]];
        }
        
        boardCell[i].frame = CGRectMake(LeftX+cellWidth*col,topY+cellWidth*row ,cellWidth ,cellWidth);
        cellX[i] = boardCell[i].center.x;
        cellY[i] = boardCell[i].center.y;
        
        [self.view addSubview:boardCell[i]];
        
        col = col + 1;
        firstColor = 1 - firstColor;
        if(col>7){
            row = row + 1;
            firstColor = 1-firstColor;
            col=0;
        }
        boardCell[i].userInteractionEnabled = YES;
        boardCell[i].multipleTouchEnabled = YES;
    }
    
    pawnCell[0] = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"knight"]];  //draw pawns
    pawnCell[1] = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"target"]];
    
    pawnCell[0].frame = CGRectMake(LeftX+cellWidth*col,topY+cellWidth*row, cellWidth, cellWidth);
    col = col+1;
    pawnCell[1].frame = CGRectMake(LeftX+cellWidth*col,topY+cellWidth*row, cellWidth, cellWidth);
    
    
    [self.view addSubview:pawnCell[0]];
    [self.view addSubview:pawnCell[1]];
    
    pawnCell[0].userInteractionEnabled=YES;
    pawnCell[0].multipleTouchEnabled = YES;
    pawnCell[1].userInteractionEnabled=YES;
    pawnCell[1].multipleTouchEnabled=YES;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button addTarget:self
               action:@selector(calculateButton:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Calculate" forState:UIControlStateNormal];
    col = col+1;
    row = row +1;
    button.frame = CGRectMake(LeftX+cellWidth*col,topY+cellWidth*row, 160.0, 40.0);
    [self.view addSubview:button];
}


@end
