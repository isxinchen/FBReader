import QtQuick 2.0
import com.syberos.basewidgets 2.0
import org.fbreader 0.14

CPage {
    id: root

    //allowedOrientations: Orientation.All

//    SilicaFlickable {
    Flickable {
        id: flickable
        anchors.fill: parent

        BookView {
           id: bookView
           anchors.fill: parent
           holder: objectHolder
           Component.onCompleted: {
               objectHolder.bookView = bookView
           }

           MouseArea {
               anchors.fill: parent
               onPressed: {
//                   toolbar.hide()
                   toolbar.visible = false
                   objectHolder.handlePress(mouse.x, mouse.y)
               }
               onReleased: objectHolder.handleRelease(mouse.x, mouse.y)
               // TODO enable text selection?
//               onPositionChanged: {
//                   if (pressed)
//                       objectHolder.handleMovePressed(mouse.x, mouse.y)
//                   else
//                       objectHolder.handleMove(mouse.x, mouse.y)
//               }
           }
        }
Rectangle{
    anchors.top: parent.top
    anchors.topMargin: 100
    width: parent.width
    height: 800
    color: "#000000"
Column {
    anchors.fill: parent
//        PullDownMenu {
//            id: mainMenu
//            width: parent.width
//            onActiveChanged: {
//                if ( active ){
//                    applicationInfo.menuBar.recheckItems()
//                }
//            }
            Repeater {
                model: applicationInfo.menuBar !== null ? applicationInfo.menuBar.items : null
//                MenuItem {
//                    parent: mainMenu
//                    text: modelData
//                    enabled: applicationInfo.menuBar.enabledItems.indexOf(modelData) !== -1
//                    visible: applicationInfo.menuBar.visibleItems.indexOf(modelData) !== -1
//                    onClicked: applicationInfo.menuBar.activate(index)
//                }
                CLabel {
                    id: menuItem
                    property bool down
                    property bool highlighted

                    signal clicked

                    property int __silica_menuitem
                    anchors.leftMargin: 20
//                    parent: mainMenu
                    text: modelData
                    width: 50
                    height: 50
                    enabled: applicationInfo.menuBar.enabledItems.indexOf(modelData) !== -1
                    visible: applicationInfo.menuBar.visibleItems.indexOf(modelData) !== -1
                    onClicked: applicationInfo.menuBar.activate(index)

//                    width: parent ? parent.width : Screen.width
//                    // Reduce height if inside pulley menu content item
//                    height: parent && parent.hasOwnProperty('__silica_pulleymenu_content') ? Theme.itemSizeExtraSmall : Theme.itemSizeSmall
//                    horizontalAlignment: Text.AlignHCenter
//                    verticalAlignment: Text.AlignVCenter
//                    color: enabled ? (down || highlighted ? Theme.primaryColor : Theme.highlightColor) : Theme.secondaryHighlightColor
                }
            }
//        }
}
    }
    }

    Connections {
        target: applicationInfo
//        onMainMenuRequested: {
            // TODO how can we show flickable menu without acutally flicking?
//                flickable.scrollToBottom() // does not work
//                flickable.scrollToTop()
//        }
//        onActionsChanged: {
//            var actions
//            console.log("actionsChanged", actions)
//            for (var i in applicationInfo.actions) {
//                var action = applicationInfo.actions[i]
//                if (action.enabled && action.visible){
//                    toolbar.show()
//                    return
//                }
//            }
//            toolbar.hide()
//        }
    }


//    DockedPanel {
    Rectangle {
        id: toolbar
//            width: root.isPortrait ? parent.width : Theme.itemSizeExtraLarge + Theme.paddingLarge
//            height: root.isPortrait ? Theme.itemSizeExtraLarge + Theme.paddingLarge : parent.height
//            dock: root.isPortrait ? Dock.Top : Dock.Left
        width: parent.width
//        height: Theme.itemSizeExtraLarge
        height: 100
        anchors.bottom: parent.bottom
        color: "#333333"
//        dock: Dock.Bottom
//        open: false
        Flow {
            anchors.centerIn: parent
            spacing: 20
            Repeater {
                id: repeater
                model: applicationInfo.actions
//                IconButton {
                CButton{
//                    iconSource: "image://theme/icon-m-" + modelData.platformIconId
                    text: modelData.platformIconId
                    width: 50
                    height: 50
                    visible: modelData.visible
                    enabled: modelData.enabled
                    onClicked: modelData.activate()
                    
                    onEnabledChanged: {
                        // show toolbar on item enabled changed. (eg as a result of 'Find' action)
//                        console.log("enabled changed", enabled)
                        if (enabled){
                            toolbar.visible = true
                        }
                    }
    
                    onVisibleChanged: {
//                        console.log("visible changed", visible)
//                        if (visible){
//                            toolbar.show()
//                        }
                    }
                }
            }
        }
        
        Component.onCompleted: {
//            toolbar.hide()
            toolbar.visible = false
        }
    }
    // use mousearea to show toolbar or not? mouse area hides progress bar unclickable
    MouseArea {
        id: toolbarArea
        anchors.bottom: parent.bottom
        width: parent.width
        height: toolbarArea.height
//        enabled: !toolbar.visible
        onClicked: {
            toolbar.visible = !toolbar.visible
        }
    }

    onStatusChanged: {
        if(status == CPageStatus.Show){
            applicationInfo.menuBar.activate(3)
        }
    }

}
