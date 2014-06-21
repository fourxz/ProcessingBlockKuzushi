static class ActorManager{
static int s_id = 0;
static ArrayList s_AllActors;
  void initialize(){
    s_AllActors = new ArrayList(); 
  }
  
  void finalize(){
    s_AllActors = null; 
  }
}

class Actor{
  int m_id; // ふつう、0以外
  boolean m_isvalid; // 無効ならfalse
  int m_parentid;

  PVector m_Pos;
  PVector m_AppearancePos;
  PVector m_DeltaPos;
  PVector m_AppearanceDeltaPos; // 見た目の速度。なんかパーティクル効果とかつけるのに使いそう

  float m_AppearanceZrot;               // 見かけの回転
  float m_zrot;                         // 回転
  float m_AppearanceZrotd;              // 見かけの回転速度
  float m_zrotd;                        // 回転速度

  float m_r;                            // 半径
  float m_colorR, m_colorG, m_colorB;

  void initialize(){
    m_isvalid = true;
    m_Pos = new PVector();
    m_AppearancePos = new PVector();
    m_DeltaPos = new PVector();
    m_AppearanceDeltaPos = new PVector();
    m_parentid = 0;
    ++ActorManager.s_id;
    if(ActorManager.s_id==0)++ActorManager.s_id; // idが1周した時点でabortするべきだとは思う
    m_id = ActorManager.s_id; 
  }
 
  void setPosition(float x, float y){
    m_Pos.x = x;
    m_Pos.y = y;
    m_Pos.z = 0.0f;
  }
  
  void setPositionDelta(float xd, float yd){
    m_DeltaPos.x = xd;
    m_DeltaPos.y = yd;
    m_DeltaPos.z = 0.0f;
  }
  
  void setZRotate(float zrot){
    m_zrot = zrot;
  }
  
  void setZRotateDelta(float zrotd){
    m_zrotd = zrotd;
  }
  
  void setRadius(float r){
    m_r = r;
  }
  
  void setColor(float colorR, float colorG, float colorB){
    m_colorR = colorR;
    m_colorG = colorG;
    m_colorB = colorB;
  }

  void update(){
    m_Pos.x += m_DeltaPos.x;
    m_Pos.y += m_DeltaPos.y;
    m_zrot += m_zrotd;
    
    if(m_parentid==0){
      m_AppearancePos.x = m_Pos.x;
      m_AppearancePos.y = m_Pos.y;
      m_AppearanceDeltaPos.x = m_DeltaPos.x;
      m_AppearanceDeltaPos.y = m_DeltaPos.y;
      m_AppearanceZrot = m_zrot;
      m_AppearanceZrotd = m_zrotd;
    }else{
      
//      m_AppearanceZrot = m_zrot;
//      m_AppearanceZrotd = m_zrotd; // この変数はいらないから後で削除しよ
//      PMatrix3D p = new PMatrix3D();
//      p.rotateZ(m_AppearanceZrot;
 //     m_AppearanceX = m_Pos.x;
 //     m_AppearanceY = m_Pos.y;
 //     m_AppearanceXd = m_Pos.xd;
 //     m_AppearanceYd = m_Pos.yd;
 //     m_AppearanceZrot = m_zrot;
 //     m_AppearanceZrotd = m_zrotd;
    }
  }
  
  void display(){
  }

  // ぶつかっているかどうかチェック
  boolean checkHit(Actor v){
    float x = m_Pos.x - v.m_Pos.x;
    float y = m_Pos.y - v.m_Pos.y;
    float r = m_r + v.m_r;
    return (x*x + y*y) < r*r;
  }
  
  // 跳ね返りの種類をチェック
  // 0 右
  // 4 右下
  // 1 下
  // 5 左下
  // 2 左
  // 6 左上
  // 3 上
  // 7 右上
  int checkReflectionType(Actor v){
    float x = m_Pos.x - v.m_Pos.x;
    float y = m_Pos.y - v.m_Pos.y;
    float val = atan2(y,x);
    if(val<-PI*0.75f){
      return 2;//左
    }else if(val<-PI*0.25f){
      return 1;//下
    }else if(val<PI*0.25f){
      return 0;//右
    }else if(val<PI*0.75){
      return 3;//上 
    }else{
      return 2;//左 
    }
  }
  
  void reflectBy4Direction(int direction){
    switch(direction){
    case 0: // 右

      if(m_DeltaPos.x<0.0f){ // 左に進みそう
        m_DeltaPos.x*=-1; // 右に進んでもらう
        m_zrotd*=-1;
      }

      break;
      
    case 1: // 下
      if(0.0f<m_DeltaPos.y){ 
        m_DeltaPos.y*=-1;
        m_zrotd*=-1;
      }    
      break;

    case 2: // 左
      if(0.0f<m_DeltaPos.x){ 
        m_DeltaPos.x*=-1;
        m_zrotd*=-1;
      }

      break;

    case 3: // 上
      if(m_DeltaPos.y<0.0f){ // 上に進みそう
        m_DeltaPos.y*=-1; // 下に進んでもらう
        m_zrotd*=-1;
      }
      break;
    } 
    
  }

  // 壁の跳ね返り  
  void reflectByWall(float left, float top, float right, float bottom){
    if(m_Pos.x<left){ // 壁の左側だった
      if(m_DeltaPos.x<0.0f){ // 左に進みそう
        m_DeltaPos.x*=-1; // 右に進んでもらう
        m_zrotd*=-1;
      }
    }
    
    if(right<m_Pos.x){ // 壁の右側だった
      if(0.0f<m_DeltaPos.x){ 
        m_DeltaPos.x*=-1;
        m_zrotd*=-1;
      }
    }

    if(m_Pos.y<top){ // 壁の上側だった
      if(m_DeltaPos.y<0.0f){ // 上に進みそう
        m_DeltaPos.y*=-1; // 下に進んでもらう
        m_zrotd*=-1;
      }
    }
/*
    if(bottom<m_Pos.y){ // 壁の下側だった
      if(0.0f<m_DeltaPos.y){ 
        m_DeltaPos.y*=-1;
        m_zrotd*=-1;
      }
    }
    */
  }

// Padにぶつかってた時に呼んで上に跳ね返らせる  
  void reflectByPad(){
    if(0.0f<m_DeltaPos.y){ 
      m_DeltaPos.y*=-1;
      m_zrotd*=-1;
    }
  }

}

class Block extends Actor{
  
  void initialize(){
    super.initialize(); 
  }
  
  void update(){ 
    super.update();
  }
 
  void display(){
    pushMatrix();
    translate(m_AppearancePos.x, m_AppearancePos.y);
    rotate(m_AppearanceZrot);
    fill(m_colorR, m_colorG, m_colorB);
    rect(-m_r, -m_r, m_r*2, m_r*2);
    popMatrix();
  }
}

class Ball extends Actor{
  void initialize(){
    super.initialize(); 
  }
  
  void update(){
    super.update(); 
  }
  
  void display(){
    pushMatrix();
    translate(m_AppearancePos.x, m_AppearancePos.y);
    rotate(m_AppearanceZrot);
    fill(m_colorR, m_colorG, m_colorB);
//    ellipse(0, 0, m_r*2, m_r*2);
    rect(-m_r, -m_r, m_r*2, m_r*2);

    popMatrix();
  }
}

class Pad extends Actor{
  void initialize(){
    super.initialize(); 
  }
  
  void update(){
    super.update(); 
  }
  
  void display(){
    pushMatrix();
    translate(m_AppearancePos.x, m_AppearancePos.y);
    rotate(m_AppearanceZrot);
    fill(m_colorR, m_colorG, m_colorB);
    rect(-m_r, -m_r, m_r*2, m_r*2);
    popMatrix();
  }
}



ArrayList Balls;
ArrayList Blocks;
ArrayList Pads;
ArrayList Planets;

void setup(){
  size(320, 480);
  Pads = new ArrayList();
  Balls = new ArrayList();
  Blocks = new ArrayList();


  for(int i=0;i<2;++i){
    Ball v;
    v = new Ball();
    v.initialize();
    v.setPosition(random(320), random(240)+240);    // 位置
    v.setPositionDelta(random(5), random(5)); // 速度
    v.setZRotate(0);          // 回転角度
    v.setZRotateDelta(random(0.2f));     // 回転角速度
    v.setRadius(random(3)+2);
    v.setColor(random(255),random(255),random(255));
    Balls.add(v);
  }
  
  for(int i=0;i<10;++i){
    Pad v = new Pad();  
    v.initialize();
    v.setPosition(10*i+10, 350);    // 位置
    v.setPositionDelta(0,0); // 速度
    v.setZRotate(0);          // 回転角度
    v.setZRotateDelta(0);     // 回転角速度
    v.setRadius(5);
    v.setColor(random(255),random(255),random(255));
    Pads.add(v);
  }
  
  for(int i = 0; i<15; ++i){
    for(int j = 0; j<5; ++j){
      Block v = new Block();
      v.initialize();
      v.setPosition(i*32+16, j*32+16);
      v.setRadius(16);
      v.setColor(random(255), random(255), random(255));
      Blocks.add(v);
    } 
  } 
  

}


void draw(){
  background(191);


  // Block
  for(int i = Blocks.size()-1; 0 <= i; --i){
    Block block = (Block) Blocks.get(i);
    block.update();
    block.display();
  }

  // ボールを動かして描画する
  for(int i = Balls.size()-1; 0 <= i; --i){
    Ball ball = (Ball) Balls.get(i);
    ball.update();
    ball.reflectByWall(0,0,320,400);
    ball.display();
  }
  
  // Padを動かして描画する
   for(int i = Pads.size()-1; 0 <= i; --i){
    Pad pad = (Pad) Pads.get(i);
    pad.update();
    pad.setPosition(10*i+mouseX-15, 400);    // 位置
    pad.reflectByWall(0,0,320, 480);
    pad.display();
  }

  // Padとぶつかっているボールがあるかどーかチェック
  for(int i = Pads.size()-1; 0 <= i; --i){
    Pad pad = (Pad) Pads.get(i);
    for(int j = Balls.size()-1; 0 <= j; --j){
      Ball ball = (Ball) Balls.get(j);
      if(pad.checkHit(ball)){
        ball.reflectByPad();
      }
    }
  }

  // Blockとぶつかっているボールがあるかどーかチェック
  for(int j = Balls.size()-1; 0 <= j; --j){
    Ball ball = (Ball) Balls.get(j);
    for(int i = Blocks.size()-1; 0 <= i; --i){
      Block block = (Block) Blocks.get(i);

      if(block.checkHit(ball)){
        int reftype = ball.checkReflectionType(block);
        ball.reflectBy4Direction(reftype);
        Blocks.remove(i);
        break;
      }
    }
  }
  



}


