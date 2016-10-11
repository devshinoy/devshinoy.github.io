import { Component } from '@angular/core';
import { TaskService } from './task.service';
import { bootstrap } from '@angular/platform-browser-dynamic'
@Component({
	selector: 'my-app',
	template: `<h1>Todo-list App</h1>
        <input type="text" [(ngModel)]="newTask.name" />
        <input type="date" [(ngModel)]="newTask.dueDate" />
        <button class="btn btn-success"(click)="addTask(newTask)">Add task</button>
        <table class="table-striped">
            <thead>
                <tr>
                    <th>Task</th>
                    <th>Status</th>
                    <th>Due date</th>
                    <th></th>
                </tr>
            </thead>    
            <tbody>
                <tr *ngFor="#task of tasks">
                    <td>{{task.name }} </td>
        <td><span [class.done]="task.done">{{task.done ? 'DONE' : 'I\\'M WORKING ON IT'}} </span></td>
                    <td>{{task.dueDate}}</td>
                    <td><button class="btn btn-primary" (click)="task.done = !task.done">{{task.done ? 'Undo' : 'Done'}}</button></td>
                </tr>
            </tbody>
        </table>
 	`,
 	styles:[`
 			.done {
 				 color: #e26b1e
 			}
 	`],
 	providers: [TaskService]
})

export class AppComponent {
	public tasks = [];
	public newTask = {done:false};

	constructor(private _taskService : TaskService){}

	ngOnInit(){
		this.getTasks();
	}

	getTasks(){
		this._taskService.getTasks().then(tasks => this.tasks = tasks);
	}

	addTask(task){
		if(task){
			this._taskService.addTask(task);
			this.newTask = {done: false};
		}
	}
 }
 bootstrap(AppComponent)