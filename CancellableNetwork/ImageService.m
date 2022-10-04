//
//  ImageService.m
//  CancellableNetwork
//
//  Created by Jinwoo Kim on 10/4/22.
//

#import "ImageService.h"

@interface ImageServiceCancellable : NSObject
@property (readonly, copy) void (^cancellationHandler)(void);
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCancellationHandler:(void (^)(void))cancellationHandler;
@end

@implementation ImageServiceCancellable

- (instancetype)initWithCancellationHandler:(void (^)(void))cancellationHandler {
    if (self = [self init]) {
        self->_cancellationHandler = [cancellationHandler copy];
    }

    return self;
}

- (void)dealloc {
    self.cancellationHandler();
    [self->_cancellationHandler release];
    [super dealloc];
}

@end

@implementation ImageService

- (void)randomImagesWithSize:(CGSize)size count:(NSUInteger)count cancellationObjectHandler:(ImageServiceCancellationObjectHandler)cancellationObjectHandler completionHandler:(ImageServiceCompletionHandler)comcompletionHandler {
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.qualityOfService = NSQualityOfServiceUtility;

    [queue addOperationWithBlock:^{
        NSMutableArray<UIImage *> *mutableImages = [NSMutableArray<UIImage *> new];
        NSMutableArray<NSError *> *mutableErrors = [NSMutableArray<NSError *> new];
        NSMutableDictionary<NSURLSessionTask *, void (^)(void)> *mutableTasks = [NSMutableDictionary<NSURLSessionTask *, void (^)(void)> new];

        //

        for (NSUInteger i = 0; i < count; i++) {
            NSURLComponents *urlComponents = [NSURLComponents new];
            urlComponents.scheme = @"https";
            urlComponents.host = @"picsum.photos";
            urlComponents.path = [NSString stringWithFormat:@"/%@/%@", @(size.width), @(size.height)];

            NSURL *url = urlComponents.URL;
            [urlComponents release];

            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.ephemeralSessionConfiguration];

            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

            NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                @synchronized (queue) {
                    if (error) {
                        [mutableErrors addObject:error];
                    } else if (data) {
                        UIImage * _Nullable image = [UIImage imageWithData:data];

                        if (image) {
                            [mutableImages addObject:image];
                        } else {
                            NSError *imageError = [NSError new];
                            [mutableErrors addObject:imageError];
                            [imageError release];
                        }
                    } else {
                        NSError *imageError = [NSError new];
                        [mutableErrors addObject:imageError];
                        [imageError release];
                    }

                    dispatch_semaphore_signal(semaphore);

                    if ((mutableImages.count + mutableErrors.count) == count) {
                        NSArray<UIImage *> *images = [mutableImages copy];
                        NSArray<NSError *> *errors = [mutableErrors copy];

                        comcompletionHandler([images autorelease], [errors autorelease]);
                    }
                }
            }];

            [request release];
            [session finishTasksAndInvalidate];

            void (^block)(void) = [^{
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                dispatch_release(semaphore);
            } copy];
            mutableTasks[task] = block;
            [block release];
        }

        [mutableImages release];
        [mutableErrors release];

        //

        ImageServiceCancellable *cancellable = [[ImageServiceCancellable alloc] initWithCancellationHandler:^{
            [mutableTasks.allKeys enumerateObjectsUsingBlock:^(NSURLSessionTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj cancel];
            }];
        }];

        [mutableTasks release];

        cancellationObjectHandler([cancellable autorelease]);

        //

        NSOperationQueue *networkQueue = [NSOperationQueue new];
        networkQueue.qualityOfService = NSQualityOfServiceUtility;
        networkQueue.maxConcurrentOperationCount = 2;

        [mutableTasks enumerateKeysAndObjectsUsingBlock:^(NSURLSessionTask * _Nonnull key, void (^ _Nonnull obj)(void), BOOL * _Nonnull stop) {
            [networkQueue addOperationWithBlock:^{
                [key resume];
                obj();
            }];
        }];

        [networkQueue release];
    }];

    [queue release];
}

@end
