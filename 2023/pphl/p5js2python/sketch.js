let myColor = [100, 100, 100];

function setup() {
  createCanvas(200, 200);
  noStroke();
  connectWebsocket("ws://localhost:8765");
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
