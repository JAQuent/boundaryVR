// Temporal order
function create_temporalOrder_stim(probe, target, targetPos, foil1, foil1Pos, foil2, foil2Pos, que) {
    img = new Array();
    img[targetPos] = target;
    img[foil1Pos]  = foil1;
    img[foil2Pos]  = foil2;
    temporalOrder_stim = "<p>" + que + "</p>" + 
                         "<p><img src= '" + probe + "' style='width: 33%'></p>" +
                         "<div class='row'>" +
                         "<div class='threeColumn'>" +
                         "<p style='float: left; font-size: 20pt; text-align: center;'><img src= '" + img[1] + "' style='width:100%'>1</p>" +
                         "</div>" +
                         "<div class='threeColumn'>" +
                         "<p style='float: left; font-size: 20pt; text-align: center;'><img src= '" + img[2] + "' style='width:100%'>2</p>" +
                         "</div>" +
                         "<div class='threeColumn'>" +
                         "<p style='float: left; font-size: 20pt; text-align: center;'><img src= '" + img[3] + "' style='width:100%'>3</p>" +
                         "</div>" +
                         "</div>"
    return temporalOrder_stim;
}

function create_roomType_stim(probe) {
        roomType_stim = "<p>In the video you just watched, in which room did this object appear?</p>" +
                        "<p><img src= '" + probe + "' style='width: 33%'></p>" +
                        "<div class='row'>" +
                        "<div class='twoColumn'>" +
                        "<p style='float: center; font-size: 20pt; text-align: center;'><img src= 'images/stimuli/nw_room.png' style='width:50%'></p>" +
                        "</div>" +
                        "<div class='twoColumn'>" +
                        "<p style='float: center; font-size: 20pt; text-align: center;'><img src= 'images/stimuli/ww_room.png' style='width:50%'></p>" +
                        "</div>" +
                        "</div>" +
                        "<div class='row'>" +
                        "<div class='twoColumn'>" +
                        "<p style='float: center; font-size: 20pt; text-align: center;'>1</p>" +
                        "</div>" +
                        "<div class='twoColumn'>" +
                        "<p style='float: center; font-size: 20pt; text-align: center;'>2</p>" +
                        "</div>" 
    return roomType_stim;
}

function create_tableNum_stim(probe) {
        tableNum_stim = "<p>In the video you just watched, on which table did the object appear?</p>" +
                        "<p><img src= '" + probe + "' style='width: 33%'></p>" +
                        "<img src= 'images/stimuli/nw_table.png' style='width:33%'>" 
    return tableNum_stim;
}