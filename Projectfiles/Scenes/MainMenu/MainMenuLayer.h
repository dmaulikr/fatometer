//
//  MainMenuLayer.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/15/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "kobold2d.h"

@interface MainMenuLayer : CCLayer
{
    CCNode *startTitleLabel;
    CCMenu *startMenu;
    CCMenu *startMenu2;
    CCMenuItem *startButton;
    CCMenuItemFont *storeButton;
    CGPoint startTitleLabelTargetPoint;
    
    
    CGPoint screenCenter;
    CGSize size;

}

@end
