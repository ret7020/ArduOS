#include "arduos.h"

ardu_os ArduOS;

ardu_os::ardu_os()
{
	TCCR2B = 0x00;
	TCNT2  = TIMER_N;
	TIFR2  = 0x00;
	TIMSK2 = 0x01;
	TCCR2A = 0x00;
	TCCR2B = 0x07;
	_queueTail = 0;
}

void ardu_os::addTask (void (*taskFunc)(void), uint16_t taskDelay, uint16_t taskPeriod)
{   
	for(byte i = 0; i < _queueTail; i++)
	{
		if(TaskQueue[i].taskP == taskFunc)
		{
			TaskQueue[i].start_delay = taskDelay;
			TaskQueue[i].period = taskPeriod;
			TaskQueue[i].ready_run = 0;
			return;
		}
	}

	if (_queueTail < MAX_TASKS)
	{
		TaskQueue[_queueTail].taskP = taskFunc;
		TaskQueue[_queueTail].start_delay = taskDelay;
		TaskQueue[_queueTail].period = taskPeriod;
		TaskQueue[_queueTail].ready_run = 0;
		_queueTail++;
	}
}

void ardu_os::deleteTask (void (*taskFunc)(void))
{
	for (uint8_t i = 0; i < _queueTail; i++)
	{
		if(TaskQueue[i].taskP == taskFunc)
		{
			if(i != (_queueTail - 1))
				{
					TaskQueue[i].taskP = TaskQueue[_queueTail - 1].taskP;
					TaskQueue[i].start_delay =TaskQueue[_queueTail - 1].start_delay;
					TaskQueue[i].period = TaskQueue[_queueTail - 1].period;
					TaskQueue[i].ready_run = TaskQueue[_queueTail - 1].ready_run;
				}
				_queueTail--;
				return;
		}
	}
}

void ardu_os::taskService()
{
	void (*function) (void);
	for (uint8_t i = 0; i < _queueTail; i++)
	{
		if (TaskQueue[i].ready_run == 1)
		{
			function = TaskQueue[i].taskP;
			if(TaskQueue[i].period == 0)
			{
				deleteTask(TaskQueue[i].taskP);
			}
			else
			{
				TaskQueue[i].start_delay = TaskQueue[i].period;
				TaskQueue[i].ready_run = 0;
				i++;
			}
			(*function)();
		} else {
			i++;
		}
	}
}


void ardu_os::timerTic()
{
	TCNT2 = TIMER_N;
	TIFR2 = 0x00;

	for (byte i=0; i<_queueTail; i++)
	{
		if (TaskQueue[i].start_delay == 0)
			TaskQueue[i].ready_run = 1;
		else 
			TaskQueue[i].start_delay--;
	}

}

// 100 times per sec (TIMER_N in arduos.h)
ISR(TIMER2_OVF_vect) 
{
	ArduOS.timerTic();
};