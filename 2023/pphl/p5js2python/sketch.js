let myColor = [100, 100, 100];

function setup() {
  createCanvas(200, 200);
  noStroke();
  connectWebsocket("wss://chat.reasonable.systems/p5js2python");
}

function draw() {
  background(255);
  fill(myColor);
  ellipse(width / 2, height / 2, width);
}

function mousePressed() {
  sendMessage({ color: [random(255), random(255), random(255)] });
}

function messageReceived(data) {
  myColor = data.color;
}
