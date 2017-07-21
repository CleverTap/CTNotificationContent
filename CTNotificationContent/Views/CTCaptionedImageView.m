
#import "CTCaptionedImageView.h"
#import "UIImage+CTImage.h"

static const float kCaptionHeight = 25.f;
static const float kSubCaptionHeight = 20.f;
static const float kBottomPadding = 5.f;
static float captionHeight = 0.f;

@interface CTCaptionedImageView ()

@property (nonatomic, strong, nullable, readwrite) NSString *actionUrl;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *subcaption;
@property (nonatomic, strong) NSString *imageUrl;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) UILabel *subcaptionLabel;

@end

@implementation CTCaptionedImageView

+ (CGFloat)captionHeight {
    if (captionHeight <= 0) {
        captionHeight = kCaptionHeight+kSubCaptionHeight+kBottomPadding;
    }
    return captionHeight;
}

- (instancetype _Nonnull)initWithFrame:(CGRect)frame
                               caption:(NSString * _Nullable)caption
                               subcaption:(NSString * _Nullable)subcaption
                              imageUrl:(NSString * _Nonnull)imageUrl
                             actionUrl:(NSString * _Nullable)actionUrl {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.imageUrl = imageUrl;
        self.caption = caption;
        self.subcaption = subcaption;
        self.actionUrl = actionUrl;
        [self setup];
    }
    return self;
}

- (void)setup {
    CGFloat viewWidth = self.frame.size.width;
    CGFloat viewHeight = self.frame.size.height;
    CGSize imageViewSize = CGSizeMake(viewWidth, viewHeight-([[self class] captionHeight]));
   
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, imageViewSize.width, imageViewSize.height)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.imageView];
    [self loadImage];
    
    self.captionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, imageViewSize.height,viewWidth, kCaptionHeight)];
    self.captionLabel.textAlignment = NSTextAlignmentLeft;
    self.captionLabel.adjustsFontSizeToFitWidth = NO;
    self.captionLabel.font = [UIFont boldSystemFontOfSize:16.f];
    self.captionLabel.textColor = [UIColor blackColor];
    self.captionLabel.text = self.caption;
    [self addSubview:self.captionLabel];
    
    self.subcaptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, imageViewSize.height+kCaptionHeight, viewWidth, kSubCaptionHeight)];
    self.subcaptionLabel.textAlignment = NSTextAlignmentLeft;
    self.subcaptionLabel.adjustsFontSizeToFitWidth = NO;
    self.subcaptionLabel.font = [UIFont boldSystemFontOfSize:12.f];
    self.subcaptionLabel.textColor = [UIColor lightGrayColor];
    self.subcaptionLabel.text = self.subcaption;
    [self addSubview:self.subcaptionLabel];
}

- (void)showPlaceholderImage {
    UIImage *placeholder = [UIImage ct_imageWithString:self.caption color:nil size:self.imageView.frame.size];
    self.imageView.image = placeholder;
}

- (void)loadImage {
    if (!self.imageUrl) return;
    
    NSURL *attachmentURL = [NSURL URLWithString:self.imageUrl];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session downloadTaskWithURL:attachmentURL
                completionHandler:^(NSURL *temporaryFileLocation, NSURLResponse *response, NSError *error) {
                    if (error != nil) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self showPlaceholderImage];
                        });
#ifdef DEBUG
                        NSLog(@"unable to download image: %@", error.localizedDescription);
#endif
                        
                    } else {
                        NSError *imageError;
                        
                        NSData *imageData = [NSData dataWithContentsOfURL:temporaryFileLocation
                                                                       options:kNilOptions
                                                                         error:&imageError];
                    
                        UIImage *image = [UIImage imageWithData:imageData];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (image) {
                                self.imageView.image = image;
                            } else {
                                [self showPlaceholderImage];
                            }
                            
                        });
#ifdef DEBUG
                        if (error != nil) {
                            NSLog(@"unable to download image: %@", error.localizedDescription);
                        }
#endif
                    }
                }] resume];

}

@end
