/*
 
 PKRevealController - Copyright (C) 2012 Philip Kluz (Philip.Kluz@zuui.org)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import <UIKit/UIKit.h>
#import "UIViewController+PKRevealController.h"

typedef NS_ENUM(NSUInteger, PKRevealControllerState)
{
    PKRevealControllerFocusesLeftViewController,
    PKRevealControllerFocusesFrontViewController,
    PKRevealControllerFocusesLeftViewControllerInPresentationMode,
};

typedef NS_ENUM(NSUInteger, PKRevealControllerAnimationType)
{
    PKRevealControllerAnimationTypeStatic, // Rear view's do not move at all.
    PKRevealControllerAnimationTypeBouncy
};

typedef NS_OPTIONS(NSUInteger, PKRevealControllerType)
{
    PKRevealControllerTypeNone  = 0,
    PKRevealControllerTypeLeft  = 1 << 0,
    PKRevealControllerTypeRight = 1 << 1,
    PKRevealControllerTypeBoth = (PKRevealControllerTypeLeft | PKRevealControllerTypeRight)
};

/*
 * List of option keys that can be passed in the options dictionary.
 */

/*
 * Animation duration for automatic front view movement.
 *
 * @default 0.185sec
 * @value NSNumber containing an NSTimeInterval (double)
 */
extern NSString * const PKRevealControllerAnimationDurationKey;

/*
 * Animation curve for automatic front view movement.
 *
 * @default UIViewAnimationCurveLinear
 * @value NSNumber containing a UIViewAnimationCurve (NSUInteger)
 */
extern NSString * const PKRevealControllerAnimationCurveKey;

/*
 * The controller's animation type.
 *
 * @default PKRevealControllerAnimationTypeStatic
 * @value NSNumber containing a PKRevealControllerAnimationType (NSUInteger)
 */
extern NSString * const PKRevealControllerAnimationTypeKey;

/*
 * Determines whether an overdraw can take place. I.e. panning further than the views min-width.
 *
 * @default YES
 * @value NSNumber containing BOOL
 */
extern NSString * const PKRevealControllerAllowsOverdrawKey;

/*
 * The minimum swipe velocity to trigger front view movement even if the actual min-threshold wasn't reached.
 *
 * @default 800.0f
 * @value NSNumber containing CGFloat
 */
extern NSString * const PKRevealControllerQuickSwipeToggleVelocityKey;

/*
 * Determines whether front view interaction is disabled while presenting a side view.
 *
 * @default YES
 * @value NSNumber containing BOOL
 */
extern NSString * const PKRevealControllerDisablesFrontViewInteractionKey;

/*
 * Determines whether there's a UIPanGestureRecognizer placed over the entire front view, enabling pan-based reveal.
 *
 * @default YES
 * @value NSNumber containing BOOL
 */
extern NSString * const PKRevealControllerRecognizesPanningOnFrontViewKey;

/*
 * Determines whether there's a UITapGestureRecognizer placed over the entire front view, when presenting
 * one of the side views to enable snap-back-on-tap functionality.
 *
 * @default YES
 * @value NSNumber containing BOOL
 */
extern NSString * const PKRevealControllerRecognizesResetTapOnFrontViewKey;


/*
 * Event identifier for notifications -- will be sent before the side menu appears.
 */
extern NSString * const PKRevealControllerSideMenuWillBeShown;

/*
 * Event identifier for notifications -- will be sent before the front view controller appears.
 */
extern NSString * const PKRevealControllerFrontViewControllerWillBeShown;


typedef void(^PKDefaultCompletionHandler)(BOOL finished);
typedef void(^PKDefaultErrorHandler)(NSError *error);

@interface PKRevealController : UIViewController <UIGestureRecognizerDelegate>

#pragma mark - Properties
@property (nonatomic, strong, readonly) UIViewController *frontViewController;
@property (nonatomic, strong, readonly) UIViewController *leftViewController;

@property (nonatomic, strong, readonly) UIPanGestureRecognizer *revealPanGestureRecognizer;
@property (nonatomic, strong, readonly) UITapGestureRecognizer *revealResetTapGestureRecognizer;

@property (nonatomic, assign, readonly) PKRevealControllerState state;
@property (nonatomic, assign, readonly) BOOL isPresentationModeActive;

@property (nonatomic, strong, readonly) NSDictionary *options;

@property (nonatomic, assign, readwrite) CGFloat animationDuration;
@property (nonatomic, assign, readwrite) UIViewAnimationCurve animationCurve;
@property (nonatomic, assign, readwrite) PKRevealControllerAnimationType animationType;
@property (nonatomic, assign, readwrite) CGFloat quickSwipeVelocity;
@property (nonatomic, assign, readwrite) BOOL allowsOverdraw;
@property (nonatomic, assign, readwrite) BOOL disablesFrontViewInteraction;
@property (nonatomic, assign, readwrite) BOOL recognizesPanningOnFrontView;
@property (nonatomic, assign, readwrite) BOOL recognizesResetTapOnFrontView;

#pragma mark - Methods


- (id)initWithFrontViewController:(UIViewController *)frontViewController
               leftViewController:(UIViewController *)leftViewController
                          options:(NSDictionary *)options;

/**
 Reveal menu
 */

- (void)showSidemenu;
- (void)showFrontViewController;
- (void)showFrontViewControllerAnimated:(BOOL)animated;
- (void)showViewController:(UIViewController *)controller
                completion:(PKDefaultCompletionHandler)completion;

/**
 Show controller
 */

- (void)showController:(UIViewController *)frontViewController;


@end