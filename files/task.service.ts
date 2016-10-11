import {Injectable} from '@angular/core'
import {TASKS} from './mock-tasks'

@Injectable()
export class TaskService{
	getTasks(){
		return Promise.resolve(TASKS);
	}

	addTask(task){
		TASKS.push(task);
	}
}