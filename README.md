# Havoc-DRM-Client

This repository contains code to interact with the [API](https://github.com/yandevelop/Havoc-DRM-Middleman) from a (jailbroken) iOS device.

## Usage
First off, you shouldn't call the API excessively, such as every time your tweak is loaded or at defined time intervals.
Instead, it is recommended to execute the API call from the tweak preferences section to validate the device. 
Implement custom logic to store an indicator confirming device authentication.

1. Define the following constants to specify the Havoc DRM Middleman API endpoint and the package identifier. Replace the placeholders with your actual values.

```objective-c
static NSString *const kMiddlemanAPI = @"http://ipaddress:80/api/verify";
static NSString *const kPackageIdentifier = @"com.your.tweak";
```

2. Instantiate the PackageDRM object and call the `validate` function:
```objective-c
PackageDRM *DRM = [[PackageDRM alloc] init];
[DRM validate:^(int statusCode) {
    // do something with the status code
    NSLog(@"Status code: %d", statusCode);
}];
```

## Response handling

The validate function returns an integer representing the following status codes:
- -1: the request failed
-  0: The device is authorized to use this package
-  1: The device is not authorized to use this package

Make sure to handle the status codes appropriately in your code. 
Depending on the returned code, you may want to implement different behaviors or error-handling mechanisms.

## Documentation
This project was created using the following resources:

- Havoc DRM API Documentation (Havoc) - https://docs.havoc.app/docs/seller/drm/
- Tweak DRM (iPhone Development Wiki)- https://iphonedev.wiki/Tweak_DRM
- Packix-DRM-Middleman (guillermo-moran) - https://github.com/guillermo-moran/Packix-DRM-Middleman/