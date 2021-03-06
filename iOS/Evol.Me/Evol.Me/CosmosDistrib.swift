//
// Star rating control written in Swift for iOS.
//
// https://github.com/exchangegroup/Cosmos
//
// This file was automatically generated by combining multiple Swift source files.
//


// ----------------------------
//
// CosmosDefaultSettings.swift
//
// ----------------------------

import UIKit

/**

Defaults setting values.

*/
struct CosmosDefaultSettings {
    init() {}
    
    static let defaultColor = UIColor(red: 1, green: 149/255, blue: 0, alpha: 1)
    
    
    // MARK: - Star settings
    // -----------------------------
    
    
    /// Border color of an empty star.
    static let borderColorEmpty = defaultColor
    
    /// Width of the border for the empty star.
    static let borderWidthEmpty: Double = 1
    
    /// Background color of an empty star.
    static let colorEmpty = UIColor.clearColor()
    
    /// Background color of a filled star.
    static let colorFilled = defaultColor
    
    /**
    
    Defines how the star is filled when the rating value is not an integer value. It can either show full stars, half stars or stars partially filled according to the rating value.
    
    */
    static let fillMode = StarFillMode.Full
    
    /// Rating value that is shown in the storyboard by default.
    static let rating: Double = 2.718281828
    
    /// Distance between stars.
    static let starMargin: Double = 5
    
    /**
    
    Array of points for drawing the star with size of 100 by 100 pixels. Supply your points if you need to draw a different shape.
    
    */
    static let starPoints: [CGPoint] = [
        CGPoint(x: 49.5,  y: 0.0),
        CGPoint(x: 60.5,  y: 35.0),
        CGPoint(x: 99.0, y: 35.0),
        CGPoint(x: 67.5,  y: 58.0),
        CGPoint(x: 78.5,  y: 92.0),
        CGPoint(x: 49.5,    y: 71.0),
        CGPoint(x: 20.5,  y: 92.0),
        CGPoint(x: 31.5,  y: 58.0),
        CGPoint(x: 0.0,   y: 35.0),
        CGPoint(x: 38.5,  y: 35.0)
    ]
    
    /// Size of a single star.
    static var starSize: Double = 20
    
    /// The total number of stars to be shown.
    static let totalStars = 5
    
    
    // MARK: - Text settings
    // -----------------------------
    
    
    /// Color of the text.
    static let textColor = UIColor(red: 127/255, green: 127/255, blue: 127/255, alpha: 1)
    
    /// Font for the text.
    static let textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
    
    /// Distance between the text and the stars.
    static let textMargin: Double = 5
    
    /// Calculates the size of the default text font. It is used for making the text size configurable from the storyboard.
    static var textSize: Double {
        get {
            return Double(textFont.pointSize)
        }
    }
    
    
    // MARK: - Touch settings
    // -----------------------------
    
    /// The lowest rating that user can set by touching the stars.
    static let minTouchRating: Double = 1
    
    /// When `true` the star fill level is updated when user touches the cosmos view. When `false` the Cosmos view only shows the rating and does not act as the input control.
    static let updateOnTouch = true
}


// ----------------------------
//
// CosmosLayerHelper.swift
//
// ----------------------------

import UIKit

/// Helper class for creating CALayer objects.
class CosmosLayerHelper {
    /**
    
    Creates a text layer for the given text string and font.
    
    - parameter text: The text shown in the layer.
    - parameter font: The text font. It is also used to calculate the layer bounds.
    - parameter color: Text color.
    
    - returns: New text layer.
    
    */
    class func createTextLayer(text: String, font: UIFont, color: UIColor) -> CATextLayer {
        let size = NSString(string: text).sizeWithAttributes([NSFontAttributeName: font])
        
        let layer = CATextLayer()
        layer.bounds = CGRect(origin: CGPoint(), size: size)
        layer.anchorPoint = CGPoint()
        
        layer.string = text
        layer.font = CGFontCreateWithFontName(font.fontName)
        layer.fontSize = font.pointSize
        layer.foregroundColor = color.CGColor
        layer.contentsScale = UIScreen.mainScreen().scale
        
        return layer
    }
}


// ----------------------------
//
// CosmosLayers.swift
//
// ----------------------------

import UIKit


/**

Colection of helper functions for creating star layers.

*/
class CosmosLayers {
    /**
    
    Creates the layers for the stars.
    
    - parameter rating: The decimal number representing the rating. Usually a number between 1 and 5
    - parameter settings: Star view settings.
    - returns: Array of star layers.
    
    */
    class func createStarLayers(rating: Double, settings: CosmosSettings) -> [CALayer] {
        
        var ratingRemander = numberOfFilledStars(rating, totalNumberOfStars: settings.totalStars)
        
        var starLayers = [CALayer]()
        
        for _ in (0..<settings.totalStars) {
            let fillLevel = starFillLevel(ratingRemainder: ratingRemander, fillMode: settings.fillMode)
            let starLayer = createCompositeStarLayer(fillLevel, settings: settings)
            starLayers.append(starLayer)
            ratingRemander--
        }
        
        positionStarLayers(starLayers, starMargin: settings.starMargin)
        return starLayers
    }
    
    
    /**
    
    Creates an layer that shows a star that can look empty, fully filled or partially filled.
    Partially filled layer contains two sublayers.
    
    - parameter starFillLevel: Decimal number between 0 and 1 describing the star fill level.
    - parameter settings: Star view settings.
    - returns: Layer that shows the star. The layer is displauyed in the cosmos view.
    
    */
    class func createCompositeStarLayer(starFillLevel: Double, settings: CosmosSettings) -> CALayer {
        
        if starFillLevel >= 1 {
            return createStarLayer(true, settings: settings)
        }
        
        if starFillLevel == 0 {
            return createStarLayer(false, settings: settings)
        }
        
        return createPartialStar(starFillLevel, settings: settings)
    }
    
    /**
    
    Creates a partially filled star layer with two sub-layers:
    
    1. The layer for the filled star on top. The fill level parameter determines the width of this layer.
    2. The layer for the empty star below.
    
    - parameter starFillLevel: Decimal number between 0 and 1 describing the star fill level.
    - parameter settings: Star view settings.
    
    - returns: Layer that contains the partially filled star.
    
    */
    class func createPartialStar(starFillLevel: Double, settings: CosmosSettings) -> CALayer {
        let filledStar = createStarLayer(true, settings: settings)
        let emptyStar = createStarLayer(false, settings: settings)
        
        let parentLayer = CALayer()
        parentLayer.contentsScale = UIScreen.mainScreen().scale
        parentLayer.bounds = CGRect(origin: CGPoint(), size: filledStar.bounds.size)
        parentLayer.anchorPoint = CGPoint()
        parentLayer.addSublayer(emptyStar)
        parentLayer.addSublayer(filledStar)
        
        // make filled layer width smaller according to the fill level.
        filledStar.bounds.size.width *= CGFloat(starFillLevel)
        
        return parentLayer
    }
    
    /**
    
    Returns a decimal number between 0 and 1 describing the star fill level.
    
    - parameter ratingRemainder: This value is passed from the loop that creates star layers. The value starts with the rating value and decremented by 1 when each star is created. For example, suppose we want to display rating of 3.5. When the first star is created the ratingRemainder parameter will be 3.5. For the second star it will be 2.5. Third: 1.5. Fourth: 0.5. Fifth: -0.5.
    
    - parameter fillMode: Describe how stars should be filled: full, half or precise.
    
    - returns: Decimal value between 0 and 1 describing the star fill level. 1 is a fully filled star. 0 is an empty star. 0.5 is a half-star.
    
    */
    class func starFillLevel(ratingRemainder ratingRemainder: Double, fillMode: StarFillMode) -> Double {
        
        var result = ratingRemainder
        
        if result > 1 { result = 1 }
        if result < 0 { result = 0 }
        
        return roundFillLevel(result, fillMode: fillMode)
    }
    
    
    /**
    
    Rounds a single star's fill level according to the fill mode. "Full" mode returns 0 or 1 by using the standard decimal rounding. "Half" mode returns 0, 0.5 or 1 by rounding the decimal to closest of 3 values. "Precise" mode will return the fill level unchanged.
    
    - parameter starFillLevel: Decimal number between 0 and 1 describing the star fill level.
    
    - parameter fillMode: Fill mode that is used to round the fill level value.
    
    - returns: The rounded fill level.
    
    */
    class func roundFillLevel(starFillLevel: Double, fillMode: StarFillMode) -> Double {
        switch fillMode {
        case .Full:
            return Double(round(starFillLevel))
        case .Half:
            return Double(round(starFillLevel * 2) / 2)
        case .Precise :
            return starFillLevel
        }
    }
    
    private class func createStarLayer(isFilled: Bool, settings: CosmosSettings) -> CALayer {
        let fillColor = isFilled ? settings.colorFilled : settings.colorEmpty
        let strokeColor = isFilled ? UIColor.clearColor() : settings.borderColorEmpty
        
        return StarLayer.create(settings.starPoints,
            size: settings.starSize,
            lineWidth: settings.borderWidthEmpty,
            fillColor: fillColor,
            strokeColor: strokeColor)
    }
    
    /**
    
    Returns the number of filled stars for given rating.
    
    - parameter rating: The rating to be displayed.
    - parameter totalNumberOfStars: Total number of stars.
    - returns: Number of filled stars. If rating is biggen than the total number of stars (usually 5) it returns the maximum number of stars.
    
    */
    class func numberOfFilledStars(rating: Double, totalNumberOfStars: Int) -> Double {
        if rating > Double(totalNumberOfStars) { return Double(totalNumberOfStars) }
        if rating < 0 { return 0 }
        
        return rating
    }
    
    /**
    
    Positions the star layers one after another with a margin in between.
    
    - parameter layers: The star layers array.
    - parameter starMargin: Margin between stars.
    
    */
    class func positionStarLayers(layers: [CALayer], starMargin: Double) {
        var positionX:CGFloat = 0
        
        for layer in layers {
            layer.position.x = positionX
            positionX += layer.bounds.width + CGFloat(starMargin)
        }
    }
}


// ----------------------------
//
// CosmosSettings.swift
//
// ----------------------------

import UIKit

/**

Settings that define the appearance of the star rating views.

*/
public struct CosmosSettings {
    init() {}
    
    // MARK: - Star settings
    // -----------------------------
    
    
    /// Border color of an empty star.
    public var borderColorEmpty = CosmosDefaultSettings.borderColorEmpty
    
    /// Width of the border for the empty star.
    public var borderWidthEmpty: Double = CosmosDefaultSettings.borderWidthEmpty
    
    /// Background color of an empty star.
    public var colorEmpty = CosmosDefaultSettings.colorEmpty
    
    /// Background color of a filled star.
    public var colorFilled = CosmosDefaultSettings.colorFilled
    
    /**
    
    Defines how the star is filled when the rating value is not a whole integer. It can either show full stars, half stars or stars partially filled according to the rating value.
    
    */
    public var fillMode = CosmosDefaultSettings.fillMode
    
    /// Distance between stars.
    public var starMargin: Double = CosmosDefaultSettings.starMargin
    
    /**
    
    Array of points for drawing the star with size of 100 by 100 pixels. Supply your points if you need to draw a different shape.
    
    */
    public var starPoints: [CGPoint] = CosmosDefaultSettings.starPoints
    
    /// Size of a single star.
    public var starSize: Double = CosmosDefaultSettings.starSize
    
    /// The maximum number of stars to be shown.
    public var totalStars = CosmosDefaultSettings.totalStars
    
    
    // MARK: - Text settings
    // -----------------------------
    
    /// Color of the text.
    public var textColor = CosmosDefaultSettings.textColor
    
    /// Font for the text.
    public var textFont = CosmosDefaultSettings.textFont
    
    /// Distance between the text and the stars.
    public var textMargin: Double = CosmosDefaultSettings.textMargin
    
    
    // MARK: - Touch settings
    // -----------------------------
    
    /// The lowest rating that user can set by touching the stars.
    public var minTouchRating: Double = CosmosDefaultSettings.minTouchRating
    
    /// When `true` the star fill level is updated when user touches the cosmos view. When `false` the Cosmos view only shows the rating and does not act as the input control.
    public var updateOnTouch = CosmosDefaultSettings.updateOnTouch
}


// ----------------------------
//
// CosmosSize.swift
//
// ----------------------------

import UIKit

/**

Helper class for calculating size for the cosmos view.

*/
class CosmosSize {
    /**
    
    Calculates the size of the cosmos view. It goes through all the star and text layers and makes size the view size is large enough to show all of them.
    
    */
    class func calculateSizeToFitLayers(layers: [CALayer]) -> CGSize {
        var size = CGSize()
        
        for layer in layers {
            if layer.frame.maxX > size.width {
                size.width = layer.frame.maxX
            }
            
            if layer.frame.maxY > size.height {
                size.height = layer.frame.maxY
            }
        }
        
        return size
    }
}


// ----------------------------
//
// CosmosText.swift
//
// ----------------------------



import UIKit

/**

Positions the text layer to the right of the stars.

*/
class CosmosText {
    /**
    
    Positions the text layer to the right from the stars. Text is aligned to the center of the star superview vertically.
    
    - parameter layer: The text layer to be positioned.
    - parameter starsSize: The size of the star superview.
    - parameter textMargin: The distance between the stars and the text.
    
    */
    class func position(layer: CALayer, starsSize: CGSize, textMargin: Double) {
        layer.position.x = starsSize.width + CGFloat(textMargin)
        let yOffset = (starsSize.height - layer.bounds.height) / 2
        layer.position.y = yOffset
    }
}


// ----------------------------
//
// CosmosTouch.swift
//
// ----------------------------

import UIKit

/**

Functions for working with touch input.

*/
struct CosmosTouch {
    /**
    
    Calculates the rating based on the touch location.
    
    - parameter locationX: The horizontal location of the touch relative to the width of the stars.
    
    - parameter starsWidth: The width of the stars excluding the text.
    
    - returns: The rating representing the touch location.
    
    */
    static func touchRating(locationX: CGFloat, starsWidth: CGFloat, settings: CosmosSettings) -> Double {
        
        let position = locationX / starsWidth
        let totalStars = Double(settings.totalStars)
        let actualRating = totalStars * Double(position)
        var correctedRating = actualRating
        
        if settings.fillMode != .Precise {
            correctedRating += 0.25
        }
        
        let starFloorNumber = floor(correctedRating)
        let singleStarRemainder = correctedRating - starFloorNumber
        
        correctedRating = starFloorNumber + CosmosLayers.starFillLevel(
            ratingRemainder: singleStarRemainder, fillMode: settings.fillMode)
        
        correctedRating = min(totalStars, correctedRating) // Can't go bigger than number of stars
        correctedRating = max(0, correctedRating) // Can't be less than zero
        correctedRating = max(settings.minTouchRating, correctedRating) // Can't be less than min rating
        
        return correctedRating
    }
}


// ----------------------------
//
// CosmosView.swift
//
// ----------------------------

import UIKit

/**

A star rating view that can be used to show customer rating for the products. On can select stars by tapping on them when updateOnTouch settings is true. An optional text can be supplied that is shown on the right side.

Example:

cosmosView.rating = 4
cosmosView.text = "(123)"

Shows: ★★★★☆ (132)

*/
@IBDesignable public class CosmosView: UIView {
    
    /**
    
    The currently shown number of stars, usually between 1 and 5. If the value is decimal the stars will be shown according to the Fill Mode setting.
    
    */
    @IBInspectable public var rating: Double = CosmosDefaultSettings.rating {
        didSet {
            if oldValue != rating {
                update()
            }
        }
    }
    
    /// Currently shown text. Set it to nil to display just the stars without text.
    @IBInspectable public var text: String? {
        didSet {
            if oldValue != text {
                update()
            }
        }
    }
    
    /// Star rating settings.
    public var settings = CosmosSettings() {
        didSet {
            update()
        }
    }
    
    /// Stores calculated size of the view. It is used as intrinsic content size.
    private var viewSize = CGSize()
    
    /// Draws the stars when the view comes out of storyboard with default settings
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        update()
    }
    
    convenience init() {
        self.init(frame: CGRect())
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        update()
        self.frame.size = intrinsicContentSize()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    /**
    
    Updates the stars and optional text based on current values of `rating` and `text` properties.
    
    */
    public func update() {
        
        // Create star layers
        // ------------
        
        var layers = CosmosLayers.createStarLayers(rating, settings: settings)
        layer.sublayers = layers
        
        // Create text layer
        // ------------
        
        if let text = text {
            let textLayer = createTextLayer(text, layers: layers)
            layers.append(textLayer)
        }
        
        // Update size
        // ------------
        
        updateSize(layers)
    }
    
    /**
    
    Creates the text layer for the given text string.
    
    - parameter text: Text string for the text layer.
    - parameter layers: Arrays of layers containing the stars.
    
    - returns: The newly created text layer.
    
    */
    private func createTextLayer(text: String, layers: [CALayer]) -> CALayer {
        let textLayer = CosmosLayerHelper.createTextLayer(text,
            font: settings.textFont, color: settings.textColor)
        
        let starsSize = CosmosSize.calculateSizeToFitLayers(layers)
        
        CosmosText.position(textLayer, starsSize: starsSize, textMargin: settings.textMargin)
        
        layer.addSublayer(textLayer)
        
        return textLayer
    }
    
    /**
    
    Updates the size to fit all the layers containing stars and text.
    
    - parameter layers: Array of layers containing stars and the text.
    
    */
    private func updateSize(layers: [CALayer]) {
        viewSize = CosmosSize.calculateSizeToFitLayers(layers)
        invalidateIntrinsicContentSize()
    }
    
    /// Returns the content size to fit all the star and text layers.
    override public func intrinsicContentSize() -> CGSize {
        return viewSize
    }
    
    
    // MARK: - Touch recognition
    
    /// Closure will be called when user touches the cosmos view. The touch rating argument is passed to the closure.
    public var didTouchCosmos: ((Double)->())?
    
    /// Overriding the function to detect the first touch gesture.
    /*public override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event!)
        
        if let touch = touches.first as? UITouch{
            let location = touch.locationInView(self).x
            onDidTouch(location, starsWidth: widthOfStars)
        }
    }
    
    /// Overriding the function to detect touch move.
    public override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event!)
        
        if let touch = touches.first as? UITouch{
            let location = touch.locationInView(self).x
            onDidTouch(location, starsWidth: widthOfStars)
        }
    }
    */
    
    /**
    
    Called when the view is touched.
    
    - parameter locationX: The horizontal location of the touch relative to the width of the stars.
    
    - parameter starsWidth: The width of the stars excluding the text.
    
    */
    func onDidTouch(locationX: CGFloat, starsWidth: CGFloat) {
        let calculatedTouchRating = CosmosTouch.touchRating(locationX, starsWidth: starsWidth,
            settings: settings)
        
        if settings.updateOnTouch {
            rating = calculatedTouchRating
        }
        
        didTouchCosmos?(calculatedTouchRating)
    }
    
    
    /// Width of the stars (excluding the text). Used for calculating touch location.
    var widthOfStars: CGFloat {
        if let sublayers = self.layer.sublayers where settings.totalStars <= sublayers.count {
            let starLayers = Array(sublayers[0..<settings.totalStars]) as! [CALayer]
            var ret = CosmosSize.calculateSizeToFitLayers(starLayers)
            return ret.width
        }
        
        return 0
    }
    
    /// Increase the hitsize of the view if it's less than 44px for easier touching.
    override public func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let oprimizedBounds = CosmosTouchTarget.optimize(bounds)
        return oprimizedBounds.contains(point)
    }
    
    
    // MARK: - Properties inspectable from the storyboard
    
    @IBInspectable var totalStars: Int = CosmosDefaultSettings.totalStars {
        didSet {
            settings.totalStars = totalStars
        }
    }
    
    @IBInspectable var starSize: Double = CosmosDefaultSettings.starSize {
        didSet {
            settings.starSize = starSize
        }
    }
    
    @IBInspectable var colorFilled: UIColor = CosmosDefaultSettings.colorFilled {
        didSet {
            settings.colorFilled = colorFilled
        }
    }
    
    @IBInspectable var colorEmpty: UIColor = CosmosDefaultSettings.colorEmpty {
        didSet {
            settings.colorEmpty = colorEmpty
        }
    }
    
    @IBInspectable var borderColorEmpty: UIColor = CosmosDefaultSettings.borderColorEmpty {
        didSet {
            settings.borderColorEmpty = borderColorEmpty
        }
    }
    
    @IBInspectable var borderWidthEmpty: Double = CosmosDefaultSettings.borderWidthEmpty {
        didSet {
            settings.borderWidthEmpty = borderWidthEmpty
        }
    }
    
    @IBInspectable var starMargin: Double = CosmosDefaultSettings.starMargin {
        didSet {
            settings.starMargin = starMargin
        }
    }
    
    @IBInspectable var fillMode: Int = CosmosDefaultSettings.fillMode.rawValue {
        didSet {
            settings.fillMode = StarFillMode(rawValue: fillMode) ?? CosmosDefaultSettings.fillMode
        }
    }
    
    @IBInspectable var textSize: Double = CosmosDefaultSettings.textSize {
        didSet {
            settings.textFont = settings.textFont.fontWithSize(CGFloat(textSize))
        }
    }
    
    @IBInspectable var textMargin: Double = CosmosDefaultSettings.textMargin {
        didSet {
            settings.textMargin = textMargin
        }
    }
    
    @IBInspectable var textColor: UIColor = CosmosDefaultSettings.textColor {
        didSet {
            settings.textColor = textColor
        }
    }
    
    @IBInspectable var updateOnTouch: Bool = CosmosDefaultSettings.updateOnTouch {
        didSet {
            settings.updateOnTouch = updateOnTouch
        }
    }
    
    @IBInspectable var minTouchRating: Double = CosmosDefaultSettings.minTouchRating {
        didSet {
            settings.minTouchRating = minTouchRating
        }
    }
    
    /// Draw the stars in interface buidler
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        update()
    }
}


// ----------------------------
//
// CosmosTouchTarget.swift
//
// ----------------------------

import UIKit

/**

Helper function to make sure bounds are big enought to be used as touch target.
The function is used in pointInside(point: CGPoint, withEvent event: UIEvent?) of UIImageView.

*/
struct CosmosTouchTarget {
    static func optimize(bounds: CGRect) -> CGRect {
        let recommendedHitSize: CGFloat = 44
        
        var hitWidthIncrease:CGFloat = recommendedHitSize - bounds.width
        var hitHeightIncrease:CGFloat = recommendedHitSize - bounds.height
        
        if hitWidthIncrease < 0 { hitWidthIncrease = 0 }
        if hitHeightIncrease < 0 { hitHeightIncrease = 0 }
        
        let extendedBounds: CGRect = CGRectInset(bounds,
            -hitWidthIncrease / 2,
            -hitHeightIncrease / 2)
        
        return extendedBounds
    }
}


// ----------------------------
//
// StarFillMode.swift
//
// ----------------------------

import Foundation

/**

Defines how the star is filled when the rating is not an integer number. For example, if rating is 4.6 and the fill more is Half, the star will appear to be half filled.

*/
public enum StarFillMode: Int {
    /// Show only fully filled stars. For example, fourth star will be empty for 3.2.
    case Full = 0
    
    /// Show fully filled and half-filled stars. For example, fourth star will be half filled for 3.6.
    case Half = 1
    
    /// Fill star according to decimal rating. For example, fourth star will be 20% filled for 3.2. By default the fill rate is not applied linearly but corrected (see correctFillLevelForPreciseMode setting).
    case Precise = 2
}


// ----------------------------
//
// StarLayer.swift
//
// ----------------------------

import UIKit

/**

Creates a layer with a single star in it.

*/
struct StarLayer {
    /**
    
    Creates a square layer with given size and draws the star shape in it.
    
    - parameter starPoints: Array of points for drawing a closed shape. The size of enclosing rectangle is 100 by 100.
    
    - parameter size: The width and height of the layer. The star shape is scaled to fill the size of the layer.
    
    - parameter lineWidth: The width of the star stroke.
    
    - parameter fillColor: Star shape fill color. Fill color is invisible if it is a clear color.
    
    - parameter strokeColor: Star shape stroke color. Stroke is invisible if it is a clear color.
    
    - returns: New layer containing the star shape.
    
    */
    static func create(starPoints: [CGPoint], size: Double,
        lineWidth: Double, fillColor: UIColor, strokeColor: UIColor) -> CALayer {
            
            let containerLayer = createContainerLayer(size)
            let path = createStarPath(starPoints, size: size)
            
            let shapeLayer = createShapeLayer(path.CGPath, lineWidth: lineWidth,
                fillColor: fillColor, strokeColor: strokeColor)
            
            let maskLayer = createMaskLayer(path.CGPath)
            
            containerLayer.mask = maskLayer
            containerLayer.addSublayer(shapeLayer)
            
            return containerLayer
    }
    
    /**
    
    Creates a mask layer with the given path shape. The purpose of the mask layer is to prevent the shape's stroke to go over the shape's edges.
    
    - parameter path: The star shape path.
    
    - returns: New mask layer.
    
    */
    static func createMaskLayer(path: CGPath) -> CALayer {
        let layer = CAShapeLayer()
        layer.anchorPoint = CGPoint()
        layer.contentsScale = UIScreen.mainScreen().scale
        layer.path = path
        return layer
    }
    
    /**
    
    Creates the star shape layer.
    
    - parameter path: The star shape path.
    
    - parameter lineWidth: The width of the star stroke.
    
    - parameter fillColor: Star shape fill color. Fill color is invisible if it is a clear color.
    
    - parameter strokeColor: Star shape stroke color. Stroke is invisible if it is a clear color.
    
    - returns: New shape layer.
    
    */
    static func createShapeLayer(path: CGPath, lineWidth: Double, fillColor: UIColor, strokeColor: UIColor) -> CALayer {
        let layer = CAShapeLayer()
        layer.anchorPoint = CGPoint()
        layer.contentsScale = UIScreen.mainScreen().scale
        layer.strokeColor = strokeColor.CGColor
        layer.fillColor = fillColor.CGColor
        layer.lineWidth = CGFloat(lineWidth)
        layer.path = path
        return layer
    }
    
    /**
    
    Creates a layer that will contain the shape layer.
    
    - returns: New container layer.
    
    */
    static func createContainerLayer(size: Double) -> CALayer {
        let layer = CALayer()
        layer.contentsScale = UIScreen.mainScreen().scale
        layer.anchorPoint = CGPoint()
        layer.masksToBounds = true
        layer.bounds.size = CGSize(width: size, height: size)
        return layer
    }
    
    /**
    
    Creates a path for the given star points and size. The star points specify a shape of size 100 by 100. The star shape will be scaled if the size parameter is not 100. For exampe, if size parameter is 200 the shape will be scaled by 2.
    
    - parameter starPoints: Array of points for drawing a closed shape. The size of enclosing rectangle is 100 by 100.
    
    - parameter size: Specifies the size of the shape to return.
    
    - returns: New shape path.
    
    */
    static func createStarPath(starPoints: [CGPoint], size: Double) -> UIBezierPath {
        let points = scaleStar(starPoints, factor: size / 100)
        let path = UIBezierPath()
        path.moveToPoint(points[0])
        let remainingPoints = Array(points[1..<points.count])
        
        for point in remainingPoints {
            path.addLineToPoint(point)
        }
        
        path.closePath()
        return path
    }
    
    /**
    
    Scale the star points by the given factor.
    
    - parameter starPoints: Array of points for drawing a closed shape. The size of enclosing rectangle is 100 by 100.  
    
    - parameter factor: The factor by which the star points are scaled. For example, if it is 0.5 the output points will define the shape twice as small as the original.
    
    - returns: The scaled shape.
    
    */
    static func scaleStar(starPoints: [CGPoint], factor: Double) -> [CGPoint] {
        return starPoints.map { point in
            return CGPoint(x: point.x * CGFloat(factor), y: point.y * CGFloat(factor))
        }
    }
}


