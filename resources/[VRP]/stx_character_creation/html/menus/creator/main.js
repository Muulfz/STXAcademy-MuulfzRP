let Misc = require('copsnrobbers/core/misc.js');
let Client = require('copsnrobbers/core/client.js');
let Game = require('copsnrobbers/core/game.js');

const overlayTypes = {"1": ["eyebrows", "facialHair", "chestHair"], "2":["blush", "lipstick"]};
let creator = false, creator_menu = false;
let charData = {
    charGender : 0,
    charDataHair : 0,
    charDataHairColor : 0,
    charDataHairColorHighlight : 0,
    charDataEyeColor : 0,
    charDataFace : {
        noseWidth : 0.0,
        noseHeight : 0.0,
        noseLength : 0.0,
        noseBridge : 0.0,
        noseTip : 0.0,
        noseShift : 0.0,
        browWidth : 0.0,
        browHeight : 0.0,
        cheekboneHeight : 0.0,
        cheekboneWidth : 0.0,
        cheeksWidth : 0.0,
        eyesWidth : 0.0,
        lipsWidth : 0.0,
        jawWidth : 0.0,
        jawHeight : 0.0,
        chinLength : 0.0,
        chinPosition : 0.0,
        chinWidth : 0.0,
        chinHeight : 0.0,
        neckHeight : 0.0
    },
    charDataParents : {
        shapeFirstID : 0,
        shapeSecondID : 0,
        shapeThirdID : 0,
        skinFirstID : 0,
        skinSecondID : 0,
        skinThirdID : 0,
        shapeMix : 0.5,
        skinMix : 0.5,
        thirdMix : 0.0
    },
    charDataOverlay : {
        blemishes : 0,
        facialHair : 0,
        eyebrows : 0,
        ageing: 0,
        makeup: 0,
        blush: 0,
        complexion: 0,
        sunDamage: 0,
        lipstick: 0,
        freckles: 0,
        chestHair: 0,
        bodyBlemishes: 0,
        addBodyBlemishes: 0
    },
    charDataOverlayColor : {
        blemishes : {"color": 0, "color2": 0},
        facialHair : {"color": 0, "color2": 0},
        eyebrows : {"color": 0, "color2": 0},
        ageing: {"color": 0, "color2": 0},
        makeup: {"color": 0, "color2": 0},
        blush: {"color": 0, "color2": 0},
        complexion: {"color": 0, "color2": 0},
        sunDamage: {"color": 0, "color2": 0},
        lipstick: {"color": 0, "color2": 0},
        freckles: {"color": 0, "color2": 0},
        chestHair: {"color": 0, "color2": 0},
        bodyBlemishes: {"color": 0, "color2": 0},
        addBodyBlemishes: {"color": 0, "color2": 0}
    }
}

mp.events.add({
    "characterCreator": (force = false, undershirt = 15, torso = 15, clothes = 15) => {
        creator = (!force) ? !creator : true;

        let editorCamera = mp.cameras.new('default', Client.player.position, new mp.Vector3(402.8966979980469, -996.6461791992188, -99.00025939941406), 30);

        if(creator) {
            Client.player.setComponentVariation(11, undershirt, 0, 2);
            Client.player.setComponentVariation(3, torso, 0, 2);
            
            if(!creator_menu) creator_menu = Game.browser("package://copsnrobbers/menus/creator/index.html");
            editorCamera.attachToPedBone(Client.player.handle, 31086, 0, 1, ((Client.player.isMale()) ? 0 : 0.1), true);
            editorCamera.setRot(0, 0, Client.player.getHeading() - 180,2);

            editorCamera.setActive(true);
            Game.cam.renderScriptCams(true, false, 0, true, false);
            Client.setCursor(true);
            Game.chat(false);
            Game.blur(false);
            Client.player.freezePosition(creator);
            if(!force) creator_menu.executeLog(`randomize()`);
            Client.call('setDlcInfo');
        } else {
            if(creator_menu) {
                creator_menu.destroy();

                editorCamera.setActive(false);
                Game.cam.renderScriptCams(false, false, 0, true, false);
                Client.call('playerLoggedIn');
            }
        }
    },
    "finishCreator": () => {
        Client.remote('createCharacter', JSON.stringify(charData));
        Client.call('characterCreator', false);
    },
    "charDataParents": (array) => {
        let keys = Object.keys(charData.charDataParents);
        let args = JSON.parse(array);

        args.forEach(function(val, idx, arr) {
            charData.charDataParents[keys[idx]] = val;
        });

        Client.player.setHeadBlendData(...args, true);
    },
    "charDataFace": (array) => {
        let keys = Object.keys(charData.charDataFace);
        let args = JSON.parse(array);

        args.forEach(function(val, idx, arr) {
            charData.charDataFace[keys[idx]] = val;

            Client.player.setFaceFeature(idx, val);
        });
    },
    "charDataOverlay": (array) => {
        let keys = Object.keys(charData.charDataOverlay);
        let args = JSON.parse(array);

        args.forEach(function(val, idx, arr) {
            val -= 1;
            charData.charDataOverlay[keys[idx]] = val;

            Client.player.setHeadOverlay(idx, val, 1, 0, 0);
        });

        let y = 0;
        Object.entries(charData.charDataOverlayColor).forEach(([key, value]) => {
            let type = 0;

            Object.entries(overlayTypes).forEach(([keyz, valuez]) => {
                if(type == 0) type = valuez.includes(key) ? parseInt(keyz) : 0;
            });

            Client.player.setHeadOverlayColor(y, type, parseInt(value.color), parseInt(value.color2));
            y++;
        });
    },
    "charDataEyeColor": (index) => {
        charData.charDataEyeColor = index;

        Client.player.setEyeColor(index);
    },
    "charDataOverlayColor": (array, type) => {
        let keys = Object.keys(charData.charDataOverlayColor);
        let args = JSON.parse(array);

        args.forEach(function(val, idx, arr) {
            let type = 0;
            charData.charDataOverlayColor[keys[idx]] = val;

            Object.entries(overlayTypes).forEach(([key, value]) => {
                if(type == 0) type = value.includes(keys[idx]) ? parseInt(key) : 0;
            });

            Client.player.setHeadOverlayColor(idx, type, parseInt(val.color), parseInt(val.color2));
        });
    },
    "charDataHair": (index) => {
        charData.charDataHair = index;

        Client.remote('setHair', index);
    },
    "charDataHairColor": (color, highlight) => {
        charData.charDataHairColor = color;
        charData.charDataHairColorHighlight = highlight;
        
        Client.player.setHairColor(color, highlight);
    },
    "charSetGender": (...args) => {
        if(typeof Client.creatorTimeout !== 'undefined') clearTimeout(Client.creatorTimeout);
        charData.charGender = args[0];
        Client.remote('setGender', args[0]);

        Client.creatorTimeout = setTimeout(function() {
            let blendData = [];
            Object.entries(charData.charDataParents).forEach(([key, value]) => {7
                blendData.push(value);
            });

            Client.player.setHeadBlendData(...blendData, true);

            let i = 0;
            Object.entries(charData.charDataFace).forEach(([key, value]) => {
                Client.player.setFaceFeature(i, value);
                i++;
            });

            let x = 0;
            Object.entries(charData.charDataOverlay).forEach(([key, value]) => {
                Client.player.setHeadOverlay(x, value, 1, 0, 0);
                x++;
            });

            let y = 0;
            Object.entries(charData.charDataOverlayColor).forEach(([key, value]) => {
                let type = 0;
    
                Object.entries(overlayTypes).forEach(([keyz, valuez]) => {
                    if(type == 0) type = valuez.includes(key) ? parseInt(keyz) : 0;
                });

                Client.player.setHeadOverlayColor(y, type, parseInt(value.color), parseInt(value.color2));
                y++;
            });

            Client.player.setEyeColor(charData.charDataEyeColor);
            Client.player.setHairColor(charData.charDataHairColor, charData.charDataHairColorHighlight);
        }, 70);
    }
});