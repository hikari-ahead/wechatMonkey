//
//  UIImage+RSLength.m
//  wechatMonkeyDylib
//
//  Created by kuangjeon on 17/01/2018.
//  Copyright © 2018 kuangjeon. All rights reserved.
//

#import "UIImage+RSLength.h"

@implementation UIImage (RSLength)
- (NSInteger)length {
    if (self) {
        return UIImageJPEGRepresentation(self, .9).length;
    }else {
        return 0;
    }
}
@end
