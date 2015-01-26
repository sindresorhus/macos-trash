//
//  main.m
//  trash
//
//  Created by Sindre Sorhus on 26/01/15.
//  Copyright (c) 2015 Sindre Sorhus. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char *argv[]) {
	@autoreleasepool {
		if (argc == 1) {
			fputs("Please supply one or more filepaths\n", stderr);
			return 1;
		}

		NSArray *args = [[NSProcessInfo processInfo] arguments];

		if ([args[1] isEqualToString: @"--version"]) {
			puts("1.0.0");
			return 0;
		}

		if ([args[1] isEqualToString: @"--help"]) {
			puts("Usage: trash filepath...\n\nCreated by Sindre Sorhus");
			return 0;
		}

		NSFileManager *fm = [NSFileManager defaultManager];
		NSError *err;

		for (int i = 1; i < argc; i++) {
			NSURL *url = [NSURL fileURLWithPath:@(argv[i])];

			if (![fm trashItemAtURL:url resultingItemURL:nil error:&err]) {
				fprintf(stderr, "%s\n", [[err localizedDescription] UTF8String]);
				return 1;
			}
		}
	}

	return 0;
}
