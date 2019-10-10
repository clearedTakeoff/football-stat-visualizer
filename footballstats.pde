import java.util.Map;
import java.lang.Math;
import controlP5.*;

JSONArray input;
JSONArray homeTeam;
JSONArray awayTeam;
Map<Integer, String> team1;
Map<Integer, String> team2;
Map<Integer, JSONArray> allPasses;
int team1Id;
int team2Id;
ControlP5 cp5;

int offsetX, offsetY, multiplier;

void setup() {
  cp5 = new ControlP5(this);
  size(1200, 800);
  background(255);
  drawPitch(width, height);
  readData();
}

void readData() {
  input = loadJSONArray("19776.json");
  homeTeam = input.getJSONObject(0).getJSONObject("tactics").getJSONArray("lineup");
  awayTeam = input.getJSONObject(1).getJSONObject("tactics").getJSONArray("lineup");
  team1 = new HashMap<Integer, String>();
  team2 = new HashMap<Integer, String>();
  allPasses = new HashMap<Integer, JSONArray>();
  team1Id = input.getJSONObject(0).getJSONObject("team").getInt("id");
  team2Id = input.getJSONObject(0).getJSONObject("team").getInt("id");
  for (int i = 0; i < 11; i++) {
    JSONObject player = homeTeam.getJSONObject(i).getJSONObject("player");
    team1.put(player.getInt("id"), player.getString("name"));
    JSONObject player2 = awayTeam.getJSONObject(i).getJSONObject("player");
    team2.put(player2.getInt("id"), player2.getString("name"));
    allPasses.put(player.getInt("id"), new JSONArray());
    allPasses.put(player2.getInt("id"), new JSONArray());
  }
  int mirrorX = 60;
  int mirrorY = 40;
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
          break;
        case 30:
          int startX = currentEvent.getJSONArray("location").getInt(0);
          int startY = currentEvent.getJSONArray("location").getInt(1);
          int endX = currentEvent.getJSONObject("pass").getJSONArray("end_location").getInt(0);
          int endY = currentEvent.getJSONObject("pass").getJSONArray("end_location").getInt(1);
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
          allPasses.get(currentEvent.getJSONObject("player").getInt("id")).append(pass);
          break;
    }
  }
  int counter = 1;
  for (int key : team1.keySet()) {
    //rect(50, counter * 50, 150, 50);
    cp5.addButton(team1.get(key)).setValue(key).setPosition(50, counter * 50).setSize(150, 40)
                  .onPress(new CallbackListener() { // a callback function that will be called onPress
                    public void controlEvent(CallbackEvent theEvent) {
                      String name = theEvent.getController().getName();
                      int value = (int)theEvent.getController().getValue();
                      println("got a press from a " + name + ", the value is " + value);
                      drawPasses(value);
                    }
                  });
    counter++;
  }
  counter = 1;
  for (int key : team2.keySet()) {
    cp5.addButton(team2.get(key)).setValue(key).setPosition(width - 200, counter * 50).setSize(150, 40)
                  .onPress(new CallbackListener() { // a callback function that will be called onPress
                    public void controlEvent(CallbackEvent theEvent) {
                      String name = theEvent.getController().getName();
                      int value = (int)theEvent.getController().getValue();
                      println("got a press from a " + name + ", the value is " + value);
                      drawPasses(value);
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

void drawPasses(int playerId) {
  drawPitch(width, height);
  JSONArray passes = allPasses.get(playerId);
  for (int i = 0; i < passes.size(); i++) {
    JSONObject currentPass = (JSONObject) passes.get(i);
    line(currentPass.getInt("startX") * multiplier + offsetX, currentPass.getInt("startY") * multiplier + offsetY,
        currentPass.getInt("endX") * multiplier + offsetX, currentPass.getInt("endY") * multiplier + offsetY);
  }
}

void draw() {
  // Pass id = 30
}
