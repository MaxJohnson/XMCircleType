//
//  XMCircleView.m
//  XMCircleType
//
//  Created by Michael Teeuw on 07-01-14.
//  Copyright (c) 2014 Michael Teeuw. All rights reserved.
//

#import "XMCircleView.h"

@interface XMCircleView ()

@property (nonatomic) CGPoint circleCenterPoint;

@end

@implementation XMCircleView

#define VISUAL_DEBUGGING NO

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setDefaults];
}

- (void)layoutSubviews
{
    self.circleCenterPoint = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    [self setNeedsDisplay];
}

- (void) setDefaults
{
    self.radius = (self.bounds.size.width <= self.bounds.size.height) ? self.bounds.size.width / 3 : self.bounds.size.height / 3;
    self.baseAngle = 270 * M_PI / 180;
    self.characterSpacing = 0.85;
}

- (float) kerningForCharacter:(NSString *)currentCharacter afterCharacter:(NSString *)previousCharacter
{
    float totalSize = [[NSString stringWithFormat:@"%@%@", previousCharacter, currentCharacter] sizeWithAttributes:self.textAttributes].width;
    float currentCharacterSize = [currentCharacter sizeWithAttributes:self.textAttributes].width;
    float previousCharacterSize = [previousCharacter sizeWithAttributes:self.textAttributes].width;
    
    return (currentCharacterSize + previousCharacterSize) - totalSize;
}

- (void)drawRect:(CGRect)rect
{
    //Calculate the angle per charater.
    CGSize stringSize = [self.text sizeWithAttributes:self.textAttributes];

    float circumference = 2 * self.radius * M_PI;
    float anglePerPixel = M_PI * 2 / circumference * self.characterSpacing;
    float startAngle;
    
    //Set initial angle.
    if (self.textAlignment == NSTextAlignmentRight) {
        startAngle = self.baseAngle - (stringSize.width * anglePerPixel);
    } else if(self.textAlignment == NSTextAlignmentLeft) {
        startAngle = self.baseAngle;
    } else {
        startAngle = self.baseAngle - (stringSize.width * anglePerPixel/2);
    }
    
    //Set drawing context.
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Set helper vars.
    float characterPosition = 0;
    NSString *lastCharacter;
    
    //Loop thru characters of string.
    for (NSInteger charIdx=0; charIdx<self.text.length; charIdx++) {
        
        //Set current character.
        NSString *currentCharacter = [NSString stringWithFormat:@"%c", [self.text characterAtIndex:charIdx]];
        
        //Set currenct character size & kerning.
        CGSize stringSize = [currentCharacter sizeWithAttributes:self.textAttributes];
        float kerning = (lastCharacter) ? [self kerningForCharacter:currentCharacter afterCharacter:lastCharacter] : 0;

        //Add half of character width to characterPosition, substract kerning.
        characterPosition += (stringSize.width / 2) - kerning;
        
        //Calculate character Angle
        float angle = characterPosition * anglePerPixel + startAngle;
        
        //Calculate character drawing point.
        CGPoint characterPoint = CGPointMake(self.radius * cos(angle) + self.circleCenterPoint.x, self.radius * sin(angle) + self.circleCenterPoint.y);

        //Strings are always drawn from top left. Calculate the right pos to draw it on bottom center.
        CGPoint stringPoint = CGPointMake(characterPoint.x -stringSize.width/2 , characterPoint.y - stringSize.height);
        
        //Save the current context and do the character rotation magic.
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, characterPoint.x, characterPoint.y);
        CGAffineTransform textTransform = CGAffineTransformMakeRotation(angle + M_PI_2);
        CGContextConcatCTM(context, textTransform);
        CGContextTranslateCTM(context, -characterPoint.x, -characterPoint.y);
        
        //Draw the character
        [currentCharacter drawAtPoint:stringPoint withAttributes:self.textAttributes];
        
        //If we need some viaual debugging, draw the visuals.
        if (VISUAL_DEBUGGING) {
            [[UIColor colorWithRed:1 green:0 blue:0 alpha:0.5] setStroke];
            [[UIBezierPath bezierPathWithRect:CGRectMake(stringPoint.x, stringPoint.y, stringSize.width, stringSize.height)] stroke];

            
            //Show character point
            [[UIColor blueColor] setStroke];
            [[UIBezierPath bezierPathWithArcCenter:characterPoint radius:1 startAngle:0 endAngle:2*M_PI clockwise:YES] stroke];
        }
        
        //Restore context to make sure the rotation is only applied to this character.
        CGContextRestoreGState(context);
        
        //Add the other half of the character size to the character position.
        characterPosition += stringSize.width / 2;
        
        //store the currentCharacter to use in the next run for kerning calculation.
        lastCharacter = currentCharacter;
    }
     
    //If we need some viaual debugging, draw the circle.
    if (VISUAL_DEBUGGING) {
        //Show Circle
        [[UIColor greenColor] setStroke];
        [[UIBezierPath bezierPathWithArcCenter:self.circleCenterPoint radius:self.radius startAngle:0 endAngle:2*M_PI clockwise:YES] stroke];
        
        UIBezierPath *line = [UIBezierPath bezierPath];
        [line moveToPoint:CGPointMake(self.circleCenterPoint.x, self.circleCenterPoint.y - self.radius)];
        [line addLineToPoint:CGPointMake(self.circleCenterPoint.x, self.circleCenterPoint.y + self.radius)];
        [line moveToPoint:CGPointMake(self.circleCenterPoint.x-self.radius, self.circleCenterPoint.y)];
        [line addLineToPoint:CGPointMake(self.circleCenterPoint.x+self.radius, self.circleCenterPoint.y)];
        [line stroke];
    }

}

#pragma mark Getters & Setters

- (void)setText:(NSString *)text
{
    _text = text;
    [self setNeedsDisplay];
}

- (void)setTextAttributes:(NSDictionary *)textAttributes
{
    _textAttributes = textAttributes;
    [self setNeedsDisplay];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    _textAlignment = textAlignment;
    [self setNeedsDisplay];
}

-(void)setRadius:(float)radius
{
    _radius = radius;
    [self setNeedsDisplay];
}

- (void)setBaseAngle:(float)baseAngle
{
    _baseAngle = baseAngle;
    [self setNeedsDisplay];
}

- (void)setCharacterSpacing:(float)characterSpacing
{
    _characterSpacing = characterSpacing;
    [self setNeedsDisplay];
}

@end