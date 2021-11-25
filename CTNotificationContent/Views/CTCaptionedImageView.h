#import <UIKit/UIKit.h>

@interface CTCaptionedImageView : UIView

@property(nonatomic, strong, nullable, readonly) NSString *actionUrl;
@property (nonatomic, strong, nullable) UIImageView *imageView;
@property (nonatomic, strong, nullable) UIButton *nextButton;
@property (nonatomic, strong, nullable) UIButton *previousButton;

+ (CGFloat)captionHeight;

- (instancetype _Nonnull)initWithFrame:(CGRect)frame
                               caption:(NSString * _Nullable)caption
                            subcaption:(NSString * _Nullable)subcaption
                              imageUrl:(NSString * _Nonnull)imageUrl
                             actionUrl:(NSString * _Nullable)actionUrl;

@end
