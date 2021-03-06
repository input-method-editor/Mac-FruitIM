//
//  main.m
//
//  Copyright (c) 2012, Chi-En Wu All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  * Neither the name of the organization nor the
//  names of its contributors may be used to endorse or promote products
//  derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>
#import "DataTable.h"

IMKCandidates *sharedCandidates;

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSBundle *mainBundle = [NSBundle mainBundle];

    NSString *connectionName = [[mainBundle infoDictionary] objectForKey:@"InputMethodConnectionName"];
    if (!connectionName)
    {
        NSLog(@"Fatal error: InputMethodConnectionName key not defined in Info.plist.");
        [pool drain];
        return -1;
    }

    IMKServer *server = [[IMKServer alloc] initWithName:connectionName
                                       bundleIdentifier:[mainBundle bundleIdentifier]];
    if (!server)
    {
        NSLog(@"Fatal error: Cannot initialize input method server with connection %@.", connectionName);
        [pool drain];
        return -1;
    }

    sharedCandidates = [[IMKCandidates alloc] initWithServer:server
                                                   panelType:kIMKSingleRowSteppingCandidatePanel];
    if (!sharedCandidates)
    {
        NSLog(@"Fatal error: Cannot initialize shared candidate panel with connection %@.", connectionName);
        [server release];
        [pool drain];
        return -1;
    }

    NSString *mainNibName = [[mainBundle infoDictionary] objectForKey:@"NSMainNibFile"];
    if (!mainNibName)
    {
        NSLog(@"Fatal error: NSMainNibFile key not defined in Info.plist.");
        [sharedCandidates release];
        [server release];
        [pool drain];
        return -1;
    }

    BOOL loadResult = [NSBundle loadNibNamed:mainNibName owner:[NSApplication sharedApplication]];
    if (!loadResult)
    {
        NSLog(@"Fatal error: Cannot load %@.", mainNibName);
        [sharedCandidates release];
        [server release];
        [pool drain];
        return -1;
    }

    NSString *path = [mainBundle pathForResource:@"bpmf" ofType:@"cin"];
    [DataTable registerName:@"bpmf" filePath:path];

    [[NSApplication sharedApplication] run];

    [sharedCandidates release];
    [server release];
    [pool drain];

    return 0;
}
