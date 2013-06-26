//
//  DecorativeObjectsNode.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 6/19/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "DecorativeObjectsNode.h"
#import "Tree.h"

@implementation DecorativeObjectsNode


- (id)init
{
    self = [super init];
    
    if (self)
    {
        // add tree
        Tree *tree = [[Tree alloc] initWithTreeImage];
        tree.position = ccp(350,80);
        [self addChild:tree];
    }
    
    return self;
}

@end
