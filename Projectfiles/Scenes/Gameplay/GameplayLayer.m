//
//  GameplayScene.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/15/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//
//
//

/*
  So this is the objective of the game: You are the last person remaining on earth all the food has gone bad. So you have to try and maintain your weight to save the human race from extinction. You have to try to not get too fat, or get too skinny and pass out, otherwise, the extinction of the human race will be blamed upon you.
*/


#import "SimpleAudioEngine.h"
#import "GameplayLayer.h"
#import "ParallaxBackground.h"
#import "Game.h"
#import "Coins.h"
#import "Coins2.h"
#import "Coins3.h"
#import "UnhealthyFood.h"
#import "Apples.h"
#import "Donuts.h"
#import "Cake.h"
#import "Chicken.h"
#import "Fries.h"
#import "Cupcake.h"
#import "Oranges.h"
#import "Pizza.h"
#import "Strawberries.h"
#import "HealthyFood.h"
#import "GameMechanics.h"
#import "EnemyCache.h"
#import "MainMenuLayer.h"
#import "Mission.h"
#import "RecapScreenScene.h"
#import "Store.h"
#import "PopupProvider.h"
#import "CCControlButton.h"
#import "StyleManager.h"
#import "NotificationBox.h"
#import "PauseScreen.h"
#import "MyCustomMonster.h"
#import "DecorativeObjectsNode.h"
#import "STYLES.h"  

// defines how many update cycles run, before the missions get an update about the current game state
#define MISSION_UPDATE_FREQUENCY 10

@interface GameplayLayer()
/*
 Tells the game to display the skipAhead button for N seconds.
 After the N seconds the button will automatically dissapear.
 */
- (void)presentSkipAheadButtonWithDuration:(NSTimeInterval)duration;

/*
 called when skipAheadButton has been touched
 */
- (void)skipAheadButtonPressed;

/*
 called when pause button was pressed
 */
- (void)pauseButtonPressed;

/*
 called when the player has chosen if he wants to continue the game (for paying coins) or not
 */
- (void)goOnPopUpButtontaped:(CCControlButton *)sender;


@end

@implementation GameplayLayer

+ (id)scene
{
    CCScene *scene = [CCScene node];
    GameplayLayer* layer = [GameplayLayer node];
    
    // By default we want to show the main menu
    layer.showMainMenu = TRUE;
    
    [scene addChild:layer];
    return scene;
}

+ (id)noMenuScene
{
    CCScene *scene = [CCScene node];
    GameplayLayer* layer = [GameplayLayer node];
    
    // By default we want to show the main menu
    layer.showMainMenu = FALSE;
    
    [scene addChild:layer];
    return scene;
}

#pragma mark - Initialization

- (void)dealloc
{
    /*
     When our object is removed, we need to unregister from all notifications.
     */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    
    if (self)
    {        
        scrollSpeed = 200.0f;
        
        // This is to update the speed and make it faster
        fasterSpeed = FALSE;
        fasterSpeed2 = FALSE;
        fasterSpeed3 = FALSE;
        fasterSpeed4 = FALSE;
        fasterSpeed5 = FALSE;
        fasterSpeed6 = FALSE;
        fasterSpeed7 = FALSE;
        fasterSpeed8 = FALSE;
        fasterSpeed9 = FALSE;
        fasterSpeed10 = FALSE;
        fasterSpeed11 = FALSE;
        fasterSpeed12 = FALSE;
        fasterSpeed13 = FALSE;
        fasterSpeed14 = FALSE;
        fasterSpeed15 = FALSE;
        fasterSpeed16 = FALSE;
        fasterSpeed17 = FALSE;
        fasterSpeed18 = FALSE;
        fasterSpeed19 = FALSE;
        fasterSpeed20 = FALSE;
        
        coinSide1 = FALSE;
        coinSide2 = FALSE;
        coinSide3 = FALSE;
        coinSide4 = FALSE;
        coinSide5 = FALSE;
        coinSide6 = FALSE;
        coinSide7 = FALSE;
        coinSide8 = FALSE;
        coinSide9 = FALSE;
        coinSide10 = FALSE;
        
        coinUp1 = FALSE;
        coinUp2 = FALSE;
        coinUp3 = FALSE;
        coinUp4 = FALSE;
        coinUp5 = FALSE;
        coinUp6 = FALSE;
        coinUp7 = FALSE;
        coinUp8 = FALSE;
        coinUp9 = FALSE;
        coinUp10 = FALSE;
        
        spawnCoinsOutside = FALSE;
        
        sidewaysCoins = 7;
        coinValue = 1;
        
        // get screen center
        CGPoint screenCenter = [CCDirector sharedDirector].screenCenter;
        
        //Preload the music
        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"background.mp3"];
//        [[SimpleAudioEngine sharedEngine] preloadEffect:@"select.mp3"];
        
        // Play the Music
//        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background.mp3" loop:TRUE];
//        if([[SimpleAudioEngine sharedEngine]isBackgroundMusicPlaying])
//        {
//            NSLog(@"Music Played");
//        } else {
//            NSLog(@"");
//        }
        
        // preload particle effects
        // To preload the textures, play each effect once off-screen
        CCParticleSystem* system = [CCParticleSystemQuad particleWithFile:@"fx-explosion.plist"];
        system.positionType = kCCPositionTypeFree;
        system.autoRemoveOnFinish = YES;
        system.position = ccp(MAX_INT, MAX_INT);
        // adding it as child lets the particle effect play
        [self addChild:system];
        
        // add the scrolling background
        ParallaxBackground *background = [ParallaxBackground node];
        [self addChild:background z:-2];
        
        hudNode = [CCNode node];
        [self addChild:hudNode];
        
        // add the knight
        knight = [[Knight alloc] initWithKnightPicture];
        [self addChild:knight];
        knight.anchorPoint = ccp(0,0);
        
        
        // add scoreboard entry for in-app currency
        inAppCurrencyDisplayNode = [[ScoreboardEntryNode alloc] initWithScoreImage:@"bubble.png" fontFile:@"avenir.fnt"];
        inAppCurrencyDisplayNode.scoreStringFormat = @"%d";
        inAppCurrencyDisplayNode.position = ccp(self.contentSize.width - 220, self.contentSize.height - 70);
        inAppCurrencyDisplayNode.score = [Store availableAmountInAppCurrency];
        [hudNode addChild:inAppCurrencyDisplayNode z:MAX_INT-1];
        
        // add scoreboard entry for points
        pointsDisplayNode = [[ScoreboardEntryNode alloc] initWithScoreImage:nil fontFile:@"avenir24.fnt"];
        pointsDisplayNode.position = ccp(10, self.contentSize.height - 50);
        pointsDisplayNode.scoreStringFormat = @"%d m";
        [hudNode addChild:pointsDisplayNode z:MAX_INT-1];
        
        // set up the skip ahead menu
        CCSprite *skipAhead = [CCSprite spriteWithFile:@"skipahead.png"];
        CCSprite *skipAheadSelected = [CCSprite spriteWithFile:@"skipahead-pressed.png"];
        skipAheadMenuItem = [CCMenuItemSprite itemWithNormalSprite:skipAhead selectedSprite:skipAheadSelected target:self selector:@selector(skipAheadButtonPressed)];
        skipAheadMenu = [CCMenu menuWithItems:skipAheadMenuItem, nil];
        skipAheadMenu.position = ccp(self.contentSize.width - skipAheadMenuItem.contentSize.width -20, self.contentSize.height - 80);
        // initially skipAheadMenu is hidden
        skipAheadMenu.visible = FALSE;
        [hudNode addChild:skipAheadMenu];
        
        // set up pause button
        CCSprite *pauseButton = [CCSprite spriteWithFile:@"pause.png"];
        CCSprite *pauseButtonPressed = [CCSprite spriteWithFile:@"pause.png"];
        pauseButtonMenuItem = [CCMenuItemSprite itemWithNormalSprite:pauseButton selectedSprite:pauseButtonPressed target:self selector:@selector(pauseButtonPressed)];
        pauseButtonMenu = [CCMenu menuWithItems:pauseButtonMenuItem, nil];
        pauseButtonMenu.position = ccp(self.contentSize.width - 30, self.contentSize.height - 70);
        [hudNode addChild:pauseButtonMenu];
        
        
        // SET UP TOOLBAR, POINTER, AND FATNESS
        toolBar = [CCSprite spriteWithFile:@"toolbar.png"];
        pointer = [CCSprite spriteWithFile:@"pointer.png"];
        toolBar.position = ccp(239.5, 300);
        
        if ([[CCDirector sharedDirector] winSizeInPixels].width == 1136) {
            toolBar = [CCSprite spriteWithFile:@"toolbarip5.png"];
            toolBar.position = ccp(285, 300);
        }
        
        
        // Set up Tutorial
        tut = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:30];
        tut.position = screenCenter;
        [self addChild:tut z:10000];
        tut.visible = FALSE;
        bool tutorialStatusCheck = [[NSUserDefaults standardUserDefaults] boolForKey:@"tutorialStatus"];
        if (tutorialStatusCheck == FALSE) {
            playedTutorial = FALSE;
        }
        else {
            playedTutorial = [[NSUserDefaults standardUserDefaults] objectForKey:@"tutorialStatus"];
        }
                

        [self convertFromPercent:[[GameMechanics sharedGameMechanics] game].fatness];
                
        // add the enemy cache containing all spawned enemies
        [self addChild:[EnemyCache node]];
        
        // add decorative node
        //[self addChild:[DecorativeObjectsNode node]];
        
        // setup a new gaming session
        [self resetGame];
        [self scheduleUpdate];
        
        /**
         A Notification can be used to broadcast an information to all objects of a game, that are interested in it.
         Here we sign up for the 'GamePaused' and 'GameResumed' information, that is broadcasted by the GameMechanics class. Whenever the game pauses or resumes, we get informed and can react accordingly.
         **/
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gamePaused) name:@"GamePaused" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameResumed) name:@"GameResumed" object:nil];
        
        coinArray = [[NSMutableArray alloc] init];
        
        [self resizeSprite:knight toWidth:80 toHeight:70];
        for (int numBubbles = 0; numBubbles < [coinArray count]; numBubbles++)
        {
            Coins *tempCoin = [coinArray objectAtIndex:numBubbles];
            tempCoin.visible = false;
        }
    }
    return self;
}
/*
 Useful Little Code Snippets that make my life easier
*/

-(void)resizeSprite:(CCSprite*)sprite toWidth:(float)width toHeight:(float)height {
    sprite.scaleX = width / sprite.contentSize.width;
    sprite.scaleY = height / sprite.contentSize.height;
    NSLog(@"Resized Sprite");  
}

-(void) flashLabel:(NSString *) stringToFlashOnScreen actionWithDuration:(float) numSecondsToFlash color:(NSString *) colorString
{
    if ([colorString isEqualToString:@"red"] == TRUE) {
        tut.color = ccc3(255,0,0);
    }
    if ([colorString isEqualToString:@"blue"] == TRUE) {
        tut.color = ccc3(0,0,255);
    }
    if ([colorString isEqualToString:@"green"] == TRUE) {
        tut.color = ccc3(0,255,0);
    }
    if ([colorString isEqualToString:@"black"] == TRUE) {
        tut.color = ccc3(0,0,0);
    }
    if ([colorString isEqualToString:@"white"] == TRUE) {
        tut.color = ccc3(255,255,255);
    }
    [tut setString:stringToFlashOnScreen];
    id addVisibility = [CCCallFunc actionWithTarget:self selector:@selector(makeFlashLabelVisible)];
    id delayInvis = [CCDelayTime actionWithDuration:numSecondsToFlash];
    id addInvis = [CCCallFunc actionWithTarget:self selector:@selector(makeFlashLabelInvisible)];
    CCSequence *showLabelSeq = [CCSequence actions:addVisibility, delayInvis, addInvis, nil];
    [self runAction:showLabelSeq];
}

-(void) makeFlashLabelVisible
{
    tut.visible = TRUE;
}

-(void) makeFlashLabelInvisible
{
    tut.visible = FALSE;
}

-(void) convertFromPercent:(float) floatToConvert
{
    float percentVal = [toolBar boundingBox].size.width/100;
    float percent = floatToConvert * percentVal;
    pointerPosition = ccp(percent, toolBar.position.y);
}

- (void)gamePaused
{
    tut.visible = FALSE;
    [self pauseSchedulerAndActions];
}

- (void)gameResumed
{
    [self resumeSchedulerAndActions];
}

#pragma mark - Reset Game

- (void)startGame
{
    [[GameMechanics sharedGameMechanics] setGameState:GameStateRunning];
    [self enableGamePlayButtons];
    [self presentSkipAheadButtonWithDuration:5.f];
    
    /*
     inform all missions, that they have started
     */
    for (Mission *m in game.missions)
    {
        [m missionStart:game];
    }
    
    [self addChild:toolBar];
    [self addChild:pointer];
    [self resetFatness];
    [self startTutorial];
}

- (void)quit
{
    [[GameMechanics sharedGameMechanics] setGameState:GameStateRunning];
    self.showMainMenu = TRUE;
}
- (void)reset {
    [[GameMechanics sharedGameMechanics] setGameState:GameStateRunning];
}
- (void)resetGame
{
    [[GameMechanics sharedGameMechanics] resetGame];
    
    game = [[Game alloc] init];
    [[GameMechanics sharedGameMechanics] setGame:game];
    [[GameMechanics sharedGameMechanics] setKnight:knight];
    // add a reference to this gamePlay scene to the gameMechanics, which allows accessing the scene from other classes
    [[GameMechanics sharedGameMechanics] setGameScene:self];
    
    // set the default background scroll speed
    [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed];
    
    /* setup initial values */
    
    // setup knight
    knight.position = ccp(50,20);
    knight.zOrder = 10;
    knight.hitPoints = KNIGHT_HIT_POINTS;

    // setup HUD
    healthDisplayNode.health = knight.hitPoints;
    coinsDisplayNode.score = game.score;
    pointsDisplayNode.score = game.meters;
    
    // set spwan rate for monsters
    [[GameMechanics sharedGameMechanics] setSpawnRate:240 forMonsterType:[UnhealthyFood class]];
    [[GameMechanics sharedGameMechanics] setSpawnRate:290 forMonsterType:[HealthyFood class]];
    [[GameMechanics sharedGameMechanics] setSpawnRate:350 forMonsterType:[MyCustomMonster class]];
    
    // set gravity (used for jumps)
    [[GameMechanics sharedGameMechanics] setWorldGravity:ccp(0.f, -740.f)];
    
    // set the floor height, this will be the minimum y-Position for all entities
    [[GameMechanics sharedGameMechanics] setFloorHeight:20.f];
}

-(void) startTutorial
{
// Uses NSUserDefaults so doesn't appear twice
    if (playedTutorial == FALSE) {
        playedTutorial = TRUE;
        id delay = [CCDelayTime actionWithDuration:4.0f];
        id part1 = [CCCallFunc actionWithTarget:self selector:@selector(tutorial1)];
        id part2 = [CCCallFunc actionWithTarget:self selector:@selector(tutorial2)];
        id part3 = [CCCallFunc actionWithTarget:self selector:@selector(tutorial3)];
        CCSequence *tutorialSeq = [CCSequence actions:part1, delay, part2, delay, part3, delay, nil];
        [self runAction:tutorialSeq];
        [[NSUserDefaults standardUserDefaults] setBool:playedTutorial forKey:@"tutorialStatus"];
    }
}
-(void) tutorial1
{
    [self flashLabel:@"Tap to jump" actionWithDuration:2.0f color:@"black"];
}
-(void) tutorial2
{
    [self flashLabel:@"Turn device to move" actionWithDuration:2.0f color:@"black"];
}
-(void) tutorial3
{
    [self flashLabel:@"Maintain your weight" actionWithDuration:2.0f color:@"black"];
}



#pragma mark - Update & Input Events

-(void) accelerometer:(UIAccelerometer *)accelerometer
        didAccelerate:(UIAcceleration *)acceleration
{
	// controls how quickly velocity decelerates (lower = quicker to change direction)
	float deceleration = 0.0001f;
	// determines how sensitive the accelerometer reacts (higher = more sensitive)
	float sensitivity = 300.0f;
	// how fast the velocity can be at most
	float maxVelocity = 700;
    
	// adjust velocity based on current accelerometer acceleration
	float velocityX = knight.velocity.x * deceleration + acceleration.y * sensitivity;
    
	// we must limit the maximum velocity of the player sprite, in both directions
	if (knight.velocity.x > maxVelocity)
	{
		velocityX = maxVelocity;
	}
	else if (knight.velocity.x < - maxVelocity)
	{
		velocityX = - maxVelocity;
	}
    
    knight.velocity = ccp(velocityX, knight.velocity.y);
}

- (void)pushGameStateToMissions
{
    for (Mission *mission in game.missions)
    {
        if (mission.successfullyCompleted)
        {
            // we skip this mission, since it succesfully completed
            continue;
        }
        
        if ([mission respondsToSelector:@selector(generalGameUpdate:)])
        {
            // inform about current game state
            [mission generalGameUpdate:game];
            
            // check if mission is now completed
            if (mission.successfullyCompleted)
            {
                NSString *missionAccomplished = [NSString stringWithFormat:@"Completed: %@", mission.missionDescription];
                [NotificationBox presentNotificationBoxOnNode:self withText:missionAccomplished duration:1.f];
            }
        }
    }
}



-(void) updatePointer
{
    if ([[GameMechanics sharedGameMechanics] game].fatness > 100)
    {   
        [self flashWithRed:255 green:0 blue:0 alpha:255 actionWithDuration:0.5f];
        knight.visible = FALSE;
        [[GameMechanics sharedGameMechanics] game].fatness = 100;
        [self presentGoOnPopUp];
    }
    if ([[GameMechanics sharedGameMechanics] game].fatness < 0)
    {
        [self flashWithRed:255 green:0 blue:0 alpha:255 actionWithDuration:0.5f];
        knight.visible = FALSE;
        [[GameMechanics sharedGameMechanics] game].fatness = 0;
        [self presentGoOnPopUp];
    }
    
    // Implement the score here
    
    [self convertFromPercent:[[GameMechanics sharedGameMechanics] game].fatness];
    pointer.position = pointerPosition;
}

- (void) update:(ccTime)delta
{
    
    // update the amount of in-App currency in pause mode, too
    inAppCurrencyDisplayNode.score = [Store availableAmountInAppCurrency];
    
    if ([[GameMechanics sharedGameMechanics] gameState] == GameStateRunning)
    {
        [self updateRunning:delta];
        
        // check if we need to inform missions about current game state
        updateCount++;
        if ((updateCount % MISSION_UPDATE_FREQUENCY) == 0)
        {
            [self pushGameStateToMissions];
        }
    }
    
    [self updatePointer];
    [self changeStuff];
    [self coinSidewaysRowOne];

    CGRect knightRect = [knight boundingBox];
    for (int i = 0; i < [coinArray count]; i++)
    {
        Coins *coin = [coinArray objectAtIndex:i];
        CGRect coinRect = [coin boundingBox];
        if (CGRectIntersectsRect(knightRect, coinRect))
        {
            [coinArray removeObject:coin];
            [self removeChild:coin];
//            [Store addInAppCurrency:coinValue]; // This is how to add money
        }
    }
}

- (void)updateRunning:(ccTime)delta
{
    // Move coins off the screen and make them move away
    for (int cNum = 0; cNum < [coinArray count]; cNum ++)
    {
        Coins *coin = [coinArray objectAtIndex:cNum];
        // apply background scroll speed
        float backgroundScrollSpeedX = [[GameMechanics sharedGameMechanics] backGroundScrollSpeedX];
        float xSpeed = 1.09 * backgroundScrollSpeedX;
        
        // move the coin until it leaves the left edge of the screen
        if (coin.position.x > (coin.contentSize.width * (-1)))
        {
            coin.position = ccp(coin.position.x - (xSpeed*delta), coin.position.y);
        }
        else
        {
            [self removeChild:coin];
            [coinArray removeObject:coin];
            [self performSelector:@selector(showSpriteAgain:) withObject:coin afterDelay:7.0f];
        }
    }
    
    // distance depends on the current scrolling speed
    gainedDistance += (delta * [[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]) / 2.5;
    game.meters = (int) (gainedDistance);
    // update the score display
    pointsDisplayNode.score = game.meters;
    coinsDisplayNode.score = game.score;
    healthDisplayNode.health = knight.hitPoints;
    
    // the gesture recognizer assumes portrait mode, so we need to use rotated swipe directions
    KKInput* input = [KKInput sharedInput];
    if ([input anyTouchBeganThisFrame])
    {
        [knight jump];
    }
    if (knight.hitPoints == 0)
    {
        // knight died, present screen with option to GO ON for paying some coins
        [self presentGoOnPopUp];
    }
}

-(void) showSpriteAgain:(CCSprite *)coin{
    if ([coinArray count] == 0)
    {
        coinSide1 = FALSE;
    }
}

/*
    These are the methods for displaying the different horizontal rows of coins to generate a horizontal pattern
*/
- (void)coinSidewaysRowOne {
if (coinSide1 == FALSE)
{
    coinSide1 = TRUE;
    NSLog(@"coinSide1 = TRUE");
    int originalX = 500;
    for(int i = 0; i < 8; i++)
    {
        CCSprite *coinHorizontal = [CCSprite spriteWithFile:@"bubble.png"];
        coinHorizontal.position = ccp(originalX, 150);
        originalX += 20;
        
        [self addChild:coinHorizontal];
        [coinArray addObject:coinHorizontal];
    }
    for(int i = 0; i < 8; i++)
    {
        CCSprite *coinHorizontal = [CCSprite spriteWithFile:@"bubble.png"];
        coinHorizontal.position = ccp(originalX, 170);
        originalX += 20;
        
        [self addChild:coinHorizontal];
        [coinArray addObject:coinHorizontal];
    }
    for(int i = 0; i < 8; i++)
    {
        CCSprite *coinHorizontal = [CCSprite spriteWithFile:@"bubble.png"];
        coinHorizontal.position = ccp(originalX, 190);
        originalX += 20;
        
        [self addChild:coinHorizontal];
        [coinArray addObject:coinHorizontal];
    }
    for(int i = 0; i < 8; i++)
    {
        CCSprite *coinHorizontal = [CCSprite spriteWithFile:@"bubble.png"];
        coinHorizontal.position = ccp(originalX, 210);
        originalX += 20;
        
        [self addChild:coinHorizontal];
        [coinArray addObject:coinHorizontal];
    }
}
}

- (void)changeStuff {
    if (pointsDisplayNode.score > 1500) {
         if (fasterSpeed == FALSE) {
            fasterSpeed = TRUE;
             scrollSpeed = 240;
            NSLog(@"Speed Changed 1");
            [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed];
            [[GameMechanics sharedGameMechanics] setSpawnRate:240 forMonsterType:[UnhealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:290 forMonsterType:[HealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:350 forMonsterType:[MyCustomMonster class]];
         }
    }
    if (pointsDisplayNode.score > 3000) {
         if (fasterSpeed2 == FALSE) {
            fasterSpeed2 = TRUE;
            scrollSpeed = 280;
            NSLog(@"Speed Changed 2");
            [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed];
            [[GameMechanics sharedGameMechanics] setSpawnRate:190 forMonsterType:[UnhealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:240 forMonsterType:[HealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:290 forMonsterType:[MyCustomMonster class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:440 forMonsterType:[Apples class]];
        }
    }
    if (pointsDisplayNode.score > 6000) {
         if (fasterSpeed3 == FALSE) {
            fasterSpeed3 = TRUE;
            scrollSpeed = 320;
            NSLog(@"Speed Changed 3");
            [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed];
            [[GameMechanics sharedGameMechanics] setSpawnRate:180 forMonsterType:[UnhealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:230 forMonsterType:[HealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:280 forMonsterType:[MyCustomMonster class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:430 forMonsterType:[Apples class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:600 forMonsterType:[Pizza class]];
         }
    }
    if (pointsDisplayNode.score > 7500) {
         if (fasterSpeed4 == FALSE) {
            fasterSpeed4 = TRUE;
            scrollSpeed = 360;
            NSLog(@"Speed Changed 4");
            [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed];
            [[GameMechanics sharedGameMechanics] setSpawnRate:170 forMonsterType:[UnhealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:220 forMonsterType:[HealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:270 forMonsterType:[MyCustomMonster class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:420 forMonsterType:[Apples class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:570 forMonsterType:[Pizza class]];
         }
    }
    if (pointsDisplayNode.score > 10000) {
         if (fasterSpeed5 == FALSE) {
            fasterSpeed5 = TRUE;
            scrollSpeed = 400;
            NSLog(@"Speed Changed 5");
            [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed];
            [[GameMechanics sharedGameMechanics] setSpawnRate:160 forMonsterType:[UnhealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:210 forMonsterType:[HealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:260 forMonsterType:[MyCustomMonster class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:410 forMonsterType:[Apples class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:500 forMonsterType:[Pizza class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:480 forMonsterType:[Cupcake class]];
         }
    }
    if (pointsDisplayNode.score > 13000) {
         if (fasterSpeed6 == FALSE) {
            fasterSpeed6 = TRUE;
            scrollSpeed = 440;
            NSLog(@"Speed Changed 6");
            [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed];
            [[GameMechanics sharedGameMechanics] setSpawnRate:150 forMonsterType:[UnhealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:200 forMonsterType:[HealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:250 forMonsterType:[MyCustomMonster class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:400 forMonsterType:[Apples class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:500 forMonsterType:[Pizza class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:460 forMonsterType:[Cupcake class]];
         }
    }
    if (pointsDisplayNode.score > 16500) {
         if (fasterSpeed7 == FALSE) {
            fasterSpeed7 = TRUE;
            scrollSpeed = 480;
            NSLog(@"Speed Changed 7");
            [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed];
            [[GameMechanics sharedGameMechanics] setSpawnRate:140 forMonsterType:[UnhealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:190 forMonsterType:[HealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:240 forMonsterType:[MyCustomMonster class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:390 forMonsterType:[Apples class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:500 forMonsterType:[Pizza class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:450 forMonsterType:[Cupcake class]];
         }
    }
    if (pointsDisplayNode.score > 20000) {
         if (fasterSpeed8 == FALSE) {
            fasterSpeed8 = TRUE;
            scrollSpeed = 500;
            NSLog(@"Speed Changed 8");
            [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed];
            [[GameMechanics sharedGameMechanics] setSpawnRate:130 forMonsterType:[UnhealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:180 forMonsterType:[HealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:230 forMonsterType:[MyCustomMonster class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:380 forMonsterType:[Apples class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:500 forMonsterType:[Pizza class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:440 forMonsterType:[Cupcake class]];
         }
    }
    if (pointsDisplayNode.score > 22500) {
         if (fasterSpeed9 == FALSE) {
            fasterSpeed9 = TRUE;
            scrollSpeed = 520;
            NSLog(@"Speed Changed 9");
            [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed];
            [[GameMechanics sharedGameMechanics] setSpawnRate:120 forMonsterType:[UnhealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:170 forMonsterType:[HealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:220 forMonsterType:[MyCustomMonster class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:370 forMonsterType:[Apples class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:500 forMonsterType:[Pizza class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:410 forMonsterType:[Cupcake class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:510 forMonsterType:[Strawberries class]];
         }
    }
    if (pointsDisplayNode.score > 25000) {
         if (fasterSpeed10 == FALSE) {
            fasterSpeed10 = TRUE;
            scrollSpeed = 540;
            NSLog(@"Speed Changed 10");
            [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed];
            [[GameMechanics sharedGameMechanics] setSpawnRate:110 forMonsterType:[UnhealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:160 forMonsterType:[HealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:210 forMonsterType:[MyCustomMonster class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:360 forMonsterType:[Apples class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:500 forMonsterType:[Pizza class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:410 forMonsterType:[Cupcake class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:510 forMonsterType:[Strawberries class]];
         }
    }
    if (pointsDisplayNode.score > 27500) {
         if (fasterSpeed11 == FALSE) {
            fasterSpeed11 = TRUE;
            scrollSpeed = 560;
            NSLog(@"Speed Changed 11");
            [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed];
            fasterSpeed11 = TRUE;
            [[GameMechanics sharedGameMechanics] setSpawnRate:100 forMonsterType:[UnhealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:150 forMonsterType:[HealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:200 forMonsterType:[MyCustomMonster class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:350 forMonsterType:[Apples class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:500 forMonsterType:[Pizza class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:410 forMonsterType:[Cupcake class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:510 forMonsterType:[Strawberries class]];
         }
    }
    if (pointsDisplayNode.score > 30000) {
         if (fasterSpeed12 == FALSE) {
            fasterSpeed12 = TRUE;
            scrollSpeed = 580;
            NSLog(@"Speed Changed 12");
            [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed];
            [[GameMechanics sharedGameMechanics] setSpawnRate:90 forMonsterType:[UnhealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:140 forMonsterType:[HealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:190 forMonsterType:[MyCustomMonster class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:340 forMonsterType:[Apples class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:500 forMonsterType:[Pizza class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:560 forMonsterType:[Fries class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:410 forMonsterType:[Cupcake class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:510 forMonsterType:[Strawberries class]];
        }
    }
    if (pointsDisplayNode.score > 32500) {
         if (fasterSpeed13 == FALSE) {
            fasterSpeed13 = TRUE;
            scrollSpeed = 600;
            NSLog(@"Speed Changed 13");
            [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed];
            [[GameMechanics sharedGameMechanics] setSpawnRate:80 forMonsterType:[UnhealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:130 forMonsterType:[HealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:180 forMonsterType:[MyCustomMonster class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:330 forMonsterType:[Apples class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:500 forMonsterType:[Pizza class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:360 forMonsterType:[Chicken class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:540 forMonsterType:[Fries class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:390 forMonsterType:[Cupcake class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:490 forMonsterType:[Strawberries class]];
         }
    }
    if (pointsDisplayNode.score > 35000) {
         if (fasterSpeed14 == FALSE) {
            fasterSpeed14 = TRUE;
            scrollSpeed = 620;
            NSLog(@"Speed Changed 14");
            [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed];
            [[GameMechanics sharedGameMechanics] setSpawnRate:70 forMonsterType:[UnhealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:120 forMonsterType:[HealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:170 forMonsterType:[MyCustomMonster class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:320 forMonsterType:[Apples class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:500 forMonsterType:[Pizza class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:360 forMonsterType:[Chicken class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:640 forMonsterType:[Fries class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:390 forMonsterType:[Cupcake class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:540 forMonsterType:[Oranges class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:490 forMonsterType:[Strawberries class]];
         }
    }
    if (pointsDisplayNode.score > 37500) {
         if (fasterSpeed15 == FALSE) {
            fasterSpeed15 = TRUE;
            scrollSpeed = 640;
            NSLog(@"Speed Changed 15");
            [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed];
            [[GameMechanics sharedGameMechanics] setSpawnRate:60 forMonsterType:[UnhealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:110 forMonsterType:[HealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:160 forMonsterType:[MyCustomMonster class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:310 forMonsterType:[Apples class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:500 forMonsterType:[Pizza class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:360 forMonsterType:[Chicken class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:740 forMonsterType:[Cake class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:640 forMonsterType:[Fries class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:390 forMonsterType:[Cupcake class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:540 forMonsterType:[Oranges class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:490 forMonsterType:[Strawberries class]];
         }
    }
    if (pointsDisplayNode.score > 40000) {
         if (fasterSpeed16 == FALSE) {
            fasterSpeed16 = TRUE;
            scrollSpeed = 660;
            NSLog(@"Speed Changed 16");
            [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed];
            [[GameMechanics sharedGameMechanics] setSpawnRate:50 forMonsterType:[UnhealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:100 forMonsterType:[HealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:150 forMonsterType:[MyCustomMonster class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:300 forMonsterType:[Apples class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:500 forMonsterType:[Pizza class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:340 forMonsterType:[Chicken class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:720 forMonsterType:[Cake class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:620 forMonsterType:[Fries class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:370 forMonsterType:[Cupcake class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:520 forMonsterType:[Oranges class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:470 forMonsterType:[Strawberries class]];
         }
    }
    if (pointsDisplayNode.score > 42500) {
         if (fasterSpeed17 == FALSE) {
            fasterSpeed17 = TRUE;
            scrollSpeed = 680;
            NSLog(@"Speed Changed 17");
            [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed];
            [[GameMechanics sharedGameMechanics] setSpawnRate:40 forMonsterType:[UnhealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:190 forMonsterType:[HealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:140 forMonsterType:[MyCustomMonster class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:290 forMonsterType:[Apples class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:500 forMonsterType:[Pizza class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:140 forMonsterType:[Chicken class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:620 forMonsterType:[Cake class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:520 forMonsterType:[Fries class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:270 forMonsterType:[Cupcake class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:420 forMonsterType:[Oranges class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:370 forMonsterType:[Strawberries class]];
         }
    }
    if (pointsDisplayNode.score > 45000) {
         if (fasterSpeed18 == FALSE) {
            fasterSpeed18 = TRUE;
            scrollSpeed = 700;
            NSLog(@"Speed Changed 18");
            [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed];
            [[GameMechanics sharedGameMechanics] setSpawnRate:30 forMonsterType:[UnhealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:180 forMonsterType:[HealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:130 forMonsterType:[MyCustomMonster class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:280 forMonsterType:[Apples class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:500 forMonsterType:[Pizza class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:110 forMonsterType:[Chicken class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:600 forMonsterType:[Cake class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:500 forMonsterType:[Fries class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:250 forMonsterType:[Cupcake class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:400 forMonsterType:[Oranges class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:350 forMonsterType:[Strawberries class]];
         }
    }
    if (pointsDisplayNode.score > 47500) {
         if (fasterSpeed19 == FALSE) {
            fasterSpeed19 = TRUE;
            scrollSpeed = 720;
            NSLog(@"Speed Changed 19");
            [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed];
            [[GameMechanics sharedGameMechanics] setSpawnRate:20 forMonsterType:[UnhealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:170 forMonsterType:[HealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:120 forMonsterType:[MyCustomMonster class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:270 forMonsterType:[Apples class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:500 forMonsterType:[Pizza class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:110 forMonsterType:[Chicken class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:600 forMonsterType:[Cake class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:500 forMonsterType:[Fries class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:250 forMonsterType:[Cupcake class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:400 forMonsterType:[Oranges class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:350 forMonsterType:[Strawberries class]];
         }
    }
    if (pointsDisplayNode.score > 50000) {
         if (fasterSpeed20 == FALSE) {
            fasterSpeed20 = TRUE;
            scrollSpeed = 740;
            NSLog(@"Speed Changed 20");
            [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed];
            [[GameMechanics sharedGameMechanics] setSpawnRate:10 forMonsterType:[UnhealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:160 forMonsterType:[HealthyFood class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:110 forMonsterType:[MyCustomMonster class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:260 forMonsterType:[Apples class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:300 forMonsterType:[Pizza class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:110 forMonsterType:[Chicken class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:600 forMonsterType:[Cake class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:500 forMonsterType:[Fries class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:250 forMonsterType:[Cupcake class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:400 forMonsterType:[Oranges class]];
            [[GameMechanics sharedGameMechanics] setSpawnRate:350 forMonsterType:[Strawberries class]];
         }
    }
}

#pragma mark - Scene Lifecycle

- (void)onEnterTransitionDidFinish
{
    // setup a gesture listener for jumping and stabbing gestures
    [KKInput sharedInput].gestureSwipeEnabled = TRUE;
    // register for accelerometer input, to controll the knight
    self.accelerometerEnabled = YES;
    
    if (self.showMainMenu)
    {
        // add main menu
        MainMenuLayer *mainMenuLayer = [[MainMenuLayer alloc] init];
        [self addChild:mainMenuLayer z:MAX_INT];
        [self hideHUD:TRUE];
        [self disableGameplayButtons];

    } else
    {
        // start game directly
        [self showHUD:TRUE];
        [self startGame];
    }
}

- (void)onExit
{
    // very important! deactivate the gestureInput, otherwise touches on scrollviews and tableviews will be cancelled!
    [KKInput sharedInput].gestureSwipeEnabled = FALSE;
    self.accelerometerEnabled = FALSE;
}

#pragma mark - UI

- (void)presentGoOnPopUp
{
    [[GameMechanics sharedGameMechanics] setGameState:GameStatePaused];
    CCScale9Sprite *backgroundImage = [StyleManager goOnPopUpBackground];
    goOnPopUp = [PopupProvider presentPopUpWithContentString:nil backgroundImage:backgroundImage target:self selector:@selector(goOnPopUpButtontaped:) buttonTitles:@[@"OK", @"No"]];
    [self disableGameplayButtons];
    
}

- (void)showHUD:(BOOL)animated
{
    // TODO: implement animated
    hudNode.visible = TRUE;
}

- (void)hideHUD:(BOOL)animated
{
    // TODO: implement animated
    hudNode.visible = FALSE;
}

- (void)presentSkipAheadButtonWithDuration:(NSTimeInterval)duration
{
    skipAheadMenu.visible = TRUE;
    skipAheadMenu.opacity = 0.f;
    CCFadeIn *fadeIn = [CCFadeIn actionWithDuration:0.5f];
    [skipAheadMenu runAction:fadeIn];
    
    [self scheduleOnce: @selector(hideSkipAheadButton) delay:duration];
}

- (void)hideSkipAheadButton
{
    CCFiniteTimeAction *fadeOut = [CCFadeOut actionWithDuration:1.5f];
    CCCallBlock *hide = [CCCallBlock actionWithBlock:^{
        // execute this code to hide the 'Skip Ahead'-Button, once it is faded out
        skipAheadMenu.visible = FALSE;
        // enable again, so that interaction is possible as soon as the menu is visible again
        skipAheadMenu.enabled = TRUE;
    }];
    
    CCSequence *fadeOutAndHide = [CCSequence actions:fadeOut, hide, nil];
    
    [skipAheadMenu runAction:fadeOutAndHide];
}

- (void)disableGameplayButtons
{
    pauseButtonMenu.enabled = FALSE;
    skipAheadMenu.enabled = FALSE;
}
- (void)enableGamePlayButtons
{
    pauseButtonMenu.enabled = TRUE;
    skipAheadMenu.enabled = TRUE;
}

-(void) flashWithRed:(int) red green:(int) green blue:(int) blue alpha:(int) alpha actionWithDuration:(float) duration
{
    colorLayer = [CCLayerColor layerWithColor:ccc4(red, green, blue, alpha)];
    [self addChild:colorLayer z:0];
    id delay = [CCDelayTime actionWithDuration:duration];
    id fadeOut = [CCFadeOut actionWithDuration:0.9f];
    id remove = [CCCallFunc actionWithTarget:self selector:@selector(removeFlashColor)];
    [colorLayer runAction:[CCSequence actions:delay, fadeOut, remove, nil]];
    
}

-(void) removeFlashColor
{
    [self removeChild:colorLayer cleanup:YES];
}

#pragma mark - Delegate Methods

/*
 This method is called, when purchases on the In-Game-Store occur.
 Then we need to update the coins display on the HUD.
 */
- (void)storeDisplayNeedsUpdate
{
    inAppCurrencyDisplayNode.score = [Store availableAmountInAppCurrency];
}

- (void)resumeButtonPressed:(PauseScreen *)pauseScreen
{
    // enable the pause button again, since the pause menu is hidden now
    [self enableGamePlayButtons];
}

#pragma mark - Button Callbacks

- (void)skipAheadButtonPressed
{
    if ([Store hasSufficientFundsForSkipAheadAction])
    {
        skipAheadMenu.enabled = FALSE;
        CCLOG(@"Skip Ahead!");
        [self startSkipAheadMode];
        
        // hide the skip ahead button, after it was pressed
        // we need to cancel the previously scheduled perform selector...
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideSkipAheadButton) object:nil];
        
        // ... in order to execute it directly
        [self hideSkipAheadButton];
    } else
    {
        // pause the game, to allow the player to buy coins
        [[GameMechanics sharedGameMechanics] setGameState:GameStatePaused];
        [self presentMoreCoinsPopUpWithTarget:self selector:@selector(returnedFromMoreCoinsScreenFromSkipAheadAction)];
    }
//    [[SimpleAudioEngine sharedEngine] playEffect:@"select.mp3"];
}

- (void)goOnPopUpButtontaped:(CCControlButton *)sender
{
    CCLOG(@"Button tapped.");
    if (sender.tag == 0)
    {
        if ([Store hasSufficientFundsForGoOnAction])
        {
            // OK button selected
            [goOnPopUp dismiss];
            [self executeGoOnAction];
            [self enableGamePlayButtons];
            knight.visible = TRUE;
            [self resetFatness];
            
        } else
        {
            // game is paused in this state already, we only need to present the more coins screen
            // dismiss the popup; presented again when we return from the 'Buy More Coins'-Screen
            [goOnPopUp dismiss];
            [self presentMoreCoinsPopUpWithTarget:self selector:@selector(returnedFromMoreCoinsScreenFromGoOnAction)];
        }
    } else if (sender.tag == 1)
    {
        // Cancel button selected
        [goOnPopUp dismiss];
        game.score ++;
        
        // IMPORTANT: set game state to 'GameStateMenu', otherwise menu animations will no be played
        [[GameMechanics sharedGameMechanics] setGameState:GameStateMenu];
        
        RecapScreenScene *recap = [[RecapScreenScene alloc] initWithGame:game];
        [[CCDirector sharedDirector] replaceScene:recap];
    }
}

-(void)resetFatness {
    [[GameMechanics sharedGameMechanics] game].fatness = 50;
}

- (void)pauseButtonPressed
{
//    [[SimpleAudioEngine sharedEngine] playEffect:@"select.mp3"];
    NSLog(@"Pause");
    // disable pause button while the pause menu is shown, since we want to avoid, that the pause button can be hit twice.
    [self disableGameplayButtons];
    
    PauseScreen *pauseScreen = [[PauseScreen alloc] initWithGame:game];
    pauseScreen.delegate = self;
    [self addChild:pauseScreen z:10];
    [pauseScreen present];
    [[GameMechanics sharedGameMechanics] setGameState:GameStatePaused];
}

#pragma mark - Game Logic

- (void)executeGoOnAction
{
    [Store purchaseGoOnAction];
    knight.hitPoints = KNIGHT_HIT_POINTS;
    [[GameMechanics sharedGameMechanics] setGameState:GameStateRunning];
    [NotificationBox presentNotificationBoxOnNode:self withText:@"Going on!" duration:1.f];
}

- (void)startSkipAheadMode
{
    BOOL successful = [Store purchaseSkipAheadAction];
    
    /*
     Only enter the skip ahead mode if the purchase was successful (player had enough coins).
     This is checked previously, but we want to got sure that the player can never access this item
     without paying.
     */
    if (successful)
    {
        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:SCROLL_SPEED_SKIP_AHEAD];
        [[GameMechanics sharedGameMechanics] knight].invincible = TRUE;
        [self scheduleOnce: @selector(endSkipAheadMode) delay:5.f];
        
        // present a notification, to inform the user, that he is in skip ahead mode
        [NotificationBox presentNotificationBoxOnNode:self withText:@"Skip Ahead Mode!" duration:4.5f];
    }
}

- (void)endSkipAheadMode
{    
 
    [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed];
    
    [[GameMechanics sharedGameMechanics] knight].invincible = FALSE;
}

- (void)presentMoreCoinsPopUpWithTarget:(id)target selector:(SEL)selector
{
    CCLOG(@"You need more coins!");
    NSArray *inGameStoreItems = [Store inGameStoreStoreItems];
    
    /*
     The inGameStore is initialized with a callback method, which is called,
     once the closebutton is pressed.
     */
    inGameStore = [[InGameStore alloc] initWithStoreItems:inGameStoreItems backgroundImage:@"InGameStore_background.png" closeButtonImage:@"InGameStore_close.png" target:target selector:selector];
    /* The delegate adds a further callback, called when Items are purchased on the store, and we need to update our coin display */
    inGameStore.delegate = self;
    
    inGameStore.position = ccp(self.contentSize.width / 2, self.contentSize.height + 0.5 * inGameStore.contentSize.height);
    CGPoint targetPosition = ccp(self.contentSize.width / 2, self.contentSize.height /2);
    
    CCMoveTo *moveTo = [CCMoveTo actionWithDuration:1.f position:targetPosition];
    [self addChild:inGameStore z:MAX_INT];
    
    [inGameStore runAction:moveTo];
}


/* called when the 'More Coins Screen' has been closed, after previously beeing opened by
 attempting to buy a 'Skip Ahead' action */
- (void)returnedFromMoreCoinsScreenFromSkipAheadAction
{
    // hide store and resume game
    [inGameStore removeFromParent];
    [[GameMechanics sharedGameMechanics] setGameState:GameStateRunning];
    [self enableGamePlayButtons];
}


- (void)returnedFromMoreCoinsScreenFromGoOnAction
{
    [inGameStore removeFromParent];
    [self presentGoOnPopUp];
}

@end
