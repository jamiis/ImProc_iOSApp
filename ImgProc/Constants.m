//
//  Constants.m
//  ImgProc
//
//  Created by Jamis Johnson on 2/23/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import "Constants.h"


// PHOTOVIEW
const CGRect PHOTOVIEW_FRAME = { {15.0f, 15.0f} , {290.0f, 312.0f} };


// ANIMATION FRAMES

// :  IPHONE :
// :: FRAMES, ALGORITHM-VIEW ::
const CGRect FRAME_ALGORITHMS_VIEW_IPHONE_SCROLL_VIEW = { 
                        {-320.0, 436.0-SCROLLVIEW_HEIGHT}, 
                        {320.0, SCROLLVIEW_HEIGHT} };
const CGRect FRAME_ALGORITHMS_VIEW_IPHONE_ALGORITHM_CONTROLS = {
                        {0.0, 436.0-ALGORITHM_VIEW_HEIGHT},
                        {320.0, ALGORITHM_VIEW_HEIGHT} };
const CGRect FRAME_ALGORITHMS_VIEW_IPHONE_NAV_BAR = {
                        {0.0, -44.0},
                        {320.0, 44.0} };
// :: FRAMES, MAIN-VIEW ::
const CGRect FRAME_MAIN_VIEW_IPHONE_SCROLL_VIEW = { 
                        {0.0, 436.0-SCROLLVIEW_HEIGHT}, 
                        {320.0, SCROLLVIEW_HEIGHT} };
const CGRect FRAME_MAIN_VIEW_IPHONE_ALGORITHM_CONTROLS = {
                        {0.0, 436.0},
                        {320.0, ALGORITHM_VIEW_HEIGHT} };
const CGRect FRAME_MAIN_VIEW_IPHONE_NAV_BAR = {
                        {0.0, 0.0},
                        {320.0, 44.0} };

// :  IPAD  :
// :: FRAMES, ALGORITHM-VIEW ::
const CGRect FRAME_ALGORITHMS_VIEW_IPAD_SCROLL_VIEW = { 
                        {-768.0, 980.0-SCROLLVIEW_HEIGHT_IPAD}, 
                        {768.0, SCROLLVIEW_HEIGHT_IPAD} };
const CGRect FRAME_ALGORITHMS_VIEW_IPAD_ALGORITHM_CONTROLS = {
                        {0.0, 980.0-ALGORITHM_VIEW_HEIGHT_IPAD},
                        {768.0, ALGORITHM_VIEW_HEIGHT_IPAD} };
const CGRect FRAME_ALGORITHMS_VIEW_IPAD_NAV_BAR = {
                        {0.0, -44.0},
                        {768.0, 44.0} };
// :: FRAMES, MAIN-VIEW ::
const CGRect FRAME_MAIN_VIEW_IPAD_SCROLL_VIEW = { 
                        {0.0, 980.0-SCROLLVIEW_HEIGHT_IPAD}, 
                        {768.0, SCROLLVIEW_HEIGHT_IPAD} };
const CGRect FRAME_MAIN_VIEW_IPAD_ALGORITHM_CONTROLS = {
                        {0.0, 980.0},
                        {768.0, ALGORITHM_VIEW_HEIGHT_IPAD} };
const CGRect FRAME_MAIN_VIEW_IPAD_NAV_BAR = {
                        {0.0, 0.0},
                        {768.0, 44.0} };

    
//float new_y = 436.0 - ALGORITHM_VIEW_HEIGHT;
//_algorithmControlsView.frame = CGRectMake(0.0, new_y, 320.0, ALGORITHM_VIEW_HEIGHT);
