//
//  TOCropCustomBottomView.h
//  CropViewController
//
//  Created by LION KING on 2024/6/16.
//  Copyright © 2024 Tim Oliver. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOCropCustomBottomView : UIView

@property (nonatomic, copy) void (^doneCallback)(void);
@property (nonatomic, copy) void (^rotateCallback)(void);
@property (nonatomic, copy) void (^adFreeCallback)(void);
@property (nonatomic, copy) void (^aspectRatioCallback)(float width, float height);

- (void)updateAdFree: (BOOL)showAdFree;
- (void)updateTranslates:(NSDictionary<NSString *, NSString *> *)translates;
- (void)updateShowAspectRatioBar: (BOOL)showAspectRatioBar;

@end

NS_ASSUME_NONNULL_END
