# FAQ

This **FAQ** will answer some basic questions for developers building a game on the endless template game.

## Missions

### How can I add new Missions?

Missions are created in the class `MissionProvider.m`.
The template game creates for sample missions, using three mission types:

	RunDistanceMission *mission1 = [[RunDistanceMission alloc] init];
        mission1.missionDescriptionFormat = @"Run %d meters";
        mission1.thumbnailFileName = @"missions_1.png";
        [[mission1.missionObjectives objectAtIndex:0] setGoalValue:50];
        [self storeLastObjectiveGoalValuesForMission:mission1];
        
        KillAmountOfEnemiesMission *mission2 = [[KillAmountOfEnemiesMission alloc] init];
        mission2.missionDescriptionFormat = @"Kill %d enemies";
        mission2.thumbnailFileName = @"missions_2.png";
        [[mission2.missionObjectives objectAtIndex:0] setGoalValue:1];
        [self storeLastObjectiveGoalValuesForMission:mission2];
        
        KillAmountOfEnemiesInDistance *mission3 = [[KillAmountOfEnemiesInDistance alloc] init];
        mission3.missionDescriptionFormat = @"Kill %d enemies in %d meters";
        mission3.thumbnailFileName = @"missions_1.png";
        [[mission3.missionObjectives objectAtIndex:0] setGoalValue:2];
        [[mission3.missionObjectives objectAtIndex:1] setGoalValue:1500];
        [self storeLastObjectiveGoalValuesForMission:mission3];
        
        RunDistanceMission *mission4 = [[RunDistanceMission alloc] init];
        mission4.missionDescriptionFormat = @"Run %d meters";
        mission4.thumbnailFileName = @"missions_1.png";
        [[mission4.missionObjectives objectAtIndex:0] setGoalValue:150];
        [self storeLastObjectiveGoalValuesForMission:mission4];
        
        [missions addObjectsFromArray:@[mission1, mission2, mission3, mission4]];
 

Missions consist of 1 or 2 objectives.
At the moment the template game has three mission types:

* RunDistanceMission
	* 1 Objective: RunDistance (HigherIsBetter) 
* KillAmountOfEnemiesMission
	* 1 Objective: KilledAmountEnemies (HigherIsBetter)
* KillAmountOfEnemiesInDistance
	* 2 Objectives:
		* KilledAmountEnemies (HigherIsBetter)
		* Distance (LowerIsBetter)

If you simply want to add different variations of these existing Mission-Types, you can create new instances and change the goal values for the objectives.

All missions added to the `missions`array, will be played by the player in that order. The player will always see 3 missions, once one is completed, the next one from the missions array is picked.

When the end of the missions array is reached, the `MissionProvider` will generate missions, based on the previous ones in the `missions`array.

Whenever you create a mission manually, it is useful to call `        [self storeLastObjectiveGoalValuesForMission:missionX];`.

That method will store the highest difficulty for each mission type. That information is used to generate new missions, that are more difficult than previous ones. That is why, objectives can have to different `objectiveTypes`:
	
	typedef NS_ENUM(NSInteger, MissionObjectiveType) {
    MissionObjectiveTypeHigherIsBetter,
    MissionObjectiveTypeLowerIsBetter
	};

### When are missions generated?

When no missions are left in the `missions` array, filled by the developer, the method `+ (Mission *)generateNewMission` is called, that generates a new mission, based on the ones created by the developer.
		
		 
### How can I create custom Missions?

Therefore you need to subclass the `Missions` class. Take a look at the 3 initially provided mission types, to get all implementation details.

Basically most missions will use these two methods:

	- (void)missionStart:(Game *)game
	{
	    // capture the initial state, e.g. initial distance
	    startDistance = game.meters;
	}
	
	- (void)generalGameUpdate:(Game *)game
	{
	    // check if goal is reached, e.g. the required distance
	    if ((game.meters - startDistance) > runningDistance.goalValue)
	    {
	        self.successfullyCompleted = TRUE;
	    }
	}
	
For the mission generator it is important, that all your objectives are initialized in the `-(id)init` method:

	- (id)init
	{
	    self = [super init];
	    
	    if (self)
	    {
	        self.missionObjectives = [[NSMutableArray alloc] init];
	        
	        // available mission objectives need to be defined here, for mission generator
	        killAmountOfEnemies = [[MissionObjective alloc] initWithObjectiveType:MissionObjectiveTypeHigherIsBetter];
	        [self.missionObjectives addObject:killAmountOfEnemies];
	        
	        withinDistance = [[MissionObjective alloc] initWithObjectiveType:MissionObjectiveTypeLowerIsBetter];
	        [self.missionObjectives addObject:withinDistance];
	        // the goal value will be set later on, either manually or by the mission generator
	    }
	    
	    return self;
	}
	
	
Basically there will be 4 steps to your first custom mission:

1. Create a subclass of `Mission`
2. Initialize your MissionObjectives in `-(id)init`
3. Implement `-(void)missionStart:` to capture the game variables, when your mission starts.
4. Implement `-generalGameUpdate` to check, if your mission goals have been reached. Once that happens set `self.successfullyCompleted = TRUE;`	
#### Why do I need to implement -(id)initWithCoder ?

The Missions are stored to disk when the game terminates. Therefore that method needs to be implemented. Your implementation probably will look similar to this one:

	- (id)initWithCoder:(NSCoder *)decoder
	{
	    // call the superclass, that initializes a mission from disk
	    self = [super initWithCoder:decoder];
	    // additionally store a reference to the 'runningDistance' objective in the instance variable.
	    runningDistance = [self.missionObjectives objectAtIndex:0];
	    
	    return self;
	}
	
You call `[super initWithCoder:decoder]`, because the `Mission` class will take care of encoding/decoding all the default fields. Only if you add anything else than the default fields, you will have to implement `initWithCoder`. All the initial Missions in the template game have an instance variable, to be able the reference the objectives more quickly. This relation needs to be setup in `initWithCoder:`.

### How can the Mission System be extended?

Probably the next useful step would be to add further messages, that missions can receive. This would allow a wider variety of Missions.
One example:

	- (void)monsterKilled:(Class)monsterClass; 

This method could provide the type of monster that has been killed and could be used by a totally new kind of mission.



## Store

Currently the Store only supports the In-App-Purchase of Coins. These coins can be used for an 'Go On' and 'Skip Ahead' action.

### How can I add StoreItems?

The Store is setup in `[Store setupDefault]`.

	        CoinPurchaseStoreItem *item1 = [[CoinPurchaseStoreItem alloc] init];
	        item1.title = @"40 Coins";
	        item1.thumbnailFilename = @"missions_1.png";
	        item1.detailDescription = @"Pocket Money!";
	        item1.cost = 0.99f;
	        item1.coinValue = 40;
	        item1.productID = @"TestProductID";
	        item1.inGameStoreImageFile = @"buy1.png";
        
…

Finally all items are added to the stores.
The Game has two different Stores. The one is the InGameStore, which is presented, when the player attempts to buy an 'Skip Ahead' or 'Go On' action, but does not have enough Coins.

All items that shall be presented in the inGameStore need an `inGameStoreImageFile`.

To the normal store screen, the items are added in different sections.
The sample code does that in the `setup` dictionary.

	        inGameStoreItems = [@[item1, item2, item3] mutableCopy];
	        NSDictionary *setup = @{@"Coins": @[item1, item2,item3, item4, item5, item6]};

To add new Coin-Items, simply create new instances and add them to both or one of the two stores.

## Monsters

### How can I add a new custom monster?

#### 1) Create new monster class
In the first step you need to create a Subclass of `Monster`.
Your new Class for the custom monster should look like this:

	#import "Monster.h"

	@interface MyCustomMonster : Monster

	@end

#### 2) Let monster be spawned

Next, we need to inform the game, that our new monster shall be spawned automatically. Therefore we go to `GameplayLayer.m`.
Here you see the following lines, that cause enemies to be spawned:
	
	// set spawn rate for monsters
    [[GameMechanics sharedGameMechanics] setSpawnRate:25 forMonsterType:[BasicMonster class]];
    [[GameMechanics sharedGameMechanics] setSpawnRate:50 forMonsterType:[SlowMonster class]];
    
Here we add a new line for our `MyCustomMonster`:
	    
	[[GameMechanics sharedGameMechanics] setSpawnRate:10 forMonsterType:[MyCustomMonster class]];
	
The number you pass to this method defines how many update cycles need to happen, before a new monster of the type is spawned.
	
#### 3) Implementing our new monster

If you run the game now, it will crash, because there are three methods, we need to implement in our `MyCustomMonster`class. These are the methods defined in `Monster.h`:

	- (id)initWithMonsterPicture;
	- (void)spawn;
	- (void)gotHit;
	
##### -(id)initWithMonsterPicture

In this method you set the representation for your monster.
To start, the most simple implementation is this one:

	- (id)initWithMonsterPicture
	{
	    self = [super initWithFile:@"basicbarrell.png"];
	
	    return self;
	}
	
This implementation sets a specific image as the static representation for our monster.

##### -(void)spawn

This method is called, when the `EnemyCache` wants to spawn our monster. The most simple implementation that works, is the following:

	- (void)spawn
	{
	    self.position = CGPointMake(50, 50);
		
		// Finally set yourself to be visible, this also flag the enemy as "in use"
		self.visible = YES;
	}

Now every time our monster is spawned, it will be placed at position _x=50, y=50_.

##### -(void)gotHit

This method is called when our enemy is hit. Usually we will want to increase the current score of the player and let the monster disappear in this method.
A simple implementation is the following:

	- (void)gotHit
	{
	    // mark as invisible and move off screen
	    self.visible = FALSE;
	    self.position = ccp(-MAX_INT, 0);
	    [[GameMechanics sharedGameMechanics] game].enemiesKilled += 1;
	    [[GameMechanics sharedGameMechanics] game].score += 1;
	}
	
Basically, all we do is hide the monster and updating the statistics on the game object.
**Now the game will run, without crashing and spawn our new Monster!**

### Moving our monster
If you run the game now, you will see a barrell at a static position. Usually you will want the enemy to move. Therefore we need to extend our current implementation.

We need to do two changes. First we request, that we want to be informed about updates in our init method:

	- (id)initWithMonsterPicture
	{
	    self = [super initWithFile:@"basicbarrell.png"];
	
	    if (self)
	    {
	        [self scheduleUpdate];
	    }
	
	    return self;
	}
	
Then we need to implement an update method, in which we move our monster:

	- (void)update:(ccTime)delta
	{
	    // apply background scroll speed
	    float backgroundScrollSpeedX = [[GameMechanics sharedGameMechanics] backGroundScrollSpeedX];
	    float xSpeed = 1.1 * backgroundScrollSpeedX;
	    
	    // move the monster until it leaves the left edge of the screen
	    if (self.position.x > (self.contentSize.width * (-1)))
	    {
	        self.position = ccp(self.position.x - (xSpeed*delta), self.position.y);
	    }
	}
	
We move our monster 10% faster than the background.
**When you run the game now, you will have an unanimated but moving monster, that will be destroyed, once the knight attacks it**.
For all the special stuff, such as Sprite animations, you can have a look at `BasicMonster.m` or the other MGUW tutorials (e.g. Peeved Penguins).


## Other custom game objects

This chapter explains how you can add other objects to the game, that aren't monsters.

Basically all game objects, that aren't enemies, can be added to the `GameplayLayer.m`. **To maintain a good design, you usually will want to add a node/layer, for each group of game objects**.

This chapter will describe both opportunities. The first step is the same in both cases. You need to create a `CCSprite`Subclass for your new game object. As an example we will implement a **Tree**. You can do the same for any other type of object. 

### Create game object
Game objects need to be CCSprite subclasses. Therefore the header-File of our new Tree object should look like this:

	#import "CCSprite.h"
	
	@interface Tree : CCSprite
	
	@end
	
Now, analogous to custom monsters, we implement a custom init method, that creates the representation of our object:

	- (id)initWithTreeImage
	{
	    self = [super initWithFile:@"tree.png"];
	    
	    return self;
	}
	
**Info: you can also add movement to that tree, so that it scrolls with the background. That works the same way as explained for custom monsters.**
	
### Display game object in scene - Option 1: GamePlayLayer

The first option, to display our tree, is to create an instance of it in `GameplayLayer.m` and add it there. Simply add this code, somewhere in the `-(id)init` method of the GamePlayLayer:

        // add tree
        Tree *tree = [[Tree alloc] initWithTreeImage];
        tree.position = ccp(350,80);
        [self addChild:tree];

If you add this line and start the game, the tree should appear at the right edge of the screen.

Adding game objects to the GameplayLayer is the most simple method, but it can result in unreadable code if you have to many different objects. Take a look at the second suggestion.

### Display game object in scene - Option 2: DecorativeObjectsNode

Since we plan to add a lot of different decorative items, not only trees, we think it is worth to create an own node for them. This groups them logically and makes it a lot easier to add a certain behaviour for all decorative objects.

#### 1) Create a new CCNode subclass

Your new class should look like this:

	#import "DecorativeObjectsNode.h"
	
	@implementation DecorativeObjectsNode
	
	@end
	
#### 2) Add the tree to our new DecorativeObjectsNode

There are a lot of different possibilities, when and how to add the tree to our new Node. Usually we will have to choose an appropriate method, depending on the type of objects  we create (e.g. spawning for enemies).

For now, we will simply add the tree in the init method. The implementation should look similar to this:

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
	
#### 3) Add the DecorativeObjectsNode to the GameplayLayer

In the last step, we need to add our new Node to the GameplayLayer.
Simplay add one line to the init method in `GameplayLayer.m`:

        // add decorative node
        [self addChild:[DecorativeObjectsNode node]];
        
Now, the not moving tree is displayed on screen again.
**For your game, you can add custom nodes for all groups of objects (e.g. PowerUps, Collectables, Platforms, etc.)**.