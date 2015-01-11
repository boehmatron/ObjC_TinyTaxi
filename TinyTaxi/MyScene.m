//
//  MyScene.m
//  TinyTaxi
//
//  Created by Johannes Boehm on 21.04.14.
//  Copyright (c) 2014 Johannes Boehm. All rights reserved.
//

#import "MyScene.h"
#import "SKSpriteNode+DebugDraw.h"

// Define Bit Masks for Collision Detection
typedef NS_OPTIONS(uint32_t, CNPhysicsCategory)
{
    CNPhysicsCategoryEdge = 1 <<0,
    CNPhysicsCategoryTaxi = 1 <<1,
    CNPhysicsCategoryPlatform = 1 <<2,
    CNPhysicsCategoryGround = 1 <<3,

};

@interface MyScene() <SKPhysicsContactDelegate>
@end

@implementation MyScene
{
    SKNode *_gameNode;
    SKSpriteNode *_taxiNode;
    SKLabelNode *platformLabel;
    
    int _currentLevel;

}

-(instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        [self initializeScene];
    }
    return self;
}

-(void)initializeScene
{
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsWorld.contactDelegate = self;
    self.physicsBody.categoryBitMask = CNPhysicsCategoryEdge;
    self.physicsBody.collisionBitMask = CNPhysicsCategoryTaxi;
    self.physicsWorld.gravity = CGVectorMake(0.0f, -4.0f);
    
    SKSpriteNode* bg = [SKSpriteNode spriteNodeWithImageNamed:@"background.png"];
    bg.position = CGPointMake(self.size.width/2, self.size.height/2);
    [self addChild: bg];
    
    SKSpriteNode* ground = [SKSpriteNode spriteNodeWithImageNamed:@"ground.png"];
    ground.position = CGPointMake(self.size.width/2, 16);
    CGSize contactSizeGround = CGSizeMake(ground.size.width, ground.size.height);
    ground.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: contactSizeGround];
    ground.physicsBody.dynamic = YES;
    ground.physicsBody.allowsRotation = NO;
    
    [ground attachDebugRectWithSize:contactSizeGround];
    
    ground.physicsBody.categoryBitMask = CNPhysicsCategoryGround;
    ground.physicsBody.collisionBitMask = CNPhysicsCategoryEdge | CNPhysicsCategoryTaxi | CNPhysicsCategoryPlatform;
    ground.physicsBody.contactTestBitMask = CNPhysicsCategoryEdge | CNPhysicsCategoryTaxi | CNPhysicsCategoryPlatform;
    [self addChild: ground];

    
    /*/Buttons
    SKSpriteNode* platform = [SKSpriteNode spriteNodeWithImageNamed:@"button.png"];
    CGSize contactSize = CGSizeMake(platform.size.width, platform.size.height);
    platform.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:contactSize];
    platform.physicsBody.dynamic = NO;
    platform.physicsBody.categoryBitMask = CNPhysicsCategoryPlatform;
    platform.physicsBody.collisionBitMask = CNPhysicsCategoryTaxi;
    platform.physicsBody.contactTestBitMask = CNPhysicsCategoryTaxi;
    
    platform.position = CGPointMake(100, 100);
    platform.name = @"platform";
    [self addChild:platform];*/
    
    SKLabelNode *platformLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetiva"];
    platformLabel.position = CGPointMake(self.size.width/2, 200);
    platformLabel.fontSize = 20;
    platformLabel.text = @"Test";
    platformLabel.name = @"platformLabel";
    [self addChild:platformLabel];

  
    _gameNode = [SKNode node];
    [self addChild:_gameNode];

    _currentLevel = 1;
    [self setupLevel: _currentLevel];
}

- (void)setupLevel:(int)levelNum
{
    //load the plist file
    NSString *fileName = [NSString stringWithFormat:@"level%i",levelNum];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    NSDictionary *level = [NSDictionary dictionaryWithContentsOfFile:filePath];
    [self addTaxiAtPosition: CGPointFromString(level[@"taxiPosition"])];
    [self addBlocksFromArray:level[@"blocks"]];
}

-(void)createLabel {
    //SKLabelNode *platformLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetiva"];
    //platformLabel.position = CGPointMake(self.size.width/2, 200);
    //platformLabel.fontSize = 20;
    //[self addChild:platformLabel];
}

-(void)addTaxiAtPosition:(CGPoint)pos
{
    
    _taxiNode = [SKSpriteNode spriteNodeWithImageNamed:@"taxi.png"];
    // _taxiNode.position = CGPointMake(self.size.width/2, self.size.height/2);
    _taxiNode.position = pos;
    
    CGSize contactSize = CGSizeMake(_taxiNode.size.width, _taxiNode.size.height);
    _taxiNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: contactSize];
    _taxiNode.physicsBody.dynamic = YES;
    _taxiNode.physicsBody.allowsRotation = NO;

    [_taxiNode attachDebugRectWithSize:contactSize];
    
    _taxiNode.physicsBody.categoryBitMask = CNPhysicsCategoryTaxi;
    _taxiNode.physicsBody.collisionBitMask = CNPhysicsCategoryEdge | CNPhysicsCategoryTaxi | CNPhysicsCategoryPlatform |CNPhysicsCategoryGround;
    _taxiNode.physicsBody.contactTestBitMask = CNPhysicsCategoryEdge | CNPhysicsCategoryTaxi | CNPhysicsCategoryPlatform | CNPhysicsCategoryGround;
    
    [_gameNode addChild:_taxiNode];
    
}

-(void)addBlocksFromArray:(NSArray*)blocks {
    // 1
    for (NSDictionary *block in blocks) {
        //2
        SKSpriteNode *blockSprite = [self addBlockWithRect:CGRectFromString(block[@"rect"])];
        blockSprite.physicsBody.dynamic = NO;
        blockSprite.physicsBody.categoryBitMask = CNPhysicsCategoryPlatform;
        blockSprite.physicsBody.collisionBitMask = CNPhysicsCategoryEdge | CNPhysicsCategoryTaxi | CNPhysicsCategoryPlatform;
        blockSprite.physicsBody.contactTestBitMask = CNPhysicsCategoryEdge | CNPhysicsCategoryTaxi | CNPhysicsCategoryPlatform;
        [_gameNode addChild:blockSprite]; }
}

-(SKSpriteNode*)addBlockWithRect:(CGRect)blockRect
{
    // 3
    NSString *textureName = [NSString stringWithFormat: @"%.fx%.f.png",blockRect.size.width, blockRect.size.height];
    // 4
    SKSpriteNode *blockSprite = [SKSpriteNode spriteNodeWithImageNamed:textureName];
    blockSprite.position = blockRect.origin;
    // 5
    CGRect bodyRect = CGRectInset(blockRect, 2, 2); blockSprite.physicsBody =
    [SKPhysicsBody bodyWithRectangleOfSize:bodyRect.size];
    //6
    [blockSprite attachDebugRectWithSize:blockSprite.size];
    
    return blockSprite;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint touchLocation = [touch locationInNode:self];
        if (touchLocation.x > self.size.width / 2.0) {
            [_taxiNode.physicsBody applyImpulse:CGVectorMake(0.6, 3.5)];
        } else {
            [_taxiNode.physicsBody applyImpulse:CGVectorMake(-0.6, 3.5)];
        }
    }
    
    //[_taxiNode.physicsBody applyImpulse:CGVectorMake(0.0, 5)];
    
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    uint32_t collision = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask);
    if (collision == (CNPhysicsCategoryTaxi|CNPhysicsCategoryPlatform)) {
        platformLabel.text = @"YES";
        
        NSLog(@"SUCCESS");
    }
    if (collision == (CNPhysicsCategoryTaxi|CNPhysicsCategoryEdge)) {
        platformLabel.text = @"YEAEE";
        NSLog(@"FAIL"); }
}

-(void)update:(CFTimeInterval)currentTime
{
    /* Called before each frame is rendered */
}

@end
