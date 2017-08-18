//
//    Copyright 2016 - Jorge Ouahbi
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//

import  UIKit

/// OMMeter class

public class OMMeter : UIControl
{
    private let reflectEffectGradient = CGGradient(colorSpace: CGColorSpaceCreateDeviceRGB(),
                                                   colorComponents: [ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0], locations: nil, count: 2)!
    private let glassEffectGradient   = CGGradient(colorSpace: CGColorSpaceCreateDeviceRGB(),
                                                   colorComponents: [1.0, 1.0, 1.0, 0.2, 1.0, 1.0, 1.0, 0.0], locations: nil, count: 2)!
    
    
    private var lowerCircleRadius:CGFloat = 0
    private var lowerCircleCenterPoint:CGPoint = CGPoint.zero
    private var lowerChordLeftPoint:CGPoint  = CGPoint.zero
    private var lowerChordRightPoint:CGPoint = CGPoint.zero
    
    
    private var upperCircleRadius:CGFloat = 0
    private var upperRectGlassCenterPoint:CGPoint = CGPoint.zero
    private var upperChordLeftPoint:CGPoint = CGPoint.zero
    private var upperChordRightPoint:CGPoint = CGPoint.zero
    
    private var startGradientPoints:[CGPoint] = [CGPoint]()
    
    /// Glass effect
    
    private var rectGlassLeft:CGRect = CGRect.zero;
    private var rectGlassRight:CGRect = CGRect.zero;
    
    private var numberOfGradientElements:CGFloat = 0
    private var spanValue:CGFloat = 0
    private var percentValue:CGFloat = 0
    private var stringMaxSize:CGSize = CGSize.zero
    
    /// Font
    
    /// Font attributes
    private var fontAttributtes:[NSAttributedStringKey:Any] = [:]
    
    ///Font name (default:HelveticaNeue-Light)
    public var fontName:String = "HelveticaNeue-Light" {
        didSet {
            setNeedsLayout()
        }
    }
    ///Font color (default:black)
    public var fontColor:UIColor = UIColor.black {
        didSet {
            setNeedsLayout()
        }
    }
    /// Ticks
    
    /// Tick Points
    private var ticksPoints:[CGPoint]  = [CGPoint]()
    
    /// Number of ticks
    private var numberOfTicks:Int = 100 + 1
    
    /// Ticks line width
    private var tickLineWidth:CGFloat = 0.18
    
    /// Set the stroke ticks color (default: black)
    var strokeTicksColor:UIColor = UIColor.gray {
        didSet {
            setNeedsDisplay()
        }
    }
    /// Minimum value
    public var minimumValue:CGFloat = -80 {
        didSet {
            value.clamp(toLowerValue: minimumValue, upperValue: maximumValue)
            setNeedsLayout()
        }
    }
    /// Maximum value
    public var maximumValue:CGFloat = 0 {
        didSet {
            value.clamp(toLowerValue: minimumValue, upperValue: maximumValue)
            setNeedsLayout()
        }
    }
    /// Current value
    public var value:CGFloat = 0 {
        didSet {
            value.clamp(toLowerValue: minimumValue, upperValue: maximumValue)
            sendActions(for: .valueChanged)
            setNeedsLayout()
        }
    }
    /// Set glass effect
    public var glassEffect:Bool = true {
        didSet {
            setNeedsLayout()
        }
    }
    /// Set gradient colors
    public var gradientColors:[UIColor] = [UIColor]() {
        didSet {
            // map monochrome colors to rgba colors
            self.gradientColors = gradientColors.map({
                return ($0.colorSpace?.model == .monochrome) ?
                    UIColor(red: $0.components[0],
                            green : $0.components[0],
                            blue  : $0.components[0],
                            alpha : $0.components[1]) : $0
            })
            setNeedsLayout()
        }
    }
    
    /// Contructors
    override init(frame: CGRect) {
        super.init(frame: frame)
        setNeedsLayout()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setNeedsLayout()
    }
    
    /// Draw glass effect
    ///
    /// - Parameter context: current context
    
    fileprivate func drawGlassEffect(context:CGContext) {
        
        let options  = CGGradientDrawingOptions(rawValue: 0)
        let endPointLeft = CGPoint(x:bounds.midX ,y:upperChordLeftPoint.y)
        let endPointRight = CGPoint(x:bounds.midX ,y:upperChordRightPoint.y)
        
        // left glass effect
        context.setStrokeColor(UIColor.white.cgColor)
        context.addRect(rectGlassLeft)
        context.closePath()
        context.saveGState()
        //context.strokePath()
        context.clip()
        context.drawLinearGradient(glassEffectGradient,
                                   start: upperChordLeftPoint,
                                   end: endPointLeft,
                                   options: options)
        context.restoreGState()
        
        // right glass effect
        context.addRect(rectGlassRight)
        context.closePath()
        context.saveGState()
        //context.strokePath()
        context.clip()
        context.drawLinearGradient(glassEffectGradient,
                                   start: upperChordRightPoint,
                                   end: endPointRight,
                                   options: options)
        context.restoreGState()
    }
    
    override public func draw(_ rect: CGRect) {
        
        if self.isHidden || startGradientPoints.count == 0 {
            // Nothing to do.
            return
        }
        if let context = UIGraphicsGetCurrentContext() {
            
            context.clear(rect)
            
            var elementIndex = 0
            var elementValue:CGFloat = 0
            
            repeat {
                let startPoint:CGPoint = startGradientPoints[elementIndex]
                var endPoint:CGPoint   = startGradientPoints[elementIndex+1]
                let startColor:UIColor = gradientColors[elementIndex]
                var endColor:UIColor   = gradientColors[elementIndex+1]
                
                let ratioSpan = CGFloat(elementIndex + 1) / numberOfGradientElements
                elementValue  = ratioSpan * spanValue
                
                if value <= elementValue + minimumValue {
                    let percentGradient = CGFloat(numberOfGradientElements) * percentValue - CGFloat(elementIndex)
                    endColor = UIColor.lerp(startColor,end: endColor,t: percentGradient)
                    let percentPointDifference = ((endPoint.y - startPoint.y) * percentGradient)
                    endPoint = CGPoint(x:startPoint.x, y:startPoint.y + percentPointDifference)
                }
                // Draw the gradient.
                if let  gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                              colors: [startColor.cgColor, endColor.cgColor] as CFArray,
                                              locations: nil) {
                    context.drawLinearGradient(gradient,
                                               start: startPoint,
                                               end: endPoint,
                                               options: CGGradientDrawingOptions(rawValue: 0))
                }
                elementIndex = elementIndex + 1
            } while value > elementValue + minimumValue
            
            // Draw the glass effect.
            if (glassEffect) {
                drawGlassEffect(context: context)
            }
            // Draw the text and the ticks
            drawTicksAndText(context:context,
                             color:strokeTicksColor.cgColor,
                             tickLineWidth:tickLineWidth)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let height = self.bounds.height
        lowerCircleRadius      = height / 8
        lowerCircleCenterPoint = CGPoint(x:self.bounds.midX, y:height - lowerCircleRadius)
        lowerChordLeftPoint    = CGPoint(x:(lowerCircleCenterPoint.x - CGFloat(cos(.pi / 4.0)) * lowerCircleRadius),
                                         y:(lowerCircleCenterPoint.y - CGFloat(sin(.pi / 4.0)) * lowerCircleRadius))
        lowerChordRightPoint   = CGPoint(x:(lowerCircleCenterPoint.x + CGFloat(cos(.pi / 4.0)) * lowerCircleRadius),
                                         y:(lowerCircleCenterPoint.y - CGFloat(sin(.pi / 4.0)) * lowerCircleRadius))
        upperCircleRadius         = (lowerChordRightPoint.x - lowerChordLeftPoint.x) * 0.5
        upperRectGlassCenterPoint = CGPoint(x:self.bounds.midX, y:upperCircleRadius)
        upperChordLeftPoint       = CGPoint(x:lowerChordLeftPoint.x, y:upperRectGlassCenterPoint.y)
        upperChordRightPoint      = CGPoint(x:lowerChordRightPoint.x,y:upperRectGlassCenterPoint.y)
        rectGlassLeft             = CGRect(x:upperChordLeftPoint.x, y:self.bounds.minY,
                                           width:upperRectGlassCenterPoint.x - upperChordLeftPoint.x, height:height)
        rectGlassRight            = CGRect(x:upperRectGlassCenterPoint.x,y:self.bounds.minY,
                                           width:upperChordRightPoint.x - upperRectGlassCenterPoint.x, height:height)
        startGradientPoints.removeAll()
        
        if gradientColors.count == 0 {
            // Do not fail
            gradientColors = [UIColor.green, UIColor.red]
        } else if gradientColors.count == 1 {
            // Duplicate the color
            let color = gradientColors[0]
            gradientColors = [color.lighterColor(percent: 0.8), color.darkerColor(percent: 0.5)]
        }
        
        numberOfGradientElements = CGFloat(gradientColors.count - 1)
        for colorIndex in 0 ..< gradientColors.count  {
            let pointGradientStartY = height +  ((CGFloat(colorIndex) *  -height) / numberOfGradientElements)
            startGradientPoints.append(CGPoint(x:self.bounds.midX, y:pointGradientStartY))
            //DBG
            //print("\(colorIndex) \(startGradientPoint) \(newStartGradientPointY) \(gradientColors[colorIndex].shortDescription)")
        }
        
        spanValue        = (maximumValue - minimumValue)
        percentValue     = (value - minimumValue) / spanValue
        
        // Configure text
        let paragraphStyle   = NSMutableParagraphStyle()
        let maxTextHeight    = (height / CGFloat(numberOfTicks - 1)) * 2.0 // 2 ticks
        let maxTextWidth     = (self.bounds.width  / 3.0)
        let stringSizeToFit  = CGSize(width:maxTextWidth, height:maxTextHeight)
        
        // Max string size
        stringMaxSize        = UIFont.stringSize(s: "-\(max(abs(minimumValue),abs(minimumValue)))",
            fontName: fontName,
            size: stringSizeToFit)
        // Configure the font attributes
        paragraphStyle.alignment = .center
        fontAttributtes = [NSAttributedStringKey.font: UIFont(name: fontName, size: stringMaxSize.height)!,
                           NSAttributedStringKey.paragraphStyle: paragraphStyle,
                           NSAttributedStringKey.foregroundColor: fontColor,
                           // https://developer.apple.com/library/content/qa/qa1531/_index.html
            // Supply a negative value for stroke width that is 2% of the font point size in thickness
            NSAttributedStringKey.strokeWidth:NSNumber(value:-2.0),
            NSAttributedStringKey.strokeColor:UIColor.white]
        
        setNeedsDisplay()
    }

    /// Draw text and ticks
    ///
    /// - Parameter context: current context
    /// - Parameter color: UIColor
    /// - Parameter tickLineWidth: tick line width
    ///
    fileprivate func drawTicksAndText(context:CGContext,color:CGColor,tickLineWidth:CGFloat) {
        
        // Configure the shadow
        let shadowOffset = CGSize(width:0,height: tickLineWidth)
        // Default color
        let shadowColor  = UIColor(red:0.0,green:0.0,blue:0.0,alpha:1.0/3.0).cgColor
        let shadowBlur   = CGFloat(1.0)
        
        // Configure the context
        context.setStrokeColor(color)
        context.setShadow(offset: shadowOffset, blur: shadowBlur, color:shadowColor)
        context.setLineWidth(tickLineWidth)
        
        let tickLengthTen  =  ((self.bounds.width  / 3.0) * 0.5)
        let tickLengthFive =  ((self.bounds.width  / 3.0) * 0.25)
        let tickLengthOne  =  ((self.bounds.width  / 3.0) * 0.125)
        
        // Configure the ticks
        let numberOfTicksElements = CGFloat(numberOfTicks - 1)
        let maximumTickValue      = minimumValue + CGFloat(10 * numberOfTicksElements)
        var targetPoint:CGPoint   = CGPoint.zero
        
        for i in 0 ..< numberOfTicks  {
            let pointTickMid   = CGPoint(x:self.bounds.midX,
                                         y:(self.bounds.height + (CGFloat(i) * -self.bounds.height) / numberOfTicksElements))
            if i % 10 == 0 {
                targetPoint = CGPoint(x:pointTickMid.x - tickLengthTen , y:pointTickMid.y)
                let textLevel = map(input: minimumValue + CGFloat(i * 10),
                                    input_start:minimumValue ,
                                    input_end: maximumTickValue,
                                    output_start: minimumValue,
                                    output_end: maximumValue)
                let textLevelRect = CGRect(x: pointTickMid.x + stringMaxSize.width  - (stringMaxSize.width * 0.5),
                                           y: pointTickMid.y - stringMaxSize.height,
                                           width: stringMaxSize.width,
                                           height: stringMaxSize.height)
                
                let levelString = "\(Int(textLevel))" as NSString
                levelString.draw(with:textLevelRect, options: .usesLineFragmentOrigin, attributes: fontAttributtes, context: nil)
                context.addRect(textLevelRect)
                context.move(to:CGPoint(x:pointTickMid.x + tickLengthTen, y:pointTickMid.y))
            } else if i % 5 == 0 {
                targetPoint = CGPoint(x:pointTickMid.x - tickLengthFive, y:pointTickMid.y)
                context.move(to:CGPoint(x:pointTickMid.x + tickLengthFive, y:pointTickMid.y))
            } else {
                targetPoint = CGPoint(x:pointTickMid.x - tickLengthOne,  y:pointTickMid.y)
                context.move(to:CGPoint(x:pointTickMid.x + tickLengthOne, y:pointTickMid.y))
            }
            context.addLine(to: targetPoint)
            // Stroke path
            context.strokePath()
        }
    }
}
