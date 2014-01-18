//
//  PauseScreen.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 6/10/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "CCLayer.h"
#import "Game.h"
#import "CCSpriteBackgroundNode.h"
#import "CCBackgroundColorNode.h"
#import "MissionsNode.h"
#import "MainMenuLayer.h"

@class PauseScreen;
/*
 Allows other classes to listen to the event of the resume
 button beeing pressed and the pause screen beeing dismissed.
 */
@protocol PauseScreenDelegate <NSObject>

- (void)resumeButtonPressed:(PauseScreen *)pauseScreen;
- (void)quitButtonPressed:(PauseScreen *)pauseScreen;
- (void)resetButtonPressed:(PauseScreen *)pauseScreen;
- (void)storeButtonPressed:(PauseScreen *)pauseScreen;

@end

@interface PauseScreen : CCLayer
{
    CGPoint screenCenter;
    CGSize size;
    CCBackgroundColorNode *backgroundNode;
    CCMenu *menu;
//    CCMenu *menu2;
//    CCMenu *menu3;
    CCMenuItemSprite *resumeMenuItem;
    CCMenuItemSprite *homeMenuItem;
    CCMenuItemSprite *resetMenuItem;
    CCMenuItemSprite *storeMenuItem;
    MissionsNode *missionNode;
}

@property (nonatomic, weak) id<PauseScreenDelegate> delegate;

- (id)initWithGame:(Game *)game;
- (void)present;

@end
