//
//  TOCropCustomBottomView.m
//  CropViewController
//
//  Created by LION KING on 2024/6/16.
//  Copyright © 2024 Tim Oliver. All rights reserved.
//
#import "TOCropCustomBottomView.h"

@interface TOCropCustomBottomView() <UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *customView;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UILabel *underlineLabel;
@property (nonatomic, strong) UIImageView *adIcon;
@property (nonatomic, strong) UIButton *rotationBtn;

@property (nonatomic, strong) NSArray* aspectRatios;
@property (nonatomic, assign) int curIndex;
@property (nonatomic, assign) bool showAdFree;
@property (nonatomic, assign) bool showAspectRatioBar;

@end

@implementation TOCropCustomBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor colorWithWhite:0.12f alpha:1.0f];
    
    UIButton *rotationBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - 40  - 10, 0, 40, 40)];
    if (@available(iOS 13.0, *)) {
        UIImage *rotationImage = [[UIImage systemImageNamed:@"rotate.right"] imageWithTintColor:[UIColor whiteColor] renderingMode:UIImageRenderingModeAlwaysOriginal];
        [rotationBtn setImage:rotationImage forState:UIControlStateNormal];
        rotationBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent: 0.7];
        rotationBtn.layer.cornerRadius = 10;
        rotationBtn.layer.masksToBounds = YES;
    } else {
        [rotationBtn setTitle:@"rotate" forState:UIControlStateNormal];
    }
    [rotationBtn addTarget:self action:@selector(onClickRotation) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:rotationBtn];
    self.rotationBtn = rotationBtn;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 50, self.bounds.size.width, 50) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = false;
    self.collectionView.showsVerticalScrollIndicator = false;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.contentInset = UIEdgeInsetsZero;
    [self addSubview:self.collectionView];
    
    self.aspectRatios = @[@"3:4", @"4:3", @"1:1", @"4:5", @"5:4", @"9:16", @"16:9"];
    
    // 创建按钮
    self.actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.actionButton.frame = CGRectMake(self.bounds.size.width/4, self.frame.size.height - 50 - 30 - 20, self.bounds.size.width/2, 50);
    self.actionButton.backgroundColor = [UIColor whiteColor];
    self.actionButton.layer.cornerRadius = 15;
    [self.actionButton addTarget:self action:@selector(doneButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.actionButton];
    [self addCustomView:@"Try It"];
    
    // 添加带下划线的文字
    UILabel *underlineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.actionButton.frame) + 20, self.bounds.size.width, 30)];
    underlineLabel.text = @"Ad-Free Creation";
    underlineLabel.textColor = [UIColor whiteColor];
    underlineLabel.font = [UIFont systemFontOfSize:16];
    underlineLabel.textAlignment = NSTextAlignmentCenter;
    underlineLabel.userInteractionEnabled = YES;
    underlineLabel.hidden = true;
    // 启用用户交互
    // 创建带下划线的属性字符串
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:underlineLabel.text];
    [attributedText addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, underlineLabel.text.length)];
    underlineLabel.attributedText = attributedText;
    // 添加点击手势识别器
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(underlineLabelTapped)];
    [underlineLabel addGestureRecognizer:tapGesture];
    self.underlineLabel = underlineLabel;
    [self addSubview:underlineLabel];
}

- (void)updateAdFree: (BOOL)showAdFree {
    self.underlineLabel.hidden = !showAdFree;
    self.showAdFree = showAdFree;
    self.adIcon.hidden = !showAdFree;
}

- (void)updateTranslates:(NSDictionary<NSString *, NSString *> *)translates {
    NSString *adFreeCreation = translates[@"adFreeCreation"];
    if (adFreeCreation != nil && adFreeCreation.length > 0) {
        self.underlineLabel.text = translates[@"adFreeCreation"];
    }
    NSString *tryIt = translates[@"tryIt"];
    if (tryIt != nil && tryIt.length > 0) {
        [self addCustomView:tryIt];
    }
}

- (void)updateShowAspectRatioBar: (BOOL)showAspectRatioBar {
    self.showAspectRatioBar = showAspectRatioBar;
    self.collectionView.hidden = !showAspectRatioBar;
    self.rotationBtn.hidden = !showAspectRatioBar;
    self.actionButton.frame = CGRectMake(self.bounds.size.width/4, self.frame.size.height - 50 - 30 - 20, self.bounds.size.width/2, 50);
    self.underlineLabel.frame = CGRectMake(0, CGRectGetMaxY(self.actionButton.frame) + 20, self.bounds.size.width, 30);
}

- (void)addCustomView: (NSString *)text {
    if (self.customView != nil) {
        [self.customView removeFromSuperview];
    }
    // 创建自定义视图
    UIView *customView = [[UIView alloc] initWithFrame:self.actionButton.bounds];
    customView.userInteractionEnabled = NO;
    // 创建标签
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = text;
    label.font = [UIFont boldSystemFontOfSize:20];
    label.textColor = [UIColor blackColor];
    [label sizeToFit];
    label.center = CGPointMake(customView.frame.size.width / 2, customView.frame.size.height / 2);
    [customView addSubview:label];
    // 创建图标
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ad_icon"]];
    CGFloat imageWidth = 15;
    imageView.frame = CGRectMake(customView.frame.size.width - imageWidth - 30, (customView.frame.size.height - imageWidth) / 2, imageWidth, imageWidth); // 调整图标的位置和大小
    imageView.hidden = !self.showAdFree;
    self.adIcon = imageView;
    [customView addSubview:imageView];
    
    self.customView = customView;
    // 添加自定义视图到按钮
    [self.actionButton addSubview:customView];
}

- (void)onClickRotation {
    if (self.aspectRatioCallback != nil) {
        self.rotateCallback();
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.aspectRatios.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    // Remove any existing subviews from the cell
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    bool isSelected = (self.curIndex == indexPath.row);
    CGFloat width = [self getItemWidth: (int)indexPath.row];
    CGFloat labelWidth = MAX(width, 35);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, labelWidth, 15)];
    label.text = self.aspectRatios[indexPath.row];
    label.textColor = isSelected ? [UIColor yellowColor] : [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:label];
    
    UIView *ratioView = [[UIView alloc] initWithFrame:CGRectMake((labelWidth - width)/2, 0, width, 30)];
    ratioView.layer.borderColor = isSelected ? [UIColor yellowColor].CGColor : [UIColor whiteColor].CGColor;
    ratioView.layer.borderWidth = 1.0;
    [cell.contentView addSubview:ratioView];
    
    return cell;
}

// UICollectionViewDelegateFlowLayout methods
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = [self getItemWidth:(int)indexPath.row];
    width = MAX(width, 40);
    return CGSizeMake(width, 50);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *aspectRatio = self.aspectRatios[indexPath.row];
    NSArray *components = [aspectRatio componentsSeparatedByString:@":"];
    CGFloat widthRatio = [components[0] floatValue];
    CGFloat heightRatio = [components[1] floatValue];
    self.curIndex = (int)indexPath.row;
    [self.collectionView reloadData];
    if (self.aspectRatioCallback != nil) {
        self.aspectRatioCallback(widthRatio, heightRatio);
    }
}

- (CGFloat)getItemWidth: (int)index {
    NSString *aspectRatio = self.aspectRatios[index];
    NSArray *components = [aspectRatio componentsSeparatedByString:@":"];
    CGFloat widthRatio = [components[0] floatValue];
    CGFloat heightRatio = [components[1] floatValue];
    return 30*widthRatio/heightRatio;
}


- (void)ratioButtonTapped:(UIButton *)sender {
    for (UIView *subview in sender.superview.subviews) {
        if ([subview isKindOfClass:[UIButton class]] && subview != sender) {
            UIButton *button = (UIButton *)subview;
            button.selected = NO;
            button.layer.borderColor = [UIColor yellowColor].CGColor;
        }
    }
    sender.selected = YES;
    sender.layer.borderColor = [UIColor blueColor].CGColor;
}

- (void)doneButtonTapped {
    if (self.doneCallback != nil) {
        self.doneCallback();
    }
}

- (void)underlineLabelTapped {
    if (self.adFreeCallback != nil) {
        self.adFreeCallback();
    }
}
@end
