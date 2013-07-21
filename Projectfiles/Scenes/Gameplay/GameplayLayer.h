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
#import "Coins.h"
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
    
    CCMenu *menu;
    CCMenu *menu2;
    CCMenu *menu3;
        
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
    
    int sidewaysCoins;
    
    int posX;
    int posY;
    int coinValue;
    
    int coinsCollected;
    
    /* stores the exact distance the knight has ran */
    float gainedDistance;
    
    CCSprite *toolBar;
    CCSprite *pointer;
    
    CCLayerColor* colorLayer;
    
    CGPoint pointerPosition;
    
    CCLabelTTF* label;
    CCLabelBMFont* tut;
    
    BOOL playedTutorial;
    
    // Coin Stuff
    BOOL coinPattern1;
    NSMutableArray *coinArray;

}

// defines if the main menu shall be displayed, or if the game shall start directly. By default the menu is displayed.
@property (nonatomic, assign) BOOL showMainMenu;
@property (nonatomic, assign) BOOL visible;

// velocity in pixels per second
@property (nonatomic, assign) CGPoint velocity;
@property (nonatomic, strong) NSMutableArray *animationFrames;
@property (nonatomic, strong) CCAction *run;
@property (nonatomic, assign) NSInteger initialHitPoints;

/**
 Tells the game to start
 */
- (id) setKnight;
- (void)startGame;
- (void)startTutorial;
- (void)resetFatness;

-(void)resizeSprite;

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