//
//  AudioTableMeter.swift
//
//  Created by Jorge Ouahbi on 20/11/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//
//  Abstract: Class for handling conversion from linear scale to dB

import Foundation

/*
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2009 Apple Inc. All Rights Reserved.
 
 */


public func DbToAmp(inDb:Double) -> Double
{
    return pow(10.0, 0.05 * inDb);
}

public class AudioMeterTable
{
    var minDecibels:Double = -80.0;
    var decibelResolution:Double = 0.0;
    var scaleFactor:Double = 1.0;
    var lookupTable:[Double] =  [Double](repeating:0,count:800)
    
    
    /// Constructor AudioMeterTable
    ///
    /// tableSize - The size of the table. The table needs to be large enough that there are no large gaps in the response.
    /// minDbs - the decibel value of the minimum displayed amplitude.
    /// inRoot - this controls the curvature of the response. 2.0 is square root, 3.0 is cube root. But inRoot doesn't have to be integer valued, it could be 1.8 or 2.5, etc.
    
    public init?(minDbs:Double = -80.0,tableSize:Int = 400, inRoot:Double = 2.0)
    {
        minDecibels = minDbs
        decibelResolution = (minDecibels / Double(tableSize - 1))
        scaleFactor = (1.0 / decibelResolution)
        
        if !(minDbs < 0.0) {
            print("AudioMeterTable minDbs must be negative")
            return nil;
        }
        
        if lookupTable.count != tableSize  {
            // reallocate
            lookupTable = [Double](repeating:0,count:tableSize)
        }
        
        let minAmp = DbToAmp(inDb: minDbs)
        let ampRange = 1.0 - minAmp;
        let invAmpRange = 1.0 / ampRange;
        
        let invRoot = 1.0 / inRoot;
        for i in 0 ..< tableSize {
            let decibels = Double(i) * decibelResolution;
            let amp = DbToAmp(inDb:decibels);
            let adjAmp = (amp - minAmp) * invAmpRange;
            lookupTable[i] = pow(adjAmp, invRoot);
        }
    }

    func ValueAt(inDecibels:Double) -> Double {
        if inDecibels < minDecibels {
            return 0.0
        }
        if (inDecibels >= 0.0) {
            return 1.0
        }
        let index = Int(inDecibels * scaleFactor);
        return lookupTable[index];
    }

}

