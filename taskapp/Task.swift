//
//  Task.swift
//  taskapp
//
//  Created by 小島大舗 on 2020/08/02.
//  Copyright © 2020 daisuke.kojima. All rights reserved.
//

import RealmSwift

class Task: Object {
    
    //idの設定
    @objc dynamic var id = 0
    
    //タイトル
    @objc dynamic var title = ""
    
    //内容
    @objc dynamic var contents = ""
    
    //日時
    @objc dynamic var date = Date()
    
    //カテゴリー
    @objc dynamic var category = ""
    
    //プライマリーキーの設定
    override static func primaryKey() -> String? {
        return "id"
    }
    
    
}
