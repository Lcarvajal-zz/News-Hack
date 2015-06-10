//
//  Article.h
//  News-Hack
//
//  Created by Lukas Carvajal on 6/10/15.
//  Copyright (c) 2015 Lukas Carvajal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Article : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *url;

@end
