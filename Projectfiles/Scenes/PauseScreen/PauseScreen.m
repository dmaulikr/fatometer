//
//  PauseScreen.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 6/10/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "PauseScreen.h"
#import "GameMechanics.h"
#import "STYLES.h"
#import "MainMenuLayer.h"
#import "SimpleAudioEngine.h"


@interface PauseScreen()

- (void)resumeButtonPressed;
- (void)quitButtonPressed;
- (void)resetButtonPressed;

@end

@implementation PauseScreen

- (id)initWithGame:(Game *)game
{
    self = [super init];
    
    if (self)
    {
        // Preload Sound
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"select.mp3"];
        
        self.contentSize = [[CCDirector sharedDirector] winSize];
        // position of screen, animate to screen
        self.position = ccp(self.contentSize.width / 2, self.contentSize.height * 1.5);
        
        // add a background image node
        backgroundNode = [[CCBackgroundColorNode alloc] init];
        backgroundNode.backgroundColor = ccc4(255, 255, 255, 255);
        backgroundNode.contentSize = self.contentSize;
        [self addChild:backgroundNode];
        
        // set anchor points new, since we changed content size
        //self.anchorPoint = ccp(0.5, 0.5);
        backgroundNode.anchorPoint = ccp(0.5, 0.5);
        
        // add title label
        CCLabelTTF *storeItemLabel = [CCLabelTTF labelWithString:@"Paused"
                                                        fontName:DEFAULT_FONT
                                                        fontSize:50];
        storeItemLabel.color = DEFAULT_FONT_COLOR;
        storeItemLabel.position = ccp(0, 0.5 * self.contentSize.height - 45);
        [self addChild:storeItemLabel];
        
        // add a resume button
        CCSprite *resumeButtonNormal = [CCSprite spriteWithFile:@"button_playbutton.png"];
        resumeMenuItem = [[CCMenuItemSprite alloc] initWithNormalSprite:resumeButtonNormal selectedSprite:nil disabledSprite:nil target:self selector:@selector(resumeButtonPressed)];
        
        
        // add a quit button
        CCSprite *quitButtonNormal = [CCSprite spriteWithFile:@"close.png"];
        quitMenuItem = [[CCMenuItemSprite alloc] initWithNormalSprite:quitButtonNormal selectedSprite:nil disabledSprite:nil target:self selector:@selector(quitButtonPressed)];
        
        // add a reset button
        CCSprite *resetButtonNormal = [CCSprite spriteWithFile:@"reset.png"];
        resetMenuItem = [[CCMenuItemSprite alloc] initWithNormalSprite:resetButtonNormal selectedSprite:nil disabledSprite:nil target:self selector:@selector(resetButtonPressed)];
        
        
        menu = [CCMenu menuWithItems:resumeMenuItem, resetMenuItem, quitMenuItem, nil];
        [menu alignItemsHorizontally];
        menu.position = ccp(0, 30);
        [self addChild:menu];
        
        //        menu2 = [CCMenu menuWithItems:resetMenuItem, nil];
        //        [menu2 alignItemsHorizontally];
        //        menu2.position = ccp(0, -15);
        //        [self addChild:menu2];
        //
        //        menu3 = [CCMenu menuWithItems:quitMenuItem, nil];
        //        [menu3 alignItemsHorizontally];
        //        menu3.position = ccp(0, -95);
        //        [self addChild:menu3];

        
        // add a missions node
                missionNode = [[MissionsNode alloc] initWithMissions:game.missions];
                missionNode.contentSize = CGSizeMake(240.f, 120.f);
                missionNode.anchorPoint = ccp(0.5, 0.5);
                missionNode.position = ccp(0, -80);
        
                // we want to use the 9Patch background on the pause screen
                missionNode.usesScaleSpriteBackground = TRUE;
                [self addChild:missionNode];
    }
    
    return self;
}

- (void)quitButtonPressed
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:0.5f scene:[GameplayLayer node]]];
    [[[GameMechanics sharedGameMechanics] gameScene] quit];
    NSLog(@"quit button pressed");
    [[SimpleAudioEngine sharedEngine] playEffect:@"select.mp3"];
}

- (void)resetButtonPressed
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFadeBL transitionWithDuration:0.5f scene:[GameplayLayer node]]];
    [[[GameMechanics sharedGameMechanics] gameScene] reset];
    NSLog(@"reset button pressed");
    [[SimpleAudioEngine sharedEngine] playEffect:@"select.mp3"];
}

- (void)resumeButtonPressed
{
    [self hideAndResume];
    [self.delegate resumeButtonPressed:self];
    [[SimpleAudioEngine sharedEngine] playEffect:@"select.mp3"];
}

- (void)present
{
    CCMoveTo *move = [CCMoveTo actionWithDuration:0.2f position:ccp(self.contentSize.width / 2, self.contentSize.height * 0.5)];
    [self runAction:move];
    [missionNode updateCheckmarks];
}

- (void)hideAndResume
{
    if (self.parent != nil)
    {
        // animate off screen
        CGPoint targetPosition = ccp(self.contentSize.width / 2, self.contentSize.height * 1.5);
        CCMoveTo *move = [CCMoveTo actionWithDuration:0.2f position:targetPosition];
        
        CCCallBlock *removeFromParent = [[CCCallBlock alloc] initWithBlock:^{
            [self removeFromParentAndCleanup:TRUE];
            // resume the game
            [[GameMechanics sharedGameMechanics] setGameState:GameStateRunning];
        }];
        
        CCSequence *hideSequence = [CCSequence actions:move, removeFromParent, nil];
        [self runAction:hideSequence];
    }
}

@end