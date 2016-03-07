//
//  ForeignerMeViewController.m
//  TalKNic
//
//  Created by ldy on 15/11/27.
//  Copyright © 2015年 TalKNic. All rights reserved.
//

#import "ForeignerMeViewController.h"
#import "ForeignerMe.h"
#import "ForeignerBalanceViewController.h"
#import "CreditCardViewController.h"
#import "ForeignerHistoryViewController.h"
#import "ForeignerAboutViewController.h"
#import "SettingViewController.h"
#import "AppDelegate.h"
#import "AppDelegate+ShareSDK.h"
#import <MessageUI/MessageUI.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDKUI.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import <ShareSDKExtension/SSEThirdPartyLoginHelper.h>
#import "MeHeadViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

#import "AFNetworking.h"
#import "MBProgressHUD+MJ.h"
#import "solveJsonData.h"
#import "Header.h"
#import "BalanceViewController.h"
@interface ForeignerMeViewController ()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,MeImageCropperDelegate,UIPickerViewAccessibilityDelegate,UINavigationControllerDelegate,UITextViewDelegate>
{
    NSArray *_allMesetup;
    BOOL btnstare;
    UITextView * _nameText;
    UITextView * _topText;

    NSDictionary *dic;
    NSDictionary *dica;
}
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)UIButton *rightItem;
@property (nonatomic,strong)UIImageView *imageViewBar;
@property (nonatomic,strong)UIImageView *photoView;

@property (nonatomic,strong)UILabel *nameLabel;
@property (nonatomic,strong)UILabel *countries;

@property (nonatomic,strong)UIButton *editBtn;
@property (nonatomic,strong)UILabel *about;

@property (nonatomic,strong)UIButton *feedsBtn;
@property (nonatomic,strong)UIButton *followedBtn;
@property (nonatomic,strong)UIButton *followingBtn;

@property (nonatomic,strong)UILabel *feeds1Label;
@property (nonatomic,strong)UILabel *followed1Label;
@property (nonatomic,strong)UILabel *following1Label;

@property (nonatomic,strong)UILabel *feeds2Label;
@property (nonatomic,strong)UILabel *followed2Label;
@property (nonatomic,strong)UILabel *following2Label;

@property (nonatomic)BOOL isClickFeeds;
@property (nonatomic)BOOL isClickFollowed;
@property (nonatomic)BOOL isClickFollowing;
@property (nonatomic,strong)NSArray *fsearchArr;
@property (nonatomic,strong)UIView *backview;
@property (nonatomic,copy)NSString *city;
@property (nonatomic,copy)NSString *nationality;
@end

@implementation ForeignerMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    
    title.text = @"Me";
    
    title.textAlignment = NSTextAlignmentCenter;
    
    title.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    title.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:17.0];
    
    self.navigationItem.titleView = title;
    
    UIImageView *imageViewH = [[UIImageView alloc]init];
    imageViewH.frame = kCGRectMake(0, 64, 375, 2);
    imageViewH.image = [UIImage imageNamed:@"me_line_bold_long.png"];
    [self.view addSubview:imageViewH];
    
    [self Setupthe];
    
    [self LayoutProfile];
    
    [self TopBarView];
    
    [self TableView];
    
    [self layoutClickBtn];
    
    [self loadId];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
}
-(void)loadId
{
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    NSData *usData = [userD objectForKey:@"ccUID"];
    NSString *idU = [[NSString alloc]initWithData:usData encoding:NSUTF8StringEncoding];
    _uid = idU;
    
    TalkLog(@"DATA -- %@  userD ---  %@",usData,userD);
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSMutableDictionary *parme = [NSMutableDictionary dictionary];
    parme[@"cmd"] = @"19";
    parme[@"user_id"] = _uid;
    TalkLog(@"个人中心ID -- %@",_uid);
    [session POST:PATH_GET_LOGIN parameters:parme progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TalkLog(@"个人中心 -- %@",responseObject);
        dic = [solveJsonData changeType:responseObject];
        
        if (([(NSNumber *)[dic objectForKey:@"code"] intValue] == 2)) {
            NSDictionary *dict = [dic objectForKey:@"result"];
            _city = [NSString stringWithFormat:@"%@",[dict objectForKey:@"city"]];
            _nationality = [NSString stringWithFormat:@",%@",[dict objectForKey:@"nationality"]];
            _nameLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"username"]];
            _countries.text = [_city stringByAppendingString:_nationality];
            _followed1Label.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"fans"]];
            _following1Label.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"praise"]];
            NSURL *url =[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"pic"]]];
            [self.photoView sd_setImageWithURL:url placeholderImage:nil];
            
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

#pragma mark - 图片剪辑
////图片裁剪
//-(UIImage *)getImageFromImage:(UIImage*) superImage subImageSize:(CGSize)subImageSize subImageRect:(CGRect)subImageRect {
//    // CGSize subImageSize = CGSizeMake(WIDTH, HEIGHT); //定义裁剪的区域相对于原图片的位置
//    // CGRect subImageRect = CGRectMake(START_X, START_Y, WIDTH, HEIGHT);
//    CGImageRef imageRef = superImage.CGImage;
//    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, subImageRect);
//    UIGraphicsBeginImageContext(subImageSize);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextDrawImage(context, subImageRect, subImageRef);
//    UIImage* returnImage = [UIImage imageWithCGImage:subImageRef];
//    UIGraphicsEndImageContext(); //返回裁剪的部分图像
//    return returnImage;
//}
-(void)layoutClickBtn
{
    self.isClickFeeds = NO;
    self.isClickFollowed = NO;
    self.isClickFollowing = NO;
    
    
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageViewBar.frame), kWidth, kHeight - CGRectGetMaxY(self.imageViewBar.frame))];
    [backView setBackgroundColor:[UIColor grayColor]];
    backView.alpha = 0.4;
    [[[UIApplication sharedApplication].windows lastObject]addSubview:backView];
    self.backview = backView;
    self.backview.hidden = YES;
    [[[UIApplication sharedApplication].windows lastObject]addSubview:self.FsearchBarView];
    self.FsearchBarView.hidden = YES;
    self.FsearchBarView.center = CGPointMake(kWidth / 2, CGRectGetMaxY(self.imageViewBar.frame) + self.FsearchBarView.height /2) ;
    self.FsearchBarView.backgroundColor = [UIColor clearColor];
    self.fsearchTable.delegate = self;
    self.fsearchTable.dataSource = self;

}
-(void)Setupthe
{
    
    self.rightItem = [[UIButton alloc]init];
    _rightItem.frame = kCGRectMake(0, 0, 41/2, 42/2);
    [_rightItem setBackgroundImage:[UIImage imageNamed:@"me_setting_icon.png"] forState:(UIControlStateNormal)];
    [_rightItem addTarget:self action:@selector(setuptheAction) forControlEvents:(UIControlEventTouchUpInside)];
    UIBarButtonItem *right =[[UIBarButtonItem alloc]initWithCustomView:_rightItem];
    self.navigationItem.rightBarButtonItem = right;
    
}
-(void)LayoutProfile
{
    self.imageViewBar = [[UIImageView alloc]init];
    _imageViewBar.frame = kCGRectMake(0, 66, 375, 191.5);
    _imageViewBar.image = [UIImage imageNamed:@"me_top_bar.png"];
    _imageViewBar.userInteractionEnabled = YES;
    [self.view addSubview:_imageViewBar];
}
-(void)TopBarView
{
    self.photoView = [[UIImageView alloc]init];
    _photoView.frame = kCGRectMake(15, 30, 82.5, 82.5);
    _photoView.image = [UIImage imageNamed:@"me_avatar_area.png"];
    UITapGestureRecognizer *portraitTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editPortrait:)];
    _photoView.layer.cornerRadius = _photoView.frame.size.width /2;
    _photoView.layer.masksToBounds = YES;
    _photoView.userInteractionEnabled = YES;
    [_photoView addGestureRecognizer:portraitTap];
    [_imageViewBar addSubview:_photoView];
    
    
    self.nameLabel = [[UILabel alloc]init];
    _nameLabel.frame = kCGRectMake(112.5, 10, 150, 25);
//    _nameLabel.text = @"Elishia Raskin";
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.numberOfLines = 0;
    _nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:14.0];
    [_imageViewBar addSubview:_nameLabel];
    
    self.countries = [[UILabel alloc]init];
    _countries.frame = kCGRectMake(112.5, 27, 150, 25);
//    _countries.text = @"California,USA";
    _countries.textColor = [UIColor whiteColor];
    _countries.numberOfLines = 0;
    _countries.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0];
    [_imageViewBar addSubview:_countries];
    
    self.editBtn = [[UIButton alloc]init];
    _editBtn.frame = kCGRectMake(112.5, 52.5, 210.5, 36.5);
#warning 修改7开始处
    //    [_editBtn setBackgroundImage:[UIImage imageNamed:@"me_profile_btn.png"] forState:(UIControlStateNormal)];
    //    [_editBtn setBackgroundImage:[UIImage imageNamed:@"me_profile_btn_a.png"] forState:(UIControlStateHighlighted)];
    //    [_editBtn setTitle:@"Edit your profile" forState:(UIControlStateNormal)];
    //    _editBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:12.0];
    //    [_editBtn setTitleColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0] forState:(UIControlStateNormal)];
    
    [_editBtn setTitle:@"Edit your profile" forState:(UIControlStateNormal)];
    _editBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:12.0f];
    [_editBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
#warning 修改7 结束处
    [_editBtn addTarget:self action:@selector(editprofileAction) forControlEvents:(UIControlEventTouchUpInside)];
    [_imageViewBar addSubview:_editBtn];
    
    self.about = [[UILabel alloc]init];
    _about.frame = kCGRectMake(112.5, 95, 232.5, 38);
//    _about.text = @"Live in Los Angeles for 2 years! Now I am in Shanghai. Funny, Chatting, make friends with you guys!\nThanks for following me, hoping you will have a good life.";
    _about.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9.0];
    _about.textColor = [UIColor whiteColor];
    _about.numberOfLines = 0;
    _about.textAlignment = NSTextAlignmentLeft;
    [_imageViewBar addSubview:_about];
    
    
    
    UIImageView *horizontalLine = [[UIImageView alloc]init];
    horizontalLine.frame = kCGRectMake(30, 165/2 +60, 315, 1);
    horizontalLine.image = [UIImage imageNamed:@"me_line_center_long.png"];
    [_imageViewBar addSubview:horizontalLine];
    
    //选项卡1
    self.feeds1Label = [[UILabel alloc]initWithFrame:kCGRectMake(39, 165/2+72, 40, 20)];
    _feeds1Label.text = @"0";
    _feeds1Label.textColor = [UIColor whiteColor];
    _feeds1Label.textAlignment = NSTextAlignmentCenter;
    _feeds2Label.numberOfLines = 0;
    _feeds1Label.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:14.0];
    [_imageViewBar addSubview:_feeds1Label];
    self.feeds2Label = [[UILabel alloc]initWithFrame:kCGRectMake(35, 165/2+86, 50, 20)];
    _feeds2Label.text = @"Feeds";
    _feeds2Label.textColor = [UIColor whiteColor];
    _feeds2Label.textAlignment = NSTextAlignmentCenter;
    _feeds2Label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0];
    [_imageViewBar addSubview:_feeds2Label];
    
    self.feedsBtn = [[UIButton alloc]initWithFrame:kCGRectMake(35, 165/2+72, 50, 35)];
    _feedsBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.00001];
    //    _feedsBtn.imageEdgeInsets = UIEdgeInsetsMake(32, 0, 2, 0);
    
    [_feedsBtn addTarget:self action:@selector(optionsAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [_imageViewBar addSubview:_feedsBtn];
    
    //选项卡2
    self.followed1Label = [[UILabel alloc]initWithFrame:kCGRectMake(165, 165/2+72, 40, 20)];
//    _followed1Label.text = @"52";
    _followed1Label.textAlignment = NSTextAlignmentCenter;
    _followed1Label.numberOfLines = 0;
    _followed1Label.textColor = [UIColor whiteColor];
    _followed1Label.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:14.0];
    [_imageViewBar addSubview:_followed1Label];
    self.followed2Label = [[UILabel alloc]initWithFrame:kCGRectMake(161, 165/2+86, 50, 20)];
    _followed2Label.text = @"Followed";
    _followed2Label.textAlignment = NSTextAlignmentCenter;
    _followed2Label.textColor = [UIColor whiteColor];
    _followed2Label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0];
    _followed2Label.numberOfLines = 0;
    [_imageViewBar addSubview:_followed2Label];
    
    self.followedBtn = [[UIButton alloc]initWithFrame:kCGRectMake(161, 165/2 +72, 50, 35)];
    _followedBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.00001];
    [_followedBtn addTarget:self action:@selector(optionsAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [_imageViewBar addSubview:_followedBtn];
    
    //选项卡3
    self.following1Label = [[UILabel alloc]initWithFrame:kCGRectMake(296, 165/2+72, 40, 20)];
//    _following1Label.text = @"76";
    _following1Label.textAlignment = NSTextAlignmentCenter;
    _following1Label.numberOfLines = 0;
    _following1Label.textColor = [UIColor whiteColor];
    _following1Label.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:14.0];
    [_imageViewBar addSubview:_following1Label];
    self.following2Label = [[UILabel alloc]initWithFrame:kCGRectMake(292, 165/2+86, 50, 20)];
    _following2Label.text = @"Following";
    _following2Label.textAlignment = NSTextAlignmentCenter;
    _following2Label.textColor = [UIColor whiteColor];
    _following2Label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0];
    _following2Label.numberOfLines = 0;
    [_imageViewBar addSubview:_following2Label];
    self.followingBtn = [[UIButton alloc]initWithFrame:kCGRectMake(292, 165/2+72, 50, 35)];
    [_followingBtn addTarget:self action:@selector(optionsAction:) forControlEvents:(UIControlEventTouchUpInside)];
    _followingBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.00001];
    [_imageViewBar addSubview:_followingBtn];
    
    
}
-(void)TableView
{
    self.tableView = [[UITableView alloc]initWithFrame: kCGRectMake(0, 477/2.2+65, 375, 667-477/2.2-50) style:(UITableViewStyleGrouped)];
    _tableView.dataSource =self;
    _tableView.delegate = self;
    [_tableView setScrollEnabled:NO];
    [self.view addSubview:_tableView];
    
    _allMesetup =@[[ForeignerMe mesetupWithHeader:@"Payment" group:@[@"Balance",@"Credit Card",@"History",]],
                   [ForeignerMe mesetupWithHeader:@"General" group:@[@"Invite Friends",@"About"]]];
    
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        return _allMesetup.count;

    }else
    {
        return 1;
    }
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        ForeignerMe *mesetup = _allMesetup[section];
        return  mesetup.grouping.count;

    }else
    {
        return self.fsearchArr.count;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:nil];
    
    if (tableView == self.tableView) {
        ForeignerMe *mesetup = _allMesetup[indexPath.section];
        cell.textLabel.text = mesetup.grouping[indexPath.row];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
        cell.textLabel.textColor = [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0];
        NSArray *arr = @[@[@"me_balance_icon.png",@"me_card_icon.png",@"me_history_icon.png"],@[@"me_invite_icon.png",@"me_about_icon.png"]];
        cell.imageView.image = [UIImage imageNamed:arr[indexPath.section][indexPath.row]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }else
    {
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section ==0) {
        UILabel *label = [[UILabel alloc]init];
        label.frame = kCGRectMake(10, 3, 100, 15);
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
        label.textColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0];
        label.text = @"   Payment";
        return label;
    }else
    {
        UILabel *label = [[UILabel alloc]init];
        label.frame = kCGRectMake(10, 3, 100, 15);
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
        label.textColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0];
        label.text = @"   General";
        return label;
        
    }
}
-(void)setuptheAction
{
    SettingViewController *setVC = [[SettingViewController alloc]init];
    [self.navigationController pushViewController:setVC animated:NO];
}
-(void)editprofileAction
{
    if (btnstare) {
        [self.editBtn setTitle:@"Edit your profile" forState:(UIControlStateNormal)];
        self.nameLabel.hidden=NO;
        self.about.hidden = NO;
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        NSMutableDictionary *dicc = [NSMutableDictionary dictionary];
        dicc[@"cmd"] = @"21";
        dicc[@"user_id"] = _uid;
        if (![_nameText.text isEqualToString:@""]) {
            dicc[@"username"] = _nameText.text;
        }
        if (![_topText.text isEqualToString:@""]) {
            dicc[@"biography"] = _topText.text;
        }
        
        TalkLog(@"修改资料参数 -- %@",_uid);
        
        [manager POST:PATH_GET_LOGIN parameters:dicc progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            TalkLog(@"修改资料 -- %@",responseObject);
            
            dica = [solveJsonData changeType:responseObject];
            if (([(NSNumber *)[dica objectForKey:@"code"]intValue] == 2)) {
                if (![_nameText.text isEqualToString:@""]) {
                    _nameLabel.text = _nameText.text;
                }
                if (![_topText.text isEqualToString:@""]) {
                    _about.text = _topText.text;
                }
                _nameText.hidden = YES;
                _topText.hidden = YES;
                [MBProgressHUD showSuccess:kAlertdataSuccess];
                
            }else
            {
                [MBProgressHUD showError:kAlertdataFailure];
                return ;
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            TalkLog(@"修改资料失败 -- %@",error);
        }];
        
        
        
        NSLog(@"DOne");
    }else
    {
        [self.editBtn setTitle:@"Done" forState:(UIControlStateNormal)];
        self.nameLabel.hidden = YES;
        self.about.hidden = YES;
        _nameText = [[UITextView alloc]initWithFrame:kCGRectMake(112.5, 10, 150, 25)];
        _nameText.delegate = self;       //设置代理方法的实现类
        _nameText.font=[UIFont fontWithName:@"HelveticaNeue-Regular" size:14.0];
        _nameText.keyboardType = UIKeyboardTypeDefault;
        _nameText.textAlignment = NSTextAlignmentLeft;
        _nameText.alpha = 0.5;
        _nameText.backgroundColor = [UIColor colorWithWhite:1.f alpha:1];
        
        [_imageViewBar addSubview:_nameText];
        _topText = [[UITextView alloc]initWithFrame:kCGRectMake(112.5, 95, 232.5, 38)];
        _topText.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
        _topText.delegate = self;
        _topText.alpha = 0.5;
        _topText.backgroundColor = [UIColor colorWithWhite:1.f alpha:1];
        _topText.textAlignment = NSTextAlignmentLeft;
        [_imageViewBar addSubview:_topText];
        NSLog(@"Edit");
    }
    btnstare = !btnstare;
}

-(void)optionsAction:(id)sender
{
    self.FsearchBarView.hidden = NO;
    self.backview.hidden = NO;
    if (sender == self.feedsBtn) {
        self.isClickFeeds = !self.isClickFeeds;
        self.isClickFollowed = NO;
        self.isClickFollowing = NO;
        _feedsBtn.imageEdgeInsets = UIEdgeInsetsMake(32, 0, 2, 0);
        _feedsBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.00001];
        [_feedsBtn setImage:[UIImage imageNamed:@"me_feeditem_line.png"] forState:(UIControlStateNormal)];
        [_followedBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [_followingBtn setImage:[UIImage imageNamed:@""] forState:(UIControlStateNormal)];
        [self.fimageview setImage:[UIImage imageNamed:@"me_feeds_tab_bg.png"]];
        
    }else if (sender == self.followedBtn)
    {
        self.isClickFeeds = NO;
        self.isClickFollowed = !self.isClickFollowed;
        self.isClickFollowing = NO;
        _followedBtn.imageEdgeInsets = UIEdgeInsetsMake(32, 0, 2, 0);
        [_followedBtn setImage:[UIImage imageNamed:@"me_feeditem_line.png"] forState:(UIControlStateNormal)];
        [_feedsBtn setImage:[UIImage imageNamed:@""] forState:(UIControlStateNormal)];
        [_followingBtn setImage:[UIImage imageNamed:@""] forState:(UIControlStateNormal)];
        [self.fimageview setImage:[UIImage imageNamed:@"me_followed_bg.png"]];
    }else
    {
        self.isClickFeeds = NO;
        self.isClickFollowed = NO;
        self.isClickFollowing = !self.isClickFollowing;
        _followingBtn.imageEdgeInsets = UIEdgeInsetsMake(32, 0, 2, 0);
        [_followingBtn setImage:[UIImage imageNamed:@"me_feeditem_line.png"] forState:(UIControlStateNormal)];
        [_feedsBtn setImage:[UIImage imageNamed:@""] forState:(UIControlStateNormal)];
        [_followedBtn setImage:[UIImage imageNamed:@""] forState:(UIControlStateNormal)];
        [self.fimageview setImage:[UIImage imageNamed:@"me_following_tab_bg.png"]];
    }
    if (!self.isClickFeeds && !self.isClickFollowed && !self.isClickFollowing) {
        [self.view resignFirstResponder];
        self.FsearchBarView.hidden = YES;
        self.backview.hidden = YES;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.textLabel.text isEqualToString:@"Balance"]) {
        BalanceViewController *balanceVC = [[BalanceViewController alloc]init];
        [self.navigationController pushViewController:balanceVC animated:NO];
    }
    if ([cell.textLabel.text isEqualToString:@"Credit Card"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chinese" bundle:nil];
        CreditCardViewController *creditVC = [storyboard instantiateViewControllerWithIdentifier:@"creditCard"];
        creditVC.uid = _uid;
        [self.navigationController pushViewController:creditVC animated:NO];    }
    if ([cell.textLabel.text isEqualToString:@"History"]) {
        ForeignerHistoryViewController *historyVC = [[ForeignerHistoryViewController alloc]init];
        [self.navigationController pushViewController:historyVC animated:NO];
    }
    if ([cell.textLabel.text isEqualToString:@"Invite Friends"]) {
        
        AppDelegate *delegate = [[AppDelegate alloc]init];
        [delegate platShareView:self.view WithShareContent:@"Talknic直说" WithShareUrlImg:@"http://pic2.ooopic.com/01/03/51/25b1OOOPIC19.jpg" WithShareTitle:@"Talknic直说" WithShareUrl:@"http://talknic.cn" WithShareType:shareInfo];
    }
       if ([cell.textLabel.text isEqualToString:@"About"]) {
        ForeignerAboutViewController *aboutVC= [[ForeignerAboutViewController alloc]init];
        [self.navigationController pushViewController:aboutVC animated:NO];
    }
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    @property (nonatomic,strong)UILabel *nameLabel;
//    @property (nonatomic,strong)UILabel *countries;
//    
//    @property (nonatomic,strong)UIButton *editBtn;
//    @property (nonatomic,strong)UILabel *about;
//    
//    @property (nonatomic,strong)UIButton *feedsBtn;
//    @property (nonatomic,strong)UIButton *followedBtn;
//    @property (nonatomic,strong)UIButton *followingBtn;
//    
//    @property (nonatomic,strong)UILabel *feeds1Label;
//    @property (nonatomic,strong)UILabel *followed1Label;
//    @property (nonatomic,strong)UILabel *following1Label;
//    
//    @property (nonatomic,strong)UILabel *feeds2Label;
//    @property (nonatomic,strong)UILabel *followed2Label;
//    @property (nonatomic,strong)UILabel *following2Label;
    self.FsearchBarView.hidden = YES;
    self.backview.hidden = YES;
    [_topText resignFirstResponder];
    [_nameText resignFirstResponder];
    [_followed1Label resignFirstResponder];
    [_following1Label resignFirstResponder];
    [_nameLabel resignFirstResponder];
    [_countries resignFirstResponder];
    [_editBtn resignFirstResponder];
    [_about resignFirstResponder];
    [_feedsBtn resignFirstResponder];
    [_followedBtn resignFirstResponder];
    [_followingBtn resignFirstResponder];
    [_feeds1Label resignFirstResponder];
    [_feeds2Label resignFirstResponder];
    [_followed2Label resignFirstResponder];
    [_following2Label resignFirstResponder];
    [_tableView resignFirstResponder];
    [_imageViewBar resignFirstResponder];
    self.isClickFeeds = NO;
    self.isClickFollowed = NO;
    self.isClickFollowing = NO;
    [self.view resignFirstResponder];
    [self.FsearchBarView resignFirstResponder];
    [self.fsearchTable resignFirstResponder];
    [self.fsearchBar resignFirstResponder];
}


//头像点击方法
-(void)editPortrait:(UITapGestureRecognizer *)tap
{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:kAlertOurceFile delegate:self cancelButtonTitle:kAlertCancel destructiveButtonTitle:nil otherButtonTitles:kAlertCamera,kAlertLocal, nil];
    [actionSheet showInView:self.view];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    TalkLog(@"buttonIndex = [%ld]",(long)buttonIndex);
    switch (buttonIndex) {
        case 0://照相机
            
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
            
            break;
        case 1://本地相册
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:imagePicker animated:YES completion:nil];
            
        }
            break;
        default:
            break;
    }
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    if ([[info objectForKey:UIImagePickerControllerMediaType]isEqualToString:(__bridge NSString *)kUTTypeImage]) {
        UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
        [self performSelector:@selector(saveImage:) withObject:img afterDelay:0.5];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)saveImage:(UIImage *)image
{
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imageFilePath = [documentsDirectory stringByAppendingPathComponent:@"selfPhoto.jpg"];
    success  = [fileManager fileExistsAtPath:imageFilePath];
    if (success) {
        success = [fileManager removeItemAtPath:imageFilePath error:&error];
    }
    UIImage *smallImage = [self thumbnailWithImageWithoutScale:image size:CGSizeMake(80, 80)];
    [UIImageJPEGRepresentation(smallImage, 1.0f) writeToFile:imageFilePath atomically:YES];
    UIImage *selfPhoto = [UIImage imageWithContentsOfFile:imageFilePath];
    self.photoView.image = selfPhoto;
    
    [self shangchuan];
}
-(void)shangchuan
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat =@"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg",str];
    UIImage *image = _photoView.image;
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"cmd"] = @"6";
    param[@"user_id"] = _uid;
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer = [AFHTTPResponseSerializer serializer];
    [session.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil]];
    [session POST:PATH_GET_LOGIN parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *data = UIImageJPEGRepresentation(image, 0.5);
        NSLog(@"%@",data);
        [formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:@"image/jpeg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *str =[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        TalkLog(@"asdasd ---- %@",str);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}
//改变图像的尺寸，方便上传服务器
-(UIImage *)scaleFromImage:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, 37, 37)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }
    else{
        CGSize oldsize = image.size;
        CGRect rect;
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width);
            rect.origin.y = 0;
        }
        else{
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height);
        }
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end