#include "arduos.h"

uint16_t globalCounter = 0;


void task1(){
    globalCounter++;
}

void task2(){
    Serial.println(globalCounter);
}

void setup(){
    Serial.begin(9600);
    ArduOS.addTask(task1, 0, 1);
    ArduOS.addTask(task2, 10, 200);
}

void loop(){
    ArduOS.taskService();
    Serial.println(globalCounter);
}
