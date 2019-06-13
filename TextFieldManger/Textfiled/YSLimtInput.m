//
//  YSLimtInput.m
//  TextFieldManger
//
//  Created by mac on 2019/6/13.
//  Copyright © 2019 mac. All rights reserved.
//

#import "YSLimtInput.h"
#import <objc/runtime.h>

@interface YSLimtInputInfo :NSObject
@property (nonatomic,copy)NSString *limitReg;
@property (nonatomic,copy)NSString *validText;
@end


@implementation YSLimtInputInfo
@end


@interface UIView(Limit)

@property (nonatomic)YSLimtInputInfo   *ys_limtinfo;
@end


@implementation UIView (Limit)
-(YSLimtInputInfo *)ys_limtinfo{
    
    YSLimtInputInfo  *info =  objc_getAssociatedObject(self, _cmd);
    if (!info)
    {
        [self   setYs_limtinfo:[[YSLimtInputInfo alloc]init]];
        info = objc_getAssociatedObject(self,_cmd);
    }
    return info;
}


-(void)setYs_limtinfo:(YSLimtInputInfo *)ys_limtinfo
{
    objc_setAssociatedObject(self, @selector(ys_limtinfo), ys_limtinfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end



#define ys_LimtInputReg [YSLimtInputReg shareInstance]
@implementation YSLimtInputReg
static  YSLimtInputReg *g_limtInput;

+(YSLimtInputReg*)shareInstance{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_limtInput = [[YSLimtInputReg  alloc]init];
    });
    return g_limtInput;
}

+(void) limitInputView:(UIView<UITextInput>*)inputView  reg:(NSString*)reg
{
    inputView.ys_limtinfo.limitReg = reg;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [[NSNotificationCenter defaultCenter] addObserver:ys_LimtInputReg selector:@selector(textInputViewDidChangeLimitRegx:) name:UITextFieldTextDidChangeNotification object:nil];
    });
}


-(void)textInputViewDidChangeLimitRegx:(NSNotification*)notifi
{
    UIView  <UITextInput>  *inputview = (UIView <UITextInput>*)notifi.object;
    if ([inputview isFirstResponder] == NO){
        return;
    }
    
    NSString   *regx = inputview.ys_limtinfo.limitReg;
    if (!regx) {
        return ;
    }
    NSString   *key = @"text";
    NSString   *text =  [inputview valueForKey:key];
    
    if (regx && text.length > 0)
    {
        NSError   *error = nil;
        NSRegularExpression     *express = [NSRegularExpression regularExpressionWithPattern:regx options:NSRegularExpressionCaseInsensitive error:&error];
        
        NSRange   validRange = [express  rangeOfFirstMatchInString:text options:0 range:NSMakeRange(0, text.length)];
        if (validRange.location == NSNotFound)
        {
            NSString  *validText = inputview.ys_limtinfo.validText?:nil;
            [inputview setValue:validText forKey:key];
        }
        else
        {
            NSString *validText = [text substringFromIndex:validRange.location];
            inputview.ys_limtinfo.validText = validText;
            [inputview setValue:validText forKey:key];
        }
        
    }
    else{
        inputview.ys_limtinfo.validText = nil;
        [inputview setValue:nil forKey:key];
    }
    
    
    
}

@end
