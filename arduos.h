#ifndef arduos_h
#define arduos_h

#include "Arduino.h"
// #ifdef ARDUINO_STD
// 	#include "Arduino.h"
// #endif 
// #include <cstdint>

#define MAX_TASKS 32
#define TIMER_N 100
#define MESSAGE_BUFFER 10
#define MAX_MESSAGES 32

typedef struct task
{ 
	void (*taskP) (void); 
	uint16_t start_delay;
	uint16_t period;
	uint8_t ready_run; 
} task;

typedef struct message
{ 
	void (*taskP) (void); 
	uint16_t task_id;
	uint16_t[MESSAGE_BUFFER] ready_run; 
} message;

class ardu_os
{
    public:
        ardu_os();
        void addTask (void (*taskFunc)(void), uint16_t taskDelay, uint16_t taskPeriod);
        void deleteTask (void (*taskFunc)(void));
        void taskService();
        void timerTic();
		uint16_t toSeconds(uint16_t ticks);
    private:
        volatile uint8_t _queueTail;
        volatile task TaskQueue[MAX_TASKS];
		volatile message Messages[MAX_MESSAGES];

};
extern ardu_os ArduOS;

#endif