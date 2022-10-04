//
//  ImageService.h
//  CancellableNetwork
//
//  Created by Jinwoo Kim on 10/4/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ImageServiceCancellationObjectHandler)(id<NSObject> cancellationObject);;
typedef void (^ImageServiceCompletionHandler)(NSArray<UIImage *> *images, NSArray<NSError *> *errors);

@interface ImageService : NSObject
- (void)randomImagesWithSize:(CGSize)size count:(NSUInteger)count cancellationObjectHandler:(ImageServiceCancellationObjectHandler)cancellationObjectHandler completionHandler:(ImageServiceCompletionHandler)comcompletionHandler;
@end

NS_ASSUME_NONNULL_END
