//
//  DataTable.m
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
//  DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "DataTable.h"

static NSMutableDictionary *_instanceFilePaths;
static NSMutableDictionary *_instances;

static NSDictionary *_info;
static NSString *_NAME = @"ename";
static NSString *_KEYNAME = @"keyname";
static NSString *_CHARDEF = @"chardef";
static NSString *_SELKEY = @"selkey";
static NSString *_ENDKEY = @"endkey";

@interface DataTable ()

- (id) initWithDict:(NSDictionary *)dict;

@end

@implementation DataTable

+ (void) initialize
{
    _instanceFilePaths = [[NSMutableDictionary alloc] init];
    _instances = [[NSMutableDictionary alloc] init];
}

#pragma mark Register/Unregister Instances

+ (NSString *) pathForName:(NSString *)name
{
    return [_instanceFilePaths objectForKey:name];
}

+ (NSArray *) registeredNames
{
    return _instanceFilePaths.allKeys;
}

+ (void) registerName:(NSString *)name filePath:(NSString *)path
{
    [_instanceFilePaths setObject:path forKey:name];
}

+ (void) unregisterName:(NSString *)name
{
    [_instanceFilePaths removeObjectForKey:name];
}

#pragma mark Access Instances

+ (DataTable *) getInstanceByName:(NSString *)name
{
    @synchronized(self)
    {
        DataTable *instance = [_instances objectForKey:name];
        if (!instance)
        {
            NSString *path = [_instanceFilePaths objectForKey:name];
            if (!path) return nil;

            CINParser *parser = [[[CINParser alloc] init] autorelease];
            NSDictionary *dict = [parser parseContentOfFile:path
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
            if (!dict) return nil;

            instance = [[[DataTable alloc] initWithDict:dict] autorelease];
            [_instances setObject:instance forKey:name];
        }

        return instance;
    }
}

+ (NSArray *) instanceNames
{
    return _instances.allKeys;
}

+ (void) destroyInstanceByName:(NSString *)name
{
    [_instances removeObjectForKey:name];
}

+ (void) destroyAllInstances
{
    [_instances removeAllObjects];
}

#pragma mark Access Data Table

- (id) initWithDict:(NSDictionary *)dict;
{
    if (self = [super init])
    {
        _info = [dict retain];
    }

    return self;
}

- (void) dealloc
{
    [_info release];
    [super dealloc];
}

- (NSString *) name
{
    return [_info objectForKey:_NAME];
}

- (NSString *) characterForText:(NSString *)text
{
    return [[[_info objectForKey:_KEYNAME] objectForKey:text] objectAtIndex:0];
}

- (NSArray *) candidatesForText:(NSString *)text
{
    return [[_info objectForKey:_CHARDEF] objectForKey:text];
}

- (BOOL) hasSelectionKey:(NSString *)key
{
    return [[_info objectForKey:_SELKEY] rangeOfString:key].location != NSNotFound;
}

- (BOOL) hasEndKey:(NSString *)key
{
    return [[_info objectForKey:_ENDKEY] rangeOfString:key].location != NSNotFound;
}

@end
