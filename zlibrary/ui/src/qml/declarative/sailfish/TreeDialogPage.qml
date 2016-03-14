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
import com.syberos.basewidgets 2.0
import org.fbreader 0.14

CPage {
    id: root

    //allowedOrientations: Orientation.All

    property variant handler
    property variant rootIndex
    property bool isTreeRoot: true
    property Item contextMenu
    property bool fetchingChildren: false

    VisualDataModel {
        id: visualModel
        model: root.handler
        rootIndex: root.rootIndex ? root.rootIndex : visualModel.rootIndex
        delegate: MouseArea {
            id: listItem
            height: 100//Theme.itemSizeLarge
            width:  parent.width

            Row {
                id: row
                spacing: 20//Theme.paddingLarge
                Image {
                    id: icon
                    source: model.iconSource
                    anchors.verticalCenter: parent.verticalCenter
                    sourceSize.width: 50//Theme.iconSizeLarge
                    sourceSize.height: 50//Theme.iconSizeLarge
                }
                Column{
                    anchors.verticalCenter: parent.verticalCenter
                    CLabel {
                        text: model.title
                        font.pixelSize: 30//Theme.fontSizeLarge
                    }
                    CLabel {
                        text: model.subtitle
                        font.pixelSize: 30 //Theme.fontSizeExtraSmall
                        color: "#444444"//Theme.secondaryColor
                    }
                }
            }

            onClicked: {
                console.log("title", model.title,
                            "activatable", model.activatable,
                            "page", model.page)
                if (model.activatable) {
                    if (root.handler.activate(visualModel.modelIndex(index))) {
                        root.handler.finish();
                    }
                } else {
                    var modelIndex = visualModel.modelIndex(index)
                    if (model.page) {
                        var args = {
                            "handler": root.handler,
                            "modelIndex": modelIndex,
                            "imageSource": model.iconSource
                        }
                        gAppUtils.pageStackWindow.pageStack.push(Qt.resolvedUrl("TreeDialogItemPage.qml"), args)
                    } else {
                        fetchChildren(modelIndex)
                    }
                }
            }

//            onEditingChanged: {
//                if(editing){
//                    console.log("Press-and-hold", model.title)
//                    console.log("index",index)
//                    var modelIndex = visualModel.modelIndex(index)
//                    console.log("modelIndex",modelIndex)
//                    var actions = root.handler.actions(modelIndex)
//                    console.log("item actions:", actions)
//                    if (actions.length > 0){
//                        if (!contextMenu)
//                            contextMenu = contextMenuComponent.createObject(root,
//                                                                            {"actions": actions, "modelIndex": modelIndex})
//                        contextMenu.show(listItem);
//                    }
//                }
//            }

            onPressAndHold: {
                console.log("Press-and-hold", model.title)
                var modelIndex = visualModel.modelIndex(index)
                var actions = root.handler.actions(modelIndex)
                console.log("item actions:", actions)
                if (actions.length > 0){
                    if (!contextMenu)
                        contextMenu = contextMenuComponent.createObject(root,
                                    {"actions": actions, "modelIndex": modelIndex})
                    contextMenu.show(listItem);
                }
            }
        }

//        Component.onCompleted: {
//            console.log ("visualModel.count", visualModel.count)
//            if (!root.isTreeRoot && visualModel.count < 1 ){ // TODO: !root.isTreeRoot is 1 wierd hack; visualModel.count returns 0 on rootNode. why?
//                fetchChildren()
//            }
//        }
    }

    property variant modelIndexToFetch

    function fetchChildren(modelIndex) {
        fetchingChildren = true
        modelIndexToFetch = modelIndex
        root.handler.fetchChildren(modelIndex)
    }

    Connections {
        target: fetchingChildren ? handler : null
//  currently no progressChanged signal when fetching children, so this is commented out
//        onProgressChanged: {
//            var value, maximumValue
//            console.log("on progress changed", value, maximumValue)
//            if (value >= 0) {
//                if (maximumValue)
//                    busyLabel.text = value + " / " + maximumValue
//                else
//                    busyLabel.text = value
//            }
//        }
        onProgressFinished: {
            var error = ""
            if (!modelIndexToFetch || !fetchingChildren){
                console.log("onProgressFinished but not fetching children???")
                return
            }

            fetchingChildren = false
            if (error === "") {
                var args = {
                    "handler": root.handler,
                    "rootIndex": modelIndexToFetch,
                    "isTreeRoot": false
                }
                modelIndexToFetch = null
                var page = gAppUtils.pageStackWindow.pageStack.push(Qt.resolvedUrl("TreeDialogPage.qml"), args)
            } else {
                console.log(error)
            }
        }
    }

//    SilicaListView {
      ListView{
        id: listView
        anchors.fill: parent
//        header: PageHeader { title: "" /*"Library"*/ }
        model: visualModel
//        VerticalScrollDecorator {}
//        ViewPlaceholder {
//            enabled: listView.count === 0
//            text: "Empty"
//        }
    }

    Column {
        visible: fetchingChildren
        anchors.centerIn: parent
        spacing: 30//Theme.paddingLarge
        CIndicator {
            id: busyIndicator
            running: visible
            anchors.horizontalCenter: parent.horizontalCenter
            sizeMode: 0
        }
        CLabel {
            id: busyLabel
            anchors.horizontalCenter: parent.horizontalCenter
            //color: Theme.secondaryColor
        }
    }

    Component {
        id: contextMenuComponent

        ContextMenu {
//        Rectangle {
            id: menu
//            width: parent.width
//            height: 100
            property variant actions
            property variant modelIndex
            property bool hasChildren: false

            Repeater {
                model: actions
                CButton {
                    width: 100
                    height: 100
                    text: modelData
                    visible: root.handler.isVisibleAction(modelIndex, index)
                    onClicked: root.handler.run(modelIndex, index)
                }
            }
        }
    }

    Component.onCompleted: {
        console.log("TreeDialogPage:Component completed")
        if (root.isTreeRoot) {
//            handler.onFinished.connect(function() {
//                console.log("got tree dialog finished signal. closing tree dialog")
//                handler = null // stop onStatusChanged triggering handler.finished() signal
//                popPage()
//            })
        }
    }

    /*
    * Pop this page and all after
    */
    function popPage() {
        var previousPage = pageStack.previousPage(root)
        pageStack.pop(previousPage, PageStackAction.Immediate)
    }

//    onStatusChanged: {
//        if (isTreeRoot && status === PageStatus.Inactive && pageStack.depth === 1){
//            if (handler)
//                handler.finish()
//        }
//    }
}
