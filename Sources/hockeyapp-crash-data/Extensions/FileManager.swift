//
//  FileManager.swift
//  hockeyapp-crash-data
//
//  Created by Nuno Grilo on 29/01/2019.
//

import Foundation

extension FileManager {
    
    var scriptDirectory: String? {
        let cwd = FileManager.default.currentDirectoryPath
        print("script run from:\n" + cwd)
        
        let script = CommandLine.arguments[0];
        print("\n\nfilepath given to script:\n" + script)
        
        //get script working dir
        if script.hasPrefix("/") { //absolute
            let path = (script as NSString).deletingLastPathComponent
            print("\n\nscript at:\n" + path)
            return path
        } else {
            let urlCwd = URL(fileURLWithPath: cwd)
            if let path = URL(string: script, relativeTo: urlCwd)?.path {
                let path = (path as NSString).deletingLastPathComponent
                print("\n\nscript at:\n" + path)
                return path
            }
        }
        return nil
    }
    
}
