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

import QtQuick 2.0
//import Sailfish.Silica 1.0
import com.syberos.basewidgets 2.0
import org.fbreader 0.14

CPage {
    id: root

//    allowedOrientations: Orientation.All

    property variant handler
    property variant modelIndex
    property variant imageSource
    property bool hasProgress: false

    Flickable {
        anchors.fill: parent
        contentHeight: contentColumn.height

        Column {
            id: contentColumn
            width: parent.width

//            PageHeader {
//                title: dialogContent.content.title // TODO: a title instead of '??????'
//            }

            Column {
                spacing: 10//Theme.paddingMedium
                anchors {
//                    leftMargin: Theme.paddingLarge
//                    rightMargin: Theme.paddingLarge
                    left: parent.left
                    right: parent.right
                }

                Image {
                    id: image
                    source: imageSource
        //            sourceSize.width: parent.width / 2
                    width: parent.width / 2
                    fillMode: Image.PreserveAspectFit
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                DialogContent {
                    id: dialogContent
                    content: root.handler.createPageContent(root.modelIndex)
                    width: parent.width
                }

                Column {
                    id: buttons
                    width: parent.width
                    Repeater {
                        id: repeater
                        model: root.handler.actions(root.modelIndex)
                        CButton {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData
                            onClicked: {
                                console.log("TreeDialogItemPage: root.handler", root.handler)
                                console.log("TreeDialogItemPage: button clicked")
                                console.log("TreeDialogItemPage: root.modelIndex", root.modelIndex, "index", index, "modelData", modelData)

                                root.handler.run(root.modelIndex, index)
                                buttons.recheckActions()
                            }
                            Component.onCompleted: {
                                console.log("button completed", index, modelData, root.handler.isVisibleAction(root.modelIndex, index))
                            }
                        }
                    }
                    
                    Component.onCompleted: {
                        recheckActions()
                    }
                    
                    function recheckActions() {
                        var hasOngoingAction = root.handler.hasOngoingAction(root.modelIndex)
                        for (var i=0; i < repeater.count; i++) {
                            var button = repeater.itemAt(i)
                            button.visible = root.handler.isVisibleAction(root.modelIndex, i)
                            button.enabled = !hasOngoingAction
                        }
                    }
                }
            }
            
            CProgressBar {
                id: progressBar
                width: parent.width
//                label: indeterminate ? "" : value + "%"
//                maximumValue: 100
                value: value
                maximum: 100
//                indeterminate: true
//                valueText: indeterminate ? "" : value + "/" + maximumValue
                visible: root.handler.hasOngoingAction(root.modelIndex)
            }
        }
    }

    Connections {
        target: handler
        onProgressChanged: {
            var value, maximumValue
//            console.log("on progress changed", value, maximumValue)
            // only show progressbar if this book node has ongoing action
            // this signal is recieved regardless of the source node
            if (root.handler.hasOngoingAction(root.modelIndex)){
                console.log("TreeDialogPage:onProgressChanged:", "value", value, "maximumValue", maximumValue)
                progressBar.indeterminate = maximumValue === -1
                progressBar.value = Math.round(100 * value / maximumValue)
                progressBar.visible = true
            }
        }
        onProgressFinished: {
            var error

            console.log("TreeDialogPage:onProgressFinished:handler", handler)

            if (error !== "") console.log("progress finished with error:", error)
            console.assert(!root.handler.hasOngoingAction(root.modelIndex))
            console.log("TreeDialogPage:onProgressFinished:handler", handler)
            progressBar.visible = false
            buttons.recheckActions()
        }
    }

    Component.onCompleted: {
        console.log("TreeDialogItemPage",
                    "handler", handler,
                   "title", handler.title,
                   "content.title", dialogContent.content.title,
                   "imageSource", imageSource)
    }
}
