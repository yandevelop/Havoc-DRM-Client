#import "PackageDRM.h"

@implementation PackageDRM

// Get the UDID of the device
- (NSString *)deviceUDID {
    CFStringRef UDNumber = MGCopyAnswer(CFSTR("UniqueDeviceID"));
	NSString *udid = (__bridge NSString*)UDNumber;
    return udid; 
}

// Get the model identifier of the device
- (NSString *)deviceModelIdentifier {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

- (void)validate:(void (^)(int statusCode))completion {
    /*Status codes:

    (-1) request failed or other error
    (0)  device is authorized to use this package
    (1) request failed or other error. add on offset*/

    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:kMiddlemanAPI]];
    NSString *udid = [self deviceUDID];
    NSString *model = [self deviceModelIdentifier];
    NSString *identifier = kPackageIdentifier;

    if (!udid || !model || !identifier) {
        if (completion) {
            int statusCode = -1;
            completion(statusCode);
        }
        return;
    }

    NSDictionary *jsonDict = @{
        @"udid": udid,
        @"model": model,
        @"identifier": identifier
    };

    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&jsonError];
    [urlRequest setHTTPMethod:@"POST"];

    [urlRequest setHTTPBody:jsonData];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)jsonData.length] forHTTPHeaderField:@"Content-Length"];

    NSURLSession *session = [NSURLSession sharedSession];

    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        int statusCode;

        if (error) {
            statusCode = -1;
        } else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

            if (httpResponse.statusCode == 200) {
                NSError *parseError = nil;
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];

                if (parseError) {
                    statusCode = -1;
                } else {
                    NSString *status = [responseDictionary objectForKey:@"status"];

                    if ([status isEqualToString:@"completed"]) {
                        statusCode = 0;
                    } else if ([status isEqualToString:@"failed"]) {
                        statusCode = 1;
                    } else {
                        statusCode = -1;
                    }
                }
            } else {
                statusCode = -1;
            }
        }

        if (completion) {
            completion(statusCode);
        }
    }];

    [dataTask resume];
}
@end