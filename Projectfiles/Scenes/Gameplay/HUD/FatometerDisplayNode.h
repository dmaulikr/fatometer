//
//  FatometerDisplayNode.h
//  My-MGWU-Endless-Game-Project
//
//  Created by Shalin Shah on 6/27/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FatometerDisplayNode : CCNode

{
    NSString *weightImage;
    NSString *lostWeightImage;
    int tooFat;
    int tooThin;
    NSMutableArray *weightSprites;
    CCTexture2D *weightTexture;
    CCTexture2D *lostweightTexture;
    CCTexture2D *gainweightTexture;
}

- (id)initWithWeightImage:(NSString*)weightImage lostWeightImage:(NSString*)lostWeightImage maxWeight:(int)maxWeight;

@property (nonatomic, assign) int weight;


@end
