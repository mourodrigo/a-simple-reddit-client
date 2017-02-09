A simple reddit client
===================

Hello there!

Welcome to my simple reddit client example for **Swift 3**.  This project was based on iOS 10.2 has some must-know skills applied on features that compose many of the current and latest mobile application.

----------


Features
-------------
- Present the [/top](https://www.reddit.com/top/) reddit entires on a nice clean and dynamic CollectionView
- Supports Portrait and Landscape for all iOS devices with dynamic columns for each configuration
- Content storing on camera roll / photos 
- Continuous scroll pagination with a "Load more" button ( you shall never leave the timeline muahahaha )

Development method
-------------
- Storyboard with auto-layout for view design, also used for app flow with navigation control and navigation segues.
- Network request for JSON APIs using NSURLSession , URLRequest
- A few NotificationCenter methods for trading information between viewcontrollers
- Singletones for strong reference of network communications and authorization
- Class extension for helper methods reusability
- Extra Info.plist configuration for allowing external request to non https:// protocol
- Extra Info.plist configuration for app launching with query parameters 

----------

This repository is under MIT licence, find it helpful? Share it!

Hope you like it!

Bye!
