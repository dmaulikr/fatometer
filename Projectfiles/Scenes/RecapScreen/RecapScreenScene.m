//
//  RecapScreenLayer.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/14/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "RecapScreenScene.h"
#import "STYLES.h"
#import "Mission.h"
#import "RunDistanceMission.h"
#import "StoreScreenScene.h"
#import "StatisticsNode.h"
#import "MissionsNode.h"
#import "TabNode.h"
#import "PersonalBestNode.h"
#import "GameplayLayer.h"
#import "Leaderboard.h"
#import "GameplayLayer.h"
#import "MainMenuLayer.h"
#import "StoreScreenScene.h"
#import "Store.h"

@interface RecapScreenScene()

//private Methods go here
- (void)presentUsernameDialog;
// method called after facebook login is completed by player
- (void)facebookLoginCompleted:(NSString *)response;
// submit score to leaderboard
- (void)submitScoreDelayed;

@end

@implementation RecapScreenScene

- (id)init
{
    @throw @"Do not use the init-method of this class. Use initWithGame instead.";
}

- (id)initWithGame:(Game *)g
{
    self = [super init];
    
    if (self)
    {
        game = g;
        
        CGSize screenSize = [CCDirector sharedDirector].screenSize;
        size = [[CCDirector sharedDirector] winSize];
        screenCenter = ccp(size.width/2, size.height/2);
        
        CCSprite* background = [CCSprite spriteWithFile:@"background-recap.png"];
        background.position = ccp(screenCenter.x,screenCenter.y);
        [self addChild:background z:0];
        
        // set the background color
//        CCLayerColor* colorLayer = [CCLayerColor layerWithColor:SCREEN_BG_COLOR];
//        [self addChild:colorLayer z:0];
        
        /*
         We are building this screen with different modules. One module (StatistsicsPanel) will show
         the information of the game session the player has just completed.
         The second panel (tabNode) is a UI component with multiple tabs.
         One tab will show the completed missions (MissionNode), another one will show the leaderboard (LeaderboardNode)
         */
        
        /********** Statistics Panel *********/
        CCSprite *coinImage = [CCSprite spriteWithFile:@"coin-mode-icon.png"];
        coinImage.position = ccp((screenCenter.x / 5)+30, (screenCenter.y /2)+12);
        if ([[CCDirector sharedDirector] winSizeInPixels].width == 2048) {
            coinImage.position = ccp((screenCenter.x / 5)+43, (screenCenter.y /2)+85);
        }
        [self addChild:coinImage z:1000000];
        NSString *coins = [NSString stringWithFormat:@"     %d coins", [Store availableAmountInAppCurrency]];
        NSString *distance = [NSString stringWithFormat:@"%d Meters", game.meters];
        NSString *foodsCollected = [NSString stringWithFormat:@"Ate %d foods", game.foodsCollected];
        
        NSArray *highScoreStrings = [NSArray arrayWithObjects:distance, foodsCollected, coins, nil];

        // setup the statistics panel with the current game information of the user
        CCSprite *gameOverTitle = [CCSprite spriteWithFile:@"gameover.png"];
        gameOverTitle.position = ccp((screenCenter.x / 2.05), screenCenter.y * 1.4);
        gameOverTitle.scale = 1.28;
        [self addChild:gameOverTitle];
        
        statisticsNode = [[StatisticsNode alloc] initWithTitle:nil highScoreStrings:highScoreStrings];
        statisticsNode.contentSize = CGSizeMake(200, 200);
        statisticsNode.anchorPoint = ccp(0, 1);
        statisticsNode.position = ccp((screenCenter.x / 5), screenCenter.y);
        [self addChild:statisticsNode];
        
        /********** Mission Panel *********/
        missionNode = [[MissionsNode alloc] initWithMissions:game.missions];
        missionNode.contentSize = CGSizeMake(240.f, 201.f);
        if ([[CCDirector sharedDirector] winSizeInPixels].width == 2048) {
            missionNode.contentSize = CGSizeMake(463.f, 345.f);
        }
        missionNode.usesScaleSpriteBackground = TRUE;
        
        
        /********** Leaderboard Panel *********/
        leaderboardNode = [[LeaderboardNode alloc] initWithScoreBoard:nil];
        leaderboardNode.contentSize = CGSizeMake(240.f, 201.f);
        if ([[CCDirector sharedDirector] winSizeInPixels].width == 2048) {
            leaderboardNode.contentSize = CGSizeMake(452.f, 395.f);
        }

        
        /********** TabView Panel *********/
//        CCSprite *tabTileScoreboard = [CCSprite spriteWithFile:@"leaderboard-active.png"];
//        CCSprite *tabTileMission = [CCSprite spriteWithFile:@"missions-active.png"];
        
        NSArray *tabs = @[missionNode, leaderboardNode];
        NSArray *tabTitles = @[@"Missions", @"Leaderboards"];
        tabNode = [[TabNode alloc] initWithTabs:tabs tabTitles:tabTitles];
        tabNode.contentSize = CGSizeMake(270, 208);
        if ([[CCDirector sharedDirector] winSizeInPixels].width == 2048) {
            tabNode.contentSize = CGSizeMake(460.f, 320.f);
        }
        tabNode.anchorPoint = ccp(0,1);
        // initially this view will be off screen and will be animated on screen
        tabNode.position =  ccp(screenSize.width - 30,screenSize.height - 20);
        [self addChild:tabNode];
        
        if ([[CCDirector sharedDirector] winSizeInPixels].width == 2048) {
//            leaderboardNode.position = ccp(tabNode.position.x, tabNode.position.y - 200);
        }
        
        /*********** Facebook, Twitter, MGWU and MoreGames Menu **********/
//        CCMenuItemSprite *mgwuIcon = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"share-menu.png"] selectedSprite:[CCSprite spriteWithFile:@"share-menu.png"] target:self selector:@selector(mguwIconPressed)];
        
        CCMenuItemSprite *moreGamesIcon = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"more-button.png"] selectedSprite:[CCSprite spriteWithFile:@"more-button-down.png"] target:self selector:@selector(moreGamesIconPressed)];
                                           
        CCMenuItemSprite *facebookIcon = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"facebook-button.png"] selectedSprite:[CCSprite spriteWithFile:@"facebook-button-down.png"] target:self selector:@selector(fbIconPressed)];
                                          
        CCMenuItemSprite *twitterIcon = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"twitter-button.png"] selectedSprite:[CCSprite spriteWithFile:@"twitter-button-down.png"] target:self selector:@selector(twitterIconPressed)];
        
        CCMenu *socialMenu = [CCMenu menuWithItems:moreGamesIcon, facebookIcon, twitterIcon, nil];
        socialMenu.position = ccp(110, self.contentSize.height-40);
        socialMenu.anchorPoint = ccp(0,1);
        [socialMenu alignItemsHorizontallyWithPadding:0.f];
        [self addChild:socialMenu z:100000];
        
        CCSprite *socialMenuBG = [CCSprite spriteWithFile:@"share-menu.png"];
        socialMenuBG.position = ccp(100, self.contentSize.height-40);
        [self addChild:socialMenuBG];
        
        if ([[CCDirector sharedDirector] winSizeInPixels].width == 2048) {
            socialMenu.position = ccp(234, self.contentSize.height-90);
            socialMenuBG.position = ccp(210, self.contentSize.height-90);
        }

        
        /*********** Personal Best *********/
        
        PersonalBestNode *personalBestNode = [[PersonalBestNode alloc] initWithPersonalBest:
                                              [Leaderboard personalRecordRunningDistance]];
        personalBestNode.contentSize = CGSizeMake(200, 30);
        personalBestNode.position = ccp(20, 10);
        if ([[CCDirector sharedDirector] winSizeInPixels].width == 2048) {
            personalBestNode.position = ccp(45, 30);
        }
        [self addChild:personalBestNode];
        
        /*********** Next Button ***********/
//        CCMenuItemSprite *nextBu tton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"button_playbutton.png"] selectedSprite:[CCSprite spriteWithFile:@"button_playbutton.png"]block:^(id sender) {
//            [[CCDirector sharedDirector] replaceScene:[CCTransitionZoomFlipAngular transitionWithDuration:1.0f scene:[GameplayLayer node]]];
//        }];
        
        CCMenuItemImage *nextButton = [CCMenuItemImage itemWithNormalImage:@"next-button.png" selectedImage:@"next-button-down.png" disabledImage:nil target:self selector:@selector(nextPressed)];
        
        CCMenuItemImage *homeButton = [CCMenuItemImage itemWithNormalImage:@"home-button.png" selectedImage:@"home-button-down.png" disabledImage:nil target:self selector:@selector(homePressed)];

        CCMenuItemImage *storeButton = [CCMenuItemImage itemWithNormalImage:@"store-button.png" selectedImage:@"store-button-down.png" disabledImage:nil target:self selector:@selector(storePressed)];
        
                                       
        
//        CCMenuItemSprite *storeButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"next.png"] selectedSprite:[CCSprite spriteWithFile:@"next_.png"]block:^(id sender) {
//                        StoreScreenScene *storeScreenScene = [[StoreScreenScene alloc] init];
//                        [[CCDirector sharedDirector] replaceScene:storeScreenScene];
//        }];
        
        CCMenu *nextButtonMenu = [CCMenu menuWithItems:homeButton, storeButton, nextButton, nil];
        nextButtonMenu.anchorPoint = ccp(1,0);
        nextButtonMenu.position = ccp(self.contentSize.width - 120, 35);
        if ([[CCDirector sharedDirector] winSizeInPixels].width == 2048) {
            nextButtonMenu.position = ccp(self.contentSize.width - 280, 75);
        }
        [nextButtonMenu alignItemsHorizontally];
        [self addChild:nextButtonMenu];
    }
    
    return self;
}

// This is executed, when the scene is shown for the first time
- (void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    NSString *username = [Leaderboard userName];
    
    if (username)
    {
//        [MGWU submitHighScore:game.score byPlayer:username forLeaderboard:HIGHSCORE_LEADERBOARD];
//        [MGWU submitHighScore:game.meters byPlayer:username forLeaderboard:DISTANCE_LEADERBOARD];
    } else
    {
        // if no unsername is set yet, prompt dialog and submit highscore then
        [self presentUsernameDialog];
    }
    
    // animate the tabNode on to screen
    CGSize screenSize = [CCDirector sharedDirector].screenSize;
    CGPoint targetPoint = ccp(screenSize.width - 240, tabNode.position.y);
    if ([[CCDirector sharedDirector] winSizeInPixels].width == 2048) {
        targetPoint = ccp(screenSize.width - 500, screenCenter.y+155);
    }
    CCMoveTo *move = [CCMoveTo actionWithDuration:1.f position:targetPoint];
    id easeMove = [CCEaseBackInOut actionWithAction:move];
    [tabNode runAction: easeMove];
    

    // refresh missions on missions node
    [self scheduleOnce:@selector(updateMissions) delay:2.f];
}

#pragma mark - Button Callbacks

- (void)mguwIconPressed
{
    [MGWU displayAboutPage];
}

- (void)moreGamesIconPressed
{
    [MGWU displayCrossPromo];
}

- (void)fbIconPressed
{
    // share on facebook
    NSString *shareTitle = [NSString stringWithFormat:@"Checkout this amazing game! I challenge all of you in MGWU Runner Template! Can you beat my score of %d ?", [Leaderboard personalRecordRunningDistance]];
    NSString *caption = @"MGWU Runner Template is an amazingly fun game.";
    [MGWU shareWithTitle:shareTitle caption:caption andDescription:@"MGWU teaches you to build iPhone games! Visit makegameswith.us for further information."];
}

- (void)twitterIconPressed
{
    NSString *tweetMessage = [NSString stringWithFormat:@"Checkout this amazing game: Fat Guy Fred @shlns!"];
    [MGWU postToTwitter:tweetMessage];
}

- (void)nextPressed
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1.0f scene:[GameplayLayer node]]];
}

- (void)homePressed
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1.0f scene:[MainMenuLayer node]]];
}

- (void)storePressed
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1.0f scene:[StoreScreenScene node]]];
}


- (void)updateMissions
{
    // tell the game to replace all completed missions with new ones
    [game replaceCompletedMission];
    [missionNode refreshWithMission:[game.missions copy]];
}

- (void)presentUsernameDialog
{
    usernamePrompt = [[UIAlertView alloc] init];
    usernamePrompt.alertViewStyle = UIAlertViewStylePlainTextInput;
    usernamePrompt.title = @"Enter username or login with Facebook.";
    [usernamePrompt addButtonWithTitle:@"OK"];
    [usernamePrompt addButtonWithTitle:@"Facebook"];
    [usernamePrompt show];
    usernamePrompt.delegate = self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == usernamePrompt)
    {
        if (buttonIndex == 0)
        {
            // user name entered
            UITextField *usernameTextField = [alertView textFieldAtIndex:0];
            NSString *username = usernameTextField.text;
            // save the user name
            [Leaderboard setUserName:username];
//            [MGWU submitHighScore:game.score byPlayer:username forLeaderboard:HIGHSCORE_LEADERBOARD withCallback:@selector(receivedScores:) onTarget:self];
//            [MGWU submitHighScore:game.meters byPlayer:username forLeaderboard:DISTANCE_LEADERBOARD];

        } else if (buttonIndex == 1)
        {
            // attempt to login via Facebook
            // set a flag, that shows, that we are waiting for a facebook login
            [usernamePrompt dismissWithClickedButtonIndex:1 animated:FALSE];
            waitingForFacebookLogin = TRUE;
            [MGWU loginToFacebookWithCallback:@selector(facebookLoginCompleted:) onTarget:self];
        }
    }
}

- (void)facebookLoginCompleted:(NSString *)response
{
    if ([response isEqualToString:@"Success"])
    {
        // since we are succesfully logged in to facebook, username will now be the facebook name
        [usernamePrompt dismissWithClickedButtonIndex:1 animated:FALSE];
        // needs to be called delayed since MGWU currently only allows one callback-method beeing executed at a time 
        [self performSelector:@selector(submitScoreDelayed) withObject:nil afterDelay:0.01f];
 
    } else
    {
        // present InputView again
        [self presentUsernameDialog];
    }
}

- (void)submitScoreDelayed
{
    NSString *username = [Leaderboard userName];
//    [MGWU submitHighScore:game.score byPlayer:username forLeaderboard:HIGHSCORE_LEADERBOARD];
    [MGWU submitHighScore:game.meters byPlayer:username forLeaderboard:DISTANCE_LEADERBOARD];
}

- (void)receivedScores:(NSDictionary*)scores
{    
    [leaderboardNode reloadWithScoreBoard:scores];
}

- (void)didEnterForeground
{
    if (waitingForFacebookLogin)
    {
        [self presentUsernameDialog];
    }
}

@end
