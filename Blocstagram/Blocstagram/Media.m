//
//  Media.m
//  Blocstagram
//
//  Created by Dulio Denis on 11/8/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import "Media.h"
#import "User.h"
#import "Comment.h"

@implementation Media

- (instancetype)initWithDictionary:(NSDictionary *)mediaDictionary {
    self = [super init];
    
    if (self) {
        self.idNumber = mediaDictionary[@"id"];
        self.user = [[User alloc] initWithDictionary:mediaDictionary[@"user"]];
        
        NSString *standardResolutionImageURLString = mediaDictionary[@"images"][@"standard_resolution"][@"url"];
        NSURL *standardResolutionImagesURL = [NSURL URLWithString:standardResolutionImageURLString];
        
        if (standardResolutionImageURLString) {
            self.mediaURL = standardResolutionImagesURL;
            self.downloadState = MediaDownloadStateNeedsImage;
        } else {
            self.downloadState = MediaDownloadStateNonRecoverableError;
        }
        
        NSDictionary *captionDictionary = mediaDictionary[@"caption"];
        
        // Captions may be null if there are no captions
        if ([captionDictionary isKindOfClass:[NSDictionary class]]) {
            self.caption = captionDictionary[@"text"];
        } else { // it must be an NSNull
            self.caption = @"";
        }
        
        NSMutableArray *commentsArray = [NSMutableArray array];
        for (NSDictionary *commentDictionary in mediaDictionary[@"comments"][@"data"]) {
            Comment *comment = [[Comment alloc] initWithDictionary:commentDictionary];
            [commentsArray addObject:comment];
        }
        self.comments = commentsArray;
        
        // Has the user already "liked" this media or not then set to notliked
        BOOL userHasLiked = [mediaDictionary[@"user-has-liked"] boolValue];
        self.likeState = userHasLiked ? LikeStateLiked : LikeStateNotLiked;
    
        // http://instagram.com/developer/endpoints/media/#get_media
        NSDictionary *likesDictionary = mediaDictionary[@"likes"];
        if ([captionDictionary isKindOfClass:[NSDictionary class]]) {
            self.likes = likesDictionary[@"count"];
            NSLog(@"Likes = %@", self.likes);
        } else {
            self.likes = nil;
        }
    }
    return self;
}


#pragma mark - NSCoding Protocol Methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super self];
    
    if (self) {
        self.idNumber = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(idNumber))];
        self.user = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(user))];
        self.mediaURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(mediaURL))];
        self.image = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(image))];
        
        if (self.image) {
            self.downloadState = MediaDownloadStateHasImage;
        } else if (self.mediaURL) {
            self.downloadState = MediaDownloadStateNeedsImage;
        } else {
            self.downloadState = MediaDownloadStateNonRecoverableError;
        }
        
        self.downloadState = MediaDownloadStateNeedsImage;
        self.caption = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(caption))];
        self.comments = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(comments))];
        self.likeState = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(likeState))];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.idNumber forKey:NSStringFromSelector(@selector(idNumber))];
    [aCoder encodeObject:self.user forKey:NSStringFromSelector(@selector(user))];
    [aCoder encodeObject:self.mediaURL forKey:NSStringFromSelector(@selector(mediaURL))];
    [aCoder encodeObject:self.image forKey:NSStringFromSelector(@selector(image))];
    [aCoder encodeObject:self.caption forKey:NSStringFromSelector(@selector(caption))];
    [aCoder encodeObject:self.comments forKey:NSStringFromSelector(@selector(comments))];
    [aCoder encodeInteger:self.likeState forKey:NSStringFromSelector(@selector(likeState))];
}

@end
