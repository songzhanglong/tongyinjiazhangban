//
//  DJTparentView.m
//  GoOnBaby
//
//  Created by zl on 14-5-22.
//  Copyright (c) 2014年 Summer. All rights reserved.
//

#import "Guardian.h"

@implementation Guardian

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       

    }
    return self;
}

- (IBAction)buttonPressed:(id)sender {
    NSInteger index = [sender tag] - 1;
    if (_delegate && [_delegate respondsToSelector:@selector(contactGrardian:Item:)]) {
        [_delegate contactGrardian:self Item:index];
    }
}

@end
