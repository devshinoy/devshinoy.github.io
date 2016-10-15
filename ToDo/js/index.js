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
	function removeTodo(el)
	{
		el.parentNode.style.setProperty("text-decoration", "line-through");
		el.parentNode.removeChild(el);
	}
    AppComponent.annotations = [
      new angular.ComponentAnnotation({
        selector: 'todo'
      }),
      new angular.ViewAnnotation({
        template: '<h3>Tasks</h3>' +
                  '<ul  class="collection"><li class="collection-item" *ng-for="#todo of todos"><button class="btn waves-effect waves-light" onclick="removeTodo(this)">X</button>&nbsp;&nbsp;<label><strong>{{ todo }}</strong></label></li><br/></ul>' +
                  '<form (submit)="addTodo(todotext)"><input placeholder="type here" #todotext><button class="btn waves-effect waves-light blue accent-4" type="submit">add</button></form>',
        directives: [angular.NgFor]
      })
    ];

    document.addEventListener('DOMContentLoaded', function() {
      angular.bootstrap(AppComponent);
    });
