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

#import "Polaris.h"

//Web server
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"
//Web Upload
#import "GCDWebUploader.h"
//WebDav
#import "GCDWebDAVServer.h"


//Encryption
#import "RNEncryptor.h"
#import "RNDecryptor.h"


@interface Polaris () {
    
    NSURL *projectURL;
    
    GCDWebServer *_webServer;
    GCDWebUploader *_webUploader;
    GCDWebDAVServer *_davServer;
    
    
    WKWebView *webPreviewView;
    
    
    NSTimer *autoBackup;
    
    BOOL initWithProjectCreator;
    BOOL needClose;
    BOOL failed;
    
}

@end


@implementation Polaris
@synthesize inspectorURL,selectedFileURL,deleteURL;



+(id)alloc{
    #ifdef DEBUG
    NSLog(@"[Polaris] Version 1.2 || © 2015 VWAS-Studios & Vladimir Danila\nFollow us on Twitter: @VWASStudios || @DanilaVladi and stay up to date!");
    #endif
    return [super alloc];
}
+(id)init{
    #ifdef DEBUG
    NSLog(@"Wrong initializer. <Use initWithProjectPath or initWithNewProject instead>");
    #endif
    return [super init];
}





- (instancetype)initWithCreatingProjectRequiredFilesAtPath:(NSString *)path{
    self = [super init];
    //create project structure
    
    if (self) {
        
        initWithProjectCreator = true;
        projectURL = [[NSURL alloc] initFileURLWithPath:path isDirectory:true];
        
        
        NSError *error;
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createDirectoryAtURL:[self projectVersionURL] withIntermediateDirectories:YES attributes:nil error:&error];
        [fileManager createDirectoryAtURL:[self projectUserDirectoryURL] withIntermediateDirectories:YES attributes:nil error:&error];
        [fileManager createDirectoryAtURL:[self projectTempURL] withIntermediateDirectories:YES attributes:nil error:&error];
        [fileManager createDirectoryAtURL:[self projectSettingsURL] withIntermediateDirectories:YES attributes:nil error:&error];
        [fileManager createDirectoryAtURL:[self appleTVPreviewURL] withIntermediateDirectories:YES attributes:nil error:&error];

        NSString *atvIndex = @"<NEURON>/nNEURON() __PH \n()Neuron";
        [atvIndex writeToURL:[[self appleTVPreviewURL] URLByAppendingPathComponent:@"index.html" isDirectory:NO] atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        if (error) {
            #ifdef DEBUG
            NSLog(@"[Polaris] ERROR: Faild to create a new Project. Please double check if the path exists.\nDescription: %@",[error localizedDescription]);
            #endif
        }
        
    }
    
    return self;
}

- (instancetype)initWithProjectPath:(NSString *)path {
    self = [super init];

    if (self) {
        projectURL = [[NSURL alloc] initFileURLWithPath:path isDirectory:true];
        inspectorURL = [self projectUserDirectoryURL];
    }
    
    return self;
}




- (instancetype)initWithProjectPath:(NSString *)path withWebServer:(BOOL)useWebServer UploadServer:(BOOL)useUploadServer andWebDavServer:(BOOL)useWebDavServer{
    self = [super init];
      
    
    if (self) {
        
        projectURL = [[NSURL alloc] initFileURLWithPath:path isDirectory:true];
        inspectorURL = [self projectUserDirectoryURL];
        
        if (useWebServer || useUploadServer || useWebDavServer) {
            [self startServerForWeb:useWebServer forUploading:useUploadServer forWebDav:useWebDavServer];
        }
        
        [self autoBackup];
        autoBackup = [NSTimer scheduledTimerWithTimeInterval: 520.0 target: self selector:@selector(autoBackup) userInfo: nil repeats:YES];
    }
    
    return self;
}







- (void)close{
    
    [autoBackup invalidate];
    [self deleteBackup];
    
        if (_webServer.isRunning) {
            [_webServer stop];
        }
        
        if (_webUploader.isRunning) {
            [_webUploader stop];
        }
        
        if (_davServer.isRunning) {
            [_davServer stop];
        }
}






#pragma mark - functions



- (void)generateATVPreview{

    NSURL *fileUrl = selectedFileURL;
    NSURL *rootUrl = selectedFileURL;
    
        

    [webPreviewView loadFileURL:fileUrl allowingReadAccessToURL:rootUrl];

            
    
}



- (NSString *)fakePathForFile:(NSURL *)selectedFile{
    return [selectedFile.absoluteString stringByReplacingOccurrencesOfString:[[self projectUserDirectoryURL] absoluteString] withString:@""];
}

- (NSString *)fakePathForFileSelectedFile{
    return [selectedFileURL.absoluteString stringByReplacingOccurrencesOfString:[[self projectUserDirectoryURL] absoluteString] withString:@""];
}

- (NSMutableArray *)contentsOfCurrentDirectory{
    NSURL *url = inspectorURL;
    NSMutableArray *items = [[[NSFileManager defaultManager] contentsOfDirectoryAtURL:url includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil] mutableCopy];
    
    return items;
}


- (NSMutableArray *)contentsOfDirectoryAtPath:(NSString *)path{
    NSURL *url = [NSURL fileURLWithPath:path isDirectory:YES];
    NSMutableArray *items = [[[NSFileManager defaultManager] contentsOfDirectoryAtURL:url includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil] mutableCopy];
    
    
    return items;
}



- (void)archiveWorkingCopyWithCommitMessge:(NSString *)message{
    

    [self archiveWorkingCopyWithCommitMessge:message andTitle:nil];
    
}




- (void)deleteBackup{
    
    if ([self checkIfBackupExists]) {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        NSURL *url = [[self projectVersionURL] URLByAppendingPathComponent:@"Autobackup" isDirectory:YES];
        
        NSError *error;
        [[NSFileManager alloc] removeItemAtURL:url error:&error];
        
        if (error) {
            #ifdef DEBUG
            NSLog(@"[Polaris] Error deleting backup");
            #endif
        }

        
    });
    
    }
    
}


- (void)deleteBackupSync {
    if ([self checkIfBackupExists]) {
        
        
        NSURL *url = [[self projectVersionURL] URLByAppendingPathComponent:@"Autobackup" isDirectory:YES];
        
        NSError *error;
        [[NSFileManager alloc] removeItemAtURL:url error:&error];
        
        if (error) {
#ifdef DEBUG
            NSLog(@"[Polaris] Error deleting backup");
#endif
        }
        
        
        
    }
}


- (BOOL)checkIfBackupExists{
    NSURL *backupURL = [[self projectVersionURL] URLByAppendingPathComponent:@"Autobackup" isDirectory:YES];
    return [backupURL checkResourceIsReachableAndReturnError:nil];
}



#pragma mark - Server Stuff

- (NSString *)webServerURL{
    if (!initWithProjectCreator) {
        return [_webServer.serverURL absoluteString];
    }
    else{
        #ifdef DEBUG
        NSLog(@"[Polaris] Warning: Wrong initializer");
        #endif
        return nil;
    }
}

- (NSString *)webUploaderServerURL{
    if (!initWithProjectCreator) {
        return [_webUploader.serverURL absoluteString];

    }
    else{
        #ifdef DEBUG
        NSLog(@"[Polaris] Warning: Wrong initializer");
        #endif
        return nil;
    }
}

- (NSString *)webDavServerURL{
    if (!initWithProjectCreator) {
        return [_davServer.serverURL absoluteString];
    }
    else{
        #ifdef DEBUG
        NSLog(@"[Polaris] Warning: Wrong initializer");
        #endif
        return nil;
    }
}

#pragma mark - Paths

-(NSURL *)projectURL {
    return projectURL;
}


- (NSURL *)projectUserDirectoryURL {
    return [projectURL URLByAppendingPathComponent:@"Assets" isDirectory:YES];
}

- (NSURL *)projectVersionURL {
    return [projectURL URLByAppendingPathComponent:@"Versions" isDirectory:YES];
}

- (NSURL *)projectTempURL {
    return [projectURL URLByAppendingPathComponent:@"Temp" isDirectory:YES];
}

- (NSURL *)projectSettingsURL {
    return [projectURL URLByAppendingPathComponent:@"Config" isDirectory:YES];
}

- (NSURL *)appleTVPreviewURL {
    return [projectURL URLByAppendingPathComponent:@"ATV4" isDirectory:YES];
}

#pragma mark - Values


- (NSString *)projectCurrentVersion{
    if (!initWithProjectCreator) {
        NSString *version = [NSString stringWithFormat:@"%@.0", [self getSettingsDataForKey:@"version"]];
        
        #ifdef DEBUG
        if (version.length == 0) {
            NSLog(@"[Polaris] Warning: There's no version saved. Save a version for key:'Version'");
        }
        #endif
        
        return version;
    }
    else{
        #ifdef DEBUG
        NSLog(@"[Polaris] Warning: Wrong initializer");
        #endif
        return nil;
    }

}

- (NSString *)projectCopyright{
    
    if (!initWithProjectCreator) {
       return [self getSettingsDataForKey:@"Copyright"];

    }
    else{
        NSLog(@"[Polaris] Warning: Wrong initializer");
        return nil;
    }

}

- (NSString *)projectGistID{
    
    if (!initWithProjectCreator) {
        NSString *gistID = [self getSettingsDataForKey:@"gistID"];
        if (gistID.length == 0) {
            NSLog(@"[Polaris] Warning: Thre's no saved gistValue");
            return nil;
        }
        else{
            return [self getSettingsDataForKey:@"gistID"];
        }
    }
    else{
        #ifdef DEBUG
        NSLog(@"[Polaris] Warning: Wrong initializer");
        #endif
        return nil;
    }

}



#pragma mark - Settings




- (void)updateGistID:(NSString*)gistID{
    if (!initWithProjectCreator) {
        [self updateSettingsValueForKey:@"gistID" withValue:gistID];
    }
    else{
        #ifdef DEBUG
        NSLog(@"[Polaris] Warning: Wrong initializer");
        #endif
    }
}



- (void)updateVersionNumberToVersion:(int)versionNumber{
    if (!initWithProjectCreator) {
        [self updateSettingsValueForKey:@"version" withValue:[NSString stringWithFormat:@"%i",versionNumber]];
    }
    else{
        #ifdef DEBUG
        NSLog(@"[Polaris] Warning: Wrong initializer");
        #endif
    }
}



- (void)updateSettingsValueForKey:(NSString *)key withValue:(id)anObject{
    NSDictionary *dict = [self getProjectSettingsDictionary];

    if ([self isModern]) {
        [dict setValue:anObject forKey:key];
    } else {
        [dict setValue:[self encryptData:anObject forKey:key] forKey:key];
    }

    [self saveDictionary:dict];
    
    
}

- (void)saveValue:(id)anObject forKey:(NSString *)key{
    NSMutableDictionary *dict = [self getProjectSettingsDictionary];


    if ([key isEqualToString:@"modern"] || [self isModern]) {
        [dict setValue:anObject forKey:key];
    }
    else {
        [dict setValue:[self encryptData:anObject forKey:key] forKey:key];
    }


    [self saveDictionary:dict];
}




- (NSString *)getSettingsDataForKey:(NSString *)key{
    NSDictionary *dict = [self getProjectSettingsDictionary];


    NSString *string;

    if ([self isModern]) {
        string = [dict valueForKey:key];
    }
    else {
        string = [self decryptedData:[dict valueForKey:key] forKey:key];
    }
    
    #ifdef DEBUG
    if (!string) {
        NSLog(@"[Polaris] Warning: Warning: Value for key:%@ is empty or value doesn't exist.",key);
    }
    #endif
    
    return string;
}





#pragma mark - Private Methods

- (BOOL)isModern {
    NSMutableDictionary *dict = [self getProjectSettingsDictionary];
    return [[dict valueForKey:@"modern"] isEqualToString:@"YES"];
}

- (void)autoBackup{
    
    if (!self.pauseAutobackup) {
    
    NSOperation *backgroundOperation = [[NSOperation alloc] init];
    backgroundOperation.queuePriority = NSOperationQueuePriorityLow;
    backgroundOperation.qualityOfService = NSOperationQualityOfServiceBackground;
    
    backgroundOperation.completionBlock = ^{
      
        

        // get current date/time
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        NSString *currentTime = [dateFormatter stringFromDate:today];
        
        [self archiveWorkingCopyWithCommitMessge:currentTime andTitle:@"Autobackup"];
        
        
    };
    
    
        [[NSOperationQueue mainQueue] addOperation:backgroundOperation];
    }
}






#pragma mark - Shortcuts





- (void)archiveWorkingCopyWithCommitMessge:(NSString *)message andTitle:(NSString *)title{
    
    if (!initWithProjectCreator) {
        
        NSOperation *backgroundOperation = [[NSOperation alloc] init];
        backgroundOperation.queuePriority = NSOperationQueuePriorityLow;
        backgroundOperation.qualityOfService = NSOperationQualityOfServiceBackground;
        
        backgroundOperation.completionBlock = ^{
            
            
            NSURL *destination;
            
            if (title.length == 0) {
                NSString *version = [self privateProjectVersion];
                int newVersion = version.intValue + 1;
                [self updateVersionNumberToVersion:newVersion];
                
                destination = [[self projectVersionURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"Version%@", version] isDirectory:YES];
            }
            else{
                destination = [[self projectVersionURL] URLByAppendingPathComponent:title isDirectory:YES];
                if ([self checkIfBackupExists]) {
                
                    [self deleteBackupSync];
                    
                }
            }
            
            
            NSError *error;
            NSFileManager *fm = [NSFileManager defaultManager];
            
            if (destination && [self projectUserDirectoryURL]) {
                
                [fm copyItemAtURL:[self projectUserDirectoryURL] toURL:destination error:&error];
                
                if (error) {
#ifdef DEBUG
                    NSLog(@"[Polaris] ERROR: Failed to archive project. Details: %@",[error localizedDescription]);
#endif
                }
                else{
                    
                    NSError *error2;
                    NSURL *dataURL = [destination URLByAppendingPathComponent:@"data" isDirectory:NO];
                    
                    if (message.length != 0) {
                        
                        //[message writeToFile:dataPath atomically:true encoding:NSUTF8StringEncoding error:&error2];
                        [message writeToURL:dataURL atomically:YES encoding:NSUTF8StringEncoding error:&error2];
                        
                        if (error) {
#ifdef DEBUG
                            NSLog(@"[Polaris] ERROR: Failed to save the comment to the archive. Details: %@",[error2 localizedDescription]);
#endif
                        }
                        else{
#ifdef DEBUG
                            NSLog(@"[Polaris] Message: Project was archived.");
#endif
                        }
                    }
                    else{
#ifdef DEBUG
                        NSLog(@"[Polaris] Message: Project was archived without a note.");
#endif
                    }
                }

            }
            
        };
        
        
        [[NSOperationQueue mainQueue] addOperation:backgroundOperation];

    }
    
    
}





- (void)saveWithoutEncryptionValue:(id)anObject forKey:(NSString *)key{
    NSMutableDictionary *dict = [self getProjectSettingsDictionary];
    [dict setValue:anObject forKey:key];
    [self saveDictionary:dict];
}


- (NSString *)getSettingsDataForKeyWithoutEncrytion:(NSString *)key{
    
    NSDictionary *dict = [self getProjectSettingsDictionary];
    NSString *string = [dict valueForKey:key];
    
    #ifdef DEBUG
    if (!string) {
        NSLog(@"[Polaris] Warning: Warning: Value for key:%@ is empty or value doesn't exist.",key);
    }
    #endif
    return string;
    
}



- (void)startServerForWeb:(BOOL)web forUploading:(BOOL)uploading forWebDav:(BOOL)webDav{
//    NSString *path = [[self projectUserDirectoryURL] path];
//
//    if (web) {
//        
//        _webServer = [[GCDWebServer alloc] init];
//        [_webServer addGETHandlerForBasePath:@"/" directoryPath:path indexFilename:@"index.html" cacheAge:3600 allowRangeRequests:YES];
//        [_webServer startWithPort:0 bonjourName:nil];
//
//    }
//    
//    if (uploading) {
//        
//        _webUploader = [[GCDWebUploader alloc] initWithUploadDirectory:path];
//        [_webUploader startWithPort:0 bonjourName:nil];
//    }
//    
//    if (webDav) {
//        _davServer = [[GCDWebDAVServer alloc] initWithUploadDirectory:path];
//        [_davServer startWithPort:0 bonjourName:nil];
//    }

}


- (void)saveDictionary:(NSDictionary *)dict{
    [dict writeToURL:[self projectSettingsDictionaryURL] atomically:YES];
}


- (NSMutableDictionary *)getProjectSettingsDictionary{
    
    NSString *settingsFilePath = [[self projectSettingsDictionaryURL] path];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:settingsFilePath];
    
    if (fileExists) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:settingsFilePath];
        return dict;
    }
    else{
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [self saveDictionary:dict];
        return dict;
    }
    
}


- (NSURL *)projectSettingsDictionaryURL{
    return [[self projectSettingsURL] URLByAppendingPathComponent:@"settings.cnSettings" isDirectory:NO];
}




#pragma mark - Private - Encryption

- (NSData *)encryptData:(NSString *)string forKey:(NSString *)key{
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSData *encryptedData = [RNEncryptor encryptData:data
                                        withSettings:kRNCryptorAES256Settings
                                            password:key
                                               error:&error];
    
    #ifdef DEBUG
    if (error) {
        NSLog(@"[Polaris] ERROR: An unexpected error happened: %@",[error localizedDescription]);
    }
    #endif
    
    
    return encryptedData;
}

- (NSString *)decryptedData:(NSData *)data forKey:(NSString *)key{
    
    NSError *error;
    NSData *decryptedData = [RNDecryptor decryptData:data
                                        withPassword:key
                                               error:&error];
    
    if (error) {
        #ifdef DEBUG
        NSLog(@"[Polaris] ERROR: An unexpected error happened: %@",[error localizedDescription]);
        #endif
        return nil;
    }
    else{
        NSString *string = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
        return string;
    }
    
}


- (NSString *)privateProjectVersion{
    if (!initWithProjectCreator) {
        NSString *version = [NSString stringWithFormat:@"%@.0", [self getSettingsDataForKey:@"version"]];
        
        #ifdef DEBUG
        if (version.length == 0) {
            NSLog(@"[Polaris] Warning: There's no version saved. Save a version for key:'Version'");
        }
        #endif
        
        return version;
    }
    else{
        return nil;
    }
    
}

@end

