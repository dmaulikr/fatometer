/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim, Andreas Loew 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

//  Updated by Andreas Loew on 20.06.11:
//  * retina display
//  * framerate independency
//  * using TexturePacker http://www.texturepacker.com

#import "ParallaxBackground.h"
#import "GameMechanics.h"

@implementation ParallaxBackground


-(id) init
{
	if ((self = [super init]))
	{
		// The screensize never changes during gameplay, so we can cache it in a member variable.
		screenSize = [[CCDirector sharedDirector] winSize];
		
		// Create the background node
        backgroundNode = [CCNode node];
		[self addChild:backgroundNode];
        
        // For Parralax, set this to however many different background layers there are. So If there are 3 backgrounds, then this would be set to 3.
        numStripes = 1;
        
        /*
         The Below Code is For for NON Parralax Backgrounds. Comment this if you want to use a parralax background.
         These images can be set to anything, and they don't have to be in numerical order.
         The if statements below check the devices size, so you can display the right image for other iOS devices such as the iPhone 5 or iPad.
         */
        
        for (NSUInteger i = 0; i < numStripes; i++)
        {
            CCSprite *sprite = [CCSprite spriteWithFile:@"background-left.png"];
            CCSprite *sprite2 = [CCSprite spriteWithFile:@"background-right.png"];
            
            sprite.anchorPoint = CGPointMake(0, 0.5f);
            sprite.position = CGPointMake(0, screenSize.height / 2);
            
            sprite2.anchorPoint = CGPointMake(0, 0.5f);
            sprite2.position = CGPointMake(sprite.position.x + sprite.contentSize.width, screenSize.height / 2);
            
            [backgroundNode addChild:sprite z:i tag:i];
            [backgroundNode addChild:sprite2 z:i tag:i];
        }
        
		// Add 4 more layers, and position them next to their neighbor stripe this allows endless scrolling
        for (NSUInteger i = 0; i < numStripes; i++)
        {
            CCSprite *sprite = [CCSprite spriteWithFile:@"background-left.png"];
            CCSprite *sprite2 = [CCSprite spriteWithFile:@"background-right.png"];
            sprite.anchorPoint = CGPointMake(0, 0.5f);
            sprite2.anchorPoint = CGPointMake(0, 0.5f);
            sprite.position = CGPointMake(sprite.contentSize.width + sprite2.contentSize.width - 1, screenSize.height / 2);
            sprite2.position = CGPointMake(sprite.contentSize.width * 2.0f + sprite2.contentSize.width - 1.0f, screenSize.height / 2);
            
            [backgroundNode addChild:sprite z:i tag:i + 2];
            [backgroundNode addChild:sprite2 z:i tag:i + 2];
        }
        
        
		// Initialize the array that contains the scroll factors for individual layers.
        // Uncomment this line of code if not using parralax backgrounds
		speedFactors = [[CCArray alloc] initWithCapacity:numStripes];
		[speedFactors addObject:[NSNumber numberWithFloat:1.0f]];
		NSAssert([speedFactors count] == numStripes, @"speedFactors count does not match numStripes!");
        
        /*
         The Below Code is Only for Parralax Backgrounds. Uncomment this if you want to use a parralax background.
         Also, you need to add a number in front of the png file name.
         For Example, the file name will be bg0.png, and then bg1.png, and bg2.png
         */
        
//		// Add the 4 different layers and position them on the screen
//        for (NSUInteger i = 0; i < numStripes; i++)
//        {
//            NSString* fileName = [NSString stringWithFormat:@"bg%i.png", i];
//            CCSprite* sprite = [CCSprite spriteWithFile:fileName];
//            sprite.anchorPoint = CGPointMake(0, 0.5f);
//            sprite.position = CGPointMake(0, screenSize.height / 2);
//            [backgroundNode addChild:sprite z:i tag:i];
//        }
//        
//		// Add 4 more layers, and position them next to their neighbor stripe this allows endless scrolling
//        for (NSUInteger i = 0; i < numStripes; i++)
//		{
//			NSString* fileName = [NSString stringWithFormat:@"bg%i.png", i];
//			CCSprite* sprite = [CCSprite spriteWithFile:fileName];
//			sprite.anchorPoint = CGPointMake(0, 0.5f);
//			sprite.position = CGPointMake(sprite.contentSize.width - 1, screenSize.height / 2);
//            
//			[backgroundNode addChild:sprite z:i tag:i];
//		}
//        
//		// Initialize the array that contains the scroll factors for individual layers.
//		speedFactors = [[CCArray alloc] initWithCapacity:numStripes];
//		[speedFactors addObject:[NSNumber numberWithFloat:0.7f]];
//		[speedFactors addObject:[NSNumber numberWithFloat:1.0f]];
//		NSAssert([speedFactors count] == numStripes, @"speedFactors count does not match numStripes!");

		[self scheduleUpdate];
	}
	
	return self;
}

-(void) dealloc
{
#ifndef KK_ARC_ENABLED
	[speedFactors release];
	[super dealloc];
#endif // KK_ARC_ENABLED
}

-(void) update:(ccTime)delta
{
    if (([[GameMechanics sharedGameMechanics] gameState] == GameStateRunning) || [[GameMechanics sharedGameMechanics] gameState] == GameStateMenu)
    {
        [self updateRunning:delta];
    }
}

- (void) updateRunning:(ccTime)delta
{
    // read current scroll Speed
    scrollSpeed = [[GameMechanics sharedGameMechanics] backGroundScrollSpeedX];
    
    CCSprite* sprite;
    // we use a c-array since it is faster on iteration
	CCARRAY_FOREACH([backgroundNode children], sprite)
	{
        // retrieve the scrollspeed factor for the current sprite
        NSNumber* factor = [NSNumber numberWithFloat:1.0f];
		
        // move the background layer
		CGPoint pos = sprite.position;
		pos.x -= scrollSpeed * [factor floatValue] * delta;
		
		// when a layer is off screen on the left side, move it to the right end of the screen
		if (pos.x < -sprite.contentSize.width)
		{
			pos.x += 2644.0f;
		}
		
		sprite.position = pos;
	}
}
@end
