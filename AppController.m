//
//  AppController.m
//  Countdown
//
//  Created by Michael Parlee on 9/4/09.
//  Copyright __MyCompanyName__ 2009 . All rights reserved.
//

#import "AppController.h"

@interface AppController(PrivateMethods) 

- (NSDate*)targetDateFromTime:(NSString *)time;
- (NSTimeInterval)getRemainingTime;

@end

@implementation AppController

@synthesize targetDate;
 
- (void) awakeFromNib
{
	if(![qcView loadCompositionFromFile:[[NSBundle mainBundle] pathForResource:@"QuartzCompTest" ofType:@"qtz"]]) {
		NSLog(@"Could not load composition");
	}
	timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target: self selector:@selector(updateDisplay:) userInfo: nil repeats: YES];
	NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
	NSLog(@"NSUserDefaults = %@",args);
	NSString *targetTime = [args stringForKey:@"t"];
	template = [args stringForKey:@"m"];
	NSLog(@"templatestr=%@",[template class]);
	
	if (targetTime == nil) {
		targetTime = @"0130";
	}
	
	if (template == nil) {
		template = @"Multi\nLine\ncountdown\n%s";
	}
	
	self.targetDate = [self targetDateFromTime:targetTime];
	NSLog(@"Got target time of %@ -> %@", targetTime, targetDate);
}


- (void)windowWillClose:(NSNotification *)notification 
{
	[NSApp terminate:self];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    int windowLevel;
    NSRect screenRect;
	
	// Capture the main display
    if (CGDisplayCapture( kCGDirectMainDisplay ) != kCGErrorSuccess) {
        NSLog( @"Couldn't capture the main display!" );
        // Note: you'll probably want to display a proper error dialog here
    }
	
	// Get the shielding window level
    windowLevel = CGShieldingWindowLevel();
	
	// Get the screen rect of our main display
    screenRect = [[NSScreen mainScreen] frame];
	
	// Put up a new window
	mainWindow = [[NSWindow alloc] initWithContentRect:screenRect
											 styleMask:NSBorderlessWindowMask
											   backing:NSBackingStoreBuffered
												 defer:NO screen:[NSScreen mainScreen]];
	
	[mainWindow setLevel:windowLevel];

    [mainWindow setBackgroundColor:[NSColor blackColor]];
    [mainWindow makeKeyAndOrderFront:nil];
	
	
	// Strings
	displayString = @"";
	[qcView setValue:displayString forInputKey:@"arg1"];
	
	// Load our content view
    [qcView setFrame:screenRect];
    [mainWindow setContentView:qcView];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	[mainWindow orderOut:self];
	
	// Release the display(s)
	if (CGDisplayRelease( kCGDirectMainDisplay ) != kCGErrorSuccess) {
		NSLog( @"Couldn't release the display(s)!" );
		// Note: if you display an error dialog here, make sure you set
		// its window level to the same one as the shield window level,
		// or the user won't see anything.
	}
}

- (void)updateDisplay: (NSTimer*) timer {
	double time = [self getRemainingTime];
	
	int hours = time / 60 / 60;
	time -= hours * 60 * 60;
	int minutes = time / 60 ;
	time -= minutes * 60;
	int secs = time;
	
	NSString *message = [template stringByReplacingOccurrencesOfString:@"%s" withString:@"%d:%02d:%02d"];
	message = [message stringByReplacingOccurrencesOfString:@"+" withString:@"\n"];
	displayString = [NSString stringWithFormat:message, hours,minutes,secs];
	
	[qcView setValue:displayString forInputKey:@"arg1"];
}


- (NSDate*)targetDateFromTime: (NSString*)time {
	
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	
	int hour = [[formatter numberFromString:[time substringToIndex:2]] integerValue];
	int minute = [[formatter numberFromString:[time substringFromIndex:2]] integerValue];
	
	[formatter release];
	
	NSCalendar *gregorian = [NSCalendar currentCalendar];
	
	NSDateComponents *hourMinute = [[NSDateComponents alloc] init];
	[hourMinute setHour:hour];
	[hourMinute setMinute:minute];
	
	NSDateComponents *day = [[NSDateComponents alloc] init];
	[day setDay:1];
	
	NSDate *date = [NSDate date];
	unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *components = [gregorian components:unitFlags fromDate:date];
	NSDate *todayMidnight = [gregorian dateFromComponents:components];
	
	NSDate *testDate = [gregorian dateByAddingComponents:hourMinute toDate:todayMidnight options:0];
	
	if ([testDate isLessThan:date]) {
		testDate = [gregorian dateByAddingComponents:day toDate:testDate options:0];
	}
	
	[hourMinute release];
	[day release];
	
	return testDate;
}

-(NSTimeInterval)getRemainingTime {
	NSDate *now = [NSDate date];
	return [self.targetDate timeIntervalSinceDate:now];
}

@end
