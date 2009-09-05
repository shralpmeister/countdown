//
//  AppController.h
//  Countdown
//
//  Created by Michael Parlee on 9/4/09.
//  Copyright __MyCompanyName__ 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface AppController : NSObject 
{
    IBOutlet QCView* qcView;
	NSWindow *mainWindow;
	NSTimer *timer;
	NSString *displayString;
	NSDate *targetDate;
	NSString *template;
}

@property (retain, nonatomic) NSDate* targetDate;

@end
