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
Map<Integer, ArrayList> activity;
Button[] team1Buttons;
Button[] team2Buttons;
int team1Id;
int team2Id;
int transparency;
float arrowWidth;
String team1Name, team2Name;
RadioButton halfSelector, playTypeSelector;
ControlP5 cp5;
int offsetX, offsetY, multiplier, selectedPlayer, currentHeight, currentWidth;

void setup() {
  //surface.setResizable(true);
  cp5 = new ControlP5(this);
  PFont p = createFont("bahnschrift.ttf", 12);
  cp5.setFont(p);
  textFont(p);
  size(1400, 900);
  currentHeight = height;
  currentWidth = width;
  background(255); 
  readData();
  drawPitch(width, height); //<>//
  createButtons(); //<>//
  transparency = 200;
  arrowWidth = 1.65;
  //heatMap(4647);
}

void createButtons() {
  // Trije gumbi za izbiro polčasa za prikaz (1., 2. ali celotna tekma(default value))
  halfSelector = cp5.addRadioButton("Polcas")
                  .setPosition((width - 340) / 2, 80)
                  .setSize(100, 50)
                  .setItemsPerRow(3)
                  .setSpacingColumn(20)
                  .setNoneSelectedAllowed(false);
  halfSelector.addItem("1. polčas", 1);
  halfSelector.addItem("2. polčas", 2);
  halfSelector.addItem("Cela tekma", 3);
  for (int i = 0; i < 2; i++) {
     halfSelector.getItem(i).getCaptionLabel().setPaddingX(-77);
  }
  halfSelector.getItem(2).getCaptionLabel().setPaddingX(-84);
  halfSelector.activate("Cela tekma");
  playTypeSelector = cp5.addRadioButton("playType")
                        .setPosition((width - 220) / 2 - 60, multiplier * 80 + offsetY + 140)
                        .setSize(100, 50)
                        .setItemsPerRow(3)
                        .setSpacingColumn(20)
                        .setNoneSelectedAllowed(false);
  playTypeSelector.addItem("Podaje", 1);
  playTypeSelector.addItem("Streli", 2);
  playTypeSelector.addItem("Aktivnost", 3);
  playTypeSelector.getItem(0).getCaptionLabel().setPaddingX(-72);
  playTypeSelector.getItem(1).getCaptionLabel().setPaddingX(-69);
  playTypeSelector.getItem(2).getCaptionLabel().setPaddingX(-80);
  playTypeSelector.activate("Podaje");
  int counter = 1;
  team2Buttons = new Button[team2.size() + 1];
  for (int key : team2.keySet()) {
    team2Buttons[counter - 1] = cp5.addButton(team2.get(key)).setValue(key).setPosition(50, counter * 50).setSize(200, 40)
                  .onPress(new CallbackListener() {
                    public void controlEvent(CallbackEvent theEvent) {
                      int value = (int)theEvent.getController().getValue();
                      selectedPlayer = value;
                      drawEvents((int)playTypeSelector.getValue(), value);
                      }
                  });
    counter++;
  }
  team2Buttons[counter - 1] = cp5.addButton("Ekipa2").setValue(2).setPosition(50, counter * 50).setSize(200, 40).setLabel("Celotna ekipa")
                  .onPress(new CallbackListener() {
                    public void controlEvent(CallbackEvent theEvent) {
                      int value = (int)theEvent.getController().getValue();
                      selectedPlayer = 2;
                      drawEvents((int)playTypeSelector.getValue(), value);
                      }});
  counter = 1;
  team1Buttons = new Button[team1.size() + 1];
  for (int key : team1.keySet()) {
    team1Buttons[counter - 1] = cp5.addButton(team1.get(key)).setValue(key).setPosition(width - 250, counter * 50).setSize(200, 40)
                  .onPress(new CallbackListener() {
                    public void controlEvent(CallbackEvent theEvent) {
                      int value = (int)theEvent.getController().getValue();
                      selectedPlayer = value;
                      drawEvents((int)playTypeSelector.getValue(), value);
                      }
                  });
    counter++;
  }
  team1Buttons[counter - 1] = cp5.addButton("Ekipa1").setValue(1).setPosition(width - 250, counter * 50).setSize(200, 40).setLabel("Celotna ekipa")
                  .onPress(new CallbackListener() {
                    public void controlEvent(CallbackEvent theEvent) {
                      int value = (int)theEvent.getController().getValue();
                      selectedPlayer = 1;
                      drawEvents((int)playTypeSelector.getValue(), value);
                      }});
}

void resizeButtons() {
  for (int i = 0; i < team1Buttons.length; i++) {
    team1Buttons[i].setPosition(width - 250, (i+1) * 50);
  }
  for (int i = 0; i < team2Buttons.length; i++) {
    team2Buttons[i].setPosition(50, (i+1) * 50);
  }
  playTypeSelector.setPosition((width - 220) / 2 - 60, multiplier * 80 + offsetY + 140);
  halfSelector.setPosition((width - 340) / 2, 80);
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.getName().equals("Polcas") || theEvent.getName().equals("playType")) {
    if (selectedPlayer != 0) {
      drawEvents((int)playTypeSelector.getValue(), selectedPlayer);
    }
  }
}

void onResize() {
  if (currentWidth != width || currentHeight != height) {
    fill(255);
    noStroke();
    rect(0, 0, width, height);
    stroke(0);
    drawPitch(width, height);
    currentWidth = width;
    currentHeight = height;
    resizeButtons();
    println("Resize detected");
  }
}

void readData() {
  input = loadJSONArray("19776.json");
  homeTeam = input.getJSONObject(0).getJSONObject("tactics").getJSONArray("lineup");
  team1Name = input.getJSONObject(0).getJSONObject("team").getString("name");
  awayTeam = input.getJSONObject(1).getJSONObject("tactics").getJSONArray("lineup");
  team2Name = input.getJSONObject(1).getJSONObject("team").getString("name");
  textSize(24);
  fill(0);
  text(team2Name, 50, 35);
  textAlign(RIGHT);
  text(team1Name, width - 50, 35);
  team1 = new HashMap<Integer, String>();
  team2 = new HashMap<Integer, String>();
  allPasses = new HashMap<Integer, JSONArray>();
  allShots = new HashMap<Integer, JSONArray>();
  activity = new HashMap<Integer, ArrayList>();
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
    activity.put(player.getInt("id"), new ArrayList<int[]>());
    activity.put(player2.getInt("id"), new ArrayList<int[]>());
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
          activity.put(substitution.getInt("id"), new ArrayList<int[]>());
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
    //println(currentEvent);
    if (!currentEvent.isNull("location") && !currentEvent.isNull("player")) {
      startX = currentEvent.getJSONArray("location").getInt(0);
      startY = currentEvent.getJSONArray("location").getInt(1);
      if (teamId == team2Id) {
            startX = -startX + mirrorX * 2;
            startY = -startY + mirrorY * 2;
      }
      activity.get(currentEvent.getJSONObject("player").getInt("id")).add(new int[]{startX, startY});
    }
  }
}

void drawPitch(int sizeX, int sizeY) {
  strokeWeight(1.25);
  multiplier = min((sizeX - 400) / 120, (sizeY - 400) / 80);
  offsetX = (sizeX - (multiplier * 120)) / 2;
  offsetY = (sizeY - (multiplier * 80)) / 2;
  offsetY -= 40;
  noStroke();
  fill(255);
  rect(offsetX - 20, multiplier * 80 + offsetY + 10, multiplier * 120 + 30, 140);
  rect(offsetX - 20, offsetY - 20, multiplier * 120 + 60, multiplier * 80 + 40);
  stroke(0);
  fill(225);
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
    } else if (type == 3) {
      drawPitch(width, height);
      heatMap(playerId);
    }
  }
}

void drawPasses(int playerId) {
  drawPitch(width, height);
  JSONArray passes = new JSONArray();
  int counter = 0;
  if (playerId == 2) {
    for (int player : team2.keySet()) {
      JSONArray current = allPasses.get(player);
      for (int i = 0; i < current.size(); i++) {
        passes.setJSONObject(counter, (JSONObject)current.get(i));
        counter++;
      }
    }
  } else if (playerId == 1) {
     for (int player : team1.keySet()) {
      JSONArray current = allPasses.get(player);
      for (int i = 0; i < current.size(); i++) {
        passes.setJSONObject(counter, (JSONObject)current.get(i));
        counter++;
      }
    }
  } else {
    passes = allPasses.get(playerId);
  }
  int successfulLeft = 0;
  int successfulRight = 0;
  int failedLeft = 0;
  int failedRight = 0;
  for (int i = 0; i < passes.size(); i++) {
    JSONObject currentPass = (JSONObject) passes.get(i);
    if ((int)halfSelector.getValue() == 3 || (int)halfSelector.getValue() == currentPass.getInt("half")) {
      if (currentPass.getBoolean("success")) {
        stroke(0, 120, 0, transparency);
        if (currentPass.getInt("startX") < 60) {
          successfulLeft++;
        } else {
          successfulRight++;
        }
      } else {
        stroke(255, 0, 0, transparency);
        if (currentPass.getInt("startX") < 60) {
          failedLeft++;
        } else {
          failedRight++;
        }
      }
      drawArrow(currentPass.getInt("startX") * multiplier + offsetX, currentPass.getInt("startY") * multiplier + offsetY,
          currentPass.getInt("endX") * multiplier + offsetX, currentPass.getInt("endY") * multiplier + offsetY);
    }
  }
  textAlign(CENTER);
  fill(0);
  textSize(16);
  int top = multiplier * 80 + offsetY + 40;
  String name, textLeft, textRight;
  if (team1.containsKey(playerId) || playerId == 1) {
    name = team1.get(playerId);
    textLeft = "napadu: ";
    textRight = "obrambi: ";
    println("TEAM1");
  } else {
    name = team2.get(playerId);
    textLeft = "obrambi: ";
    textRight = "napadu: ";
  }
  String tmp;
  if (playerId == 1) {
    tmp = "Statistika ekipe " + team1Name;
  } else if (playerId == 2) {
    tmp = "Statistika ekipe " + team2Name;
  } else {
    tmp = "Statistika igralca " + name;
  }
  text(tmp, width / 2, top - 5);
  textSize(12);
  textAlign(RIGHT);
  float percentage = round(((float(successfulLeft) / (float(successfulLeft) + float(failedLeft)) * 100f)));
  text("Podaje v " + textLeft + successfulLeft + "/" + (successfulLeft + failedLeft) + " ("+ percentage + "% uspešnost)", width / 2 - 10, top + 17);
  textAlign(LEFT);
  percentage = round(((float(successfulRight) / (float(successfulRight) + float(failedRight)) * 100f)));
  text("Podaje v " + textRight + successfulRight + "/" + (successfulRight + failedRight) + " ("+ percentage + "% uspešnost)", width / 2 + 10, top + 17);
  strokeWeight(3);
  stroke(0,0,0);
  line(width / 2, top + 20, width / 2, top + 60);
  strokeWeight(1);
  stroke(0, 120, 0);
  fill(0, 120, 0);
  if (successfulRight + failedRight > 0) {
    rect(width / 2 + 2, top + 22, (successfulRight * 60 * multiplier) / (successfulRight + failedRight), 17);
  }
  if (successfulLeft + failedLeft > 0) {
    rect(width / 2 - 2 - (successfulLeft * 60 * multiplier) / (successfulLeft + failedLeft), top + 22, (successfulLeft * 60 * multiplier) / (successfulLeft + failedLeft), 17);
  }
  stroke(255, 0, 0);
  fill(255, 0, 0);
  if (successfulRight + failedRight > 0) {
    rect(width / 2 + 2, top + 40, (failedRight * 60 * multiplier) / (successfulRight + failedRight), 17);
  }
  if (successfulLeft + failedLeft > 0) {
    rect(width / 2 - 2 - (failedLeft * 60 * multiplier) / (successfulLeft + failedLeft), top + 40, (failedLeft * 60 * multiplier) / (successfulLeft + failedLeft), 17);
  }
}

void drawShots(int playerId) {
  drawPitch(width, height);
  JSONArray shots = new JSONArray();
  int counter = 0;
  int successfulShots = 0;
  int failedShots = 0;
  if (playerId == 2) {
    for (int player : team2.keySet()) {
      JSONArray current = allShots.get(player);
      for (int i = 0; i < current.size(); i++) {
        shots.setJSONObject(counter, (JSONObject)current.get(i));
        counter++;
      }
    }
  } else if (playerId == 1) {
     for (int player : team1.keySet()) {
      JSONArray current = allShots.get(player);
      for (int i = 0; i < current.size(); i++) {
        shots.setJSONObject(counter, (JSONObject)current.get(i));
        counter++;
      }
    }
  } else {
    shots = allShots.get(playerId);
  }
  for (int i = 0; i < shots.size(); i++) {
    JSONObject currentShot = (JSONObject) shots.get(i);
    if ((int)halfSelector.getValue() == 3 || (int)halfSelector.getValue() == currentShot.getInt("half")) {
      if (currentShot.getBoolean("success")) {
        stroke(0, 120, 0, transparency);
        successfulShots++;
      } else {
        stroke(255, 0, 0, transparency);
        failedShots++;
      }
      drawArrow(currentShot.getInt("startX") * multiplier + offsetX, currentShot.getInt("startY") * multiplier + offsetY,
          currentShot.getInt("endX") * multiplier + offsetX, currentShot.getInt("endY") * multiplier + offsetY);
    }
  }
  stroke(0,0,0);
  
  textAlign(CENTER);
  fill(0);
  textSize(16);
  int top = multiplier * 80 + offsetY + 40;
  int team;
  String name;
  if (team1.containsKey(playerId) || playerId == 1) {
    name = team1.get(playerId);
    team = 1;
  } else {
    team = 2;
    name = team2.get(playerId);
  }
  String tmp;
  if (playerId == 1) {
    tmp = "Statistika ekipe " + team1Name;
  } else if (playerId == 2) {
    tmp = "Statistika ekipe " + team2Name;
  } else {
    tmp = "Statistika igralca " + name;
  }
  text(tmp, width / 2, top - 5);
  textSize(12);
  strokeWeight(3);
  stroke(0,0,0);
  line(width / 2, top + 20, width / 2, top + 60);
  float percentage = round(((float(successfulShots) / (float(successfulShots) + float(failedShots)) * 100f)));
  if (team == 1) {
    textAlign(RIGHT);
    text("Strelska učinkovitost: " + successfulShots + "/" + (successfulShots + failedShots) + " ("+ percentage + "% uspešnost)", width / 2 - 10, top + 17);
    if (successfulShots + failedShots > 0) {
      strokeWeight(1);
      stroke(0, 120, 0);
      fill(0, 120, 0);
      rect(width / 2 - 2 - (successfulShots * 60 * multiplier) / (successfulShots + failedShots), top + 22, (successfulShots * 60 * multiplier) / (successfulShots + failedShots), 17);
      stroke(255, 0, 0);
      fill(255, 0, 0);    
      rect(width / 2 - 2 - (failedShots * 60 * multiplier) / (successfulShots + failedShots), top + 40, (failedShots * 60 * multiplier) / (successfulShots + failedShots), 17);
    }
  } else {
    textAlign(LEFT);
    text("Strelska učinkovitost: " + successfulShots + "/" + (successfulShots + failedShots) + " ("+ percentage + "% uspešnost)", width / 2 + 10, top + 17);
    if (successfulShots + failedShots > 0) {
      strokeWeight(1);
      stroke(0, 120, 0);
      fill(0, 120, 0);
      rect(width / 2 + 2, top + 22, (successfulShots * 60 * multiplier) / (successfulShots + failedShots), 17);
      stroke(255, 0, 0);
      fill(255, 0, 0);    
      rect(width / 2 + 2, top + 40, (failedShots * 60 * multiplier) / (successfulShots + failedShots), 17);
    }
  }
  strokeWeight(1);
}

void drawArrow(int x1, int y1, int x2, int y2) {
  strokeWeight(arrowWidth);
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
  strokeWeight(1);
}

void heatMap(int playerId) {
  int resize = 10 * multiplier;
  int[][] groupedData = new int[12][8];
  float[][] interpolatedArray = new float[12 * resize][8 * resize];
  int maxValue = 0;
  for (int i = 0; i < groupedData.length; i++) {
    for(int j = 0; j < groupedData[i].length; j++) {
      groupedData[i][j] = 0;
    }
  }
  ArrayList playerActivity;
  if (playerId == 2) {
    playerActivity = new ArrayList<int[]>();
    for (int player : team2.keySet()) {
      playerActivity.addAll(activity.get(player));
    }
  } else if (playerId == 1) {
     playerActivity = new ArrayList<int[]>();
     for (int player : team1.keySet()) {
       playerActivity.addAll(activity.get(player));
     }
   } else {
    playerActivity = activity.get(playerId);
  }
  for(int i = 0; i < playerActivity.size(); i++) {
    int[] coords = (int[])playerActivity.get(i);
    int x = max(0, (int)(coords[0] / 10) - 1);
    int y = max(0, (int)(coords[1] / 10) - 1);
    groupedData[x][y]++;
  }
  for(int i = 0; i < groupedData.length; i++) {
    for(int j = 0; j < groupedData[i].length; j++) {
      maxValue = max(groupedData[i][j], maxValue);
      //fill(lerpColor(from, to, groupedData[i][j] / maxValue));
      //rect(offsetX + (i * 10) * multiplier, offsetY + (j * 10 * multiplier), 10 * multiplier, 10 * multiplier);
    }
  }
  //noStroke();
  for(int i = 0; i < groupedData.length; i++) {
    for(int j = 0; j < groupedData[i].length; j++) {
      int x = i * resize + 5;
      int y = j * resize + 5;
      interpolatedArray[x][y] = groupedData[i][j];    
    }
  }
  
  for(int x = 0; x < interpolatedArray.length; x++) {
    int dx1 = floor(x / (resize * 1.0f));
    int dx2 = ceil(x / (resize * 1.0f));
    dx2 = min(11, dx2);
    int x1 = dx1 * resize + 5;
    int x2 = dx2 * resize + 5;
    for(int y = 0; y < interpolatedArray[x].length; y++) {
      int dy1 = floor(y / (resize * 1.0f));
      int dy2 = ceil(y / (resize * 1.0f));
      dy2 = min(7, dy2);
      int y1 = dy1 * resize + 5;
      int y2 = dy2 * resize + 5;

      float q11 = groupedData[dx1][dy1];
      float q12 = groupedData[dx1][dy2];
      float q21 = groupedData[dx2][dy1];
      float q22 = groupedData[dx2][dy2];
      
      if (!(y1==y2 && x1==x2)) {

        float t1 = (x-x1);
        float t2 = (x2-x);
        float t3 = (y-y1);
        float t4 = (y2-y);
        float t5 = (x2-x1);
        float t6 = (y2-y1);
        if (y1==y2) {
          //interpolatedArray[x][y] = 900.0;
          //interpolatedArray[x][y] = q11 * t2 / t5 + q21 * t1 / t5;
        } else if (x1==x2) {
          //interpolatedArray[x][y] = q11 * t4 / t6 + q12 * t3 / t6;
        } else {
          interpolatedArray[x][y] = (q11 * t2 * t4 + q21 * t1 * t4 + q12 * t2 * t3 + q22 * t1 * t3) / (t5 * t6);
        }
      } else {
        interpolatedArray[x][y] = 0;
      }
    }
  }
  
  for(int i = 60; i < interpolatedArray.length; i += resize) {
    for(int j = 0; j < interpolatedArray[i].length; j++) {
      interpolatedArray[i][j] = 0.5 * (interpolatedArray[i+1][j] + interpolatedArray[i-1][j]);
    }
    //println();
  }
  for(int j = 60; j < interpolatedArray[0].length; j += resize) {
    for(int i = 0; i < interpolatedArray.length; i++) {
      interpolatedArray[i][j] = 0.5 * (interpolatedArray[i][j - 1] + interpolatedArray[i][j + 1]);
    }
  }
  
  
  color from = color(0, 0, 255, 150); 
  color to = color(255, 0, 0);
  for (int i = 0; i < interpolatedArray.length; i++) {
    for (int j = 0; j < interpolatedArray[i].length; j++) {
      stroke(lerpColor(from, to, map(interpolatedArray[i][j], 0, maxValue, 0, 1)));
      point(i + offsetX, j + offsetY);
    }
  }
  /*for(int i = 1; i < groupedColors.length - 1; i++) {
    for(int j = 1; j < groupedColors[i].length - 1; j++) {
      for(int k = 0; k < 10; k++) {
        color current = groupedColors[i][j];
        color a = lerpColor(current, groupedColors[i + 1][j],(float) k / 10f); 
        for(int l = 0; l < 10; l++) {
          color b = lerpColor(current, groupedColors[i][j + 1],(float) l / 10f);
          color c = lerpColor(current, groupedColors[i + 1][j + 1], (float) (sqrt(l * l + k * k) / sqrt(200)));
          float f1 = k / 10f;
          float f2 = l / 10f;
          fill(lerpColor(a, b, (float)(f1 / (f1 + f2))));
          rect(offsetX + (i * 10 + k) * multiplier, offsetY + (j * 10 + l) * multiplier, 5, 5);
        }
      }
      //fill(lerpColor(from, to, (float)groupedData[i][j] / maxValue));
      //rect(offsetX + (i * 10) * multiplier, offsetY + (j * 10 * multiplier), 10 * multiplier, 10 * multiplier);
      //circle(offsetX + ((i * 10 + 5) * multiplier), offsetY + ((j * 10 + 5) * multiplier), 20 * multiplier);    
    }
  }*/
}

void draw() {
  onResize();
  // Pass id = 30
  //drawShots(16378);
}
