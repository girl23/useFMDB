//
//  studentDBManager.m
//  FMDBDemo
//
//  Created by wdwk on 16/9/21.
//  Copyright © 2016年 wksc. All rights reserved.
//

#import "studentDBManager.h"
#import "FMDB.h"
static studentDBManager * manager=nil;
@implementation studentDBManager

{
    FMDatabase  * _database;
}
+(instancetype)shareManager
{
    static dispatch_once_t onceTocken;
    dispatch_once(&onceTocken, ^{
        manager=[[studentDBManager alloc]init];
    });
    return manager;
}
-(instancetype)init
{
    if (self=[super init]) {
        // 创建数据库，使用FMDB第三方框架
        // 创建数据库文件保存路径..../Documents/app.sqlite
        // sqlite数据库（轻量级的数据库），它就是一个普通的文件，txt是一样的，只不过其中的文件内容不一样。
        // 注：sqlite文件中定义了你的数据库表、数据内容
        // MySql、Oracle这些大型的数据库，它需要一个管理服务，是一整套的。
        
        NSString * dbPath=[NSString stringWithFormat:@"%@/Documents/app.sqlite",NSHomeDirectory()];
        NSLog(@"%@",dbPath);
        // 创建FMDatabase
        // 如果在目录下没有这个数据库文件，将创建该文件。
        _database=[[FMDatabase alloc]initWithPath:dbPath];
        
        if (_database) {
            if ([_database open]) {
                //创建学生信息表
                NSString * createSql=@"create table if not exists stu(stuid varchar(255),name varchar(255),age varchar(255),headimage binary)";
                // FMDatabase执行sql语句
                // 当数据库文件创建完成时，首先创建数据表，如果没有这个表，就去创建，有了就不创建
                BOOL creatableSucess=[_database executeUpdate:createSql];
                NSLog(@"创建表%d",creatableSucess);
                
    
            }
            else
            {
                NSLog(@"打开数据库失败");
            }
        }
        else
        {
            NSLog(@"创建数据库失败");
        }
    }
    return self;
}
////通过某个字段检查是否存在数据
- (BOOL)isExsitsWithConditionString:(NSString *)conditionStr andConditionValue:(NSString *)conditionValue andtable:(NSString *)table
{
    NSString * querySql = [NSString stringWithFormat:@"select * from %@ where %@='%@'", table,conditionStr,conditionValue];
    
    FMResultSet * set = [_database executeQuery:querySql];
    
    // 判断是否已存在数据
    if ([set next]) {
        return YES;
    }
    else
        return NO;
}
//添加一条数据到数据表中
-(BOOL)addDataWithModel:(Student*)student ConditionString:(NSString *)conditionStr andconditionValue:(NSString *)conditionValue andtable:(NSString * )table
{
    // 如果已存在数据，先删除已有的数据，再添加新数据
    BOOL isExsits = [self isExsitsWithConditionString:conditionStr andConditionValue:conditionValue andtable:table];
    
    if (isExsits) {
        [self deleteDataWithConditionString:conditionStr andconditionValue:conditionValue andtable:table];
    }
    // 添加新数据
    
    NSString * insertSql = [NSString stringWithFormat:@"insert into %@ values (?,?,?,?)",table];
    
    BOOL success = [_database executeUpdate:insertSql,student.stuid ,student.stuname,student.stuage,student.stuheadimage];
    NSLog(@"%d",success);
    return success;
}

//通过某个字段删除一条数据；
-(BOOL)deleteDataWithConditionString:(NSString *)conditionStr andconditionValue:(NSString *)conditionValue andtable:(NSString * )table
{
    //删除之前先判断该数据是否存在；
    BOOL isExsits=[self isExsitsWithConditionString:conditionStr andConditionValue:conditionValue andtable:table];
    if (isExsits) {
        NSString * deleteSql = [NSString stringWithFormat:@"delete from %@ where %@='%@'",table,conditionStr,conditionValue];
        BOOL success=[_database executeUpdate:deleteSql];
        return success;
    }
    else
    {
        NSLog(@"该记录不存在");
        return NO;
    }
    
}
// 删除所有的记录
- (BOOL)deleteAllDataWithtable:(NSString *)table
{
    NSString * deletesql=[NSString stringWithFormat:@"delete  from %@",table];
    
    BOOL success = [_database executeUpdate:deletesql];
    
    return success;

}
//查询一条数据；
//1.查询全部数据，2根据特定字段查询数据；
-(NSArray * )getDataWithconditionString:(NSString * )conditionstr andConditionValue:(NSString *)conditionValue allData:(BOOL)isAllData andTable:(NSString *)table
{
   
    NSString * getSql;
    if (isAllData) {
         getSql =[NSString stringWithFormat:@"select * from %@",table];
    }
    else
    {
         getSql = [NSString stringWithFormat:@"select * from %@ where %@='%@'",table,conditionstr,conditionValue];
    }
 
    
    // 执行sql
    FMResultSet * set = [_database executeQuery:getSql];
    
    // 循环遍历取出数据
    NSMutableArray * array = [[NSMutableArray alloc] init];
    while ([set next]) {
        Student * model = [[Student alloc] init];
        // 从结果集中获取数据
        // 注：sqlite数据库不区别分大小写
        model.stuid = [set stringForColumn:@"stuid"];
        model.stuname= [set stringForColumn:@"name"];
        model.stuage=[set stringForColumn:@"age"];
        model.stuheadimage=[set dataForColumn:@"headimage"];
        [array addObject:model];
    }
    //备注：stuheadimage的使用，   UIImage * image=[UIImage imageWithData:imageData];
    return array;

}
//修改某条数据
-(BOOL)updateDataWithString:(NSString*)NewStr andNewStrValue:(id)NewStrValue  andConditionStr:(NSString*)conditionStr andConditionValue:(NSString*)conditionValue andTable:(NSString*)table
{
    NSString * updateSql=[NSString stringWithFormat:@"UPDATE %@ SET %@='%@' WHERE %@='%@';",table,NewStr,NewStrValue,conditionStr,conditionValue];
    BOOL success= [_database executeUpdate:updateSql];
    
    return success;
}
@end
