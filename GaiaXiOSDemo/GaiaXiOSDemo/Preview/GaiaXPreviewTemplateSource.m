//  Copyright (c) 2023, Alibaba Group Holding Limited.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


#import "GaiaXPreviewTemplateSource.h"
#import <GaiaXiOS/NSDictionary+GX.h>
#import "GXTemplateItem.h"
@interface GaiaXPreviewTemplateSource ()

@property (nonatomic, strong) NSMutableDictionary *previewSource;

@end

@implementation GaiaXPreviewTemplateSource

- (NSMutableDictionary *)previewSource{
    if (!_previewSource) {
        _previewSource = [NSMutableDictionary dictionary];
    }
    return _previewSource;
}


#pragma mark - GXITemplateSource

- (NSInteger)priority{
    //优先级最高，优先读取
    return 99;
}

- (NSDictionary *)getTemplateInfoWithTemplateItem:(GXTemplateItem *)templateItem{
    NSDictionary *resultDict = nil;
    
    NSString *templateId = templateItem.templateId;
    if (templateId.length) {
        resultDict = [self.previewSource gx_dictionaryForKey:templateId];
    }
    return resultDict;
}


#pragma mark - Method

- (void)addPreviewTemplate:(NSDictionary *)aTemplate forTemplateId:(NSString *)templateId{
    [self.previewSource gx_setObject:aTemplate forKey:templateId];
}

- (void)clearPreviewTemplates{
    [self.previewSource removeAllObjects];
}

@end
