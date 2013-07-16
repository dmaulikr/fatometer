//
//  Coins.h
//  Fat
//
//  Created by Shalin Shah on 7/16/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "UnhealthyFood.h"
#import "GameplayLayer.h"
#import <Foundation/Foundation.h>

@interface Coins : UnhealthyFood

@property (nonatomic, assign) float cost;


@end

int coinValue;
ScoreboardEntryNode *coinsDisplayNode;
ScoreboardEntryNode *availableMoney;
ScoreboardEntryNode *inAppCurrencyDisplayNode;