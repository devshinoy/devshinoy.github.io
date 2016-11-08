 function AppComponent() {
        this.todos = [];
        this.addTodo = function(todo) {
			if(todo.value!=="")
			{
				this.todos.push(todo.value);
            todo.value = null;
			}	
            return false;
        }

    }
	function removeEntry(el)
	{
		el.parentNode.style.display="none";
	}
	
	function removeTodo(el)
	{
		el.parentNode.style.setProperty("text-decoration", "line-through");
		el.setAttribute("onclick","removeEntry(this)");
	}
    AppComponent.annotations = [
      new angular.ComponentAnnotation({
        selector: 'todo'
      }),
      new angular.ViewAnnotation({
        template: '<h3>Tasks</h3>' +
                  '<ul><li *ng-for="#todo of todos"><button class="btn waves-effect waves-light blue accent-4" onclick="removeTodo(this)">X</button>&nbsp;&nbsp;<label><b>{{ todo }}</b></label><br/></li><br/></ul>' +
                  '<form (submit)="addTodo(todotext)"><input id="input_text" type="text" length="50" placeholder="add your task here" #todotext><button class="btn waves-effect waves-light blue accent-4" type="submit">ADD</button></form>',
        directives: [angular.NgFor]
      })
    ];

    document.addEventListener('DOMContentLoaded', function() {
      angular.bootstrap(AppComponent);
    });
