#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FTRExtraInfo : NSObject

@property (nonatomic, readonly, nonnull) NSString *key;
@property (nonatomic, readonly, nonnull) NSString *value;

- (instancetype)initWithKey:(NSString *)key value:(NSString *)value;

+ (instancetype)infoWithKey:(NSString *)key value:(NSString *)value;

@end

NS_ASSUME_NONNULL_END
