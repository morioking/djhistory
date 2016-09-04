// M_6_1_03.pde
// 
// Generative Gestaltung, ISBN: 978-3-87439-759-9
// First Edition, Hermann Schmidt, Mainz, 2009
// Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
// Copyright 2009 Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
//
// http://www.generative-gestaltung.de
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/**
 * more nodes and more springs
 *
 * KEYS
 * r             : reset positions
 * s             : save png
 * p             : save pdf
 */

import generativedesign.*;
import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;

// an array for the nodes
Node[] nodes;
// an array for the springs
Spring[] springs = new Spring[0];

// dragged node
Node selectedNode = null;

float nodeDiameter = 16;

String[] labels;

JSONArray jnodes;
JSONArray jedges;

void setup() {
  size(800, 800);
  //fullScreen();
  background(20);
  smooth();
  noStroke();

  JSONObject json = loadJSONObject("data.json");
  jnodes = json.getJSONArray("nodes");
  jedges = json.getJSONArray("edges");

  labels = new String[jnodes.size()];
  nodes = new Node[jnodes.size()];

  for (int i = 0; i < jedges.size(); i++){
    JSONObject jedge = jedges.getJSONObject(i);
  }

  initNodesAndSprings();
}


void draw() {
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");

  background(255);
  background(20);
  //  fill(255, 20);
  //  rect(0, 0, width, height);

  // let all nodes repel each other
  for (int i = 0 ; i < nodes.length; i++) {
    nodes[i].attract(nodes);
  } 
  // apply spring forces
  for (int i = 0 ; i < springs.length; i++) {
    springs[i].update();
  } 
  // apply velocity vector and update position
  for (int i = 0 ; i < nodes.length; i++) {
    nodes[i].update();
  } 

  if (selectedNode != null) {
    selectedNode.x = mouseX;
    selectedNode.y = mouseY;
  }

  // draw edges
  // stroke(0, 130, 164);
  // strokeWeight(2);
  stroke(128, 128, 128);
  strokeWeight(1);
  for (int i = 0 ; i < springs.length; i++) {
    line(springs[i].fromNode.x, springs[i].fromNode.y, springs[i].toNode.x, springs[i].toNode.y);
  }
  // draw nodes
  noStroke();
  for (int i = 0 ; i < nodes.length; i++) {
    JSONObject jnode = jnodes.getJSONObject(i);
    String jcolor = jnode.getString("color");
    jcolor = jcolor.substring(4,jcolor.length()-1);
    String[]rgb = splitTokens(jcolor, ",");
    color c1 = color(int(rgb[0]), int(rgb[1]), int(rgb[2]));
    int jsize = jnode.getInt("size");
    fill(c1);
    ellipse(nodes[i].x, nodes[i].y, 8+jsize*2, 8+jsize*2);
    fill(128);
    textSize(8+jsize*2);
    text(jnode.getString("label"), nodes[i].x, nodes[i].y-8);
  }

  if (savePDF) {
    savePDF = false;
    println("saving to pdf – finishing");
    endRecord();
  }

}


void initNodesAndSprings() {
  // init nodes
  float rad = nodeDiameter/2;
  for (int i = 0; i < nodes.length; i++) {
    //nodes[i] = new Node(width/2+random(-200, 200), height/2+random(-200, 200));
    nodes[i] = new Node(width/2+random(-400, 400), height/2+random(-200, 200));
    nodes[i].setBoundary(rad, rad, width-rad, height-rad);
    nodes[i].setRadius(100);
    nodes[i].setStrength(-5);
  } 

  // set springs randomly
  springs = new Spring[0];

  for (int j = 0; j < jedges.size(); j ++){
    JSONObject jedge = jedges.getJSONObject(j);
    String source = jedge.getString("source");
    String target = jedge.getString("target");
    int source_index = -1;
    int target_index = -1;
    for (int k = 0; k < jnodes.size(); k++){
      JSONObject jnode = jnodes.getJSONObject(k);
      String id = jnode.getString("id");
      if (id.equals(source)){
        source_index = k;
      } 
      if (id.equals(target)){
        target_index = k;
      }
    }
    Spring newSpring = new Spring(nodes[source_index], nodes[target_index]);
    newSpring.setLength(80);
    newSpring.setStiffness(0.5);
    newSpring.setDamping(0.5);
    springs = (Spring[]) append(springs, newSpring);
  }

}


void mousePressed() {
  // Ignore anything greater than this distance
  float maxDist = 20;
  for (int i = 0; i < nodes.length; i++) {
    Node checkNode = nodes[i];
    float d = dist(mouseX, mouseY, checkNode.x, checkNode.y);
    if (d < maxDist) {
      selectedNode = checkNode;
      maxDist = d;
    }
  }
}

void mouseReleased() {
  if (selectedNode != null) {
    selectedNode = null;
  }
}


void keyPressed() {
  if(key=='s' || key=='S') saveFrame(timestamp()+"_##.png"); 

  if(key=='p' || key=='P') {
    savePDF = true; 
    println("saving to pdf - starting (this may take some time)");
  }

  if(key=='r' || key=='R') {
    background(20);
    initNodesAndSprings();
  }


}


String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}