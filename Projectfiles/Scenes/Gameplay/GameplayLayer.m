//
//  GameplayScene.m
//  _MGWU-SideScroller-Template_
//
//  Created by Shalin Shah on 5/15/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//
//
//

/*
 So this is the objective of the game: You are the last person remaining on earth all the food has gone bad. So you have to try and maintain your weight to save the human race from extinction. You have to try to not get too fat, or get too skinny and pass out, otherwise, the extinction of the human race will be blamed upon you.
 */
/*
 
 GAMEPLAY IDEAS:
 1). MAKE THE TOOLBAR MOVE SMOOTHLY WHEN FAT OR SKINNY FOODS ARE COLLECTED
 2). MAKE THE TOOLBAR'S POINTER SLOWLY MOVE DOWN (IMPLEMENTED)
 3). MAKE THE MISSIONS WORK (IMPLEMENTED)
 4). ADD THE STORE (IMPLEMENTED)
 5). ADD AROUND 30 ITEMS TO THE STORE
 6). ADD POWERUPS (ALMOST DONE)
 7). CHANGE THE STORE TEXT TO A STORE ICON
 8). EMERGENCY PROTEIN BAR THAT GETS YOU BACK TO THE MIDDLE (THE BAR STICKS ON THE CORNER)
 9). IF YOU DIE, A CLOUD COMES AND ATTACKS YOU WITH FOOD (TO GIVE YOU SOME BONUS POINTS)
 10).
 
 PROTEIN BARS - MAKES YOU IMMUNE TO FAT FOODS
 CARB BOOST - MAKES YOU LOSE WEIGHT FASTER
 FIVE HOUR ENERGY - MAKES YOU RUN UPSIDE DOWN
 
 
 Die certain times
 Collect fatty foods in a row
 Go combined total of 500,000 meters
 Collect certain coins
 Explode 7 times
 Die of fatness certainn times
 Die of thiness certain times
 Run a certain meters going upside down
 
 */

#import "SimpleAudioEngine.h"
#import "GameplayLayer.h"
#import "ParallaxBackground.h"
#import "Game.h"
#import "Coins.h"
#import "Sandwich.h"
#import "Apples.h"
#import "Bread.h"
#import "Broccoli.h"
#import "Carrots.h"
#import "Corn.h"
#import "Eggs.h"
#import "Fish.h"
#import "Grapefruit.h"
#import "Hotdog.h"
#import "Kiwi.h"
#import "Lemons.h"
#import "Meat.h"
#import "Pear.h"
#import "Tomato.h"
#import "Watermelon.h"
#import "Donuts.h"
#import "Chicken.h"
#import "Oranges.h"
#import "Pizza.h"
#import "Strawberries.h"
#import "Banana.h"
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
#import "DecorativeObjectsNode.h"
#import "STYLES.h"
#import "Powers.h"

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

+ (id)scene {
    CCScene *scene = [CCScene node];
    GameplayLayer* layer = [GameplayLayer node];
    
    // By default we want to show the main menu
    layer.showMainMenu = FALSE;
    
    [scene addChild:layer];
    return scene;
}

+ (id)noMenuScene {
    CCScene *scene = [CCScene node];
    GameplayLayer* layer = [GameplayLayer node];
    
    // By default we want to show the main menu
    layer.showMainMenu = FALSE;
    
    [scene addChild:layer];
    return scene;
}

#pragma mark - Initialization

- (void)dealloc {
    // When our object is removed, we need to unregister from all notifications.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init {
    self = [super init];
    if (self) {
        
        scrollSpeed = 280.0f;
        if (IS_IPOD || IS_IPAD_RETINA) {
            scrollSpeed = 600.0f;
        }
        
        // Coin Stuff
        coinPattern1 = FALSE;
        sidewaysCoins = 7;
        coinValue = 1;
        coinsCollected = 0;
        
        powerUpShow = FALSE;
        powerUpThreeOn = FALSE;
        randomPowerup = FALSE;
        
        // get screen center and screen size
        screenSize = [[CCDirector sharedDirector] winSize];
        screenCenter = ccp(screenSize.width/2, screenSize.height/2);
        
        //Preload the music
        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"fly.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"coins.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"select.mp3"];
        
        // Play the Music
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"fly.mp3" loop:TRUE];
        
        // Preload particle effects
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
        knight = [[Knight alloc] initWithKnightPicture:@"fatguyfredL3"];
        [self addChild:knight];
        knight.anchorPoint = ccp(0,0);
        
        // add scoreboard entry for in-app currency
        inAppCurrencyDisplayNode = [[ScoreboardEntryNode alloc] initWithScoreImage:@"coin-mode.png" fontFile:@"avenir.fnt"];
        inAppCurrencyDisplayNode.scoreStringFormat = @"%d";
        inAppCurrencyDisplayNode.position = ccp(15, self.contentSize.height - 20);
        if ([[CCDirector sharedDirector] winSizeInPixels].width == 2048) {
            inAppCurrencyDisplayNode.position = ccp(45, self.contentSize.height - 35);
        }
        inAppCurrencyDisplayNode.score = coinsCollected;
        [hudNode addChild:inAppCurrencyDisplayNode z:10000];
        
        // add scoreboard entry for points
        pointsDisplayNode = [[ScoreboardEntryNode alloc] initWithScoreImage:nil fontFile:@"avenir24.fnt"];
        pointsDisplayNode.position = ccp(10, self.contentSize.height - 50);
        if ([[CCDirector sharedDirector] winSizeInPixels].width == 2048) {
            pointsDisplayNode.position = ccp(40, self.contentSize.height - 75);
        }
        pointsDisplayNode.scoreStringFormat = @"%d m";
        [hudNode addChild:pointsDisplayNode z:1000];
        
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
        CCSprite *pauseButtonPressed = [CCSprite spriteWithFile:@"pause-down.png"];
        pauseButton.scale = 1.5;
        pauseButtonPressed.scale = 1.5;
        pauseButtonMenuItem = [CCMenuItemSprite itemWithNormalSprite:pauseButton selectedSprite:pauseButtonPressed target:self selector:@selector(pauseButtonPressed)];
        pauseButtonMenu = [CCMenu menuWithItems:pauseButtonMenuItem, nil];
        pauseButtonMenu.position = ccp(self.contentSize.width - 30, self.contentSize.height - 30);
        [hudNode addChild:pauseButtonMenu];
        
        // SET UP TOOLBAR, POINTER, AND FATNESS
        toolBar = [CCSprite spriteWithFile:@"weight-bar.png"];
        pointer = [CCSprite spriteWithFile:@"weight-indicator.png"];
        toolBar.position = ccp(screenCenter.x,screenSize.height-24);
        if ([[CCDirector sharedDirector] winSizeInPixels].width == 2048) {
            toolBar.position = ccp(screenCenter.x,screenSize.height-35);
        }
        toolBar.scale = 1.3;
        pointer.scale = 1.3;
        
        // Set Up Tutorial Images and Arrows
        tapGesture = [CCSprite spriteWithFile:@"tap-screen.png"];
        tapGesture.scale = 0.6f;
        tapGesture.position = ccp(screenCenter.x, screenCenter.y - 75);
        [self addChild:tapGesture z:1000];
        tapGesture.visible = false;
        
        tiltPic = [CCSprite spriteWithFile:@"tilt-screen.png"];
        tiltPic.position = ccp(screenCenter.x, screenCenter.y - 65);
        [self addChild:tiltPic z:1000];
        tiltPic.scale = 0.6f;
        tiltPic.visible = false;
        
        toolbarArrows = [CCSprite spriteWithFile:@"arrows.png"];
        toolbarArrows.position = ccp(screenCenter.x, screenCenter.y + 50);
        [self addChild:toolbarArrows z:1000];
        toolbarArrows.visible = false;

        // Set up Tutorial
        tut = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:30];
        tut.position = screenCenter;
        [self addChild:tut z:10000];
        tut.visible = FALSE;
        BOOL tutorialStatusCheck = [[NSUserDefaults standardUserDefaults] boolForKey:@"tutorialStatus"];
        if (tutorialStatusCheck == FALSE) {
            playedTutorial = FALSE;
        } else {
            playedTutorial = [[NSUserDefaults standardUserDefaults] objectForKey:@"tutorialStatus"];
        }
        
        [self convertFromPercent:[[GameMechanics sharedGameMechanics] game].fatness];
        
        // add the enemy cache containing all spawned enemies
        [self addChild:[EnemyCache node]];
        
        // add decorative node
        //[self addChild:[DecorativeObjectsNode node]];
        
        coinArray = [[NSMutableArray alloc] init];
        powerUpArray = [[NSMutableArray alloc] init];
        
        // setup a new gaming session
        [self resetGame];
        [self scheduleUpdate];
        
        /**
         A Notification can be used to broadcast an information to all objects of a game, that are interested in it.
         Here we sign up for the 'GamePaused' and 'GameResumed' information, that is broadcasted by the GameMechanics class. Whenever the game pauses or resumes, we get informed and can react accordingly.
         **/
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gamePaused) name:@"GamePaused" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameResumed) name:@"GameResumed" object:nil];
    }
    return self;
}
/*
 Useful Little Code Snippets that make my life easier
 */
-(void)resizeSprite:(CCSprite*)sprite toWidth:(float)width toHeight:(float)height {
    sprite.scaleX = width / sprite.contentSize.width;
    sprite.scaleY = height / sprite.contentSize.height;
}

-(void) flashLabel:(NSString *) stringToFlashOnScreen actionWithDuration:(float) numSecondsToFlash color:(NSString *) colorString {
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
-(void) makeFlashLabelVisible {
    tut.visible = TRUE;
}
-(void) makeFlashLabelInvisible {
    tut.visible = FALSE;
}
-(void) convertFromPercent:(float) floatToConvert {
    float percentVal = ([toolBar boundingBox].size.width)/100;
    float percent = floatToConvert * percentVal;
    pointerPosition = ccp(percent+(screenCenter.x/2), toolBar.position.y);
}
- (void)gamePaused {
    [self pauseSchedulerAndActions];
}
- (void)gameResumed {
    [self resumeSchedulerAndActions];
}

#pragma mark - Reset Game

- (void)startGame {
    [[GameMechanics sharedGameMechanics] setGameState:GameStateRunning];
    [self enableGamePlayButtons];
    [self presentSkipAheadButtonWithDuration:5.f];
    /*
     inform all missions, that they have started
     */
    for (Mission *m in game.missions) {
        [m missionStart:game];
    }
    [self addChild:toolBar z:-2];
    [self addChild:pointer];
    [self startTutorial];
    [self schedule:@selector(moveDown:)];
    [self resetJumps];
}

- (void)quit
{
    [[GameMechanics sharedGameMechanics] setGameState:GameStatePaused];
    [[CCDirector sharedDirector] replaceScene: [CCTransitionSlideInT transitionWithDuration:0.5f scene:[MainMenuLayer node]]];
    [self resetFatness];
}
- (void)reset {
    [[GameMechanics sharedGameMechanics] setGameState:GameStatePaused];
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
    coinsDisplayNode.score = coinsCollected;
    pointsDisplayNode.score = game.meters;
    
    // set spwan rate for monsters
    [[GameMechanics sharedGameMechanics] setSpawnRate:240 forMonsterType:[Sandwich class]];
    [[GameMechanics sharedGameMechanics] setSpawnRate:290 forMonsterType:[Pear class]];
    [[GameMechanics sharedGameMechanics] setSpawnRate:350 forMonsterType:[Banana class]];
    
    // set gravity (used for jumps)
    [[GameMechanics sharedGameMechanics] setWorldGravity:ccp(0.f, -740.f)];
    
    // set the floor height, this will be the minimum y-Position for all entities
    [[GameMechanics sharedGameMechanics] setFloorHeight:20.f];
    
    [self resetFatness];
    [self resetJumps];
    coinPattern1 = FALSE;
}

-(void) startTutorial
{
    // Uses NSUserDefaults so doesn't appear twice
    if (playedTutorial == FALSE) {
        playedTutorial = TRUE;
        id delay = [CCDelayTime actionWithDuration:4.0f];
        id image1 = [CCCallFunc actionWithTarget:self selector:@selector(image1)];
        id image2 = [CCCallFunc actionWithTarget:self selector:@selector(image2)];
        id image3 = [CCCallFunc actionWithTarget:self selector:@selector(image3)];
        id part1 = [CCCallFunc actionWithTarget:self selector:@selector(tutorial1)];
        id part2 = [CCCallFunc actionWithTarget:self selector:@selector(tutorial2)];
        id part3 = [CCCallFunc actionWithTarget:self selector:@selector(tutorial3)];
        CCSequence *tutorialSeq = [CCSequence actions:part1, delay, image1, part2, delay, image2, part3, delay, image3, nil];
        [self runAction:tutorialSeq];
        [[NSUserDefaults standardUserDefaults] setBool:playedTutorial forKey:@"tutorialStatus"];
    }
}
-(void) image1 {
    tapGesture.visible = false;
}
-(void) image2 {
    tiltPic.visible = false;
}
-(void) image3 {
    toolbarArrows.visible = false;
}
-(void) tutorial1 {
    tapGesture.visible = true;
    [self flashLabel:@"Tap to jump" actionWithDuration:2.0f color:@"black"];
}
-(void) tutorial2 {
    tiltPic.visible = true;
    [self flashLabel:@"Tilt device" actionWithDuration:2.0f color:@"black"];
}
-(void) tutorial3 {
    toolbarArrows.visible = true;
}



#pragma mark - Update & Input Events

-(void) accelerometer:(UIAccelerometer *)accelerometer
        didAccelerate:(UIAcceleration *)acceleration
{
	// controls how quickly velocity decelerates (lower = quicker to change direction)
	float deceleration = 0.0001f;
	// determines how sensitive the accelerometer reacts (higher = more sensitive)
	float sensitivity = 500.0f;
	// how fast the velocity can be at most
	float maxVelocity = 1500;
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

- (void)pushGameStateToMissions {
    for (Mission *mission in game.missions) {
        if (mission.successfullyCompleted) {
            // we skip this mission, since it succesfully completed
            continue;
        }
        if ([mission respondsToSelector:@selector(generalGameUpdate:)]) {
            // inform about current game state
            [mission generalGameUpdate:game];
            // check if mission is now completed
            if (mission.successfullyCompleted) {
                NSString *missionAccomplished = [NSString stringWithFormat:@"Completed: %@", mission.missionDescription];
                [NotificationBox presentNotificationBoxOnNode:self withText:missionAccomplished duration:1.f];
            }
        }
    }
}

-(void) updatePointer {
    if ([[GameMechanics sharedGameMechanics] game].fatness >= 100) {
        [self flashWithRed:255 green:0 blue:0 alpha:255 actionWithDuration:0.5f];
        knight.visible = FALSE;
        [[GameMechanics sharedGameMechanics] game].fatness = 100;
        [self presentGoOnPopUp];
    }
    if ([[GameMechanics sharedGameMechanics] game].fatness <= 0) {
        [self flashWithRed:255 green:0 blue:0 alpha:255 actionWithDuration:0.5f];
        knight.visible = FALSE;
        [[GameMechanics sharedGameMechanics] game].fatness = 0;
        [self presentGoOnPopUp];
    }
    framesPast++;
    [self convertFromPercent:[[GameMechanics sharedGameMechanics] game].fatness];
    pointer.position = pointerPosition;
    //    CCMoveTo *pointerPos = [CCMoveTo actionWithDuration:5.f position:pointerPosition];
    //    [pointer runAction:pointerPos];
}

-(void) moveDown:(ccTime) dt
{
    framesPast = framesPast % 60;
    if (framesPast == 0) {
        [[GameMechanics sharedGameMechanics] game].fatness -= 0.000001 * 0.000001;
    }
}

- (void) update:(ccTime)delta
{
    // update the amount of in-App currency in pause mode, too
    inAppCurrencyDisplayNode.score = coinsCollected;
    
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
    if (powerUpThreeOn == FALSE){
        [self changeStuff];
    }
    [self patternOne];
    [self powerUpShow];
    
    CGRect knightRect = [knight boundingBox];
    for (NSUInteger i = 0; i < [coinArray count]; i++)
    {
        Coins *coin = [coinArray objectAtIndex:i];
        CGRect coinRect = [coin boundingBox];
        if (CGRectIntersectsRect(knightRect, coinRect))
        {
            [coinArray removeObject:coin];
            [self removeChild:coin];
            coinsCollected += coinValue;
            //            [Store addInAppCurrency:coinValue];
            [[SimpleAudioEngine sharedEngine] playEffect:@"coins.mp3"];
        }
    }
    [self powersCollisionDetection];
}

- (void)updateRunning:(ccTime)delta
{
    // Move coins off the screen and make them move away
    for (NSUInteger cNum = 0; cNum < [coinArray count]; cNum ++) {
        Coins *coin = [coinArray objectAtIndex:cNum];
        // apply background scroll speed
        float backgroundScrollSpeedX = [[GameMechanics sharedGameMechanics] backGroundScrollSpeedX];
        float xSpeed = 1 * backgroundScrollSpeedX;
        
        // move the coin until it leaves the left edge of the screen
        if (coin.position.x > (coin.contentSize.width * (-1))) {
            coin.position = ccp(coin.position.x - (xSpeed*delta), coin.position.y);
        }
        else {
            [self removeChild:coin];
            [coinArray removeObject:coin];
            [self performSelector:@selector(showSpriteAgain:) withObject:coin afterDelay:5.0f];
        }
    }
    
    // Move the powerups off the screen and make them move away
    for (NSUInteger cNum = 0; cNum < [powerUpArray count]; cNum ++) {
        Powers *powerUp = [powerUpArray objectAtIndex:cNum];
        float backgroundScrollSpeedX = [[GameMechanics sharedGameMechanics] backGroundScrollSpeedX];
        float xSpeed = 1 * backgroundScrollSpeedX;
        if (powerUp.position.x > (powerUp.contentSize.width * (-1))) {
            powerUp.position = ccp(powerUp.position.x - (xSpeed*delta), powerUp.position.y);
        }
        else {
            [self removeChild:powerUp];
            [powerUpArray removeObject:powerUp];
        }
    }
    
    // distance depends on the current scrolling speed
    gainedDistance += (delta * [[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]) / 2.6;
    game.meters = (int) (gainedDistance);
    // update the score display
    pointsDisplayNode.score = game.meters;
    coinsDisplayNode.score = coinsCollected;
    
    // the gesture recognizer assumes portrait mode, so we need to use rotated swipe directions
    KKInput* input = [KKInput sharedInput];
    if ([input anyTouchBeganThisFrame])
    {
        [knight jump];
    }
}

-(void) showSpriteAgain:(CCSprite *)coin{
    if ([coinArray count] == 0) {
        coinPattern1 = FALSE;
    }
}

/*
 These are the methods for displaying the different horizontal rows of coins to generate a horizontal/diagonal pattern
 */
- (void)patternOne {
    if (coinPattern1 == FALSE)
    {
        coinPattern1 = TRUE;
        int originalX = 5000;
        
        for(int i = 0; i < 8; i++)
        {
            CCSprite *coinHorizontal = [CCSprite spriteWithFile:@"coin.png"];
            coinHorizontal.position = ccp(originalX, screenCenter.y - 20);
            originalX += 20;
            
            [self addChild:coinHorizontal];
            [coinArray addObject:coinHorizontal];
        }
        for(int i = 0; i < 8; i++)
        {
            CCSprite *coinHorizontal = [CCSprite spriteWithFile:@"coin.png"];
            coinHorizontal.position = ccp(originalX, screenCenter.y);
            originalX += 20;
            
            [self addChild:coinHorizontal];
            [coinArray addObject:coinHorizontal];
        }
        for(int i = 0; i < 8; i++)
        {
            CCSprite *coinHorizontal = [CCSprite spriteWithFile:@"coin.png"];
            coinHorizontal.position = ccp(originalX, screenCenter.y + 20);
            originalX += 20;
            
            [self addChild:coinHorizontal];
            [coinArray addObject:coinHorizontal];
        }
        for(int i = 0; i < 8; i++)
        {
            CCSprite *coinHorizontal = [CCSprite spriteWithFile:@"coin.png"];
            coinHorizontal.position = ccp(originalX, screenCenter.y + 40);
            originalX += 20;
            
            [self addChild:coinHorizontal];
            [coinArray addObject:coinHorizontal];
        }
    }
}
- (void)powerUpShow {
    /*
     The random value algorithm between ranges is this:
     (arc4random()%(toNumber-fromNumber))+fromNumber
     */
    if (pointsDisplayNode.score == (arc4random()%(1200-1001))+1000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(2200-2001))+2000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(3200-3001))+3000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(4200-4001))+4000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(5200-5001))+5000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(6200-6001))+6000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(7200-7001))+7000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(8200-8001))+8000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(9200-9001))+9000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(10200-10001))+10000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(11200-11001))+11000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(12200-12001))+12000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(13200-13001))+13000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(14200-14001))+14000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(15200-15001))+15000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(16200-16001))+16000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(17200-17001))+17000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(18200-18001))+18000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(19200-19001))+19000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(20200-20001))+20000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(21200-21001))+21000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(22200-22001))+22000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(23200-23001))+23000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(24200-24001))+24000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(25200-25001))+25000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(26200-26001))+26000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(27200-27001))+27000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(28200-28001))+28000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(29200-29001))+29000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(30200-30001))+30000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(31200-31001))+31000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(32200-32001))+32000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(33200-33001))+33000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(34200-34001))+34000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(35200-35001))+35000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(36200-36001))+36000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(37200-37001))+37000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(38200-38001))+38000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(39200-39001))+39000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(40200-40001))+40000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(41200-41001))+41000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(42200-42001))+42000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(43200-43001))+43000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(44200-44001))+44000) {
        [self addPowers];
    } else if (pointsDisplayNode.score == (arc4random()%(45200-45001))+45000) {
        [self addPowers];
    }
}
-(void)addPowers {
    int originalX = 5000;
    Powers *powers = [CCSprite spriteWithFile:@"coin-mode.png"];
    powers.position = ccp(originalX, screenCenter.y);
    originalX += 20;
    powers.scale = 2.0;
    [self addChild:powers];
    [powerUpArray addObject:powers];
    NSLog(@"Powerup showed");
}
- (void)power1 {
    [self flashLabel:@"Double Coins" actionWithDuration:5.0f color:@"black"];
    id coins = [CCCallFunc actionWithTarget:self selector:@selector(makeCoinsDouble)];
    id delayCoins = [CCDelayTime actionWithDuration:5.0f];
    id coinsGone = [CCCallFunc actionWithTarget:self selector:@selector(makeCoinsOne)];
    CCSequence *powerUp1Seq = [CCSequence actions:coins, delayCoins, coinsGone, nil];
    [self runAction:powerUp1Seq];
}
- (void)power2 {
    [self flashLabel:@"Slow Speed" actionWithDuration:5.0f color:@"black"];
    powerUpThreeOn = TRUE;
    id speed = [CCCallFunc actionWithTarget:self selector:@selector(scrollspeedPowerUp)];
    id delaySpeed = [CCDelayTime actionWithDuration:5.0f];
    id speedBack = [CCCallFunc actionWithTarget:self selector:@selector(defaultScrollSpeed)];
    CCSequence *powerUp1Seq = [CCSequence actions:speed, delaySpeed, speedBack, nil];
    [self runAction:powerUp1Seq];
}
- (void)power3 {
    [self flashLabel:@"Fatness Reset" actionWithDuration:2.0f color:@"black"];
    [self resetFatness];
}
-(void)makeCoinsDouble {
    coinValue = 2;
}
-(void)makeCoinsOne {
    coinValue = 1;
}
-(void) scrollspeedPowerUp {
    scrollSpeedP = 190;
    [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeedP];
}
-(void) defaultScrollSpeed {
    powerUpThreeOn = FALSE;
}

-(void) powersCollisionDetection {
    for (NSUInteger i = 0; i < [powerUpArray count]; i++)
    {
        CGRect knightRect = [knight boundingBox];
        Powers *powerUp = [powerUpArray objectAtIndex:i];
        CGRect powerUpRect = [powerUp boundingBox];
        if (CGRectIntersectsRect(knightRect, powerUpRect))
        {
            [powerUpArray removeObject:powerUp];
            [self removeChild:powerUp];

            toNumber = 3;
            fromNumber = 1;
            ranDom = (arc4random()%(toNumber-fromNumber+1))+fromNumber;
            
            if (ranDom == 1) {
                [self power1];
            } else if (ranDom == 2) {
                [self power2];
            } else if (ranDom == 3) {
                [self power3];
            }
        }
    }
}
- (void)changeStuff {
    if (pointsDisplayNode.score > 1500) {
        scrollSpeed1 = 290;
        if (IS_IPOD || IS_IPAD_RETINA) {
            scrollSpeed = 440.0f;
        }
        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed1];
        [[GameMechanics sharedGameMechanics] setSpawnRate:240 forMonsterType:[Sandwich class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:290 forMonsterType:[Pear class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:350 forMonsterType:[Banana class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:300 forMonsterType:[Hotdog class]];
    }
    if (pointsDisplayNode.score > 3000) {
        scrollSpeed2 = 330;
        if (IS_IPOD || IS_IPAD_RETINA) {
            scrollSpeed = 480.0f;
        }
        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed2];
        [[GameMechanics sharedGameMechanics] setSpawnRate:190 forMonsterType:[Sandwich class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:240 forMonsterType:[Pear class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:290 forMonsterType:[Pizza class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:440 forMonsterType:[Apples class]];
    }
    if (pointsDisplayNode.score > 6000) {
        scrollSpeed3 = 370;
        if (IS_IPOD || IS_IPAD_RETINA) {
            scrollSpeed = 520.0f;
        }
        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed3];
        [[GameMechanics sharedGameMechanics] setSpawnRate:230 forMonsterType:[Pear class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:280 forMonsterType:[Banana class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:430 forMonsterType:[Strawberries class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:600 forMonsterType:[Pizza class]];
    }
    if (pointsDisplayNode.score > 7500) {
        scrollSpeed4 = 410;
        if (IS_IPOD || IS_IPAD_RETINA) {
            scrollSpeed = 560.0f;
        }
        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed4];
        [[GameMechanics sharedGameMechanics] setSpawnRate:220 forMonsterType:[Pear class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:270 forMonsterType:[Banana class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:420 forMonsterType:[Lemons class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:570 forMonsterType:[Pizza class]];
    }
    if (pointsDisplayNode.score > 10000) {
        scrollSpeed5 = 450;
        if (IS_IPOD || IS_IPAD_RETINA) {
            scrollSpeed = 580.0f;
        }
        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed5];
        [[GameMechanics sharedGameMechanics] setSpawnRate:210 forMonsterType:[Meat class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:260 forMonsterType:[Banana class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:410 forMonsterType:[Apples class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:500 forMonsterType:[Pizza class]];
    }
    if (pointsDisplayNode.score > 13000) {
        scrollSpeed6 = 490;
        if (IS_IPOD || IS_IPAD_RETINA) {
            scrollSpeed = 620.0f;
        }
        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed6];
        [[GameMechanics sharedGameMechanics] setSpawnRate:150 forMonsterType:[Watermelon class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:200 forMonsterType:[Pear class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:250 forMonsterType:[Banana class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:400 forMonsterType:[Apples class]];
        
    }
    if (pointsDisplayNode.score > 16500) {
        scrollSpeed7 = 530;
        if (IS_IPOD || IS_IPAD_RETINA) {
            scrollSpeed = 660.0f;
        }
        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed7];
        [[GameMechanics sharedGameMechanics] setSpawnRate:140 forMonsterType:[Sandwich class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:190 forMonsterType:[Pear class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:240 forMonsterType:[Watermelon class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:390 forMonsterType:[Apples class]];
    }
    if (pointsDisplayNode.score > 20000) {
        scrollSpeed8 = 570;
        if (IS_IPOD || IS_IPAD_RETINA) {
            scrollSpeed = 700.0f;
        }
        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed8];
        [[GameMechanics sharedGameMechanics] setSpawnRate:130 forMonsterType:[Sandwich class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:380 forMonsterType:[Apples class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:500 forMonsterType:[Pizza class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:440 forMonsterType:[Oranges class]];
    }
    if (pointsDisplayNode.score > 22500) {
        scrollSpeed9 = 580;
        if (IS_IPOD || IS_IPAD_RETINA) {
            scrollSpeed = 710.0f;
        }
        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed9];
        [[GameMechanics sharedGameMechanics] setSpawnRate:120 forMonsterType:[Donuts class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:500 forMonsterType:[Pizza class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:410 forMonsterType:[Kiwi class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:510 forMonsterType:[Strawberries class]];
    }
    if (pointsDisplayNode.score > 25000) {
        scrollSpeed10 = 590;
        if (IS_IPOD || IS_IPAD_RETINA) {
            scrollSpeed = 720.0f;
        }
        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed10];
        [[GameMechanics sharedGameMechanics] setSpawnRate:110 forMonsterType:[Donuts class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:160 forMonsterType:[Pear class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:410 forMonsterType:[Bread class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:510 forMonsterType:[Strawberries class]];
    }
    if (pointsDisplayNode.score > 27500) {
        scrollSpeed11 = 600;
        if (IS_IPOD || IS_IPAD_RETINA) {
            scrollSpeed = 730.0f;
        }
        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed11];
        [[GameMechanics sharedGameMechanics] setSpawnRate:350 forMonsterType:[Apples class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:500 forMonsterType:[Pizza class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:410 forMonsterType:[Broccoli class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:510 forMonsterType:[Strawberries class]];
    }
    if (pointsDisplayNode.score > 30000) {
        scrollSpeed12 = 610;
        if (IS_IPOD || IS_IPAD_RETINA) {
            scrollSpeed = 740.0f;
        }
        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed12];
        [[GameMechanics sharedGameMechanics] setSpawnRate:190 forMonsterType:[Donuts class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:340 forMonsterType:[Hotdog class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:560 forMonsterType:[Fish class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:410 forMonsterType:[Corn class]];
    }
    if (pointsDisplayNode.score > 32500) {
        scrollSpeed13 = 620;
        if (IS_IPOD || IS_IPAD_RETINA) {
            scrollSpeed = 750.0f;
        }
        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed13];
        [[GameMechanics sharedGameMechanics] setSpawnRate:180 forMonsterType:[Banana class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:360 forMonsterType:[Chicken class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:540 forMonsterType:[Hotdog class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:390 forMonsterType:[Donuts class]];
    }
    if (pointsDisplayNode.score > 35000) {
        scrollSpeed14 = 630;
        if (IS_IPOD || IS_IPAD_RETINA) {
            scrollSpeed = 760.0f;
        }
        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed14];
        [[GameMechanics sharedGameMechanics] setSpawnRate:70 forMonsterType:[Sandwich class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:120 forMonsterType:[Pear class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:320 forMonsterType:[Apples class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:500 forMonsterType:[Pizza class]];
    }
    if (pointsDisplayNode.score > 37500) {
        scrollSpeed15 = 640;
        if (IS_IPOD || IS_IPAD_RETINA) {
            scrollSpeed = 770.0f;
        }
        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed15];
        [[GameMechanics sharedGameMechanics] setSpawnRate:110 forMonsterType:[Pear class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:360 forMonsterType:[Chicken class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:390 forMonsterType:[Carrots class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:490 forMonsterType:[Strawberries class]];
    }
    if (pointsDisplayNode.score > 40000) {
        scrollSpeed16 = 650;
        if (IS_IPOD || IS_IPAD_RETINA) {
            scrollSpeed = 780.0f;
        }
        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed16];
        [[GameMechanics sharedGameMechanics] setSpawnRate:50 forMonsterType:[Sandwich class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:620 forMonsterType:[Eggs class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:520 forMonsterType:[Oranges class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:470 forMonsterType:[Strawberries class]];
    }
    if (pointsDisplayNode.score > 42500) {
        scrollSpeed17 = 652;
        if (IS_IPOD || IS_IPAD_RETINA) {
            scrollSpeed = 782.0f;
        }
        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed17];
        [[GameMechanics sharedGameMechanics] setSpawnRate:40 forMonsterType:[Sandwich class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:190 forMonsterType:[Pear class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:140 forMonsterType:[Banana class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:290 forMonsterType:[Apples class]];
    }
    if (pointsDisplayNode.score > 45000) {
        scrollSpeed18 = 654;
        if (IS_IPOD || IS_IPAD_RETINA) {
            scrollSpeed = 784.0f;
        }
        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed18];
        [[GameMechanics sharedGameMechanics] setSpawnRate:180 forMonsterType:[Pear class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:600 forMonsterType:[Carrots class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:500 forMonsterType:[Kiwi class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:250 forMonsterType:[Donuts class]];
    }
    if (pointsDisplayNode.score > 47500) {
        scrollSpeed19 = 655;
        if (IS_IPOD || IS_IPAD_RETINA) {
            scrollSpeed = 785.0f;
        }
        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed19];
        [[GameMechanics sharedGameMechanics] setSpawnRate:120 forMonsterType:[Banana class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:500 forMonsterType:[Pizza class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:110 forMonsterType:[Chicken class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:250 forMonsterType:[Eggs class]];
    }
    if (pointsDisplayNode.score > 50000) {
        scrollSpeed20 = 656;
        if (IS_IPOD || IS_IPAD_RETINA) {
            scrollSpeed = 786.0f;
        }
        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:scrollSpeed20];
        [[GameMechanics sharedGameMechanics] setSpawnRate:202 forMonsterType:[Apples class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:169 forMonsterType:[Pizza class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:204 forMonsterType:[Carrots class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:294 forMonsterType:[Kiwi class]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:204 forMonsterType:[Tomato class]];
    }
}

#pragma mark - Scene Lifecycle

- (void)onEnterTransitionDidFinish
{
//  RecapScreenScene *recap = [[RecapScreenScene alloc] initWithGame:game];
//  [[CCDirector sharedDirector] replaceScene:recap];
  
    // setup a gesture listener for jumping and stabbing gestures
    [KKInput sharedInput].gestureSwipeEnabled = TRUE;

    // start game directly
        [self showHUD:TRUE];
        [self startGame];
}

- (void)onExit {
    // very important! deactivate the gestureInput, otherwise touches on scrollviews and tableviews will be cancelled!
    [KKInput sharedInput].gestureSwipeEnabled = FALSE;
}

#pragma mark - UI

- (void)presentGoOnPopUp {
    [[GameMechanics sharedGameMechanics] setGameState:GameStatePaused];
    CCScale9Sprite *backgroundImage = [StyleManager goOnPopUpBackground];
    goOnPopUp = [PopupProvider presentPopUpWithContentString:nil backgroundImage:backgroundImage target:self selector:@selector(goOnPopUpButtonClicked) buttonTitles:nil];
    
    CCMenuItemImage *yes = [CCMenuItemImage itemWithNormalImage:@"play-button.png" selectedImage:@"play-button-down.png" disabledImage:nil target:self selector:@selector(goOnPopUpButtonClicked)];

    CCMenuItemImage *no = [CCMenuItemImage itemWithNormalImage:@"home-button.png" selectedImage:@"home-button-down.png" disabledImage:nil target:self selector:@selector(goOnPopUpButtonCancel)];
    
    
    popupMenu = [CCMenu menuWithItems:yes, no, nil];
    [popupMenu alignItemsHorizontally];
    popupMenu.position = ccp(screenCenter.x, goOnPopUp.position.y-50);
    [self addChild:popupMenu z:10000];
    
    [self disableGameplayButtons];
}

- (void)showHUD:(BOOL)animated {
    // TODO: implement animated
    hudNode.visible = TRUE;
}

- (void)hideHUD:(BOOL)animated {
    // TODO: implement animated
    hudNode.visible = FALSE;
}

- (void)presentSkipAheadButtonWithDuration:(NSTimeInterval)duration {
    skipAheadMenu.visible = TRUE;
    skipAheadMenu.opacity = 0.f;
    CCFadeIn *fadeIn = [CCFadeIn actionWithDuration:1.0f];
    [skipAheadMenu runAction:fadeIn];
    
    [self scheduleOnce: @selector(hideSkipAheadButton) delay:duration];
}

- (void)hideSkipAheadButton {
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

- (void)disableGameplayButtons {
    pauseButtonMenu.enabled = FALSE;
    skipAheadMenu.enabled = FALSE;
}
- (void)enableGamePlayButtons {
    pauseButtonMenu.enabled = TRUE;
    skipAheadMenu.enabled = TRUE;
}
-(void) flashWithRed:(int) red green:(int) green blue:(int) blue alpha:(int) alpha actionWithDuration:(float) duration {
    colorLayer = [CCLayerColor layerWithColor:ccc4(red, green, blue, alpha)];
    [self addChild:colorLayer z:0];
    id delay = [CCDelayTime actionWithDuration:duration];
    id fadeOut = [CCFadeOut actionWithDuration:0.9f];
    id remove = [CCCallFunc actionWithTarget:self selector:@selector(removeFlashColor)];
    [colorLayer runAction:[CCSequence actions:delay, fadeOut, remove, nil]];
}
-(void) removeFlashColor {
    [self removeChild:colorLayer cleanup:YES];
}

#pragma mark - Delegate Methods

/*
 This method is called, when purchases on the In-Game-Store occur.
 Then we need to update the coins display on the HUD.
 */
- (void)storeDisplayNeedsUpdate {
    inAppCurrencyDisplayNode.score = coinsCollected;
}

- (void)resumeButtonPressed:(PauseScreen *)pauseScreen {
    // enable the pause button again, since the pause menu is hidden now
    [self enableGamePlayButtons];
    [self showHUD:TRUE];
    [self resumeSchedulerAndActions];
    [[GameMechanics sharedGameMechanics] setGameState:GameStateRunning];
}

#pragma mark - Button Callbacks

- (void)skipAheadButtonPressed {
    if ([Store hasSufficientFundsForSkipAheadAction]) {
        skipAheadMenu.enabled = FALSE;
        NSLog(@"Skip Ahead!");
        [self startSkipAheadMode];
        
        // hide the skip ahead button, after it was pressed
        // we need to cancel the previously scheduled perform selector...
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideSkipAheadButton) object:nil];
        
        // ... in order to execute it directly
        [self hideSkipAheadButton];
    } else {
        // pause the game, to allow the player to buy coins
        [[GameMechanics sharedGameMechanics] setGameState:GameStatePaused];
        [self presentMoreCoinsPopUpWithTarget:self selector:@selector(returnedFromMoreCoinsScreenFromSkipAheadAction)];
    }
    [[SimpleAudioEngine sharedEngine] playEffect:@"select.mp3"];
}

- (void)goOnPopUpButtonClicked {
//    [[GameMechanics sharedGameMechanics] game].deaths+=1;
//    NSLog(@"Button clicked.");
//    if (sender.tag == 0)
//    {
        if ([Store hasSufficientFundsForGoOnAction])
        {
            // OK button selected
            [goOnPopUp dismiss];
            [self removeChild:popupMenu];
            [self executeGoOnAction];
            [self enableGamePlayButtons];
            [self resetFatness];
            knight.visible = TRUE;
        } else
        {
            // game is paused in this state already, we only need to present the more coins screen
            // dismiss the popup; presented again when we return from the 'Buy More Coins'-Screen
            [self removeChild:popupMenu];
            [goOnPopUp dismiss];
            [self presentMoreCoinsPopUpWithTarget:self selector:@selector(returnedFromMoreCoinsScreenFromGoOnAction)];
        }
//    } else if (sender.tag == 1)
//    {

//    }
}

-(void)goOnPopUpButtonCancel {
    // Cancel button selected
    [self removeChild:popupMenu];
    [goOnPopUp dismiss];
    game.score ++;

    // IMPORTANT: set game state to 'GameStateMenu', otherwise menu animations will no be played
    [[GameMechanics sharedGameMechanics] setGameState:GameStateMenu];

    RecapScreenScene *recap = [[RecapScreenScene alloc] initWithGame:game];
    [[CCDirector sharedDirector] replaceScene:recap];
}

-(void)resetFatness {
    [[GameMechanics sharedGameMechanics] game].fatness = 50;
}
-(void)resetJumps {
    [[GameMechanics sharedGameMechanics] game].jumps = 0;
}
-(void)resetDeaths {
    [[GameMechanics sharedGameMechanics] game].deaths = 0;
}

- (void)pauseButtonPressed
{
    NSLog(@"Pause");
    // disable pause button while the pause menu is shown, since we want to avoid, that the pause button can be hit twice.
    [self disableGameplayButtons];
    
    PauseScreen *pauseScreen = [[PauseScreen alloc] initWithGame:game];
    pauseScreen.delegate = self;
    [self addChild:pauseScreen z:10];
    [pauseScreen present];
    [[GameMechanics sharedGameMechanics] setGameState:GameStatePaused];
    tut.visible = false;
    tapGesture.visible = false;
    tiltPic.visible = false;
    toolbarArrows.visible = false;
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
    NSLog(@"You need more coins!");
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