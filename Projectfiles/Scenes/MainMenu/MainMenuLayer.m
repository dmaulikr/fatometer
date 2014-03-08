//
//  MainMenuLayer.m
//  _MGWU-SideScroller-Template_
//
//  Created by Shalin Shah on 5/15/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "SimpleAudioEngine.h"
#import "MainMenuLayer.h"
#import "RecapScreenScene.h"
#import "StoreScreenScene.h"
#import "GameplayLayer.h"
#import "Leaderboard.h"
#import "STYLES.h"
#import "Mission.h"
#import "Store.h"
#import "GameMechanics.h"

#define TITLE_LABEL @"Food Gone Wild"
#define TITLE_AS_SPRITE TRUE

@interface MainMenuLayer ()

@end

@implementation MainMenuLayer

-(id) init
{
	if (self = [super init])
    {
        // Preload Sound
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"select.mp3"];
        
        // setup In-App-Purchase Store
        [Store setupDefault]; 
        
        screenCenter = [CCDirector sharedDirector].screenCenter;
        size = [CCDirector sharedDirector].screenSize;
        
        // set background
        CCSprite *background = [CCSprite spriteWithFile:@"background-mainlayer.png"];
        background.position = screenCenter;
        [self addChild:background z:2];
    
        //setup the start menu title
        if (!TITLE_AS_SPRITE) {
            // OPTION 1: Title as Text
            CCLabelTTF *tempStartTitleLabel = [CCLabelTTF labelWithString:TITLE_LABEL
                                                   fontName:DEFAULT_FONT
                                                   fontSize:45];
            tempStartTitleLabel.color = DEFAULT_FONT_COLOR;
            startTitleLabel = tempStartTitleLabel;
        } else {
            // OPTION 2: Title as Sprite
            CCSprite *startLabelSprite = [CCSprite spriteWithFile:@"title.png"];
            startTitleLabel = startLabelSprite;
        }
        
        // place the startTitleLabel off-screen, later we will animate it on screen 
        startTitleLabel.position = ccp (screenCenter.x, size.height + 70);
        
        // this will be the point, we will animate the title to
        startTitleLabelTargetPoint = ccp(screenCenter.x, screenCenter.y * 1.15);

		[self addChild:startTitleLabel z:4];
        
        /* add a start button */
        CCSprite *normalStartButton = [CCSprite spriteWithFile:@"mainmenu.png"];
        CCSprite *selectedStartButton = [CCSprite spriteWithFile:@"mainmenu.png"];
        
        startButton = [CCMenuItemSprite itemWithNormalSprite:normalStartButton selectedSprite:selectedStartButton target:self selector:@selector(startButtonPressed)];
        
        CCSprite *taptoplay = [CCSprite spriteWithFile:@"taptoplay.png"];
        taptoplay.position = ccp(screenCenter.x, screenCenter.y / 2.5);
        taptoplay.scale = 1.3;
        [self addChild:taptoplay z:3];
        
        id blinker = [CCBlink actionWithDuration:4.0f blinks:7];
        
        id fadeIn = [CCFadeIn actionWithDuration:1.0];
        id fadeOut = [CCFadeOut actionWithDuration:1.0];

        CCSequence *sequence = [CCSequence actions:fadeOut, fadeIn, nil];
        CCAction *forever = [CCRepeatForever actionWithAction:sequence];
        [taptoplay runAction:forever];

        
        [self scheduleUpdate];
        
    }

	return self;
}

-(void) update:(ccTime)delta {
    if ([KKInput sharedInput].anyTouchEndedThisFrame) {
        [self startButtonPressed];
    }
}

-(void) storeScene
{
    CCScene *scene = [[StoreScreenScene alloc] init];
    [[CCDirector sharedDirector] replaceScene:scene];
}

- (void)startButtonPressed
{
//    [[SimpleAudioEngine sharedEngine] playEffect:@"select.mp3"];
    
    [[CCDirector sharedDirector] replaceScene: [CCTransitionSlideInB transitionWithDuration:0.5f scene:[GameplayLayer node]]];

}

#pragma mark - Scene Lifecyle

/**
 This method is called when the scene becomes visible. You should add any code, that shall be executed once
 the scene is visible, to this method.
 */
-(void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    // animate the title on to screen
    CCMoveTo *move = [CCMoveTo actionWithDuration:1.f position:startTitleLabelTargetPoint];
    id easeMove = [CCEaseBackInOut actionWithAction:move];
    [startTitleLabel runAction: easeMove];
}

@end