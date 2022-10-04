//
//  ViewController.m
//  CancellableNetwork
//
//  Created by Jinwoo Kim on 10/4/22.
//

#import "ViewController.h"
#import "ImageService.h"

@interface ViewController ()
@property (retain, nonatomic) IBOutlet UIStackView *imagesStackView;
@property (retain, nonatomic) IBOutlet UIButton *downloadButton;
@property (retain, nonatomic) IBOutlet UIButton *cancelButton;
@property (retain) ImageService *imageService;
@property (retain) id<NSObject> _Nullable cancellationObject;
@end

@implementation ViewController

- (void)dealloc {
    [_imagesStackView release];
    [_downloadButton release];
    [_cancelButton release];
    [_imageService release];
    [_cancellationObject release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    ImageService *imageService = [ImageService new];
    self.imageService = imageService;
    [imageService release];
}

- (IBAction)triggeredDownloadButton:(UIButton *)sender {
    if (self.cancellationObject) return;
    
    UIButtonConfiguration *configuration = [self.downloadButton.configuration copy];
    configuration.showsActivityIndicator = YES;
    self.downloadButton.configuration = configuration;
    [configuration release];

    [self.imageService randomImagesWithSize:CGSizeMake(2000.0f, 1000.0f)
                                      count:self.imagesStackView.arrangedSubviews.count
                  cancellationObjectHandler:^(id<NSObject>  _Nonnull cancellationObject) {
        self.cancellationObject = cancellationObject;
    }
                          completionHandler:^(NSArray<UIImage *> * _Nonnull images, NSArray<NSError *> * _Nonnull errors) {
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            [self.imagesStackView.arrangedSubviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (idx >= images.count) {
                    *stop = YES;
                    return;
                }
                
                [(UIImageView *)obj setImage:images[idx]];
            }];
            
            //
            
            UIButtonConfiguration *configuration = [self.downloadButton.configuration copy];
            configuration.showsActivityIndicator = NO;
            self.downloadButton.configuration = configuration;
            [configuration release];
            
            //
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success!" message:[NSString stringWithFormat:@"%@", errors] preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alert addAction:doneAction];
            [self presentViewController:alert animated:YES completion:^{

            }];

            //

            self.cancellationObject = nil;
        }];
    }];
}

- (IBAction)triggeredCancelButton:(UIButton *)sender {
    self.cancellationObject = nil;
}

@end
