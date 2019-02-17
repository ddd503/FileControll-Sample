//
//  ViewController.swift
//  FileControll-Sample
//
//  Created by kawaharadai on 2019/02/18.
//  Copyright © 2019 kawaharadai. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    @IBOutlet weak var fileCountLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var saveTextView: UITextView!

    private let saveText = "test contents"
    private var createFilePathsDic: [String: String] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func createFile(_ sender: UIButton) {
        create()
    }

    @IBAction func removeFile(_ sender: UIButton) {
        guard !createFilePathsDic.isEmpty, let removeFilePath = createFilePathsDic["\(createFilePathsDic.count - 1)"] else {
            print("not found remove file path or empty createFilePathsDic")
            return
        }
        remove(filePath: removeFilePath)
    }

    @IBAction func editFile(_ sender: UIButton) {
        guard !createFilePathsDic.isEmpty, let seachFileName = textField.text, let filePath = createFilePathsDic[seachFileName] else {
            print("not found file path or empty createFilePathsDic")
            return
        }
        add(filePath: filePath)
    }

    private func create() {
        guard let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            fatalError("not found file path")
        }
        let fileName = "\(createFilePathsDic.count)"
        let filePath = documentDirectoryPath + "/\(fileName).txt"
        let isSuccess = FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
        if isSuccess {
            print("success create file")
            createFilePathsDic[fileName] = filePath
            do {
                try saveText.write(toFile: filePath, atomically: true, encoding: .utf8)
            } catch let error {
                fatalError(error.localizedDescription)
            }
        } else {
            print("failed create file")
        }
        updateCountLabel()
    }

    private func remove(filePath: String) {
        do {
            try FileManager.default.removeItem(atPath: filePath)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        createFilePathsDic.removeValue(forKey: "\(createFilePathsDic.count - 1)")
        updateCountLabel()
    }

    private func add(filePath: String) {
        guard let fileHandle = FileHandle(forUpdatingAtPath: filePath) else {
            print("failed init FileHandle")
            return
        }
        let addText = "\n" + saveTextView.text
        guard let textData = addText.data(using: .utf8) else {
            print("failed get text data")
            return
        }
        // テキストの最後までindexを進める
        fileHandle.seekToEndOfFile()
        // テキストを追加
        fileHandle.write(textData)
        // fileの更新内容を同期(他アクセス用、閉じる前に行う)
        // 参考：http://cocoaapi.hatenablog.com/entry/10010425/NSFileHandle
        fileHandle.synchronizeFile()
        fileHandle.closeFile()

        saveTextView.text = ""
    }

    private func updateCountLabel() {
        fileCountLabel.text = "\(createFilePathsDic.count)"
    }

}

