//  Created by GalaxyWeblinks on 11/01/18.
//  Copyright © 2017 GalaxyWeblinks. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^dateTimeCallBack)(NSDate *dateObject);
@interface GWLCalenderVC : UIViewController
@property (nonatomic) dateTimeCallBack block;
-(void)initializeController:(UIViewController* )parent timeIntervel:(int)intervel completion:(dateTimeCallBack)callback;

@end
