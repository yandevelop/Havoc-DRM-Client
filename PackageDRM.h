#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import "Constants.h"

OBJC_EXTERN CFStringRef MGCopyAnswer(CFStringRef key) WEAK_IMPORT_ATTRIBUTE;

@interface PackageDRM : NSObject
- (NSString *)deviceUDID;
- (NSString *)deviceModelIdentifier;
- (void)validate:(void (^)(int statusCode))completion;
@end
