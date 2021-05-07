/* https://freeze.sh/_/2018/amroui/ */
'use strict';
(function () {

  function animate() {
    requestAnimationFrame(animate);
    draw("canvas");
  }

  function draw(drawwhat) {

    var canvas  = document.getElementById('canvas');
    var loopDuration = 1;
    var LINES = 40;

    if ( drawwhat == "canvas" ) {
       //console.log("CANVAS")
         var context = canvas.getContext('2d');
         context.canvas.width  = window.innerWidth;
         context.canvas.height = window.innerHeight;
    } else if ( drawwhat == "svg" ) {
         //console.log("SVG")
         var context = new C2S(window.innerWidth,window.innerHeight);
    }

    context.fillStyle = '#fff';
    context.lineWidth = 1;
    context.fillRect(0,0,canvas.width, canvas.height);
    var time = ( .001 * performance.now() ) % loopDuration;

    for (var j = 0; j < LINES; j++) {
      var y = j * canvas.height / LINES;
      context.beginPath();
      context.moveTo(0,y);
      for(var x=15; x<canvas.width+15;x=x+15) {
        var dx = .5 * canvas.width - x;
        var dy = .5 * canvas.height - y;
        var d = Math.sqrt(dx*dx+dy*dy);
        var offset = 50. * Math.sin( .00005 * d * d - time * 2 
                                     * Math.PI / loopDuration  ) 
                         * Math.exp( - .00001 * d * d );
        context.lineTo(x,y+offset);
      }
      context.stroke();
    }

    if ( drawwhat == "svg" ) {
         var svgData = context.getSerializedSvg();
         postCanvas(svgData);
       //postCanvas("ssdfd");
    }
  }    
   document.addEventListener(
        "DOMContentLoaded",
        function () { animate(); }
   );

   window.onkeydown = function(e) { 
      if (event.keyCode == 32) {
          draw("svg");
      }
      return !(e.keyCode == 32);
   };

}());
