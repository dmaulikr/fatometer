//
//  GameplayScene.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/15/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "CCScene.h"
#import "StoreTableViewCell.h"
#import "PauseScreen.h"
#import "InGameStore.h"
#import "ScoreboardEntryNode.h"
#import "HealthDisplayNode.h"
#import "PopUp.h"
#import "Knight.h"



@interface GameplayLayer : CCLayer <StoreDisplayNeedsUpdate>
{
    float scrollSpeed;
    
    HealthDisplayNode *healthDisplayNode;
    ScoreboardEntryNode *coinsDisplayNode;
    ScoreboardEntryNode *pointsDisplayNode;
    ScoreboardEntryNode *inAppCurrencyDisplayNode;
    // groups health, coins and points display
    CCNode *hudNode;
    
    /* Skip Ahead Button */
    CCMenu *skipAheadMenu;
    CCMenuItemSprite *skipAheadMenuItem;
    
    /* Pause Button */
    CCMenu *pauseButtonMenu;
    CCMenuItemSprite *pauseButtonMenuItem;
    
    /* "GO ON?" popup */
    PopUp *goOnPopUp;
    
    /* "Buy more coins"-Popup */
    InGameStore *inGameStore;
    
    Game *game;
    Knight *knight;
    
    /* used to trigger events, that need to run every X update cycles*/
    int updateCount;
    
    /* stores the exact distance the knight has ran */
    float gainedDistance;
    
    CCSprite *toolBar;
    CCSprite *pointer;
    
    CCLayerColor* colorLayer;
    
    CGPoint pointerPosition;
    
    CCLabelTTF* label;
    CCLabelBMFont* tut;
    
    BOOL playedTutorial;
    BOOL fasterSpeed;
    BOOL fasterSpeed2;
    BOOL fasterSpeed3;
    BOOL fasterSpeed4;
    BOOL fasterSpeed5;
    BOOL fasterSpeed6;
    BOOL fasterSpeed7;
    BOOL fasterSpeed8;
    BOOL fasterSpeed9;
    BOOL fasterSpeed10;
    BOOL fasterSpeed11;
    BOOL fasterSpeed12;
    BOOL fasterSpeed13;
    BOOL fasterSpeed14;
    BOOL fasterSpeed15;
    BOOL fasterSpeed16;
    BOOL fasterSpeed17;
    BOOL fasterSpeed18;
    BOOL fasterSpeed19;
    BOOL fasterSpeed20;
}

// defines if the main menu shall be displayed, or if the game shall start directly. By default the menu is displayed.
@property (nonatomic, assign) BOOL showMainMenu;

/**
 Tells the game to start
 */
- (void)startGame;
- (void)startTutorial;
- (void)resetFatness;

- (void)quit;
- (void)reset;

// returns a GamePlayLayer, with an overlayed MainMenu
+ (id)scene;

// return a GamePlayLayer without a MainMenu
+ (id)noMenuScene;

// makes the Heads-Up-Display (healthInfo, pointInfo, etc.) appear. Can be animated.
- (void)showHUD:(BOOL)animated;

// hides the Heads-Up-Display (healthInfo, pointInfo, etc.). Can be animated.
- (void)hideHUD:(BOOL)animated;

@end