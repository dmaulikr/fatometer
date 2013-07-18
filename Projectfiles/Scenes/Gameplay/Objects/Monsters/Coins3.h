//
//  Coins3.h
//  Fat
//
//  Created by Shalin Shah on 7/17/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "UnhealthyFood.h"
#import "GameplayLayer.h"

@interface Coins3 : UnhealthyFood
{
    
    int posX;
    int posY;
    
    int coinValue;
    ScoreboardEntryNode *coinsDisplayNode;
    ScoreboardEntryNode *availableMoney;
    ScoreboardEntryNode *inAppCurrencyDisplayNode;
}

@property (nonatomic, assign) float cost;



@end
