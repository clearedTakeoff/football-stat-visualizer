import java.util.Map;
import java.lang.Math;

JSONArray input;
JSONArray homeTeam;
JSONArray awayTeam;
Map<Integer, String> team1;
Map<Integer, String> team2;
Map<Integer, JSONArray> allPasses;
int team1Id;
int team2Id;

int offsetX, offsetY, multiplier;

void setup() {
  size(800,800);
  background(255);
  drawPitch(800, 800);
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
  
  for (int i = 4; i < input.size(); i++) {
      JSONObject currentEvent = input.getJSONObject(i);
      int eventType = currentEvent.getJSONObject("type").getInt("id");
      switch(eventType) {
        case 19:
          int teamId = currentEvent.getJSONObject("team").getInt("id");
          JSONObject substitution = currentEvent.getJSONObject("substitution").getJSONObject("replacement");
          if (teamId == team1Id) {
            team1.put(substitution.getInt("id"), substitution.getString("name"));
          } else {
            team2.put(substitution.getInt("id"), substitution.getString("name"));
          }
          allPasses.put(substitution.getInt("id"), new JSONArray());
          break;
        case 30:
          JSONObject pass = new JSONObject();
          // !! Preveri kaj je x, kaj y
          pass.setInt("startX", currentEvent.getJSONArray("location").getInt(0));
          pass.setInt("startY", currentEvent.getJSONArray("location").getInt(1));
          pass.setInt("endX", currentEvent.getJSONObject("pass").getJSONArray("end_location").getInt(0));
          pass.setInt("endY", currentEvent.getJSONObject("pass").getJSONArray("end_location").getInt(1));
          allPasses.get(currentEvent.getJSONObject("player").getInt("id")).append(pass);
          break;
    }
  }
}

void drawPitch(int sizeX, int sizeY) {
  multiplier = min(sizeX / 120, sizeY / 80);
  offsetX = (sizeX - (multiplier * 120)) / 2;
  offsetY = (sizeY - (multiplier * 80)) / 2;
  noFill();
  // Leva stran
  rect(offsetX, offsetY, multiplier * 120, multiplier * 80);
  rect(offsetX, offsetY + 18 * multiplier, 18 * multiplier, 44 * multiplier);
  rect(offsetX, offsetY + 30 * multiplier, 6 * multiplier, 20 * multiplier);
  rect(offsetX - 15, offsetY + 36 * multiplier, 15, 8 * multiplier);
  arc(offsetX + 13 * multiplier, offsetY + 40 * multiplier, 16.2 * multiplier, 16.2 * multiplier, (float)Math.toRadians(310), (float)Math.toRadians(360));
  arc(offsetX + 13 * multiplier, offsetY + 40 * multiplier, 16.2 * multiplier, 16.2 * multiplier, (float)Math.toRadians(0), (float)Math.toRadians(50));
  
  // Desna stran
  rect(offsetX + 102 * multiplier, offsetY + 18 * multiplier, 18 * multiplier, 44 * multiplier);
  rect(offsetX + 114 * multiplier, offsetY + 30 * multiplier, 6 * multiplier, 20 * multiplier);
  rect(offsetX + 120 * multiplier, offsetY + 36 * multiplier, 15, 8 * multiplier);
  arc(offsetX + 107 * multiplier, offsetY + 40 * multiplier, 16.2 * multiplier, 16.2 * multiplier, (float)Math.toRadians(130), (float)Math.toRadians(230));
  //arc(offsetX + 107 * multiplier, offsetY + 40 * multiplier, 16.2 * multiplier, 16.2 * multiplier, (float)Math.toRadians(0), (float)Math.toRadians(50));
}

void draw() {
  // Pass id = 30
  int playerid = 4640;
  JSONArray passes = allPasses.get(playerid);
  for (int i = 0; i < passes.size(); i++) {
    JSONObject currentPass = (JSONObject) passes.get(i);
    line(currentPass.getInt("startX") * multiplier + offsetX, currentPass.getInt("startY") * multiplier + offsetY,
        currentPass.getInt("endX") * multiplier + offsetX, currentPass.getInt("endY") * multiplier + offsetY);
  }
}
