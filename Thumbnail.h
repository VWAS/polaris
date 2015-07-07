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


@import Foundation;
@import UIKit;

@interface Thumbnail : NSObject


/**
 * Returns thumbnail for a file
 */

- (UIImage *)thumbnailForFileAtPath:(NSString *)filePath;


/**
 * Returns thumbnail for pdf file
 */
- (UIImage *)thubnailForPDFwithPath:(NSString *)path;

/**
 * Checks if file at path is a dir
 */
- (BOOL)isFileAtPathDir:(NSString *)path;


@property (nonatomic) UIImage *dirImage;
@property (nonatomic) UIImage *playGroundImageImage;
@property (nonatomic) UIImage *projectImage;


@property (nonatomic) UIImage *htmlImage;
@property (nonatomic) UIImage *jsImage;
@property (nonatomic) UIImage *cssImage;
@property (nonatomic) UIImage *ukImage;
@property (nonatomic) UIImage *txtImage;
@property (nonatomic) UIImage *swiftImage;
@property (nonatomic) UIImage *fontImage;
@property (nonatomic) UIImage *vectorImage;
@property (nonatomic) UIImage *phpImage;
@property (nonatomic) UIImage *lessImage;
@property (nonatomic) UIImage *zipImage;



@end
