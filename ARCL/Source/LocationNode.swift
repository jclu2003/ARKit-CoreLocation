//
//  LocationNode.swift
//  ARKit+CoreLocation
//
//  Created by Andrew Hart on 02/07/2017.
//  Copyright © 2017 Project Dent. All rights reserved.
//

import Foundation
import SceneKit
import CoreLocation

/// This node type enables the client to have access to the view or image that was used to initialize the `LocationAnnotationNode`.
open class AnnotationNode: SCNNode {
    public var view: UIView?
    public var image: UIImage?

    public init(view: UIView?, image: UIImage?) {
        super.init()
        self.view = view
        self.image = image
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// A location node can be added to a scene using a coordinate.
///
/// Its scale and position should not be adjusted, as these are used for scene layout purposes
/// To adjust the scale and position of items within a node, you can add them to a child node and adjust them there
open class LocationNode: SCNNode {
    /// Location can be changed and confirmed later by SceneLocationView.
    public var location: CLLocation!

    /// A general purpose tag that can be used to find nodes already added to a SceneLocationView
    public var tag: String?

    /// Whether the location of the node has been confirmed.
    /// This is automatically set to true when you create a node using a location.
    /// Otherwise, this is false, and becomes true once the user moves 100m away from the node,
    /// except when the locationEstimateMethod is set to use Core Location data only,
    /// as then it becomes true immediately.
    public var locationConfirmed = false

    /// Whether a node's position should be adjusted on an ongoing basis
    /// based on its' given location.
    /// This only occurs when a node's location is within 100m of the user.
    /// Adjustment doesn't apply to nodes without a confirmed location.
    /// When this is set to false, the result is a smoother appearance.
    /// When this is set to true, this means a node may appear to jump around
    /// as the user's location estimates update,
    /// but the position is generally more accurate.
    /// Defaults to true.
    public var continuallyAdjustNodePositionWhenWithinRange = true

    /// Whether a node's position and scale should be updated automatically on a continual basis.
    /// This should only be set to false if you plan to manually update position and scale
    /// at regular intervals. You can do this with `SceneLocationView`'s `updatePositionOfLocationNode`.
    public var continuallyUpdatePositionAndScale = true

    public init(location: CLLocation?) {
        self.location = location
        self.locationConfirmed = location != nil
        super.init()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

open class LocationAnnotationNode: LocationNode {
    /// Subnodes and adjustments should be applied to this subnode
    /// Required to allow scaling at the same time as having a 2D 'billboard' appearance
    public let annotationNode: AnnotationNode

    /// Whether the node should be scaled relative to its distance from the camera
    /// Default value (false) scales it to visually appear at the same size no matter the distance
    /// Setting to true causes annotation nodes to scale like a regular node
    /// Scaling relative to distance may be useful with local navigation-based uses
    /// For landmarks in the distance, the default is correct
    public var scaleRelativeToDistance = false

    public init(location: CLLocation?, image: UIImage) {
        let plane = SCNPlane(width: image.size.width / 100, height: image.size.height / 100)
        plane.firstMaterial!.diffuse.contents = image
        plane.firstMaterial!.lightingModel = .constant

        annotationNode = AnnotationNode(view: nil, image: image)
        annotationNode.geometry = plane

        super.init(location: location)

        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        constraints = [billboardConstraint]

        addChildNode(annotationNode)
    }

    /// Use this constructor to add a UIView as an annotation
    /// UIView is more configurable then a UIImage, allowing you to add background image, labels, etc.
    ///
    /// - Parameters:
    ///   - location: The location of the node in the world.
    ///   - view: The view to display at the specified location.
    public init(location: CLLocation?, view: UIView) {
        let plane = SCNPlane(width: view.frame.size.width / 100, height: view.frame.size.height / 100)
        plane.firstMaterial!.diffuse.contents = view
        plane.firstMaterial!.lightingModel = .constant

        annotationNode = AnnotationNode(view: view, image: nil)
        annotationNode.geometry = plane

        super.init(location: location)

        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        constraints = [billboardConstraint]

        addChildNode(annotationNode)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
