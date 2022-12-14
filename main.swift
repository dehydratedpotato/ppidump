//
//    main.swift
//    ppidump
//
//    MIT License
//
//    Copyright (c) 2022 BitesPotatoBacks
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.
//

import AppKit

let MM_PER_IN = 25.4

// nice struct to store data
struct Display {
    let name: String
    let id:   CGDirectDisplayID
    let diag: CGFloat
    let realP:CGSize
    let ppi:  Int
}

// try to get the diagonal size (in inches) of a display
func getPhysicalSize(of id: CGDirectDisplayID) -> CGFloat {
    let size = CGDisplayScreenSize(id)
    let diag = CGFloat(sqrt(pow(size.width / MM_PER_IN, 2) + pow(size.height / MM_PER_IN, 2)))
    return round(diag * 100) / 100
}

// try to get the physical pixels of a display
func getPhysicalPixels(of id: CGDirectDisplayID) -> CGSize? {
    if let modes = CGDisplayCopyAllDisplayModes(id, nil)  {
        let modes = modes as! [Any] // force downcast to prevent ruined dict vals
        var res: [CGSize] = []
        
        for i in 0..<modes.count {
            let mode = modes[i] as! CGDisplayMode // this data should always be a CGDisplayMode
            if mode.pixelWidth == mode.width {
                res.append(CGSize(width: mode.width, height: mode.height))
            }
        }
        
        res = res.sorted(by: { ($0.width + $0.height) > ($1.width + $1.height) }) // biggest px size
        
        if let first = res.first {
            return first
        }
    }
    
    return nil
}

func help() {
    print(String(format: "usage:", getprogname()))
    print(String(format: "  %s", getprogname()))
    print(String(format: "  %s [width_px height_px diag_size]", getprogname()))
    exit(0)
}

func err(_ s: String) {
    print(s)
    exit(0)
}

var displays: [Display] = []

// don't mind my poor handling of cmd args... but hey, it works ;)
if CommandLine.arguments.count == 2 && (CommandLine.arguments[1] == "-h" || CommandLine.arguments[1] == "--help") {
    help()
} else {
    // if no args, load data for every display
    if CommandLine.arguments.count == 1 {
        for idx in 0..<NSScreen.screens.count {
            let id = NSScreen.screens[idx].deviceDescription[NSDeviceDescriptionKey(rawValue: "NSScreenNumber")] as! CGDirectDisplayID
            let nm = NSScreen.screens[idx].localizedName
            
            if let realP = getPhysicalPixels(of: id) {
                let diagS = getPhysicalSize(of: id)
                let diagP = CGFloat(sqrt(pow(realP.width, 2) + pow(realP.height, 2)))
                
                displays.append(Display(name:  nm,
                                        id:    id,
                                        diag:  diagS,
                                        realP: realP,
                                        ppi:   Int(round(diagP / diagS))))
            } else {
                err("error: failed to find real pixels for \(nm) (display \(id))")
            }
        }
        
        if displays.count != 0 {
            for d in displays {
                print(String(format: "\u{001B}[1;36m%@ (%dx%d Physical at %.1f\") =\u{001B}[0;0m %i ppi",
                             d.name,
                             Int(d.realP.width),
                             Int(d.realP.height),
                             d.diag,
                             d.ppi))
            }
        } else {
            err("error: display array empty")
        }
        
    } else if CommandLine.arguments.count == 4 { // if there are enough args for a manual input, calc manually
        let realP_w = CGFloat(atof(CommandLine.arguments[1]))
        let realP_h = CGFloat(atof(CommandLine.arguments[2]))
        let diagS   = CGFloat(atof(CommandLine.arguments[3]))
        let diagP   = CGFloat(sqrt(pow(realP_w, 2) + pow(realP_h, 2)))
        let ppi     = Int(round(diagP / diagS))
        
        print(String(format: "\u{001B}[1;36mManual Input (%dx%d Physical at %.1f\") =\u{001B}[0;0m %i ppi",
                     Int(realP_w),
                     Int(realP_h),
                     diagS,
                     ppi))
        
    } else if CommandLine.arguments.count > 1 && CommandLine.arguments.count != 4 { // return help with bad arg count
        help()
    }
}


