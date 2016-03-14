/*
 * Copyright (C) 2004-2011 Geometer Plus <contact@geometerplus.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 * 02110-1301, USA.
 */

import QtQuick 1.0
//import com.nokia.meego 1.0
//import com.nokia.extras 1.0
import com.syberos.basewidgets 2.0
import org.fbreader 0.14

CPage {
	id: root
	property variant handler
//	rejectButtonText: qsTr("Cancel")

     CSlideListView {
        id: view
		anchors { leftMargin: 14; fill: parent; rightMargin: 14 }
        model: VisualDataModel {
			id: visualModel
			rootIndex: dirModel.rootIndex
            model: FileSystemModel {
				id: dirModel
				rootPath: handler.directoryPath
			}
            delegate: CSlideDelegate {
				id: itemDelegate
				// TODO: Find why dirModel ignores filter QDir::NoDot
				visible: model.directory
						 ? model.fileName != "."
						 : (root.handler !== null && root.handler.check(model.filePath))
				height: visible ? 88 : 0 // UI.LIST_ITEM_HEIGHT
				onClicked: {
					if (model.directory) {
						dirModel.rootPath = model.filePath
					} else {
						console.log("finish", dirModel.rootPath, model.fileName)
						handler.directoryPath = dirModel.rootPath;
						handler.fileName = model.filePath;
						handler.finish();
						accept();
					}
				}
//				MoreIndicator {
//					id: indicator
//					anchors { verticalCenter: parent.verticalCenter; right: parent.right }
//					visible: model.directory
//				}
			}
        }
    }
}
