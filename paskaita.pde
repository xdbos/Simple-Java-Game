PImage img;
PImage temp;
PImage[] photomas; //dinaminiai masyvai
int col, row; //suzinot dydyi nuotraukos

int tSize=32;
int imgId;
int imgOffsetX=1000;
int imgOffsetY=0;

int[][] maps;
int mapX=20;
int mapY=20;
int mapScale=2;
int mapCoinCount=0;

String editor = "data.csv";

int editorOffsetX=0;
int editorOffsetY=0;
int camX;
int camY;
int editorX=0;
int editorY=0;


boolean inEditor = false;
boolean mainMenu = true;
boolean inGame = false;

int tempCol;
int tempRow;

//for player sprite animations
int time = 0;
int frameIndex=0;

int runFramesLeft = 0;
int runFramesDuration = 48; // how many frames the run pose lingers after a step


enum GameState { mainMenu, editor, game }
GameState state = GameState.mainMenu;





class Player{
  PImage pImg;
  PImage[] anim;
  int cordX=0;
  int cordY=0;
  int x=width/2 - (tSize*mapScale)/2;
  int y=height/2 - (tSize*mapScale)/2;
  boolean alive = true;
  boolean coinsCollected = false;
  int coinCount;
  
  void idleAnim(){
    time++;
    if(time >= 12)
    {
      time=0;
      
      frameIndex = (frameIndex+1)%4;
      
    }
    image(mc.anim[frameIndex], x, y, tSize*mapScale, tSize*mapScale);
  }
  
  void runAnim(){
    time++;
    if(time >= 8)
    {
      time=0;
      frameIndex = (frameIndex+1)%16+16; //teksturu offsetai(tai basically no magic numbers here)
      
    }
    image(mc.anim[frameIndex], x, y, tSize*mapScale, tSize*mapScale);
  }
  
  boolean checkHitBoxes(){
    if(maps[cordY][cordX] == 0 || maps[cordY][cordX] == 65) return false;
    return true;
  }
  boolean checkCoin(){
    if(maps[cordY][cordX] == 132) return true;
    return false;
  }
}






void coinTracker(){
      if(mc.checkCoin()==true)
      {
        maps[mc.cordY][mc.cordX] = 183;
        mc.coinCount++;
      }
      if(mc.coinCount == mapCoinCount)
      {
        mc.coinsCollected = true;
      }
      
}








void cutphoto() { //nuotrauku karpymui for ciklas

  for (int j=0; j<row; j++) {
    for (int i=0; i<col; i++) {
      temp = img.get(tSize*i, tSize*j, tSize, tSize); //dauginam is i kad slinktusi su for'u
      photomas[i+j*col] = temp;
    }
  }
}

void cutphotoplayer() { //nuotrauku karpymui for ciklas
  PImage temp2;
  for (int j=0; j<tempRow; j++) {
    for (int i=0; i<tempCol; i++) {
      temp2 = mc.pImg.get(tSize*i, tSize*j, tSize, tSize); //dauginam is i kad slinktusi su for'u
      mc.anim[i+j*tempCol] = temp2;
    }
  }
}









void mousePressed() {
  if(state == GameState.editor){
    if (mouseX>=imgOffsetX && mouseX<=imgOffsetX+col*tSize && mouseY>=imgOffsetY && mouseY<=imgOffsetY+row*tSize) {
      int col2=(mouseX-imgOffsetX)/tSize;
      int row2=(mouseY-imgOffsetY)/tSize;
      imgId=row2*col+col2;
    }
  }
}




void placeTile(){
  int col3 = floor((mouseX - camX) / float(tSize*mapScale));
  int row3 = floor((mouseY - camY) / float(tSize*mapScale));
  if(col3 < 0 || col3 >= mapX || row3 < 0 || row3 >= mapY) return;
  maps[row3][col3] = imgId;
}

//while dragging places tiles
void mouseDragged(){
  if(state == GameState.editor){
    placeTile();
  }
}

void mouseReleased(){
  if(state == GameState.editor){
    placeTile();
  }
}

void dragger() {
  image(photomas[imgId], mouseX-tSize/2, mouseY-tSize/2, 50, 50);
}





void grid(int xOffset, int yOffset, int col2, int row2, int scale) {
  noFill();
  for (int j = 0; j<row2; j++) {
    for (int i = 0; i<col2; i++) {
      rect(i*tSize*scale+xOffset, j*tSize*scale+yOffset, tSize*scale, tSize*scale); //nzn kodel mes offseta dauginom, bet dbr fixed
    }
  }
}

void render() {
  for (int j=0; j<mapY; j++) {
    for (int i=0; i<mapX; i++) {
      maps[j][i]=0;
    }
  }
}

void drawMaps(int offsetX, int offsetY) {
  for (int j=0; j<mapY; j++) {
    for (int i=0; i<mapX; i++) {
      int n = maps[j][i];
      image(photomas[n], i*tSize*mapScale+offsetX, j*tSize*mapScale+offsetY, tSize*mapScale, tSize*mapScale);
    }
  }
}




void saveMap(String mapName){
    PrintWriter output = createWriter(mapName);
    for(int j=0; j<mapY; j++){
      for(int i=0; i<mapX; i++){
        output.printf("%d ", maps[j][i]);
      }
     output.printf("\n");
    }
    output.flush();
}

void loadMap(String mapName){
    String[] mapLines = loadStrings(mapName); //"data.csv"
    for (int j=0; j<mapY; j++) {
      String[] values = split(mapLines[j], ' ');
      for (int i=0; i<mapX; i++) {
        maps[j][i] = int(values[i]);
        if(maps[j][i] == 66){
          mc.cordX = i;
          mc.cordY = j;
        }
        if(maps[j][i] == 132)
        {
          mapCoinCount++;
        }
      }
    }
}






void keyPressed(){
  if(state == GameState.editor){
    if(key == '='){
      mapScale++;
    }
    if(key == '1'){
      saveMap("map1.csv");
    }
    if(key == '2'){
      saveMap("map2.csv");
    }
    if(key == '3'){
      saveMap("map3.csv");
    }
    if(key == '-'){
      mapScale--;
      if(mapScale<=0) mapScale=1;
    }
    if(key == 'q'){
      loadMap(editor);
    }
    if(key == 'e'){
      saveMap("data.csv");
    }
    if(key == 'm'){
      MainMenu();
      mapScale=2;
    }
    if(key == 'r'){
      render(); //to reset the map back to empty :)
    }
    if(key == 'w'){
      editorY--;
      camY = editorY*tSize*mapScale;
    }
    if(key == 'a'){
      editorX--;
      camX = editorX*tSize*mapScale;
    }
    if(key == 's'){
      editorY++;
      camY = editorY*tSize*mapScale;
    }
    if(key == 'd'){
      editorX++;
      camX = editorX*tSize*mapScale;
    }
  }
  if(state == GameState.mainMenu){
    if(key == 'e'){
      camX=0;
      camY=0;
      editorX = 0;
      editorY = 0;
      Editor();
    }
    if(key=='1'){
      startGame("map1.csv");
    }
    if(key=='2'){
      startGame("map2.csv");
    }
    if(key=='3'){
      startGame("map3.csv");
    }
  }
  if(state == GameState.game){
    if(key == 'm'){
      MainMenu();
      //also should prob make the player position go back to the spawn or maybe do that for the player loads the map idk
    }
    boolean moved = false;
    
    if(key == 'w' && mc.cordY>0 && mc.alive){ //for now less than 10 nes 10 laikinai map size
      mc.cordY--;
      if(mc.checkHitBoxes()==false) mc.cordY++;
      else moved = true;
    }
    if(key == 'd' && mc.cordX<mapX-1 && mc.alive){
      mc.cordX++;
      if(mc.checkHitBoxes()==false) mc.cordX--;
      else moved = true;
    }
    if(key == 's' && mc.cordY<mapY-1 && mc.alive){
      mc.cordY++;
      if(mc.checkHitBoxes()==false) mc.cordY--;
      else moved = true;
    }
    if(key == 'a' && mc.cordX>0 && mc.alive){
      mc.cordX--;
      if(mc.checkHitBoxes()==false) mc.cordX++;
      else moved = true;
    }
    if(moved){
    runFramesLeft = runFramesDuration;
    }
  }
}







void MainMenu(){
  state = GameState.mainMenu;
  mapCoinCount=0;
  text("Main Menu Hello!", width/2, height/2);
}

void Editor(){
  state = GameState.editor;
  dragger();
  drawMaps(camX, camY);
  grid(editorOffsetX+camX, editorOffsetY+camY, mapX, mapY, mapScale);
  image(loadImage("BackgroundForTileSelection.png"), imgOffsetX, imgOffsetY, img.width, img.height);
  image(img, imgOffsetX, imgOffsetY);
  grid(imgOffsetX, imgOffsetY, col, row, 1);
}

//sitas kartosis daug kartu per void draw
void drawGame(){
  camX = width/2  - mc.cordX*tSize*mapScale - (tSize*mapScale)/2;
  camY = height/2 - mc.cordY*tSize*mapScale - (tSize*mapScale)/2;

  coinTracker();
  drawMaps(camX, camY);

  if(runFramesLeft > 16)
  {
    runFramesLeft--;
    mc.runAnim();
  }
  else
  {
    mc.idleAnim();
  }

  mc.checkHitBoxes();
  
  if(mc.coinsCollected)
  {
    text("you got the coins, escape!", width/2, height/4);
    if(maps[mc.cordY][mc.cordX] == 66){
      text("victory!", width/2, height/2);
      text("press \"m\" to go back to the main menu!", width/2, height/1.5);
      mc.alive = false;
    }
  }
  //System.out.println(mapCoinCount +" " +mc.coinCount + " " + mc.coinsCollected);
}

//sitas kad nesikartotu loadinimas infinitely per void draw
void startGame(String mapName){
  state = GameState.game;
  mapCoinCount=0;
  mc.coinCount=0;
  mc.coinsCollected=false;
  mc.alive=true;
  loadMap(mapName);
}





Player mc;

void setup() {
  size (1600, 800);
  maps = new int[mapY][mapX];
  render();
  img = loadImage("TextureTileMap.png");
  col=img.width/tSize; //dydi fotkes
  row=img.height/tSize; //dydi fotkes
  //temp = img.get(100, 200, 200, 100);
  photomas = new PImage[col*row]; //fotkes dydyis visas
  cutphoto();
  
  mc= new Player();
  mc.pImg = loadImage("MainCharacterKnight.png");
  tempCol=mc.pImg.width/tSize; //dydi fotkes
  tempRow=mc.pImg.height/tSize; //dydi fotkes
  mc.anim = new PImage[tempCol * tempRow];
  cutphotoplayer();

  //created custom font just to change the size of my text :DDDDD
  textFont(createFont("Arial", 50));
  textAlign(CENTER, CENTER);
  
}


void draw() {
  background(180, 200, 240);
  switch(state) {
    case mainMenu:
      MainMenu();
    break;
    
    case editor:
      Editor();
      break;
      
    case game:
      drawGame();
      break;
  }
}
