import java.util.Map;
import java.lang.Math;
import controlP5.*;

JSONArray input;
JSONArray homeTeam;
JSONArray awayTeam;
Map<Integer, String> team1;
Map<Integer, String> team2;
Map<Integer, JSONArray> allPasses;
Map<Integer, JSONArray> allShots;
int team1Id;
int team2Id;
RadioButton halfSelector, playTypeSelector;
ControlP5 cp5;
int offsetX, offsetY, multiplier, selectedPlayer;

void setup() {
  cp5 = new ControlP5(this);
  size(1200, 800);
  background(255);
  drawPitch(width, height);
  readData();
  
  // Trije gumbi za izbiro polčasa za prikaz (1., 2. ali celotna tekma(default value))
  halfSelector = cp5.addRadioButton("Polcas")
                  .setPosition((width - 340) / 2, 120)
                  .setSize(100, 50)
                  .setItemsPerRow(3)
                  .setSpacingColumn(20)
                  .setNoneSelectedAllowed(false);
  halfSelector.addItem("1. polcas", 1);
  halfSelector.addItem("2. polcas", 2);
  halfSelector.addItem("Cela tekma", 3);
  for (int i = 0; i < 3; i++) {
     halfSelector.getItem(i).getCaptionLabel().setPaddingX(-70);
  }
  halfSelector.activate("Cela tekma");
  
  playTypeSelector = cp5.addRadioButton("playType")
                        .setPosition((width - 220) / 2, 700)
                        .setSize(100, 50)
                        .setItemsPerRow(2)
                        .setSpacingColumn(20)
                        .setNoneSelectedAllowed(false);
  playTypeSelector.addItem("Podaje", 1);
  playTypeSelector.addItem("Streli", 2);
  for (int i = 0; i < 2; i++) {
     playTypeSelector.getItem(i).getCaptionLabel().setPaddingX(-60);
  }
  playTypeSelector.activate("Podaje");
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.getName().equals("Polcas") || theEvent.getName().equals("playType")) {
    if (selectedPlayer != 0) {
      drawEvents((int)playTypeSelector.getValue(), selectedPlayer);
    }
  }
}

void readData() {
  input = loadJSONArray("19776.json");
  homeTeam = input.getJSONObject(0).getJSONObject("tactics").getJSONArray("lineup");
  String team1Name = input.getJSONObject(0).getJSONObject("team").getString("name");
  awayTeam = input.getJSONObject(1).getJSONObject("tactics").getJSONArray("lineup");
  String team2Name = input.getJSONObject(1).getJSONObject("team").getString("name");
  textSize(24);
  fill(0);
  text(team2Name, 50, 35);
  textAlign(RIGHT);
  text(team1Name, width - 50, 35);
  team1 = new HashMap<Integer, String>();
  team2 = new HashMap<Integer, String>();
  allPasses = new HashMap<Integer, JSONArray>();
  allShots = new HashMap<Integer, JSONArray>();
  team1Id = input.getJSONObject(0).getJSONObject("team").getInt("id");
  team2Id = input.getJSONObject(0).getJSONObject("team").getInt("id");
  for (int i = 0; i < 11; i++) {
    JSONObject player = homeTeam.getJSONObject(i).getJSONObject("player");
    team1.put(player.getInt("id"), player.getString("name"));
    JSONObject player2 = awayTeam.getJSONObject(i).getJSONObject("player");
    team2.put(player2.getInt("id"), player2.getString("name"));
    allPasses.put(player.getInt("id"), new JSONArray());
    allShots.put(player.getInt("id"), new JSONArray());
    allPasses.put(player2.getInt("id"), new JSONArray());
    allShots.put(player2.getInt("id"), new JSONArray());
  }
  int mirrorX = 60;
  int mirrorY = 40;
  int startX, startY, endX, endY;
  for (int i = 4; i < input.size(); i++) {
      JSONObject currentEvent = input.getJSONObject(i);
      int eventType = currentEvent.getJSONObject("type").getInt("id");
      int teamId = currentEvent.getJSONObject("team").getInt("id");
      switch(eventType) {
        case 19:
          JSONObject substitution = currentEvent.getJSONObject("substitution").getJSONObject("replacement");
          if (teamId == team1Id) {
            team1.put(substitution.getInt("id"), substitution.getString("name"));
          } else {
            team2.put(substitution.getInt("id"), substitution.getString("name"));
          }
          allPasses.put(substitution.getInt("id"), new JSONArray());
          allShots.put(substitution.getInt("id"), new JSONArray());
          break;
        case 16:  
          startX = currentEvent.getJSONArray("location").getInt(0);
          startY = currentEvent.getJSONArray("location").getInt(1);
          endX = currentEvent.getJSONObject("shot").getJSONArray("end_location").getInt(0);
          endY = currentEvent.getJSONObject("shot").getJSONArray("end_location").getInt(1);
          if (teamId == team2Id) {
            startX = -startX + mirrorX * 2;
            startY = -startY + mirrorY * 2;
            endX = -endX + mirrorX * 2;
            endY = -endY + mirrorY * 2;
          }
          JSONObject shot = new JSONObject();
          shot.setInt("startX", startX);
          shot.setInt("startY", startY);
          shot.setInt("endX", endX);
          shot.setInt("endY", endY);
          shot.setInt("half", currentEvent.getInt("period"));
          if (currentEvent.getJSONObject("shot").getJSONObject("outcome").getInt("id") == 97) {
            shot.setBoolean("success", true);
          } else {
            shot.setBoolean("success", false);
          }
          allShots.get(currentEvent.getJSONObject("player").getInt("id")).append(shot);
          break;
        case 30:
          startX = currentEvent.getJSONArray("location").getInt(0);
          startY = currentEvent.getJSONArray("location").getInt(1);
          endX = currentEvent.getJSONObject("pass").getJSONArray("end_location").getInt(0);
          endY = currentEvent.getJSONObject("pass").getJSONArray("end_location").getInt(1);
          if (teamId == team2Id) {
            startX = -startX + mirrorX * 2;
            startY = -startY + mirrorY * 2;
            endX = -endX + mirrorX * 2;
            endY = -endY + mirrorY * 2;
          }
          JSONObject pass = new JSONObject();
          pass.setInt("startX", startX);
          pass.setInt("startY", startY);
          pass.setInt("endX", endX);
          pass.setInt("endY", endY);
          pass.setInt("half", currentEvent.getInt("period"));
          if (currentEvent.getJSONObject("pass").isNull("outcome")) {
            pass.setBoolean("success", true);
          } else {
            pass.setBoolean("success", false);
          }
          allPasses.get(currentEvent.getJSONObject("player").getInt("id")).append(pass);
          break;
    }
  }
  int counter = 1;
  for (int key : team2.keySet()) {
    cp5.addButton(team2.get(key)).setValue(key).setPosition(50, counter * 50).setSize(150, 40)
                  .onPress(new CallbackListener() {
                    public void controlEvent(CallbackEvent theEvent) {
                      String name = theEvent.getController().getName();
                      int value = (int)theEvent.getController().getValue();
                      selectedPlayer = value;
                      drawEvents((int)playTypeSelector.getValue(), value);
                      }
                  });
    counter++;
  }
  counter = 1;
  for (int key : team1.keySet()) {
    cp5.addButton(team1.get(key)).setValue(key).setPosition(width - 200, counter * 50).setSize(150, 40)
                  .onPress(new CallbackListener() {
                    public void controlEvent(CallbackEvent theEvent) {
                      String name = theEvent.getController().getName();
                      int value = (int)theEvent.getController().getValue();
                      selectedPlayer = value;
                      drawEvents((int)playTypeSelector.getValue(), value);
                      }
                  });
    counter++;
  }
}

void drawPitch(int sizeX, int sizeY) {
  multiplier = min((sizeX - 400) / 120, (sizeY - 400) / 80);
  offsetX = (sizeX - (multiplier * 120)) / 2;
  offsetY = (sizeY - (multiplier * 80)) / 2;
  fill(255);
  noStroke();
  rect(offsetX - 20, offsetY - 20, multiplier * 120 + 40, multiplier * 80 + 40);
  stroke(0);
  rect(offsetX, offsetY, multiplier * 120, multiplier * 80);
  noFill();
  // Leva stran
  rect(offsetX, offsetY + 18 * multiplier, 18 * multiplier, 44 * multiplier);
  rect(offsetX, offsetY + 30 * multiplier, 6 * multiplier, 20 * multiplier);
  rect(offsetX - 15, offsetY + 36 * multiplier, 15, 8 * multiplier);
  arc(offsetX + 13 * multiplier, offsetY + 40 * multiplier, 16 * multiplier, 16 * multiplier, (float)Math.toRadians(310), (float)Math.toRadians(360));
  arc(offsetX + 13 * multiplier, offsetY + 40 * multiplier, 16 * multiplier, 16 * multiplier, (float)Math.toRadians(0), (float)Math.toRadians(50));
  
  // Desna stran
  rect(offsetX + 102 * multiplier, offsetY + 18 * multiplier, 18 * multiplier, 44 * multiplier);
  rect(offsetX + 114 * multiplier, offsetY + 30 * multiplier, 6 * multiplier, 20 * multiplier);
  rect(offsetX + 120 * multiplier, offsetY + 36 * multiplier, 15, 8 * multiplier);
  arc(offsetX + 107 * multiplier, offsetY + 40 * multiplier, 16 * multiplier, 16 * multiplier, (float)Math.toRadians(130), (float)Math.toRadians(230));
  
  // Sredina
  line(offsetX + 60 * multiplier, offsetY, offsetX + 60 * multiplier, offsetY + 80 * multiplier);
  circle(offsetX + 60 * multiplier, offsetY + 40 * multiplier, (offsetX + 80 * multiplier) / 4);
}

void drawEvents(int type, int playerId) {
  if (playerId != 0) {
    if (type == 1) {
      drawPasses(playerId);
    } else if (type == 2) {
      drawShots(playerId);
    }
  }
}

void drawPasses(int playerId) {
  drawPitch(width, height);
  JSONArray passes = allPasses.get(playerId);
  for (int i = 0; i < passes.size(); i++) {
    JSONObject currentPass = (JSONObject) passes.get(i);
    if ((int)halfSelector.getValue() == 3 || (int)halfSelector.getValue() == currentPass.getInt("half")) {
      if (currentPass.getBoolean("success")) {
        stroke(0, 255, 0);
      } else {
        stroke(255, 0, 0);
      }
      drawArrow(currentPass.getInt("startX") * multiplier + offsetX, currentPass.getInt("startY") * multiplier + offsetY,
          currentPass.getInt("endX") * multiplier + offsetX, currentPass.getInt("endY") * multiplier + offsetY);
    }
  }
  stroke(0,0,0);
}

void drawShots(int playerId) {
  drawPitch(width, height);
  JSONArray shots = allShots.get(playerId);
  for (int i = 0; i < shots.size(); i++) {
    JSONObject currentShot = (JSONObject) shots.get(i);
    if ((int)halfSelector.getValue() == 3 || (int)halfSelector.getValue() == currentShot.getInt("half")) {
      if (currentShot.getBoolean("success")) {
        stroke(0, 255, 0);
      } else {
        stroke(255, 0, 0);
      }
      drawArrow(currentShot.getInt("startX") * multiplier + offsetX, currentShot.getInt("startY") * multiplier + offsetY,
          currentShot.getInt("endX") * multiplier + offsetX, currentShot.getInt("endY") * multiplier + offsetY);
    }
  }
  stroke(0,0,0);
}

void drawArrow(int x1, int y1, int x2, int y2) {
  float angle = radians(30);
  float cos = cos(angle);
  float sin = sin(angle);
  float dx = (x1 - x2) * (8 / dist(x1, y1, x2, y2));
  float dy = (y1 - y2) * (8 / dist(x1, y1, x2, y2));
  float end1_x = x2 + (dx * cos - sin * dy);
  float end1_y = y2 + (dx * sin + dy * cos);
  angle = radians(-30);
  cos = cos(angle);
  sin = sin(angle);
  float end2_x = x2 + (dx * cos - sin * dy);
  float end2_y = y2 + (dx * sin + dy * cos);
  line(x1, y1, x2, y2);
  line(x2, y2, end1_x, end1_y);
  line(x2, y2, end2_x, end2_y);
}

void draw() {
  // Pass id = 30
  //drawShots(16378);
}
