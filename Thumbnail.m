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


#import "Thumbnail.h"

@implementation Thumbnail



- (UIImage *)thumbnailForFileAtPath:(NSString *)filePath{

    
    NSString *imageName = filePath.pathExtension;
    
    
    ///if is dir
    if ([self isFileAtPathDir:filePath]){
    
        
        //if is Playground
        if ([imageName isEqualToString:@"cnPlay"]) {
            
            
            if (!self.playGroundImageImage) {
                self.playGroundImageImage = [UIImage imageNamed:@"CnPlaygroundProj"];
            }

            return self.playGroundImageImage;

        //is normal dir
        }
        else {
            
            if (!self.dirImage) {
                self.dirImage = [UIImage imageNamed:@"dir"];
            }
            
            return self.dirImage;
        }
    }
    
    //Isn't a dir so continue checking
    
        //if is image
    else if ([imageName isEqualToString:@"png"] || [imageName isEqualToString:@"jpg"] ){
        return [[UIImage alloc] initWithContentsOfFile:filePath];
    }
        //if is font image
    else if ([imageName isEqualToString:@"ttf"] || [imageName isEqualToString:@"oet"] || [imageName isEqualToString:@"otf"] || [imageName isEqualToString:@"woff"]){
        
        if (!self.fontImage) {
            self.fontImage = [UIImage imageNamed:@"font"];
        }
        
        return self.fontImage;
        
    }
        //if is vector
    else if ([imageName isEqualToString:@"svg"]){
        
        if (!self.vectorImage) {
            self.vectorImage = [UIImage imageNamed:@"vector"];
        }
        
        return self.vectorImage;
        
    }
        //if is html doc
    else if ([imageName isEqualToString:@"html"]){
        if (!self.htmlImage) {
            self.htmlImage = [UIImage imageNamed:@"html"];
        }
        
        return self.htmlImage;
    }
        //if is js file
    else if ([imageName isEqualToString:@"js"]){
      
        if (!self.jsImage) {
            self.jsImage = [UIImage imageNamed:@"js"];
        }
    
        return self.jsImage;
    }
        //if is swift file
    else if ([imageName isEqualToString:@"swift"]){
        
        if (!self.swiftImage) {
            self.swiftImage = [UIImage imageNamed:@"swift"];
        }
        
        return self.swiftImage;
    }
        //if is css file
    else if ([imageName isEqualToString:@"css"]){
        
        if (!self.cssImage) {
            self.cssImage = [UIImage imageNamed:@"css"];
        }
        
        return self.cssImage;
    }
        //if is txt file
    else if ([imageName isEqualToString:@"txt"]){
        
        if (!self.txtImage) {
            self.txtImage = [UIImage imageNamed:@"txt"];
        }
        
        return self.txtImage;
    }
        //if is php file
    else if ([imageName isEqualToString:@"php"]){
        
        if (!self.phpImage) {
            self.phpImage = [UIImage imageNamed:@"php"];
        }
     
        return self.phpImage;
    }
        //if is pdf
    else if ([imageName isEqualToString:@"pdf"]){

        return [self thubnailForPDFwithPath:filePath];
        
    }
        //if is less
    else if ([imageName isEqualToString:@"less"]){
        
        if (!self.lessImage) {
            self.lessImage = [UIImage imageNamed:@"less"];
        }
        
        return self.lessImage;
    }
        //if is zip file
    else if ([imageName isEqualToString:@"zip"]){
        
        if (!self.zipImage) {
            self.zipImage = [UIImage imageNamed:@"zip"];
        }
        
        return self.zipImage;
    }
    
    //ELSE
    else{
        
        if (!self.ukImage) {
            self.ukImage = [UIImage imageNamed:@"generic"];
        }
    
        return self.ukImage;
    }
}


//Check if file is a Dir
- (BOOL)isFileAtPathDir:(NSString *)path{
    
    BOOL isDir = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];

    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir){
        return true;
    }
    else{
        return false;
    }
}





//Returm PDF Thumbnail 
- (UIImage *)thubnailForPDFwithPath:(NSString *)path{
    
    NSURL* pdfFileUrl = [NSURL fileURLWithPath:path];
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)pdfFileUrl);
    CGPDFPageRef page;
    
    CGRect aRect = CGRectMake(0, 0, 110, 140); // thumbnail size
    UIGraphicsBeginImageContext(aRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIImage *thumbnailImage;
    
    
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0.0, aRect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetGrayFillColor(context, 1.0, 1.0);
    CGContextFillRect(context, aRect);
    
    
    // Grab the first PDF page
    page = CGPDFDocumentGetPage(pdf, 1);
    CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFMediaBox, aRect, 0, true);
    // And apply the transform.
    CGContextConcatCTM(context, pdfTransform);
    
    CGContextDrawPDFPage(context, page);
    
    // Create the new UIImage from the context
    thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //Use thumbnailImage (e.g. drawing, saving it to a file, etc)
    
    CGContextRestoreGState(context);
    
    
    
    
    UIGraphicsEndImageContext();
    CGPDFDocumentRelease(pdf);
    
    
    return thumbnailImage;
}



@end