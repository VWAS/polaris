/*
 Copyright (c) 2015, Vladimir Danila
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * The name of Pierre-Olivier Latour may not be used to endorse
 or promote products derived from this software without specific
 prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL PIERRE-OLIVIER LATOUR BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NSUserDefaults+Additions.h"


NSString * const customFontsKey = @"CFACustomFontsKey";
NSString * const customFontKeyFontName = @"CFACustomFontKeyFontName";
NSString * const customFontKeyFontSize = @"CFACustomFontKeyFontSize";


@implementation NSUserDefaults (Additions)


#pragma mark - UIColor

- (UIColor *)colorForKey:(NSString *)key{
    
    
    NSData *colorData = [self objectForKey:key];
    
    UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    
    
    return color;
}



- (void)setColor:(UIColor *)color ForKey:(NSString *)key{
    
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
    
    [self setObject:colorData forKey:key];
    
}





#pragma mark - Dictionarys


- (NSDictionary *)dicForKey:(NSString *)key{
    NSUserDefaults *self_ = [NSUserDefaults standardUserDefaults];
    NSData *dictionaryData = [self_ objectForKey:key];
    NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:dictionaryData];
    return dictionary;
}

- (void)setDic:(NSDictionary *)dictionary ForKey:(NSString *)key{
    NSUserDefaults *self_ = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    [self_ setObject:data forKey:key];
}





@end
