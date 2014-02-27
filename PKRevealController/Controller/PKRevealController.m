/*
 
 PKRevealController - Copyright (C) 2012 Philip Kluz (Philip.Kluz@zuui.org)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "PKRevealController.h"
#import "PKRevealControllerContainerView.h"

#define DEFAULT_ANIMATION_DURATION_VALUE 0.185
#define DEFAULT_ANIMATION_CURVE_VALUE UIViewAnimationCurveLinear
#define DEFAULT_LEFT_VIEW_WIDTH_RANGE NSMakeRange(280, 310)
#define DEFAULT_RIGHT_VIEW_WIDTH_RANGE DEFAULT_LEFT_VIEW_WIDTH_RANGE
#define DEFAULT_ALLOWS_OVERDRAW_VALUE YES
#define DEFAULT_ANIMATION_TYPE_VALUE PKRevealControllerAnimationTypeStatic
#define DEFAULT_QUICK_SWIPE_TOGGLE_VELOCITY_VALUE 800.0f
#define DEFAULT_DISABLES_FRONT_VIEW_INTERACTION_VALUE YES
#define DEFAULT_RECOGNIZES_PAN_ON_FRONT_VIEW_VALUE YES
#define DEFAULT_RECOGNIZES_RESET_TAP_ON_FRONT_VIEW_VALUE YES

@interface PKRevealController ()

#pragma mark - Properties
@property (nonatomic, assign, readwrite) PKRevealControllerState state;
@property (nonatomic, assign, readwrite) BOOL isPresentationModeActive;
@property (nonatomic, assign, readwrite) BOOL isAnimationActive;

@property (nonatomic, strong, readwrite) UIViewController *frontViewController;
@property (nonatomic, strong, readwrite) UIViewController *leftViewController;

@property (nonatomic, strong, readwrite) PKRevealControllerContainerView *frontViewContainer;
@property (nonatomic, strong, readwrite) PKRevealControllerContainerView *leftViewContainer;
@property (nonatomic, strong, readwrite) PKRevealControllerContainerView *rightViewContainer;

@property (nonatomic, assign, readwrite) NSRange leftViewWidthRange;
@property (nonatomic, assign, readwrite) NSRange rightViewWidthRange;

@property (nonatomic, strong, readwrite) NSMutableDictionary *controllerOptions;
@property (nonatomic, strong, readwrite) UIPanGestureRecognizer *revealPanGestureRecognizer;
@property (nonatomic, strong, readwrite) UITapGestureRecognizer *revealResetTapGestureRecognizer;

@property (nonatomic, assign, readwrite) CGPoint initialTouchLocation;
@property (nonatomic, assign, readwrite) CGPoint previousTouchLocation;

@end

@implementation PKRevealController

NSString * const PKRevealControllerAnimationDurationKey = @"PKRevealControllerAnimationDurationKey";
NSString * const PKRevealControllerAnimationCurveKey = @"PKRevealControllerAnimationCurveKey";
NSString * const PKRevealControllerAnimationTypeKey = @"PKRevealControllerAnimationTypeKey";
NSString * const PKRevealControllerAllowsOverdrawKey = @"PKRevealControllerAllowsOverdrawKey";
NSString * const PKRevealControllerQuickSwipeToggleVelocityKey = @"PKRevealControllerQuickSwipeToggleVelocityKey";
NSString * const PKRevealControllerDisablesFrontViewInteractionKey = @"PKRevealControllerDisablesFrontViewInteractionKey";
NSString * const PKRevealControllerRecognizesPanningOnFrontViewKey = @"PKRevealControllerRecognizesPanningOnFrontViewKey";
NSString * const PKRevealControllerRecognizesResetTapOnFrontViewKey = @"PKRevealControllerRecognizesResetTapOnFrontViewKey";

NSString * const PKRevealControllerSideMenuWillBeShown = @"PKRevealControllerSideMenuWillBeShown";
NSString * const PKRevealControllerFrontViewControllerWillBeShown = @"PKRevealControllerFrontViewControllerWillBeShown";

#pragma mark - Initialization

+ (instancetype)revealControllerWithFrontViewController:(UIViewController *)frontViewController
                                     leftViewController:(UIViewController *)leftViewController
                                    rightViewController:(UIViewController *)rightViewController
                                                options:(NSDictionary *)options
{
    return [[[self class] alloc] initWithFrontViewController:frontViewController
                                          leftViewController:leftViewController
                                         rightViewController:rightViewController
                                                     options:options];
}

+ (instancetype)revealControllerWithFrontViewController:(UIViewController *)frontViewController
                                     leftViewController:(UIViewController *)leftViewController
                                                options:(NSDictionary *)options
{
    return [[[self class] alloc] initWithFrontViewController:frontViewController
                                          leftViewController:leftViewController
                                                     options:options];
}

+ (instancetype)revealControllerWithFrontViewController:(UIViewController *)frontViewController
                                    rightViewController:(UIViewController *)rightViewController
                                                options:(NSDictionary *)options
{
    return [[[self class] alloc] initWithFrontViewController:frontViewController
                                         rightViewController:rightViewController
                                                     options:options];
}

- (id)initWithFrontViewController:(UIViewController *)frontViewController
               leftViewController:(UIViewController *)leftViewController
                          options:(NSDictionary *)options
{
    return [self initWithFrontViewController:frontViewController
                          leftViewController:leftViewController
                         rightViewController:nil
                                     options:options];
}

- (id)initWithFrontViewController:(UIViewController *)frontViewController
              rightViewController:(UIViewController *)rightViewController
                          options:(NSDictionary *)options
{
    return [self initWithFrontViewController:frontViewController
                          leftViewController:nil
                         rightViewController:rightViewController
                                     options:options];
}

- (id)initWithFrontViewController:(UIViewController *)frontViewController
               leftViewController:(UIViewController *)leftViewController
              rightViewController:(UIViewController *)rightViewController
                          options:(NSDictionary *)options
{
    self = [super init];
    
    if (self != nil)
    {
        _frontViewController = frontViewController;
        _leftViewController = leftViewController;
        
        [self commonInitializer];
        
        if (options)
        {
            _controllerOptions = [options mutableCopy];
        }
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    
    if (self != nil)
    {
        [self commonInitializer];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self != nil)
    {
        [self commonInitializer];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self != nil)
    {
        [self commonInitializer];
    }
    
    return self;
}

- (void)commonInitializer
{
    _controllerOptions = [NSMutableDictionary dictionaryWithCapacity:10];
    _frontViewController.revealController = self;
    _leftViewController.revealController = self;
}

#pragma mark - API

- (void)showViewController:(UIViewController *)controller
{
    [self showViewController:controller
                    animated:YES
                  completion:NULL];
}

- (void)showSidemenu; {
    [[NSNotificationCenter defaultCenter] postNotificationName:PKRevealControllerSideMenuWillBeShown object:self];
    [self showViewController:self.leftViewController completion:NULL];
}

- (void)showFrontViewController; {
    [[NSNotificationCenter defaultCenter] postNotificationName:PKRevealControllerFrontViewControllerWillBeShown object:self];
    [self showViewController:self.frontViewController completion:NULL];
}

- (void)showViewController:(UIViewController *)controller
                completion:(PKDefaultCompletionHandler)completion; {
    if (self.isAnimationActive) {
        return;
    }
    self.isAnimationActive = YES;
    [self showViewController:controller animated:YES completion:completion];
}

 
- (void)showViewController:(UIViewController *)controller
                  animated:(BOOL)animated
                completion:(PKDefaultCompletionHandler)completion
{
    if (controller == self.leftViewController)
    {
        if ([self hasLeftViewController])
        {
            [self showLeftViewControllerAnimated:animated completion:completion];
        }
        
    }
    else if (controller == self.frontViewController)
    {
        [self showFrontViewControllerAnimated:animated completion:completion];
    }
}


- (void)setFrontViewController:(UIViewController *)frontViewController
{
    if (_frontViewController != frontViewController)
    {
        [self removeFrontViewControllerFromHierarchy];
        
        _frontViewController = frontViewController;
        _frontViewController.revealController = self;
        
        [self addFrontViewControllerToHierarchy];
    }
}

- (void)setFrontViewController:(UIViewController *)frontViewController
              focusAfterChange:(BOOL)focus
                    completion:(PKDefaultCompletionHandler)completion
{
    [self setFrontViewController:frontViewController];
    
    [self showViewController:self.frontViewController
                    animated:YES
                  completion:completion];
    
}

- (void)setLeftViewController:(UIViewController *)leftViewController
{
    if (_leftViewController != leftViewController)
    {
        if ([self isLeftViewVisible])
        {
            [self removeLeftViewControllerFromHierarchy];
        }
        
        _leftViewController = leftViewController;
        _leftViewController.revealController = self;
        
        if ([self isLeftViewVisible])
        {
            [self addLeftViewControllerToHierarchy];
        }
    }
}

- (void)showController:(UIViewController *)frontViewController; {
    if (self.isAnimationActive) {
        return;
    }
    self.isAnimationActive = YES;
    [self setFrontViewController:frontViewController];
    [self showViewController:frontViewController animated:YES completion:NULL];
}


- (void)setIsAnimationActive:(BOOL)isAnimationActive; {
    _isAnimationActive = isAnimationActive;
    self.revealPanGestureRecognizer.enabled = !isAnimationActive;
    self.revealResetTapGestureRecognizer.enabled = !isAnimationActive;
    [self.leftViewContainer setUserInteractionEnabled:!isAnimationActive];
}



- (PKRevealControllerType)type
{
    return PKRevealControllerTypeLeft;
}

- (BOOL)hasRightViewController
{
    return PKRevealControllerTypeRight == (self.type & PKRevealControllerTypeRight);
}

- (BOOL)hasLeftViewController
{
    return PKRevealControllerTypeLeft == (self.type & PKRevealControllerTypeLeft);
}

- (void)setMinimumWidth:(CGFloat)minWidth
           maximumWidth:(CGFloat)maxWidth
      forViewController:(UIViewController *)controller
{
    NSRange widthRange = NSMakeRange(minWidth, maxWidth);
    
    if (controller == self.leftViewController)
    {
        self.leftViewWidthRange = widthRange;
    }
}

- (UIViewController *)focusedController
{
    UIViewController *returnViewController = nil;
    switch (self.state)
    {
        case PKRevealControllerFocusesFrontViewController:
            returnViewController = self.frontViewController;
            break;
            
        case PKRevealControllerFocusesLeftViewController:
            returnViewController =  self.leftViewController;
            break;
                        
        case PKRevealControllerFocusesLeftViewControllerInPresentationMode:
            break;
    }
    return returnViewController;
}


#pragma mark - View Lifecycle (System)

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setup];
    [self setupPanGestureRecognizer];
    [self setupTapGestureRecognizer];
    
    [self addFrontViewControllerToHierarchy];
}

#pragma mark - View Lifecycle (Controller)

- (void)addFrontViewControllerToHierarchy
{
    if (self.frontViewController != nil && ![self.childViewControllers containsObject:self.frontViewController])
    {
        [self addChildViewController:self.frontViewController];
        self.frontViewContainer.viewController = self.frontViewController;
        
        if (self.frontViewContainer == nil)
        {
            self.frontViewContainer = [[PKRevealControllerContainerView alloc] initForController:self.frontViewController shadow:YES];
        }
        
        //self.frontViewContainer.frame = [self frontViewFrameForCurrentState];
        [self.view addSubview:self.frontViewContainer];
        [self.frontViewController didMoveToParentViewController:self];
        
        [self updatePanGestureRecognizer];
    }
}

- (void)removeFrontViewControllerFromHierarchy
{
    if ([self.childViewControllers containsObject:self.frontViewController])
    {
        [self removePanGestureRecognizerFromFrontView];
        [self.frontViewContainer removeFromSuperview];
        [self.frontViewController removeFromParentViewController];
    }
}

- (void)addLeftViewControllerToHierarchy
{
    if (self.leftViewController != nil && ![self.childViewControllers containsObject:self.leftViewController])
    {
        [self addChildViewController:self.leftViewController];
        self.leftViewContainer.viewController = self.leftViewController;
        
        if (self.leftViewContainer == nil)
        {
            self.leftViewContainer = [[PKRevealControllerContainerView alloc] initForController:self.leftViewController shadow:NO];
        }
        
        self.leftViewContainer.frame = [self leftViewFrame];
        [self.view insertSubview:self.leftViewContainer belowSubview:self.frontViewContainer];
        [self.leftViewController didMoveToParentViewController:self];
    }
}

- (void)removeLeftViewControllerFromHierarchy
{
    if ([self.childViewControllers containsObject:self.leftViewController])
    {
        [self.leftViewContainer removeFromSuperview];
        [self.leftViewController removeFromParentViewController];
    }
}



- (void)addPanGestureRecognizerToFrontView
{
    [self.frontViewContainer addGestureRecognizer:self.revealPanGestureRecognizer];
}

- (void)removePanGestureRecognizerFromFrontView
{
    if ([[self.frontViewContainer gestureRecognizers] containsObject:self.revealPanGestureRecognizer])
    {
        [self.frontViewContainer removeGestureRecognizer:self.revealPanGestureRecognizer];
    }
}

- (void)addTapGestureRecognizerToFrontView
{
    [self.frontViewContainer addGestureRecognizer:self.revealResetTapGestureRecognizer];
}

- (void)removeTapGestureRecognizerFromFrontView
{
    if ([[self.frontViewContainer gestureRecognizers] containsObject:self.revealResetTapGestureRecognizer])
    {
        [self.frontViewContainer removeGestureRecognizer:self.revealResetTapGestureRecognizer];
    }
}

- (void)updatePanGestureRecognizer
{
    if (self.recognizesPanningOnFrontView)
    {
        [self addPanGestureRecognizerToFrontView];
    }
    else
    {
        [self removePanGestureRecognizerFromFrontView];
    }
}

- (void)updateResetTapGestureRecognizer
{
    if (self.recognizesResetTapOnFrontView
        && (self.state != PKRevealControllerFocusesFrontViewController))
    {
        [self addTapGestureRecognizerToFrontView];
    }
    else
    {
        [self removeTapGestureRecognizerFromFrontView];
    }
}

#pragma mark - Setup

- (void)setup
{
    self.state = PKRevealControllerFocusesFrontViewController;
    self.leftViewWidthRange = DEFAULT_LEFT_VIEW_WIDTH_RANGE;
    self.rightViewWidthRange = DEFAULT_RIGHT_VIEW_WIDTH_RANGE;
    
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
}

- (void)setupViewControllers
{
    [self addFrontViewControllerToHierarchy];
}

- (void)setupPanGestureRecognizer
{
    SEL panRecognitionCallback = @selector(didRecognizePanWithGestureRecognizer:);
    self.revealPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                              action:panRecognitionCallback];
    self.revealPanGestureRecognizer.delegate = self;
}

- (void)setupTapGestureRecognizer
{
    SEL tapRecognitionCallback = @selector(didRecognizeTapWithGestureRecognizer:);
    self.revealResetTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                   action:tapRecognitionCallback];
    self.revealResetTapGestureRecognizer.delegate = self;
}

#pragma mark - Options

- (NSDictionary *)options
{
    return (NSDictionary *)self.controllerOptions;
}

#pragma mark -

- (CGFloat)animationDuration
{
    NSNumber *number = [self.controllerOptions objectForKey:PKRevealControllerAnimationDurationKey];
    
    if (number == nil)
    {
        [self setAnimationDuration:DEFAULT_ANIMATION_DURATION_VALUE];
        return [self animationDuration];
    }
    else
    {
        return [number floatValue];
    }
}

- (void)setAnimationDuration:(CGFloat)animationDuration
{
    [self.controllerOptions setObject:[NSNumber numberWithFloat:animationDuration]
                               forKey:PKRevealControllerAnimationDurationKey];
}

#pragma mark -

- (UIViewAnimationCurve)animationCurve
{
    NSNumber *number = [self.controllerOptions objectForKey:PKRevealControllerAnimationCurveKey];
    
    if (number == nil)
    {
        [self setAnimationCurve:DEFAULT_ANIMATION_CURVE_VALUE];
        return [self animationCurve];
    }
    else
    {
        return (UIViewAnimationCurve)[number integerValue];
    }
}

- (void)setAnimationCurve:(UIViewAnimationCurve)animationCurve
{
    [self.controllerOptions setObject:[NSNumber numberWithInteger:animationCurve]
                               forKey:PKRevealControllerAnimationCurveKey];
}

#pragma mark -

- (PKRevealControllerAnimationType)animationType
{
    NSNumber *number = [self.controllerOptions objectForKey:PKRevealControllerAnimationTypeKey];
    
    if (number == nil)
    {
        [self setAnimationType:DEFAULT_ANIMATION_TYPE_VALUE];
        return [self animationType];
    }
    else
    {
        return (PKRevealControllerAnimationType)[number integerValue];
    }
}

- (void)setAnimationType:(PKRevealControllerAnimationType)animationType
{
    [self.controllerOptions setObject:[NSNumber numberWithInteger:animationType]
                               forKey:PKRevealControllerAnimationTypeKey];
}

#pragma mark -

- (BOOL)allowsOverdraw
{
    NSNumber *number = [self.controllerOptions objectForKey:PKRevealControllerAllowsOverdrawKey];
    
    if (number == nil)
    {
        [self setAllowsOverdraw:DEFAULT_ALLOWS_OVERDRAW_VALUE];
        return [self allowsOverdraw];
    }
    else
    {
        return [number boolValue];
    }
}

- (void)setAllowsOverdraw:(BOOL)allowsOverdraw
{
    [self.controllerOptions setObject:[NSNumber numberWithBool:allowsOverdraw]
                               forKey:PKRevealControllerAllowsOverdrawKey];
}

#pragma mark -

- (void)setQuickSwipeVelocity:(CGFloat)quickSwipeVelocity
{
    [self.controllerOptions setObject:[NSNumber numberWithFloat:quickSwipeVelocity]
                               forKey:PKRevealControllerQuickSwipeToggleVelocityKey];
}

- (CGFloat)quickSwipeVelocity
{
    NSNumber *number = [self.controllerOptions objectForKey:PKRevealControllerQuickSwipeToggleVelocityKey];
    
    if (number == nil)
    {
        [self setQuickSwipeVelocity:DEFAULT_QUICK_SWIPE_TOGGLE_VELOCITY_VALUE];
        return [self quickSwipeVelocity];
    }
    else
    {
        return [number floatValue];
    }
}

#pragma mark -

- (BOOL)disablesFrontViewInteraction
{
    NSNumber *number = [self.controllerOptions objectForKey:PKRevealControllerDisablesFrontViewInteractionKey];
    
    if (number == nil)
    {
        [self setDisablesFrontViewInteraction:DEFAULT_DISABLES_FRONT_VIEW_INTERACTION_VALUE];
        return [self disablesFrontViewInteraction];
    }
    else
    {
        return [number boolValue];
    }
}

- (void)setDisablesFrontViewInteraction:(BOOL)disablesFrontViewInteraction
{
    [self.controllerOptions setObject:[NSNumber numberWithBool:disablesFrontViewInteraction]
                               forKey:PKRevealControllerDisablesFrontViewInteractionKey];
}

#pragma mark -

- (void)setRecognizesPanningOnFrontView:(BOOL)recognizesPanningOnFrontView
{
    [self.controllerOptions setObject:[NSNumber numberWithBool:recognizesPanningOnFrontView]
                               forKey:PKRevealControllerRecognizesPanningOnFrontViewKey];
    [self updatePanGestureRecognizer];
}

- (BOOL)recognizesPanningOnFrontView
{
    NSNumber *number = [self.controllerOptions objectForKey:PKRevealControllerRecognizesPanningOnFrontViewKey];
    
    if (number == nil)
    {
        [self setRecognizesPanningOnFrontView:DEFAULT_RECOGNIZES_PAN_ON_FRONT_VIEW_VALUE];
        return [self recognizesPanningOnFrontView];
    }
    else
    {
        return [number boolValue];
    }
}

#pragma mark -

- (void)setRecognizesResetTapOnFrontView:(BOOL)recognizesResetTapOnFrontView
{
    [self.controllerOptions setObject:[NSNumber numberWithBool:recognizesResetTapOnFrontView]
                               forKey:PKRevealControllerRecognizesResetTapOnFrontViewKey];
    [self updateResetTapGestureRecognizer];
}

- (BOOL)recognizesResetTapOnFrontView
{
    NSNumber *number = [self.controllerOptions objectForKey:PKRevealControllerRecognizesResetTapOnFrontViewKey];
    
    if (number == nil)
    {
        [self setRecognizesResetTapOnFrontView:DEFAULT_RECOGNIZES_RESET_TAP_ON_FRONT_VIEW_VALUE];
        return [self recognizesResetTapOnFrontView];
    }
    else
    {
        return [number boolValue];
    }
}

#pragma mark - Gesture Recognition

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    SEL checkSelector = @selector(shouldReceiveRevealControllerTouch:);
    if ([self.frontViewContainer.viewController.childViewControllers count] > 0 && [[self.frontViewContainer.viewController.childViewControllers objectAtIndex:0] respondsToSelector:checkSelector]) {
        id _controller = [self.frontViewContainer.viewController.childViewControllers objectAtIndex:0];
        
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[_controller class] instanceMethodSignatureForSelector:checkSelector]];
        [invocation setTarget:_controller];
        [invocation setSelector:checkSelector];
        [invocation setArgument:&touch atIndex:2];
        [invocation invoke];

        BOOL returnValue;
        [invocation getReturnValue:&returnValue];
        return returnValue;
    } else {
        return YES;
    }
}

- (void)didRecognizeTapWithGestureRecognizer:(UITapGestureRecognizer *)recognizer
{
    [self showViewController:self.frontViewController];
}

- (void)didRecognizePanWithGestureRecognizer:(UIPanGestureRecognizer *)recognizer
{
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
            [self handleGestureBeganWithRecognizer:recognizer];
            break;
            
        case UIGestureRecognizerStateChanged:
            [self handleGestureChangedWithRecognizer:recognizer];
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self handleGestureEndedWithRecognizer:recognizer];
            break;
            
        default:
        {
            self.revealPanGestureRecognizer.enabled = YES;
        }
            break;
    }
}

#pragma mark - Gesture Handling

- (void)handleGestureBeganWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    self.initialTouchLocation = [recognizer locationInView:self.view];
    self.previousTouchLocation = self.initialTouchLocation;
}

- (void)handleGestureChangedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGPoint currentTouchLocation = [recognizer locationInView:self.view];
    CGFloat delta = currentTouchLocation.x - self.previousTouchLocation.x;
    self.previousTouchLocation = currentTouchLocation;
    
    [self translateViewsBy:delta animationType:[self animationType]];
    [self adjustLeftAndRightViewVisibilities];
}

- (void)handleGestureEndedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGFloat velocity = [recognizer velocityInView:self.view].x;
    
    if ([self shouldMoveFrontViewRightwardsForVelocity:velocity])
    {
        [self moveFrontViewRightwardsIfPossible];
    }
    else if ([self shouldMoveFrontViewLeftwardsForVelocity:velocity])
    {
        [self moveFrontViewLeftwardsIfPossible];
    }
    else
    {
        [self snapFrontViewToClosestEdge];
    }
    
    self.revealPanGestureRecognizer.enabled = YES;
}

#pragma mark - Gesture Delegation

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.revealPanGestureRecognizer)
    {
        CGPoint translation = [self.revealPanGestureRecognizer translationInView:self.frontViewContainer];
        return (fabs(translation.x) >= fabs(translation.y));
    }
    else if (gestureRecognizer == self.revealResetTapGestureRecognizer)
    {
        return ([self isLeftViewVisible]);
    }
    
    return YES;
}

#pragma mark - Translation

- (void)translateViewsBy:(CGFloat)delta animationType:(PKRevealControllerAnimationType)animationType
{
    CGRect frame = self.frontViewContainer.frame;
    CGRect frameForFrontViewCenter = [self frontViewFrameForCenter];
    CGFloat translation = CGRectGetMinX(frame)+delta;
    
    BOOL isPositiveTranslation = (translation > CGRectGetMinX(frameForFrontViewCenter));
    BOOL positiveTranslationDoesNotExceedMinWidth = (translation < CGRectGetMinX(frameForFrontViewCenter)+[self leftViewMinWidth]);
    BOOL positiveTranslationDoesNotExceedMaxWidth = (translation < CGRectGetMinX(frameForFrontViewCenter)+[self leftViewMaxWidthRespectingOverdraw:YES]);
    
    BOOL isNegativeTranslation = (translation < CGRectGetMinX(frameForFrontViewCenter));
    BOOL negativeTranslationDoesNotExceedMinWidth = (translation > CGRectGetMinX(frameForFrontViewCenter)-[self rightViewMinWidth]);
    BOOL negativeTranslationDoesNotExceedMaxWidth = (translation > CGRectGetMinX(frameForFrontViewCenter)-[self rightViewMaxWidthRespectingOverdraw:YES]);
    
    BOOL isLegalNormalTranslation = ([self hasLeftViewController] && isPositiveTranslation && positiveTranslationDoesNotExceedMinWidth)
    || ([self hasRightViewController] && isNegativeTranslation && negativeTranslationDoesNotExceedMinWidth);
    
    BOOL isLegalOverdrawTranslation = ([self hasLeftViewController] && isPositiveTranslation && positiveTranslationDoesNotExceedMaxWidth)
    || ([self hasRightViewController] && isNegativeTranslation && negativeTranslationDoesNotExceedMaxWidth);
    
    if (isLegalNormalTranslation || isLegalOverdrawTranslation)
    {
        BOOL isOverdrawing = (!isLegalNormalTranslation && isLegalOverdrawTranslation);
        
        if (animationType == PKRevealControllerAnimationTypeStatic)
        {
            [self translateFrontViewBy:delta
                         isOverdrawing:isOverdrawing];
        }
    }
}

- (void)translateFrontViewBy:(CGFloat)delta isOverdrawing:(BOOL)overdraw
{
    CGRect frame = self.frontViewContainer.frame;
    
    if (overdraw && self.allowsOverdraw)
    {
        frame.origin.x = floorf(frame.origin.x + (delta / 2.0f));
    }
    else if (!overdraw)
    {
        frame.origin.x += delta;
    }
    
    self.frontViewContainer.frame = frame;
}

- (void)moveFrontViewRightwardsIfPossible
{
    CGPoint origin = self.frontViewContainer.frame.origin;
    
    if (isNegative(origin.x))
    {
        [self showFrontViewController];
    }
    else if (isZero(origin.x))
    {
        [self showSidemenu];
    }
    else
    {
        [self showSidemenu];
    }
}

- (void)moveFrontViewLeftwardsIfPossible
{
    CGPoint origin = self.frontViewContainer.frame.origin;
    
    if (isNegative(origin.x))
    {

    }
    else if (isZero(origin.x))
    {

    }
    else
    {
        [self showViewController:self.frontViewController];
    }
}

#pragma mark - Helper (Internal)

- (void)showLeftViewControllerAnimated:(BOOL)animated
                            completion:(PKDefaultCompletionHandler)completion
{

    __weak PKRevealController *weakSelf = self;
    
    void (^showLeftViewBlock)(BOOL finished) = ^(BOOL finished)
    {
        [weakSelf addLeftViewControllerToHierarchy];
        
        [weakSelf setFrontViewFrame:[weakSelf frontViewFrameForVisibleLeftView]
                           animated:animated
                         completion:^(BOOL finished)
         {
             if (weakSelf.disablesFrontViewInteraction)
             {
                 [weakSelf.frontViewContainer disableUserInteractionForContainedView];
             }
             weakSelf.state = PKRevealControllerFocusesLeftViewController;
             [weakSelf updateResetTapGestureRecognizer];
             safelyExecuteCompletionBlockOnMainThread(self, completion, finished);
         }];
    };
    
    showLeftViewBlock(YES);
}


- (void)showRightViewControllerAnimated:(BOOL)animated
                             completion:(PKDefaultCompletionHandler)completion
{

    __weak PKRevealController *weakSelf = self;
    
    void (^showRightViewBlock)(BOOL finished) = ^(BOOL finished)
    {
        [weakSelf removeLeftViewControllerFromHierarchy];
        
        [weakSelf setFrontViewFrame:[weakSelf frontViewFrameForVisibleRightView]
                           animated:animated
                         completion:^(BOOL finished)
         {
             if (weakSelf.disablesFrontViewInteraction)
             {
                 [weakSelf.frontViewContainer disableUserInteractionForContainedView];
             }
             [weakSelf updateResetTapGestureRecognizer];
             safelyExecuteCompletionBlockOnMainThread(self, completion, finished);
         }];
    };
    
    if ([self isLeftViewVisible])
    {
        [self showFrontViewControllerAnimated:animated
                                   completion:^(BOOL finished)
         {
             showRightViewBlock(finished);
         }];
    }
    else
    {
        showRightViewBlock(YES);
    }
}


- (void)showFrontViewControllerAnimated:(BOOL)animated
                             completion:(PKDefaultCompletionHandler)completion
{
    
    __weak PKRevealController *weakSelf = self;
    
    [self setFrontViewFrame:[self frontViewFrameForCenter]
                   animated:animated
                 completion:^(BOOL finished)
     {
         if (weakSelf.disablesFrontViewInteraction)
         {
             [weakSelf.frontViewContainer enableUserInteractionForContainedView];
         }
         weakSelf.state = PKRevealControllerFocusesFrontViewController;
         [weakSelf removeLeftViewControllerFromHierarchy];
         [weakSelf updateResetTapGestureRecognizer];
         safelyExecuteCompletionBlockOnMainThread(weakSelf, completion, finished);
     }];
}


#pragma mark -

- (void)setFrontViewFrame:(CGRect)frame
                 animated:(BOOL)animated
               completion:(PKDefaultCompletionHandler)completion
{
    CGFloat duration = [self animationDuration];
    UIViewAnimationOptions options = (UIViewAnimationOptionBeginFromCurrentState | [self animationCurve]);

	self.isAnimationActive = YES;
    if (self.animationType == PKRevealControllerAnimationTypeStatic)
    {
        [self setFrontViewFrameLinearly:frame
                               animated:animated
                               duration:duration
                                options:options
                             completion:completion];
    } else if (self.animationType == PKRevealControllerAnimationTypeBouncy)
    {
        [self setFrontViewFrameBouncy:frame
                               animated:animated
                               duration:duration
                                options:options
                             completion:completion];
    }

}

- (void)setFrontViewFrameLinearly:(CGRect)frame
                         animated:(BOOL)animated
                         duration:(CGFloat)duration
                          options:(UIViewAnimationOptions)options
                       completion:(PKDefaultCompletionHandler)completion
{
    [UIView animateWithDuration:duration delay:0.0f options:options animations:^
     {
         self.frontViewContainer.frame = frame;
     }
                     completion:^(BOOL finished)
     {
         safelyExecuteCompletionBlockOnMainThread(self, completion, finished);
     }];
}



- (void)setFrontViewFrameBouncy:(CGRect)frame
                       animated:(BOOL)animated
                       duration:(CGFloat)duration
                        options:(UIViewAnimationOptions)options
                     completion:(PKDefaultCompletionHandler)completion
{
    NSInteger currentX = self.frontViewContainer.frame.origin.x;
    NSInteger newX = frame.origin.x;
    NSInteger bounceDistance = -10;
        
    if(newX > currentX) {
        bounceDistance = 10;
        [UIView animateWithDuration:duration/2 delay:0.0f options:options animations:^
         {
             self.frontViewContainer.frame = CGRectMake(newX+bounceDistance, frame.origin.y,
                                                        frame.size.width, frame.size.height);
         } completion:^(BOOL finished) {
             [UIView animateWithDuration:duration/4 delay:0.0f options:options animations:^
              {
                  self.frontViewContainer.frame = CGRectMake(newX-bounceDistance/6, frame.origin.y,
                                                             frame.size.width, frame.size.height);
                  
              } completion:^(BOOL finished) {
                  [UIView animateWithDuration:duration/6 delay:0.0f options:options animations:^
                   {
                       self.frontViewContainer.frame = [self frontViewFrameForVisibleLeftView];
                   } completion:^(BOOL finished) {
						safelyExecuteCompletionBlockOnMainThread(self, completion, finished);
                   }];
              }];
         }];
    } else {

        newX = 0;
        [UIView animateWithDuration:duration/2 delay:0.0f options:options animations:^
         {
             self.frontViewContainer.frame = CGRectMake(newX+bounceDistance, frame.origin.y,
                                                        frame.size.width, frame.size.height);
         } completion:^(BOOL finished) {
             [UIView animateWithDuration:duration/4 delay:0.0f options:options animations:^
              {
                  self.frontViewContainer.frame = [self frontViewFrameForCenter];
                  
                   } completion:^(BOOL finished) {
					   safelyExecuteCompletionBlockOnMainThread(self, completion, finished);
                   }];
              }];
    }
}




#pragma mark - Helpers (Gestures)

- (BOOL)shouldMoveFrontViewRightwardsForVelocity:(CGFloat)velocity
{
    return (isPositive(velocity) && velocity > self.quickSwipeVelocity);
}

- (BOOL)shouldMoveFrontViewLeftwardsForVelocity:(CGFloat)velocity
{
    return (isNegative(velocity) && fabsf(velocity) > self.quickSwipeVelocity);
}

- (void)snapFrontViewToClosestEdge
{
    UIViewController *controllerToShow = nil;
    
    if ([self isLeftViewVisible])
    {
        CGRect relevantLeftViewRect = self.leftViewContainer.frame;
        relevantLeftViewRect.size.width = [self leftViewMinWidth];
        
        BOOL showLeftView = CGRectGetWidth(CGRectIntersection(self.frontViewContainer.frame, relevantLeftViewRect)) <= floorf(CGRectGetWidth(relevantLeftViewRect)/2.0f);
        controllerToShow = showLeftView ? self.leftViewController : self.frontViewController;
    }
    else
    {
        controllerToShow = self.frontViewController;
    }
    
    [self showViewController:controllerToShow];
}

#pragma mark - Helpers (States)

- (BOOL)isLeftViewVisible
{
    return isPositive(CGRectGetMinX(self.frontViewContainer.frame));
}

- (BOOL)isFrontViewEntirelyVisible
{
    return isZero(CGRectGetMinX(self.frontViewContainer.frame));
}

- (void)adjustLeftAndRightViewVisibilities
{
    CGPoint origin = self.frontViewContainer.frame.origin;
    
    if (isPositive(origin.x))
    {
        [self addLeftViewControllerToHierarchy];
    }
    else
    {
        [self removeLeftViewControllerFromHierarchy];
    }
}

#pragma mark - Helper (Sizing)

- (CGFloat)leftViewMaxWidthRespectingOverdraw:(BOOL)respectOverdraw
{
    if (respectOverdraw)
    {
        return self.allowsOverdraw ? self.leftViewWidthRange.length : [self leftViewMinWidth];
    }
    else
    {
        return self.leftViewWidthRange.length;
    }
}

- (CGFloat)rightViewMaxWidthRespectingOverdraw:(BOOL)respectOverdraw
{
    if (respectOverdraw)
    {
        return self.allowsOverdraw ? self.rightViewWidthRange.length : [self rightViewMinWidth];
    }
    else
    {
        return self.rightViewWidthRange.length;
    }
}

- (CGFloat)leftViewMinWidth
{
    return self.leftViewWidthRange.location;
}

- (CGFloat)rightViewMinWidth
{
    return self.rightViewWidthRange.location;
}

#pragma mark - Helper (Frames)

- (CGRect)frontViewFrameForCurrentState
{
    CGRect returnRect = CGRectNull;
    switch (self.state)
    {
        case PKRevealControllerFocusesFrontViewController:
            returnRect = [self frontViewFrameForCenter];
            break;
            
        case PKRevealControllerFocusesLeftViewController:
            returnRect = [self frontViewFrameForVisibleLeftView];
            break;            
            
        case PKRevealControllerFocusesLeftViewControllerInPresentationMode:
            break;
    }
    
    return returnRect;
}

- (CGRect)frontViewFrameForVisibleLeftView
{
    CGFloat offset = [self leftViewMinWidth];
    return CGRectOffset([self frontViewFrameForCenter], offset, 0.0f);
}

- (CGRect)frontViewFrameForVisibleRightView
{
    CGFloat offset = [self rightViewMinWidth];
    return CGRectOffset([self frontViewFrameForCenter], -offset, 0.0f);
}

- (CGRect)frontViewFrameForCenter
{
    CGRect frame = self.view.bounds;
    frame.origin = CGPointMake(0.0f, 0.0f);
    return frame;
}

- (CGRect)frontViewFrameForLeftViewPresentationMode
{
    CGRect frame = [self frontViewFrameForCenter];
    frame.origin.x = [self leftViewMaxWidthRespectingOverdraw:NO];
    return frame;
}

- (CGRect)frontViewFrameForRightViewPresentationMode
{
    CGRect frame = [self frontViewFrameForCenter];
    frame.origin.x = -[self rightViewMaxWidthRespectingOverdraw:NO];
    return frame;
}

- (CGRect)leftViewFrame
{
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake([self leftViewMaxWidthRespectingOverdraw:NO], CGRectGetHeight(self.view.bounds));
    frame.origin = CGPointZero;
    return frame;
}

- (CGRect)rightViewFrame
{
    CGRect frame = self.frontViewContainer.bounds;
    
    if (self.animationType == PKRevealControllerAnimationTypeStatic)
    {
        frame.size = CGSizeMake([self rightViewMaxWidthRespectingOverdraw:NO], CGRectGetHeight(self.view.bounds));
        frame.origin.x = CGRectGetWidth(self.frontViewContainer.bounds)-CGRectGetWidth(frame);
        frame.origin.y = 0.0f;
    }
    
    return frame;
}



#pragma mark - Memory Management

- (void)dealloc
{
    [self.frontViewController removeFromParentViewController];
    [self.frontViewController.view removeFromSuperview];
    self.frontViewContainer = nil;
    
    [self.leftViewController removeFromParentViewController];
    [self.leftViewController.view removeFromSuperview];
    self.leftViewContainer = nil;
    
}

#pragma mark - Helpers (Generic)

NS_INLINE BOOL isPositive(CGFloat value)
{
    return (value > 0.0f);
}

NS_INLINE BOOL isNegative(CGFloat value)
{
    return (value < 0.0f);
}

NS_INLINE BOOL isZero(CGFloat value)
{
    return (value == 0.0f);
}

NS_INLINE void safelyExecuteCompletionBlockOnMainThread(PKRevealController* self, PKDefaultCompletionHandler block, BOOL finished)
{
    void(^executeBlock)() = ^()
    {
        if (block != NULL)
        {
            block(finished);
        }
        self.isAnimationActive = NO;
    };
    
    if ([NSThread isMainThread])
    {
        executeBlock();
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), executeBlock);
    }
}

@end