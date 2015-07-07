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
    
    NSString *projectPath;

    GCDWebServer *_webServer;
    GCDWebUploader *_webUploader;
    GCDWebDAVServer *_davServer;
    
    Polaris *projectManager;
    
    
    BOOL initWithProjectCreator;
    BOOL needClose;
    BOOL failed;
}

@end


@implementation Polaris
@synthesize inspectorPath,selectedFilePath,deletePath;



+(id)alloc{
    NSLog(@"[Polaris] Version 1.1 || © 2015 VWAS-Studios & Vladimir Danila\nFollow us on Twitter: @VWASStudios || @DanilaVladi and stay up to date!  \n\n");
    return [super alloc];
}
+(id)init{
    NSLog(@"Wrong initializer. <Use initWithProjectPath or initWithNewProject instead>");
    return [super init];
}



- (instancetype)initWithProjectCreatorAtPath:(NSString *)path withName:(NSString *)name andExtension:(NSString *)extension{
    self = [super init];
    //create project structure
    
    if (self) {
    
        initWithProjectCreator = true;
        

        NSString *projectName = [NSString stringWithFormat:@"%@.%@",name,extension];
        NSString *creationPath = [path stringByAppendingPathComponent:projectName];

        projectPath = creationPath;

        
        NSError *error;
        
        [[NSFileManager defaultManager] createDirectoryAtPath:creationPath withIntermediateDirectories:NO attributes:nil error:&error];
        [[NSFileManager defaultManager] createDirectoryAtPath:[self projectVersionsPath] withIntermediateDirectories:NO attributes:nil error:&error];
        [[NSFileManager defaultManager] createDirectoryAtPath:[self projectUserDirectoryPath] withIntermediateDirectories:NO attributes:nil error:&error];
        [[NSFileManager defaultManager] createDirectoryAtPath:[self projectTempPath] withIntermediateDirectories:NO attributes:nil error:&error];
        [[NSFileManager defaultManager] createDirectoryAtPath:[self projectSettingsPath] withIntermediateDirectories:NO attributes:nil error:&error];
        
        
        if (error) {
            NSLog(@"\n\n\n\n\n\n[Polaris] ERROR: Faild to create a new Project. Please double check if the path exists.\nDescription: %@\n\n\n\n\n\n",[error localizedDescription]);
        }
        
    }
    
    return self;
}




- (instancetype)initWithProjectPath:(NSString *)path andWithWebServer:(BOOL)useWebServer UploadServer:(BOOL)useUploadServer andWebDavServer:(BOOL)useWebDavServer{
    self = [super init];
    
    
    if (self) {
    
        projectPath = path;
        inspectorPath = [self projectUserDirectoryPath];

        if (useWebServer || useUploadServer || useWebDavServer) {
            [self startServerForWeb:useWebServer forUploading:useUploadServer forWebDav:useWebDavServer];
        }
        
    }
    
    return self;
}


- (void)close{
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



- (NSString *)fakePathForFile:(NSString *)selectedFile{

    if (!initWithProjectCreator) {
        return [selectedFile stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",[self projectUserDirectoryPath]] withString:@""];

    }
    else{
        NSLog(@"\n\n\n\n\n\n[Polaris] ERROR: Wrong initializer.\n\n\n\n\n\n");
        return nil;
    }
}

- (NSString *)fakePathForFileSelectedFile{
    if (!initWithProjectCreator) {
        
        return [selectedFilePath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",[self projectUserDirectoryPath]] withString:@""];
    }
    else{
        NSLog(@"\n\n\n\n\n\n[Polaris] ERROR: Wrong initializer.\n\n\n\n\n\n");
        return nil;
    }
}

- (NSMutableArray *)contentsOfCurrentDirectory{
    if (!initWithProjectCreator) {
        
        return [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:inspectorPath error:nil] mutableCopy];
    
    }
    else{
        NSLog(@"\n\n\n\n\n\n[Polaris] ERROR: Wrong initializer.\n\n\n\n\n\n");
        return nil;
    }
}


- (NSMutableArray *)contentsOfDirectoryAtPath:(NSString *)path{
    if (!initWithProjectCreator) {
        
    
    return [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil] mutableCopy];
    }
    else{
        NSLog(@"\n\n\n\n\n\n[Polaris] ERROR: Wrong initializer.\n\n\n\n\n\n");
        return nil;
    }
}



- (void)archiveWorkingCopyWithCommitMessge:(NSString *)message{
    
    if (!initWithProjectCreator) {
        
    
        NSString *version = [self privateProjectVersion];
    
        int newVersion = version.intValue + 1;
        [self updateVersionNumberToVersion:newVersion];
    
    
        NSString *destination = [NSString stringWithFormat:@"%@/Version%@",[self projectVersionsPath], version];
    
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:[self projectUserDirectoryPath] toPath:destination error:&error];
    
        if (error) {
            NSLog(@"\n\n\n\n\n\n[Polaris] ERROR: Failed to archive project. Details: %@\n\n\n\n\n\n",[error localizedDescription]);
        }
        else{
            if ([message isEqualToString:@"Enter commit message here"]) {
                message = @"";
            }
            
            NSError *error2;
            NSString *dataPath = [destination stringByAppendingPathComponent:@"data"];
            
            if (!message.length == 0) {

                [message writeToFile:dataPath atomically:true encoding:NSUTF8StringEncoding error:&error2];
        
            if (error) {
                        NSLog(@"\n\n\n\n\n\n[Polaris] ERROR: Failed to save the comment to the archive. Details: %@\n\n\n\n\n\n",[error2 localizedDescription]);
                }
                else{
                    NSLog(@"\n\n\n\n\n\n[Polaris] Message: Project was archived.\n\n\n\n\n\n");
                }
            }
            else{
                NSLog(@"\n\n\n\n\n\n[Polaris] Message: Project was archived without a note.\n\n\n\n\n\n");
            }
        }
    }

    
}


#pragma mark - Server Stuff

- (NSString *)webServerURL{
    if (!initWithProjectCreator) {
        return [_webServer.serverURL absoluteString];
    }
    else{
        NSLog(@"\n\n\n\n\n\n[Polaris] Warning: Wrong initializer\n\n\n\n\n\n");
        return nil;
    }
}

- (NSString *)webUploaderServerURL{
    if (!initWithProjectCreator) {
        return [_webUploader.serverURL absoluteString];

    }
    else{
        NSLog(@"\n\n\n\n\n\n[Polaris] Warning: Wrong initializer\n\n\n\n\n\n");
        return nil;
    }
}

- (NSString *)webDavServerURL{
    if (!initWithProjectCreator) {
        return [_davServer.serverURL absoluteString];
    }
    else{
        NSLog(@"\n\n\n\n\n\n[Polaris] Warning: Wrong initializer\n\n\n\n\n\n");
        return nil;
    }
}

#pragma mark - Paths

-(NSString *)projectPath{
    return projectPath;

}



- (NSString *)projectUserDirectoryPath{
    return [projectPath stringByAppendingPathComponent:@"Assets"];
}

- (NSString *)projectVersionsPath{
    return [projectPath stringByAppendingPathComponent:@"Versions"];
}

- (NSString *)projectTempPath{
    return [projectPath stringByAppendingPathComponent:@"Temp"];
}

- (NSString *)projectSettingsPath{
    return [projectPath stringByAppendingPathComponent:@"Config"];
}


#pragma mark - Values


- (NSString *)projectCurrentVersion{
    if (!initWithProjectCreator) {
        NSString *version = [NSString stringWithFormat:@"%@.0", [self getSettingsDataForKey:@"version"]];
        
        if (version.length == 0) {
            NSLog(@"\n\n\n\n\n\n[Polaris] Warning: There's no version saved. Save a version for key:'Version'\n\n\n\n\n\n");
        }
        
        return version;
    }
    else{
        NSLog(@"\n\n\n\n\n\n[Polaris] Warning: Wrong initializer\n\n\n\n\n\n");
        return nil;
    }

}

- (NSString *)projectCopyright{
    
    if (!initWithProjectCreator) {
       return [self getSettingsDataForKey:@"Copyright"];

    }
    else{
        NSLog(@"\n\n\n\n\n\n[Polaris] Warning: Wrong initializer\n\n\n\n\n\n");
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
        NSLog(@"\n\n\n\n\n\n[Polaris] Warning: Wrong initializer\n\n\n\n\n\n");
        return nil;
    }

}



#pragma mark - Settings




- (void)updateGistID:(NSString*)gistID{
    if (!initWithProjectCreator) {
        [self updateSettingsValueForKey:@"gistID" withValue:gistID];
    }
    else{
        NSLog(@"\n\n\n\n\n\n[Polaris] Warning: Wrong initializer\n\n\n\n\n\n");
    }
}



- (void)updateVersionNumberToVersion:(int)versionNumber{
    if (!initWithProjectCreator) {
        [self updateSettingsValueForKey:@"version" withValue:[NSString stringWithFormat:@"%i",versionNumber]];
    }
    else{
        NSLog(@"\n\n\n\n\n\n[Polaris] Warning: Wrong initializer\n\n\n\n\n\n");
    }
}



- (void)updateSettingsValueForKey:(NSString *)key withValue:(id)anObject{
    NSDictionary *dict = [self getProjectSettingsDictionary];
    [dict setValue:[self encryptData:anObject forKey:key] forKey:key];
    
    [self saveDictionary:dict];
    
    
}

- (void)saveValue:(id)anObject forKey:(NSString *)key{
    NSMutableDictionary *dict = [self getProjectSettingsDictionary];
    [dict setValue:[self encryptData:anObject forKey:key] forKey:key];
    [self saveDictionary:dict];
}




- (NSString *)getSettingsDataForKey:(NSString *)key{
    
    NSDictionary *dict = [self getProjectSettingsDictionary];
    NSString *string = [self decryptedData:[dict valueForKey:key] forKey:key];
    
    if (!string) {
        NSLog(@"\n\n\n\n\n\n[Polaris] Warning: Warning: Value for key:%@ is empty or value doesn't exist.\n\n\n\n\n\n",key);
    }
    
    return string;
}



#pragma mark - Private Methods


- (void)saveWithoutEncryptionValue:(id)anObject forKey:(NSString *)key{
    NSMutableDictionary *dict = [self getProjectSettingsDictionary];
    [dict setValue:anObject forKey:key];
    [self saveDictionary:dict];
}


- (NSString *)getSettingsDataForKeyWithoutEncrytion:(NSString *)key{
    
    NSDictionary *dict = [self getProjectSettingsDictionary];
    NSString *string = [dict valueForKey:key];
    
    if (!string) {
        NSLog(@"\n\n\n\n\n\n[Polaris] Warning: Warning: Value for key:%@ is empty or value doesn't exist.\n\n\n\n\n\n",key);
    }
    
    return string;
    
}



- (void)startServerForWeb:(BOOL)web forUploading:(BOOL)uploading forWebDav:(BOOL)webDav{
    NSString *path = [self projectUserDirectoryPath];

    if (web) {
        
        _webServer = [[GCDWebServer alloc] init];
        [_webServer addGETHandlerForBasePath:@"/" directoryPath:path indexFilename:@"index.html" cacheAge:3600 allowRangeRequests:YES];
        [_webServer startWithPort:8080 bonjourName:nil];
        

    }
    
    if (uploading) {
        
        _webUploader = [[GCDWebUploader alloc] initWithUploadDirectory:path];
        [_webUploader startWithPort:80 bonjourName:nil];
    }
    
    if (webDav) {
        _davServer = [[GCDWebDAVServer alloc] initWithUploadDirectory:path];
        [_davServer startWithPort:443 bonjourName:nil];
    }

}


- (void)saveDictionary:(NSDictionary *)dict{
    [dict writeToFile:[self projectSettingsDictionaryPath] atomically:true];
}


- (NSMutableDictionary *)getProjectSettingsDictionary{
    
    NSString *settingsFilePath = [self projectSettingsDictionaryPath];
    
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


- (NSString *)projectSettingsDictionaryPath{
    return [[self projectSettingsPath] stringByAppendingPathComponent:@"settings.goldSettings"];
}




#pragma mark - Private - Encryption

- (NSData *)encryptData:(NSString *)string forKey:(NSString *)key{
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSData *encryptedData = [RNEncryptor encryptData:data
                                        withSettings:kRNCryptorAES256Settings
                                            password:key
                                               error:&error];
    
    if (error) {
        NSLog(@"\n\n\n\n\n\n[Polaris] ERROR: An unexpected error happened: %@\n\n\n\n\n\n",[error localizedDescription]);
    }
    
    
    
    return encryptedData;
}

- (NSString *)decryptedData:(NSData *)data forKey:(NSString *)key{
    
    NSError *error;
    NSData *decryptedData = [RNDecryptor decryptData:data
                                        withPassword:key
                                               error:&error];
    
    if (error) {
        NSLog(@"\n\n\n\n\n\n[Polaris] ERROR: An unexpected error happened: %@\n\n\n\n\n\n",[error localizedDescription]);
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
        
        if (version.length == 0) {
            NSLog(@"\n\n\n\n\n\n[Polaris] Warning: There's no version saved. Save a version for key:'Version'\n\n\n\n\n\n");
        }
        
        return version;
    }
    else{
        return nil;
    }
    
}

@end

