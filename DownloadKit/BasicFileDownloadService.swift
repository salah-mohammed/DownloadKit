//
//  BasicFileDownloadService.swift
//  DownloadKit
//
//  Created by SalahMohamed on 03/11/2022.
//  Copyright © 2022 Salah. All rights reserved.
//

import UIKit
open class BasicFileDownloadService:ParentFileDownloadService{
   open var localFileUrl:URL?
    override func internalLocalFileUrl()->URL?{
    return self.localFileUrl
    }
}
