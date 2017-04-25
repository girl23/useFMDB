//
//  ViewController.m
//  FMDBDemo
//
//  Created by wdwk on 16/9/21.
//  Copyright © 2016年 wksc. All rights reserved.
//

#import "ViewController.h"
#import "Student.h"
#import "studentDBManager.h"
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UITextFieldDelegate>
@property(nonatomic,strong)studentDBManager * manager;
@property(nonatomic,strong)NSMutableArray * datasource;
@property(nonatomic ,strong)  UIAlertView * deleteAlert;
@property(nonatomic ,strong)  UIAlertView * queryAlert;

@end
static int i;
@implementation ViewController
@synthesize deleteAlert,queryAlert;
- (void)viewDidLoad {
    [super viewDidLoad];
    _mytableView.dataSource=self;
    _mytableView.delegate=self;
    _datasource=[NSMutableArray new];
    _manager=[studentDBManager shareManager];//表和数据库同时创建了
    //获取stu表中的所有数据
    
    _datasource=(NSMutableArray*)[_manager getDataWithconditionString:nil andConditionValue:nil allData:YES andTable:@"stu"];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)add:(id)sender {
    //创建一个学生
    Student * stu=[Student new];
    stu.stuid=[NSString stringWithFormat:@"id%d",i];
    stu.stuname=[NSString stringWithFormat:@"name%d",i];
    stu.stuage=[NSString stringWithFormat:@"age%d",i];
    UIImage * image=[UIImage imageNamed:@"1"];
    NSData * imgdata=UIImagePNGRepresentation(image);
    stu.stuheadimage=imgdata;
   
    [_manager addDataWithModel:stu ConditionString:@"stuid" andconditionValue:stu.stuid andtable:@"stu"];
    _datasource=(NSMutableArray*)[_manager getDataWithconditionString:nil andConditionValue:nil allData:YES andTable:@"stu"];
    [_mytableView reloadData];
    i++;
}
- (IBAction)delete:(id)sender {
    deleteAlert=[[UIAlertView alloc]initWithTitle:@"输入删除人的ID" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    deleteAlert.alertViewStyle=UIAlertViewStylePlainTextInput;
    deleteAlert.delegate=self;
   
    [deleteAlert show];
    
}
- (IBAction)deleteAll:(id)sender {
    [_manager deleteAllDataWithtable:@"stu"];
    _datasource=(NSMutableArray*)[_manager getDataWithconditionString:nil andConditionValue:nil allData:YES andTable:@"stu"];
    [_mytableView reloadData];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView==deleteAlert) {
        if (buttonIndex==1) {
           UITextField * textField= [deleteAlert textFieldAtIndex:0];
            
            [_manager deleteDataWithConditionString:@"stuid" andconditionValue:textField.text andtable:@"stu"];
            _datasource=(NSMutableArray*)[_manager getDataWithconditionString:nil andConditionValue:nil allData:YES andTable:@"stu"];
        }
    }
    else if(alertView==queryAlert)
    {
        UITextField * textField= [queryAlert textFieldAtIndex:0];
        
        _datasource=(NSMutableArray*)[_manager getDataWithconditionString:@"stuid" andConditionValue:textField.text allData:NO andTable:@"stu"];
       
    }
    
        [_mytableView reloadData];
}
- (IBAction)query:(id)sender {
    queryAlert=[[UIAlertView alloc]initWithTitle:@"输入查询的ID" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    queryAlert.alertViewStyle=UIAlertViewStylePlainTextInput;
    queryAlert.delegate=self;
    
    [queryAlert show];
    
}
- (IBAction)update:(id)sender {
  
    [_manager updateDataWithString:@"name" andNewStrValue:_nameTextField.text andConditionStr:@"stuid" andConditionValue:_idTextField.text andTable:@"stu"];
    if (_datasource.count>0) {
        [_datasource removeAllObjects];
    }
    
    _datasource=(NSMutableArray*)[_manager getDataWithconditionString:nil andConditionValue:nil allData:YES andTable:@"stu"];
    
    [_mytableView reloadData];
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datasource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identify=@"cell";
    UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:identify];
    
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify  ];
    }
    Student * model=_datasource[indexPath.row];
    cell.textLabel.text=[NSString stringWithFormat:@"%@==%@==%@",model.stuid,model.stuname,model.stuage];
    cell.imageView.image=[UIImage imageWithData:model.stuheadimage];
    return cell;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_idTextField resignFirstResponder];
    [_nameTextField resignFirstResponder];
}


- (IBAction)risignKeyBoard:(id)sender {
    [_idTextField resignFirstResponder];
    [_nameTextField resignFirstResponder];
}

@end
