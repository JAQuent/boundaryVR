// Temporal order
function create_temporalOrder_stim(probe, target, targetPos, foil1, foil1Pos, foil2, foil2Pos, que, width, height) {
    img = new Array();
    img[targetPos] = target;
    img[foil1Pos]  = foil1;
    img[foil2Pos]  = foil2;
    temporalOrder_stim = "<p>" + que + "</p>" + 
                         "<div class='grid'>" +
                         "<img class='top' src='" + probe + "' style='width:" + width + "px;height: " + height + "px;'>" +
                         "<div class='threeColumn'>" +
                         "<img src='" + img[1] + "' style='width:" + width + "px;height: " + height + "px;'>"+
                         "<div class='num'>1</div>"+
                         "</div>"+
                         "<div class='threeColumn'>"+
                         "<img src='" + img[2] + "' style='width:" + width + "px;height: " + height + "px;'>"+
                         "<div class='num'>2</div>"+
                         "</div>"+
                         "<div class='threeColumn'>"+
                         "<img src='" + img[3] + "' style='width:" + width + "px;height: " + height + "px;'>"+
                         "<div class='num'>3</div>"+
                         "</div>"+
                         "</div>"
    return temporalOrder_stim;
}

// Solution for this came from: https://stackoverflow.com/questions/61731819/horizontally-align-an-image-with-the-middle-image-of-three-colum-table-in-html