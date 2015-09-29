// A0UserProfile.m
//
// Copyright (c) 2014 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "A0UserProfile.h"
#import "A0UserIdentity.h"

#import <ISO8601DateFormatter/ISO8601DateFormatter.h>

@implementation A0UserProfile

- initWithUserId:(NSString *)userId
            name:(NSString *)name
        nickname:(NSString *)nickname
           email:(NSString *)email
         picture:(NSURL *)picture
       createdAt:(NSDate *)createdAt {
    self = [super init];
    if (self) {
        NSAssert(userId.length > 0, @"Should have a non empty user id");
        _userId = [userId copy];
        _name = [name copy];
        _nickname = [nickname copy];
        _email = [email copy];
        _picture = picture;
        _createdAt = createdAt;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
    self = [self initWithUserId:dictionary[@"user_id"]
                           name:dictionary[@"name"]
                       nickname:dictionary[@"nickname"]
                          email:dictionary[@"email"]
                        picture:[NSURL URLWithString:dictionary[@"picture"]]
                      createdAt:[formatter dateFromString:dictionary[@"created_at"]]];
    if (self) {
        NSArray *identitiesJSON = dictionary[@"identities"];
        NSMutableDictionary *extraInfo = [dictionary mutableCopy];
        [extraInfo removeObjectsForKeys:@[@"user_id", @"name", @"nickname", @"email", @"picture", @"created_at", @"identities"]];
        NSMutableArray *identities = [[NSMutableArray alloc] initWithCapacity:identitiesJSON.count];
        for (NSDictionary *identityJSON in identitiesJSON) {
            [identities addObject:[[A0UserIdentity alloc] initWithJSONDictionary:identityJSON]];
        }
        _identities = [NSArray arrayWithArray:identities];
        _extraInfo = extraInfo;
    }
    return self;
}

- (NSDictionary *)userMetadata {
    return self.extraInfo[@"user_metadata"] ?: @{};
}

- (NSDictionary *)appMetadata {
    return self.extraInfo[@"app_metadata"] ?: @{};
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self initWithUserId:[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(userId))]
                           name:[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(name))]
                       nickname:[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(nickname))]
                          email:[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(email))]
                        picture:[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(picture))]
                      createdAt:[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(createdAt))]];
    if (self) {
        _extraInfo = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(extraInfo))];
        _identities = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(identities))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.userId forKey:NSStringFromSelector(@selector(userId))];
    if (self.name) {
        [aCoder encodeObject:self.name forKey:NSStringFromSelector(@selector(name))];
    }
    if (self.nickname) {
        [aCoder encodeObject:self.nickname forKey:NSStringFromSelector(@selector(nickname))];
    }
    if (self.email) {
        [aCoder encodeObject:self.email forKey:NSStringFromSelector(@selector(email))];
    }
    if (self.picture) {
        [aCoder encodeObject:self.picture forKey:NSStringFromSelector(@selector(picture))];
    }
    if (self.createdAt) {
        [aCoder encodeObject:self.createdAt forKey:NSStringFromSelector(@selector(createdAt))];
    }
    if (self.extraInfo) {
        [aCoder encodeObject:self.extraInfo forKey:NSStringFromSelector(@selector(extraInfo))];
    }
    if (self.identities) {
        [aCoder encodeObject:self.identities forKey:NSStringFromSelector(@selector(identities))];
    }
}

@end
