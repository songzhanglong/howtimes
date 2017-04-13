//
//  CustomerView.m
//  TYSociety
//
//  Created by zhangxs on 16/7/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "CustomerView.h"

@implementation CustomerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [self addSubview:_tableView];
    }
    return self;
}

- (void)resetCustomerDatas:(NSMutableArray *)datas
{
    
}

- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    CGRect butRec = self.frame;
    [UIView animateWithDuration:0.35 animations:^{
        [self setFrame:CGRectMake(butRec.origin.x, butRec.origin.y - butRec.size.height, butRec.size.width, butRec.size.height)];
    }];
}

- (void)hiddenInView
{
    CGRect butRec = self.frame;
    [UIView animateWithDuration:0.35 animations:^{
        [self setFrame:CGRectMake(butRec.origin.x, butRec.origin.y + butRec.size.height, butRec.size.width, butRec.size.height)];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

-(NSString*)pinyinFirstLetter:(NSString *)hanzi
{
    NSString *result = @"";
    NSMutableString *ms = [[NSMutableString alloc] initWithString:hanzi];
    if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformMandarinLatin, NO)) {
    }
    if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformStripDiacritics, NO)){
    }
    if (ms.length>0) {
        result = [ms substringToIndex:1];
    }
    return [result uppercaseString];
}

#pragma- mark UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.dataSource count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self.dataSource objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"AddressBookCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        
        UIImageView *faceImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7.5, 40, 40)];
        [faceImgView setTag:2];
        [faceImgView setImage:CREATE_IMG(@"customer_select_normal")];
        [faceImgView.layer setMasksToBounds:YES];
        [faceImgView.layer setCornerRadius:20];
        [cell.contentView addSubview:faceImgView];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(faceImgView.frameRight + 15, 10, 100, 35)];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setTextColor:CreateColor(100, 100, 100)];
        [nameLabel setFont:[UIFont systemFontOfSize:14]];
        [nameLabel setTag:3];
        [cell.contentView addSubview:nameLabel];
        
        UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frameRight + 10, 10, 120, 35)];
        [phoneLabel setBackgroundColor:[UIColor clearColor]];
        [phoneLabel setTextColor:CreateColor(100, 100, 100)];
        [phoneLabel setFont:[UIFont systemFontOfSize:14]];
        [phoneLabel setTag:4];
        [cell.contentView addSubview:phoneLabel];
    }
    
    PerInforModel *book = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    UIImageView *faceImgView = (UIImageView *)[cell.contentView viewWithTag:2];
    [faceImgView setImage:book.faceImg ?: CREATE_IMG(@"loginLogo")];
    
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:3];
    [nameLabel setText:book.name];
    
    UILabel *phoneLabel = (UILabel *)[cell.contentView viewWithTag:4];
    [phoneLabel setText:book.phone];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    PerInforModel *book = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (_delegate && [_delegate respondsToSelector:@selector(selectPhone:)]) {
        [_delegate selectPhone:book];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    PerInforModel *book = [[self.dataSource objectAtIndex:section] objectAtIndex:0];
    NSString *toFirst = [self pinyinFirstLetter:book.name];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 15)];
    [view setBackgroundColor:CreateColor(229, 222, 255)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH - 30, 15)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:toFirst];
    [label setTextColor:CreateColor(186, 170, 252)];
    [label setFont:[UIFont systemFontOfSize:10]];
    [view addSubview:label];
    return view;
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#"];
}

//响应点击索引时的委托方法
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSInteger count = 0;
    NSArray *array = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#"];
    for(NSString *character in array)
    {
        if([character isEqualToString:title])
        {
            return count;
        }
        count ++;
    }
    return 0;
}

@end
