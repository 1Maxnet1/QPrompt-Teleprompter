/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2020-2021 Javier O. Cordero Pérez
 **
 ** This file is part of QPrompt.
 **
 ** This program is free software: you can redistribute it and/or modify
 ** it under the terms of the GNU General Public License as published by
 ** the Free Software Foundation, either version 3 of the License, or
 ** (at your option) any later version.
 **
 ** This program is distributed in the hope that it will be useful,
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 ** GNU General Public License for more details.
 **
 ** You should have received a copy of the GNU General Public License
 ** along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **
 ****************************************************************************/

import QtQuick 2.15
import QtQuick.Window 2.15
import QtQml.Models 2.15
//import QtGraphicalEffects 1.15
import org.kde.kirigami 2.9 as Kirigami

Item {
    id: viewport
    
    property alias prompter: prompter
    property alias editor: prompter.editor
    property alias document: prompter.document
    property alias countdown: countdown
    property alias overlay: overlay
    property alias prompterBackground: prompterBackground
    property alias timer: timer
    //property bool project: true

    anchors.fill: parent
    //layer.enabled: true
    // Undersample
    //layer.mipmap: true
    // Oversample
    //layer.samples: 2
    //layer.smooth: true
    // Make texture the size of the largest destinations.
    //layer.textureSize: Qt.size(projectionWindow.width, projectionWindow.height)
    
    Countdown {
        id: countdown
        z: 4
        anchors.fill: parent
    }
    
    ReadRegionOverlay {
        id: overlay
        z: 2
        anchors.fill: parent
    }
    
    TimerClock {
       id: timer
       z: 3
       anchors.fill: parent
    }
    
    Prompter {
        id: prompter
        property double delta: 16
        anchors.fill: parent
        z: 1
        textColor: colorDialog.color
        fontSize:  (prompter.state==="editing" && !prompter.__wysiwyg) ? (Math.pow(editorToolbar.fontSizeSlider.value/185,4)*185) : (Math.pow(editorToolbar.fontWYSIWYGSizeSlider.value/185,4)*185)*prompter.__vw/10
        //Math.pow((fontSizeSlider.value*prompter.__vw),3)
    }
    //FastBlur {
    //anchors.fill: prompter
    //source: prompter
    //radius: 32
    //radius: 0
    //}

    PrompterBackground {
        id: prompterBackground
        z: 0
    }
}
