//
//  BopomofoReadingBuffer.m
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

#import "BopomofoReadingBuffer.h"

typedef NSNumber BopomofoSymbolType;
static const BopomofoSymbolType *BPMF_CONSONANT;
static const BopomofoSymbolType *BPMF_MIDDLE_VOWEL;
static const BopomofoSymbolType *BPMF_VOWEL;
static const BopomofoSymbolType *BPMF_TONE;
static NSDictionary *_symbolType;

@implementation BopomofoReadingBuffer
{
    NSMutableString *_consonant;
    NSMutableString *_middleVowel;
    NSMutableString *_vowel;
    NSMutableString *_tone;
}

+ (void)initialize
{
    BPMF_CONSONANT = [[NSNumber alloc] initWithInt:1];
    BPMF_MIDDLE_VOWEL = [[NSNumber alloc] initWithInt:2];
    BPMF_VOWEL = [[NSNumber alloc] initWithInt:3];
    BPMF_TONE = [[NSNumber alloc] initWithInt:4];

    _symbolType = [[NSDictionary alloc] initWithObjectsAndKeys:
                   BPMF_CONSONANT,      @"1", // ㄅ
                   BPMF_CONSONANT,      @"q", // ㄆ
                   BPMF_CONSONANT,      @"a", // ㄇ
                   BPMF_CONSONANT,      @"z", // ㄈ
                   BPMF_CONSONANT,      @"2", // ㄉ
                   BPMF_CONSONANT,      @"w", // ㄊ
                   BPMF_CONSONANT,      @"s", // ㄋ
                   BPMF_CONSONANT,      @"x", // ㄌ
                   BPMF_CONSONANT,      @"e", // ㄍ
                   BPMF_CONSONANT,      @"d", // ㄎ
                   BPMF_CONSONANT,      @"c", // ㄏ
                   BPMF_CONSONANT,      @"r", // ㄐ
                   BPMF_CONSONANT,      @"f", // ㄑ
                   BPMF_CONSONANT,      @"v", // ㄒ
                   BPMF_CONSONANT,      @"5", // ㄓ
                   BPMF_CONSONANT,      @"t", // ㄔ
                   BPMF_CONSONANT,      @"g", // ㄕ
                   BPMF_CONSONANT,      @"b", // ㄖ
                   BPMF_CONSONANT,      @"y", // ㄗ
                   BPMF_CONSONANT,      @"h", // ㄘ
                   BPMF_CONSONANT,      @"n", // ㄙ
                   BPMF_MIDDLE_VOWEL,   @"u", // ㄧ
                   BPMF_MIDDLE_VOWEL,   @"j", // ㄨ
                   BPMF_MIDDLE_VOWEL,   @"m", // ㄩ
                   BPMF_VOWEL,          @"8", // ㄚ
                   BPMF_VOWEL,          @"i", // ㄛ
                   BPMF_VOWEL,          @"k", // ㄜ
                   BPMF_VOWEL,          @",", // ㄝ
                   BPMF_VOWEL,          @"9", // ㄞ
                   BPMF_VOWEL,          @"o", // ㄟ
                   BPMF_VOWEL,          @"l", // ㄠ
                   BPMF_VOWEL,          @".", // ㄡ
                   BPMF_VOWEL,          @"0", // ㄢ
                   BPMF_VOWEL,          @"p", // ㄣ
                   BPMF_VOWEL,          @";", // ㄤ
                   BPMF_VOWEL,          @"/", // ㄥ
                   BPMF_VOWEL,          @"-", // ㄦ
                   BPMF_TONE,           @"6", // ˊ
                   BPMF_TONE,           @"3", // ˇ
                   BPMF_TONE,           @"4", // ˋ
                   BPMF_TONE,           @"7", // ˙
                   nil];
}

- (id) init
{
    if (self = [super init])
    {
        _consonant = [[NSMutableString alloc] init];
        _middleVowel = [[NSMutableString alloc] init];
        _vowel = [[NSMutableString alloc] init];
        _tone = [[NSMutableString alloc] init];
    }

    return self;
}

- (void) dealloc
{
    [_consonant release];
    [_middleVowel release];
    [_vowel release];
    [_tone release];

    [super dealloc];
}

- (BOOL) insertSymbol:(NSString *)symbol
{
    BopomofoSymbolType *type = [_symbolType valueForKey:symbol];
    if (!type) return NO;

    if (type == BPMF_CONSONANT)
        [_consonant setString:symbol];
    else if (type == BPMF_MIDDLE_VOWEL)
        [_middleVowel setString:symbol];
    else if (type == BPMF_VOWEL)
        [_vowel setString:symbol];
    else if (type == BPMF_TONE)
        [_tone setString:symbol];

    return YES;
}

- (BOOL) erease
{
    if (![_tone isEqualToString:@""])
        [_tone setString:@""];
    else if (![_vowel isEqualToString:@""])
        [_vowel setString:@""];
    else if (![_middleVowel isEqualToString:@""])
        [_middleVowel setString:@""];
    else if (![_consonant isEqualToString:@""])
        [_consonant setString:@""];
    else
        return NO;

    return YES;
}

- (void) clear
{
    [_consonant setString:@""];
    [_middleVowel setString:@""];
    [_vowel setString:@""];
    [_tone setString:@""];
}

- (BOOL) isEmpty
{
    return [_consonant isEqualToString:@""] && [_middleVowel isEqualToString:@""] &&
            [_vowel isEqualToString:@""] && [_tone isEqualToString:@""];
}

- (NSUInteger) length
{
    NSUInteger length = 0;
    length += [_consonant isEqualToString:@""] ? 0 : 1;
    length += [_middleVowel isEqualToString:@""] ? 0 : 1;
    length += [_vowel isEqualToString:@""] ? 0 : 1;
    length += [_tone isEqualToString:@""] ? 0 : 1;

    return length;
}

- (NSString *) string
{
    return [NSString stringWithFormat:@"%@%@%@%@", _consonant, _middleVowel, _vowel, _tone];
}

@end
