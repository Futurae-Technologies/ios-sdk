#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (Map)

- (NSArray *)map:(id (^)(id obj))block;

@end

NS_ASSUME_NONNULL_END
