//
//  PersonalBestNode.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/21/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "PersonalBestNode.h"
#import "STYLES.h"

@implementation PersonalBestNode

- (id)initWithPersonalBest:(int)personalBestArg
{
    self = [super init];
    
    if (self)
    {
        personalBest = personalBestArg;
    }
    
    return self;
}

- (void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    CCLayerColor* colorLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)];
    colorLayer.size = self.contentSize;
    colorLayer.anchorPoint = ccp(0,0);
//    [self addChild:colorLayer z:-10];
    
    CCSprite *bestScoreSprite = [CCSprite spriteWithFile:@"best-score.png"];
    bestScoreSprite.position = ccp((self.contentSize.width)-122, (self.contentSize.height)-23);
    [self addChild:bestScoreSprite z:-10];
    
    NSString *personalBestString = [NSString stringWithFormat:@"BEST: %dm",personalBest];
    
    CCLabelTTF *highScoreLabel = [CCLabelTTF labelWithString:personalBestString
                                                    fontName:DEFAULT_FONT
                                                    fontSize:20];
    highScoreLabel.color = INVERSE_FONT_COLOR;
    highScoreLabel.anchorPoint = ccp(0, 1);
    highScoreLabel.position = ccp((self.contentSize.width/4) - 50, (self.contentSize.height)-18);
    [self addChild:highScoreLabel];
}

@end
